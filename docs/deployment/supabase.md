# Configurar Supabase para Pixel Crochet

Vercel sigue alojando el build de Flutter Web. Supabase aporta Google Auth y PostgreSQL. La aplicación guarda cada cambio primero en el almacenamiento local y, después de iniciar sesión, sincroniza una copia privada en la cuenta.

## Crear el proyecto gratuito

1. Crea una cuenta en Supabase y un proyecto nuevo en el plan **Free**. No agregues add-ons ni cambies a un plan de pago.
2. Guarda la contraseña de base de datos en un gestor de contraseñas; Pixel Crochet no la necesita.
3. Encuentra los datos de conexión del proyecto:
   1. Abre el proyecto que acabas de crear. Debes estar dentro del dashboard del proyecto, no en la página general de Supabase.
   2. En la barra superior del dashboard, pulsa **Connect**. En el cuadro de conexión, elige **App Frameworks** o la opción para conectar una aplicación y copia **Project URL**. Tiene un formato parecido a `https://abcdefghijklmnopqrst.supabase.co`.
   3. En ese mismo cuadro copia **Publishable key**. Debe comenzar con `sb_publishable_` (o ser la clave heredada `anon`). Esa es la clave para la app web.
   4. Si no aparece el botón **Connect**, abre **Project Settings → API Keys** para copiar la clave pública. Para encontrar la URL, revisa **Integrations → Data API** y copia **Project URL**.
   5. Comprueba que la URL termine en `.supabase.co`. La dirección que ves en el navegador, como `https://supabase.com/dashboard/project/abcdefghijklmnopqrst`, es la página del panel y **no** es la Project URL que necesita Pixel Crochet.

   Supabase también puede mostrar una clave **Secret** (`sb_secret_...`) o la antigua `service_role`. No copies esas claves ni las pongas en Vercel, en el código, en un mensaje o en un archivo del proyecto. Solo se usa **Publishable key** en el cliente.
4. En **SQL Editor**, ejecuta el contenido de `supabase/migrations/001_initial_schema.sql` una sola vez.
5. En **Table Editor → user_projects → Policies**, confirma que RLS está habilitado. La migración crea políticas para que cada cuenta lea, cree, edite y borre exclusivamente sus propios proyectos.

La URL y la publishable key están pensadas para usarse desde el cliente. Las políticas RLS son obligatorias porque cualquier visitante puede inspeccionar los valores que se compilan dentro de la web. La `Project URL` normalmente empieza por `https://` y termina en `.supabase.co`; no incluyas rutas como `/rest/v1`.

### Si Vercel ofrece instalar Supabase desde Marketplace

No necesitas instalar esa integración para que Pixel Crochet use Supabase. El instalador del Marketplace intenta aprovisionar/conectar un recurso Supabase desde Vercel. Si muestra que **Supabase Free Plan** no está disponible porque se alcanzó el límite de proyectos, no elijas **Pro** ni **Team**: cierra esa ventana. La captura corresponde al límite de **dos proyectos Free activos de Supabase**, no a una suscripción obligatoria de Vercel.

