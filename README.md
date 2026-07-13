# Protocolo 4D — El arte de desaprender

Artefacto interactivo de la conferencia **"El arte de desaprender: Hackea tu resistencia al cambio"**
impartida por **Héctor León** (Grow2GetherMx) en la **AMEE — Asociación Mexicana de Envase y Embalaje**.

## Qué es

Una app de una sola página, sin build y sin backend propio, que guía al participante por el
**Protocolo 4D** — Detecta, Desarma, Diseña, Defiende — hasta construir su **CAT** (*Call To Action*):
un compromiso de cambio con conducta observable, aliado, métrica y fecha a 30 días.

- Diagnóstico de 8 ítems → revela el **candado dominante** (aversión a la pérdida, statu quo, efecto dotación, costo hundido)
- **SCARF** para nombrar la amenaza
- Intención de implementación para diseñar la conducta de reemplazo
- Blindaje anti-recaída (base: Bouton, 2002/2004 — el cerebro no borra, compite)
- Descarga del CAT en **PDF con marca G2G**

## Stack

- HTML/CSS/JS puro. Sin framework, sin bundler.
- [jsPDF](https://github.com/parallax/jsPDF) para generar el PDF en el navegador.
- [Supabase](https://supabase.com) para persistir los CAT (`amee_cat`).

## Base de datos

El esquema está en [`supabase_schema.sql`](supabase_schema.sql). Modelo **"buzón de entrega"**:

- La *publishable key* va en el HTML (es pública por diseño).
- Con ella **solo se puede escribir**. No hay política de `SELECT` ni `DELETE` para `anon`,
  así que **nadie puede leer ni borrar** los datos con la llave pública.
- La lectura se hace desde el panel de Supabase o con la *service role key*, que **nunca** va en el cliente.
- Sin `consentimiento = true`, la fila **no se guarda** (lo fuerza la política RLS).

## Desarrollo

No hay build. Abre `index.html` en el navegador y listo.

## Deploy

Netlify sirve el directorio raíz tal cual (ver `netlify.toml`).

---

**Grow2GetherMx** — *Desaprende y transfórmate*
Héctor León · hector.leon@grow2gethermx.com · [grow2gethermx.com](https://grow2gethermx.com)
