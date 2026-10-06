# Configurar Supabase para Pixel Crochet

Vercel sigue alojando el build de Flutter Web. Supabase aporta Google Auth y PostgreSQL. La aplicación guarda cada cambio primero en el almacenamiento local; la cuenta y sincronización se habilitarán cuando esté lista la siguiente entrega.

## Crear el proyecto gratuito

1. Crea una cuenta en Supabase y un proyecto nuevo en el plan **Free**. No agregues add-ons ni cambies a un plan de pago.
2. Guarda la contraseña de base de datos en un gestor de contraseñas; Pixel Crochet no la necesita.
3. En **Project Settings → API Keys**, copia la **Project URL** y la **Publishable key**. No copies una `secret` ni una `service_role` key.
4. En **SQL Editor**, ejecuta el contenido de `supabase/migrations/001_initial_schema.sql` una sola vez.
5. En **Table Editor → user_projects → Policies**, confirma que RLS está habilitado. La migración crea políticas para que cada cuenta lea, cree, edite y borre exclusivamente sus propios proyectos.

La URL y la publishable key están pensadas para usarse desde el cliente. Las políticas RLS son obligatorias porque cualquier visitante puede inspeccionar los valores que se compilan dentro de la web.

## Activar inicio de sesión con Google

1. En el dashboard de Supabase abre **Authentication → Sign In / Providers → Google** y copia la URL de callback que muestra Supabase.
2. En Google Cloud Console crea un OAuth Client ID de tipo **Web application**. Añade el callback de Supabase como URI de redirección autorizada.
3. Copia el Client ID y Client Secret de Google al formulario del proveedor Google en Supabase. No van en Flutter ni en Vercel.
4. En **Authentication → URL Configuration → Redirect URLs**, permite el dominio de producción de Pixel Crochet, los dominios Preview que realmente utilices y el origen local que utilice Flutter.
5. Guarda los cambios del proveedor y prueba el login en Preview antes de producción.

El dominio de producción es el destino normal de OAuth. No uses un comodín amplio de dominios desconocidos; limita los redirects a tus dominios Vercel y local.

## Compilar la web

El cliente lee dos valores al compilar. Para una compilación local, usa el wrapper, que valida las claves antes de iniciar Flutter:

```sh
SUPABASE_URL=https://<project-ref>.supabase.co \
SUPABASE_PUBLISHABLE_KEY=<publishable-key> \
node tools/build_web.mjs
```

En Vercel agrega `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY` como variables de entorno del proyecto y usa `node tools/build_web.mjs` como **Build Command**. El wrapper las pasa a Flutter con `--dart-define` después de validarlas. Empieza en **Preview**; agrega las mismas variables al entorno **Production** solo después de validar login, RLS y recuperación de datos.

No agregues estas variables a Git. No uses `SUPABASE_SERVICE_ROLE_KEY`, `sb_secret_...`, Client Secret de Google ni la contraseña de Postgres en el comando de build. El wrapper detiene la compilación antes de invocar Flutter si detecta un formato conocido de clave secreta/service-role. No ejecutes `flutter build web` directamente con claves de Supabase: una comprobación en tiempo de ejecución no puede evitar que un valor `--dart-define` quede incrustado en el JavaScript.

## Si faltan variables

La aplicación inicia en modo invitado local cuando no recibe configuración Supabase o si el SDK no logra inicializarse. La biblioteca y sus respaldos locales no dependen del servicio. Esta condición no borra ni reemplaza proyectos guardados.

## Límites de gasto

Revisa el panel **Usage** de Supabase y mantén el proyecto en Free. No habilites add-ons, upgrades ni uso con cobro por excedente. El modo local y la exportación deben seguir disponibles si Supabase se pausa, queda sin cuota o no hay conexión.
