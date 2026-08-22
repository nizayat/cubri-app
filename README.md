# CUBRÍ MVP V10.3 — REAL FLOW

Actualización grande sobre V10.2.

## Incluye
- Auth real + perfil real preservados.
- Tipo de cuenta bloqueado según perfil autenticado (Empresa/Trabajador).
- Publicación real de turnos en Supabase.
- Fecha + horarios con selects propios de 30 minutos (sin selector nativo Android roto).
- Turnos nocturnos: si Fin <= Inicio se interpreta como día siguiente.
- GPS opcional al publicar turno + acceso a Google Maps.
- Feed real de turnos abiertos para trabajadores.
- Postulación real (`shift_applications`).
- Selección / descarte real por empresa.
- Confirmación real por trabajador.
- Dashboard empresa con conteos reales y turnos recientes.
- Operación real con estados de turno.
- Check-in / check-out real en `attendance`.
- Validación GPS de llegada cuando el turno tiene coordenadas (radio 500 m).
- Se eliminó el botón de “simular baja” de la operación real.

## Supabase
La migración V10.3 ya fue aplicada al proyecto CUBRÍ en producción. Se incluye `supabase/v10_3_migration.sql` como referencia/versionado.

## Deploy
Subir/reemplazar estos archivos en el repo `cubri-app` sobre `main`. Vercel debería desplegar automáticamente.
`public/config.js` conserva Project URL + Publishable key. Nunca usar secret/service-role en `public/`.

## Prueba recomendada
1. Cuenta empresa: publicar un turno.
2. Cuenta trabajador distinta: ver el turno y tocar `Me interesa`.
3. Empresa: abrir postulaciones y seleccionar trabajador.
4. Trabajador: confirmar turno.
5. Empresa: abrir Operación e iniciarla.
6. Trabajador: validar GPS, check-in y check-out.
7. Empresa: finalizar turno.