Usa directamente el proyecto Supabase Free que ya creaste y copia su `Project URL` y `Publishable key` a las variables de entorno manuales de Vercel (pasos de abajo). Supabase cuenta hasta dos proyectos Free activos por persona administradora/propietaria, incluso si están en organizaciones distintas; los proyectos pausados no cuentan. Si realmente necesitas liberar un cupo, pausa un proyecto Free que no estés usando desde **Supabase → Project Settings → General → Project availability → Pause Project**. Pausar lo deja inaccesible mientras esté pausado, pero conserva sus datos y puedes reanudarlo después. [Límite Free y proyectos pausados](https://supabase.com/docs/guides/platform/billing-on-supabase) · [Cómo pausar o reanudar](https://supabase.com/docs/guides/platform/delete-project#alternative-pause-your-project)

## Activar inicio de sesión con Google

1. En Supabase abre **Authentication → Sign In / Providers → Google**. Activa el proveedor y copia el **Callback URL** que aparece en esa pantalla; suele tener el formato `https://<project-ref>.supabase.co/auth/v1/callback`. Déjalo abierto para copiarlo después.
2. Abre [Google Auth Platform](https://console.cloud.google.com/auth/clients). Selecciona o crea un proyecto de Google Cloud para Pixel Crochet. Si Google primero pide configurar la pantalla de consentimiento, configura la marca y el público como **External**; durante las pruebas, añade las cuentas Google que probarán como **Test users**.
3. En **Clients**, pulsa **Create client** y elige **Web application**.
4. En **Authorized JavaScript origins**, agrega el origen desde el que se abrirá Pixel Crochet: por ejemplo `https://<tu-dominio-de-produccion>`. Agrega también el dominio Preview que usarás para probar y `http://localhost:<puerto>` si probarás localmente. Aquí va solo el origen (protocolo + dominio + puerto); no agregues una ruta.
5. En **Authorized redirect URIs**, agrega el **Callback URL de Supabase** que copiaste en el paso 1. No pongas aquí la URL de Vercel. El valor debe coincidir exactamente, incluido `https://` y la ruta `/auth/v1/callback`.
6. Pulsa **Create**. Google mostrará un **Client ID** y un **Client Secret**. Cópialos en ese momento y guárdalos de forma privada.
7. Vuelve a Supabase a **Authentication → Sign In / Providers → Google**. Pega el Google **Client ID** en su campo y el Google **Client Secret** en su propio campo; activa y guarda el proveedor. Estos son credenciales de Google: no los pegues en Flutter, Git ni Vercel.
8. En Supabase abre **Authentication → URL Configuration**. Define como **Site URL** el origen de producción de Pixel Crochet y añade en **Redirect URLs** el origen de Preview y el origen local que uses. La app vuelve al origen desde donde se inició el acceso. Guarda.
9. Prueba desde Preview con una cuenta incluida en los **Test users** de Google mientras la aplicación OAuth siga en modo **Testing**.

El dominio de producción es el destino normal de OAuth. No uses un comodín amplio de dominios desconocidos; limita los redirects a tus dominios Vercel y local.

**No confundas estos valores:** Google **Client ID/Client Secret** van en los campos del proveedor Google dentro de Supabase. La **Project URL/Publishable key** van en las variables de entorno de Vercel descritas arriba. La Client Secret de Google nunca debe exponerse en la app web.

## Compilar la web

Estos valores conectan Pixel Crochet con tu proyecto Supabase:

- `SUPABASE_URL`: indica a la aplicación **a qué proyecto Supabase conectarse**. Pega aquí la `Project URL` copiada desde Supabase.
- `SUPABASE_PUBLISHABLE_KEY`: identifica la aplicación cliente ante Supabase. Pega aquí la clave `Publishable` (`sb_publishable_...` o la clave antigua `anon`). Es pública; los permisos de datos los controla RLS.

### Despliegue actual: web precompilada

El proyecto Vercel usa **Root Directory: `build/web`**. Vercel publica los archivos que ya están compilados en esa carpeta; no recibe el código Dart ni la carpeta `tools` como parte de su raíz de trabajo.

Por eso la URL y la clave pública de Supabase se pasan al **build local**, no al servidor estático. Agregarlas únicamente a Environment Variables de Vercel no modifica un `main.dart.js` ya compilado.

1. Mantén **Root Directory** en `build/web`.
2. En **Settings → Build and Deployment**, conserva el proyecto estático (Framework Preset **Other**) y deja **Build Command** vacío. El `vercel.json` fija un comando vacío y **Output Directory: `.`** para publicar la propia raíz seleccionada, incluso si el dashboard conserva valores anteriores. No pongas `node tools/build_web.mjs` como comando de Vercel.
3. Compila desde la raíz local del repositorio usando los dos valores públicos de Supabase y el wrapper de abajo.
4. Revisa y sube los archivos actualizados de `build/web` en la rama `dev`. El deployment Preview debe corresponder a ese commit; los cambios en `lib/` por sí solos no actualizan esta web precompilada.
5. Espera a que el deployment esté **Ready**, abre su URL y comprueba **Cuenta y respaldo**, Google OAuth y la restauración en otro navegador antes de autorizar un merge a `main`.

### Compilación local

El wrapper valida las claves antes de iniciar Flutter y pasa ambos valores con `--dart-define`:

```sh
SUPABASE_URL=https://<project-ref>.supabase.co \
SUPABASE_PUBLISHABLE_KEY=<publishable-key> \
node tools/build_web.mjs
```

Reemplaza los marcadores por la Project URL y la Publishable key de Supabase. Usa el SDK de Flutter instalado en tu equipo. No guardes un archivo con credenciales administrativas ni pegues secretos en este comando.

La URL y la publishable key son configuración pública: quedan incorporadas al JavaScript del build y pueden ser inspeccionadas por cualquier visitante. El acceso privado lo protegen las políticas RLS, no ocultar esa clave.

No uses `SUPABASE_SERVICE_ROLE_KEY`, `sb_secret_...`, Client Secret de Google ni la contraseña de Postgres. El wrapper rechaza claves secret/service-role reconocibles antes de que Flutter las incorpore al build.

### Si aparece Cannot find module tools/build_web.mjs

Ese comando no existe dentro de la raíz estática `build/web`. Retira el Build Command de Vercel y usa el procedimiento local anterior. No cambies Root Directory a la raíz del repositorio sin preparar también un entorno de compilación con Flutter.

## Si faltan variables

La aplicación inicia en modo invitado local cuando no recibe configuración Supabase o si el SDK no logra inicializarse. La biblioteca y sus respaldos locales no dependen del servicio. Esta condición no borra ni reemplaza proyectos guardados.

## Límites de gasto

Revisa el panel **Usage** de Supabase y mantén el proyecto en Free. No habilites add-ons, upgrades ni uso con cobro por excedente. El modo local y la exportación deben seguir disponibles si Supabase se pausa, queda sin cuota o no hay conexión.

## Si Google muestra redirect_uri_mismatch

En Google Cloud abre **Google Auth Platform → Clients**, selecciona el cliente de tipo **Web application** usado en Supabase y, en **Authorized redirect URIs**, agrega exactamente:

```text
https://hztdufyrpqgntzveoppc.supabase.co/auth/v1/callback
```

Guarda el cambio. Esta URL corresponde al callback de Supabase; va en los URI de redirección autorizados del cliente Google, no en los orígenes JavaScript. Las URLs de regreso a Pixel Crochet se configuran por separado en **Supabase → Authentication → URL Configuration → Redirect URLs**.

## Patrones grandes: ampliar el límite a 1 MiB

El límite original de 256 KiB impide sincronizar patrones grandes como Shadow. Para proyectos Supabase existentes, abre **SQL Editor → New query**, pega todo el contenido de `supabase/migrations/002_increase_project_size_limit.sql` y pulsa **Run**. Para instalaciones nuevas ejecuta primero `001_initial_schema.sql` y luego `002_increase_project_size_limit.sql`. Esta migración conserva los proyectos y las políticas de acceso. También se necesita el build de la aplicación con el límite actualizado.
