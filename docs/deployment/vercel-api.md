# API web: preparación de Vercel y Google

La API vive en `api/` y usa Node.js 22.x. Vercel detecta las funciones Node/TypeScript en esa carpeta y omite archivos auxiliares cuyo nombre empieza con `_` ([documentación de Vercel](https://vercel.com/docs/functions/configuring-functions/advanced-configuration#adding-utility-files-to-the-api-directory)). `vercel.json` deja `/api/*` fuera de la regla que envía páginas Flutter a `index.html`.

## Variables del entorno

Configurar únicamente en el panel de Vercel, nunca en Flutter, Git ni los logs:

| Variable | Uso |
| --- | --- |
| `PUBLIC_ORIGIN` | Origen HTTPS exacto de la web, sin `/` final; debe coincidir con el dominio permitido en Google. |
| `GOOGLE_CLIENT_ID` | ID OAuth de una credencial de tipo aplicación web. |
| `GOOGLE_CLIENT_SECRET` | Secreto OAuth usado solo por el callback del servidor. |
| `DATABASE_URL` | Cadena de conexión PostgreSQL de Neon; solo la lee la función Node. |
| `SESSION_TTL_SECONDS` | Opcional, 300–2.592.000; predeterminado: 30 días. |

El URI de redirección Google es `{PUBLIC_ORIGIN}/api/auth/google/callback`. No copiar valores reales a esta guía ni compartirlos en incidencias.

## Rutas implementadas

- `GET /api/auth/google/start`: crea `state` y `nonce` de un solo uso y redirige a Google.
- `GET /api/auth/google/callback`: intercambia el código, verifica firma/issuer/audience/nonce del ID token y crea una sesión opaca.
- `GET /api/auth/google/me`: responde solo si la cookie corresponde a una sesión vigente.
- `POST /api/auth/google/logout`: exige el origen exacto y revoca la sesión.
- `GET /api/health`: informa únicamente `ok` o `unavailable`, sin revelar variables ni errores del proveedor.

Las cookies de producción son `Secure`, `HttpOnly`, `SameSite=Lax` y `Path=/`; la base almacena SHA-256 de los tokens aleatorios, nunca la cookie sin procesar. Google solo concede el alcance `openid`; la app guarda el identificador estable `sub`, no pide ni almacena correo o perfil. La primera migración está en `api/migrations/001_initial.sql`; aplicarla una vez a la base de preview antes de probar OAuth. El código no ejecuta migraciones automáticamente.

Los límites de inicio, callback y cierre de sesión usan una ventana fija de diez minutos y el encabezado de IP que Vercel sobrescribe. En la base solo se conserva un HMAC de la IP y acción, y las ventanas vencidas se limpian al procesar solicitudes. Si Vercel no proporciona el encabezado, la API falla cerrada con `rate_limit_unavailable`.

## Activación por etapas

No configurar la API en producción ni crear una base real hasta confirmar que el uso de Pixel Crochet puede alojarse bajo el plan gratuito elegido. Vercel limita Hobby al uso personal o no comercial y recomienda consultar con soporte si la clasificación no está clara ([términos](https://vercel.com/legal/terms), [guía de uso justo](https://vercel.com/docs/limits/fair-use-guidelines)). Como Pixel Crochet enlaza a patrones pagados en Ko-fi, la elegibilidad no está confirmada. No publicar el código de API en una rama conectada a despliegues de Vercel hasta resolver este gate. Si se confirma elegibilidad, primero usar un proyecto y secretos de **Preview**. Si la API carece de variables, responde `auth_not_configured` y el cliente invitado continúa localmente; no hay un enlace visible de login hasta terminar la integración de la cuenta.

El endpoint OAuth requiere origen HTTPS salvo `localhost` en desarrollo. Google debe tener autorizado el origen y URI de callback exactos. La elegibilidad de Vercel Hobby, cuotas actuales de Neon y el uso comercial de enlaces a Ko-fi requieren revisión de la propietaria antes de desplegar.

## Comprobaciones locales

`npm test` ejecuta pruebas con almacén falso y sin red ni credenciales. `npm run typecheck` valida handlers, DB y configuración. No se ha probado aún contra una cuenta Google o una base real; esa comprobación pertenece al gate de Preview.
