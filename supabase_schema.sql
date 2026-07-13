-- ============================================================
-- Protocolo 4D · AMEE 2026 · Grow2GetherMx
-- Esquema Supabase — modelo "buzón de entrega"
-- Ejecutar en: Supabase → SQL Editor → New query → pegar todo → Run
-- ============================================================

-- 1) Tabla principal: una fila por (correo + evento)
create table if not exists public.amee_cat (
  id               uuid primary key default gen_random_uuid(),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),

  email            text not null check (char_length(email) between 5 and 200),
  evento           text not null default 'AMEE 2026' check (char_length(evento) between 1 and 60),

  nombre           text check (char_length(coalesce(nombre,''))  <= 120),
  empresa          text check (char_length(coalesce(empresa,'')) <= 160),
  rol              text check (char_length(coalesce(rol,''))     <= 160),

  -- D1 · Detecta
  habito           text check (char_length(coalesce(habito,''))  <= 1000),
  candado          text check (char_length(coalesce(candado,'')) <= 60),

  -- D2 · Desarma
  scarf            text[] default '{}',
  pierdo           text check (char_length(coalesce(pierdo,'')) <= 1000),
  costo            text check (char_length(coalesce(costo,''))  <= 1000),

  -- D3 · Diseña
  disparador       text check (char_length(coalesce(disparador,''))      <= 500),
  conducta_vieja   text check (char_length(coalesce(conducta_vieja,''))  <= 500),
  conducta_nueva   text check (char_length(coalesce(conducta_nueva,''))  <= 500),

  -- D4 · Defiende
  riesgo           text check (char_length(coalesce(riesgo,''))  <= 500),
  aliado           text check (char_length(coalesce(aliado,''))  <= 200),
  metrica          text check (char_length(coalesce(metrica,'')) <= 500),
  fecha_revision   text check (char_length(coalesce(fecha_revision,'')) <= 40),

  consentimiento   boolean not null default false,
  payload          jsonb not null default '{}'::jsonb
                     check (pg_column_size(payload) <= 131072),  -- máx ~128 KB

  unique (email, evento)
);

create index if not exists amee_cat_empresa_idx on public.amee_cat (empresa);
create index if not exists amee_cat_candado_idx on public.amee_cat (candado);
create index if not exists amee_cat_updated_idx on public.amee_cat (updated_at desc);

-- 2) updated_at automático
create or replace function public.amee_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists amee_touch on public.amee_cat;
create trigger amee_touch before update on public.amee_cat
  for each row execute function public.amee_touch_updated_at();

-- ============================================================
-- 3) SEGURIDAD (RLS) — modelo "buzón de entrega"
--    La anon key va dentro del HTML (es pública por diseño).
--    Con ella SOLO se puede ESCRIBIR. Nadie puede LEER ni BORRAR.
--    Héctor lee los datos desde el panel de Supabase (Table Editor)
--    o con la SERVICE ROLE key, que NUNCA va en el HTML.
-- ============================================================
alter table public.amee_cat enable row level security;

drop policy if exists amee_anon_insert on public.amee_cat;
create policy amee_anon_insert on public.amee_cat
  for insert to anon
  with check (
    char_length(email) between 5 and 200
    and char_length(evento) between 1 and 60
    and consentimiento = true          -- sin consentimiento, no se guarda
  );

-- UPDATE necesario para el upsert (si el participante regresa y corrige)
drop policy if exists amee_anon_update on public.amee_cat;
create policy amee_anon_update on public.amee_cat
  for update to anon
  using (true)
  with check (
    char_length(email) between 5 and 200
    and consentimiento = true
  );

-- (Intencional) NO hay política de SELECT ni DELETE para 'anon':
--   sin SELECT -> nadie lee con la llave pública
--   sin DELETE -> nadie borra con la llave pública

-- ============================================================
-- 4) VISTA DE SEGUIMIENTO (solo para ti, en el panel de Supabase)
--    Copia/pega en el SQL Editor cuando quieras el resumen post-conferencia.
-- ============================================================
-- Participantes y su candado dominante:
--   select created_at, email, nombre, empresa, rol, candado, habito, metrica, fecha_revision
--   from public.amee_cat order by created_at desc;
--
-- Distribución de candados (para tu reporte a la AMEE):
--   select candado, count(*) as personas,
--          round(100.0*count(*)/sum(count(*)) over (), 1) as pct
--   from public.amee_cat group by candado order by personas desc;
--
-- Amenazas SCARF más frecuentes:
--   select unnest(scarf) as amenaza, count(*)
--   from public.amee_cat group by 1 order by 2 desc;
--
-- Empresas representadas:
--   select empresa, count(*) from public.amee_cat
--   where empresa is not null group by 1 order by 2 desc;
