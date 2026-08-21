# CUBRÍ MVP V10

Base técnica para convertir el prototipo aprobado en un MVP conectado.

## Incluye
- UI V9 aprobada (claro/oscuro y flujos empresa/trabajador)
- Supabase Auth bridge
- PostgreSQL schema inicial
- Row Level Security inicial
- Empresas, trabajadores, turnos, postulaciones, asistencia y ratings
- Configuración separada para URL + publishable key
- Deploy estático compatible con Vercel

## Activación
1. Crear un proyecto en Supabase.
2. Ejecutar `supabase/schema.sql` en SQL Editor.
3. Copiar Project URL y **Publishable Key** a `public/config.js`.
4. No poner jamás una Secret Key / service-role key en `public/`.
5. Subir el contenido del proyecto a GitHub/Vercel.

## Antes de producción
- Revisar RLS con tests de empresa/trabajador.
- Definir el encuadre laboral/fiscal antes de pagos o contratación real.
- Añadir Storage privado para documentación y políticas específicas.
- Implementar notificaciones push y matching server-side.
