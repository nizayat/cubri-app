# Capital AI · V37.0 RC5.2

Corrección puntual sobre la base limpia RC5.1.

## Causa encontrada
RC5.1 tenía dos capas de navegación activas al mismo tiempo:

- una capa antigua rebindeaba la barra inferior cada 5 segundos y usaba `ranking`;
- el router correcto usa la vista real `market`.

Ambas capas competían entre sí. Por eso los botones podían dejar de navegar según qué binding hubiera quedado activo en ese momento.

## Corrección
- eliminada la capa antigua de navegación;
- una sola fuente de verdad: `capitalNavigate()` / `showTab()`;
- sin `setInterval` ni rebinding periódico de la barra inferior;
- Ranking apunta siempre a `market`;
- `Preparar` navega a Operar y precarga activo, monto y stop;
- preparar ya no se bloquea por un chequeo transitorio de frescura, porque preparar no ejecuta ni registra una orden;
- no se modificó la contabilidad ni la cartera.

## QA
1. Inicio → Ranking → Análisis → Cartera → Operar → Inicio.
2. Repetir la secuencia dos veces.
3. Inicio → Preparar → comprobar Operar con activo/monto/stop precargados.
4. No confirmar registro si no se realizó una operación real.
