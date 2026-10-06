# Pixel Crochet: sincronización, patrones gratuitos y comunidad

**Estado:** aprobado; proveedor actualizado por decisión de la persona propietaria el 2026-10-06
**Rama de diseño:** `dev`  
**Fecha:** 2026-10-05

## Resumen

Pixel Crochet mantendrá el uso como invitada y el guardado local. Quien inicie sesión opcionalmente con Google podrá respaldar y sincronizar sus proyectos con Supabase Auth y PostgreSQL. Vercel seguirá alojando y desplegando Flutter Web; el cliente Flutter se conecta a Supabase con su clave pública y la seguridad de filas (RLS) limita cada operación a su propietario. Las funciones de Vercel quedan reservadas para acciones privilegiadas que no se deban ejecutar desde el cliente. La sección `+Patrones` conservará sus enlaces a Ko-fi, añadirá patrones gratuitos seleccionados por la autora y mostrará patrones de la comunidad después de una revisión manual.

El objetivo de costo es **cero gasto recurrente**. La solución propuesta usa niveles gratuitos y debe degradarse sin perder el modo local si alcanza una cuota o si una condición del proveedor deja de ser válida. No se habilitará un plan pago ni un aumento automático de gasto.

## Contexto actual

- La versión web persiste los proyectos en `SharedPreferences`, que en web usa almacenamiento del navegador, bajo la clave `projects`.
- Los datos son locales al perfil y origen del navegador; el proyecto no tiene una copia de seguridad remota ni una cuenta de usuario.
- El contenido de un proyecto combina el patrón (`rows`, dimensiones y colores) con el avance privado (`currentRowIndex` y `completedBlocks`).
- La pantalla `+Patrones` muestra productos promocionales con enlaces a Ko-fi.
- El cambio de orientación publicado en el commit `2eee702` solo modificó el manifiesto web y archivos generados del build. No incluye una operación que borre proyectos locales. Aun así, el origen de la pérdida reportada no está confirmado.

Si los datos todavía existen en el mismo perfil y origen, abrir esa dirección exacta puede hacer que reaparezcan. Si el navegador ya borró su almacenamiento local, esta versión no tiene datos remotos desde los que recuperarlos.

## Objetivos

1. Mantener la app plenamente utilizable sin iniciar sesión.
2. Permitir que una cuenta de Google respalde y sincronice proyectos entre dispositivos.
3. Añadir exportación e importación de respaldos para personas invitadas y con cuenta.
4. Mantener los enlaces a los patrones de pago de Ko-fi.
5. Añadir patrones gratuitos seleccionados por la autora.
6. Permitir que una persona con cuenta envíe un patrón a la comunidad.
7. Publicar envíos solo después de que una persona administradora los apruebe.
8. Permitir explorar, usar y compartir mediante enlace los patrones aprobados.
9. Evitar cobros automáticos; al agotarse una cuota, conservar el modo local y avisar que la sincronización no está disponible.
10. Implementar cada feature en `dev`, probarla y solo después integrarla en `main`.

## No objetivos de la primera versión

- Aplicaciones nativas Android/iOS o sincronización entre plataformas nativas.
- Comentarios, mensajes privados, seguidores, votaciones o perfiles sociales.
- Subir imágenes originales o archivos arbitrarios junto con los patrones comunitarios.
- Publicar automáticamente contenido enviado por usuarios.
- Permitir que una persona invitada publique en la galería.
- Crear una suscripción, monetizar la cuenta de usuario o introducir una base de datos de pago.

## Experiencia propuesta

### `+Patrones`

La sección conserva los enlaces de Ko-fi y presenta tres grupos diferenciados:

1. **Patrones de Ko-fi:** productos actuales y sus destinos actuales.
2. **Patrones gratuitos:** patrones seleccionados por la autora, empaquetados como contenido estático del build web.
3. **Comunidad:** patrones enviados por usuarios y aprobados por moderación.

Los patrones gratuitos y comunitarios se pueden previsualizar y copiar a los proyectos personales. La copia es independiente: el avance personal nunca modifica el patrón publicado.

Cada patrón comunitario aprobado tiene una página con un enlace compartible y aparece en la galería pública. Las publicaciones no aprobadas, retiradas o rechazadas no se muestran en las rutas públicas.

### Envío y moderación

- El usuario inicia sesión con Google y elige un alias público. El correo electrónico nunca se expone en la galería.
- Desde un proyecto puede enviar una copia del patrón, editar su título, descripción breve y etiquetas, confirmar que tiene permiso para compartirlo y elegir la atribución requerida.
- El envío queda en estado `pending` y solo es visible para su autor y la persona administradora.
- La persona administradora revisa metadatos y una previsualización generada del gráfico; puede aprobar o rechazar el envío. El rechazo guarda un motivo privado para comunicarlo al autor.
- Solo patrones aprobados reciben URL pública y aparecen en la galería.
- El autor puede retirar su publicación. La persona administradora puede retirarla y revisar reportes de contenido publicado.
- La primera versión no acepta imágenes originales. El gráfico se representa a partir de filas, colores y cantidades estructurados; eso limita el tamaño y reduce datos personales no intencionados, aunque no elimina la necesidad de revisar cada envío.

### Modo invitado, cuenta y sincronización

- Invitados pueden importar/crear proyectos, seguir el avance, explorar la galería y copiar patrones. Sus proyectos siguen guardándose localmente.
- La pantalla de cuenta presenta `Iniciar sesión con Google` como opción, nunca como requisito para continuar.
- En el primer inicio de sesión, la app ofrece migrar los proyectos locales a la cuenta. La migración es idempotente y conserva la copia local hasta verificar que todos los proyectos se guardaron en la nube.
- En un dispositivo nuevo, iniciar sesión recupera los proyectos de la cuenta.
- Los cambios se guardan localmente primero. La sincronización se reintenta cuando vuelve la conexión. La interfaz distingue entre guardado local, sincronizando y respaldo remoto confirmado.
- Un fallo de login, red, cuota o servidor no borra ni reemplaza datos locales.
- Antes de sobrescribir una revisión remota más nueva, la API informa conflicto; la app conserva ambas versiones y pide elegir o guardar una copia. No habrá una política silenciosa de “última escritura gana” que pueda eliminar avance.
- Exportar genera un archivo JSON versionado. Importar valida el archivo y ofrece combinar o cancelar; no reemplaza todos los proyectos sin confirmación.

## Arquitectura propuesta

```text
Flutter Web ── desplegada en Vercel
  ├─ guardado local y cola de sincronización
  ├─ contenido gratuito estático incluido en el build
  └─ Supabase Flutter SDK ──> Supabase Auth + PostgreSQL
                                ├─ Google OAuth
                                ├─ proyectos privados protegidos por RLS
                                ├─ envíos y galería pública con RLS
                                └─ Vercel Functions para moderación privilegiada, si hace falta
```

- Vercel continúa sirviendo la web y sus previews; cambiar el proveedor de datos no cambia el hosting. La consulta de Vercel indicó que un proveedor externo como Supabase no afecta la elegibilidad de Hobby para el uso descrito.
- La aplicación usa únicamente la URL y la clave pública de Supabase. Nunca incluir la clave `service_role` ni secretos de Google en Flutter, variables de build públicas, assets o Git.
- Auth de Supabase gestiona Google OAuth. La app invitada conserva datos locales; al iniciar sesión, una migración idempotente sube proyectos y conserva la copia local hasta verificar el resultado. Se puede vincular una sesión anónima de Supabase a Google, pero no es requisito para usar la app.
- Row Level Security (RLS) protege los proyectos por `auth.uid()`. Patrones de comunidad y moderación tienen políticas separadas para publicar solo contenido aprobado y reservar acciones administrativas a una identidad verificada.
- Supabase almacena cuentas, proyectos privados, patrones de comunidad y reportes. Los patrones gratuitos seleccionados por la autora permanecen como assets versionados del repositorio para que sigan funcionando offline y no dependan de una consulta a la base.
- Las funciones de Vercel se mantienen solo para operaciones que requieren secretos privilegiados; no se necesita una API propia para el login o el CRUD normal de proyectos.

### Entidades principales

- `users`: identidad Google (`sub`), alias y fecha de creación. La lista de administradores se configura fuera de la base pública/API del cliente.
- `user_projects`: propietario, JSON del proyecto, versión de esquema, revisión remota y marcas temporales.
- `community_patterns`: autor, snapshot estructurado del patrón, metadatos, declaración de permiso, estado (`pending`, `published`, `rejected`, `removed`) y fechas de moderación/publicación.
- `pattern_reports`: patrón, categoría/motivo, fecha y estado de revisión.

El snapshot comunitario solo incluye los datos necesarios para tejerlo. No incluye `currentRowIndex`, `completedBlocks`, datos privados de cuenta ni archivo de imagen original.

## Presupuesto y condiciones de servicio

- Objetivo de despliegue: Vercel Hobby para Flutter Web y Supabase Free para Auth/PostgreSQL, sin comprar recursos ni activar upgrades u overages. La respuesta compartida de Vercel indica que el proyecto parece elegible con las condiciones descritas; para una confirmación legal formal remitió a `privacy@vercel.com`.
- Los límites publicados de Supabase Free incluyen cuotas para usuarios, base de datos y almacenamiento; los proyectos gratuitos también pueden pausarse tras una semana de inactividad. El uso de 200 personas podría caber si los datos son compactos, pero la cantidad de usuarios por sí sola no garantiza el consumo. La guía de despliegue debe indicar cómo revisar cuotas y cómo degradar a modo local.
- No activar upgrades, overages ni facturación automática. Definir límites de tamaño por patrón/proyecto, limitar frecuencia de escrituras y observar cuotas. Si se alcanza el límite, detener nuevas escrituras remotas de forma explícita; los datos locales y la exportación siguen disponibles.
- **Elegibilidad:** la propietaria consultó Vercel Support y recibió la indicación de que el proyecto parece elegible bajo Hobby con el modelo descrito; el uso de Supabase tampoco cambia esa evaluación. No contratar planes ni activar overages. La respuesta señala `privacy@vercel.com` para una confirmación legal formal.
- Las cuotas y condiciones de servicios gratuitos pueden cambiar; el sistema debe conservar exportación/importación y una ruta de degradación local.

## Privacidad y publicación

- El avance y los patrones privados no son visibles públicamente ni a otros usuarios.
- La publicación requiere confirmación explícita y una declaración de permiso para mostrar y compartir el patrón en Pixel Crochet.
- El correo Google se utiliza para autenticación y no se devuelve en endpoints públicos.
- La persona puede retirar su patrón comunitario; esa acción elimina su visibilidad pública pero no elimina la copia que otras personas ya guardaron en sus proyectos.
- El texto de licencia/atribución para los patrones propios y comunitarios debe revisarse y aprobarse antes de aceptar los primeros envíos públicos.

## Requisitos de aceptación

1. Un invitado puede crear, editar y avanzar proyectos sin cuenta ni red.
2. Exportar e importar un respaldo válido conserva filas, colores y avance; archivos inválidos o versiones desconocidas no reemplazan datos.
3. Un error de sincronización no hace desaparecer proyectos locales ni muestra falsamente que están respaldados.
4. Después de iniciar sesión, el usuario puede migrar su biblioteca y recuperar la misma biblioteca en otro navegador.
5. Un usuario autenticado no puede leer ni modificar proyectos de otra cuenta mediante la API.
6. Un proyecto no se publica sin acción explícita; una solicitud pendiente no aparece en la galería ni responde a su URL pública.
7. Solo la identidad administradora puede aprobar/rechazar; aprobar publica la ficha, rechazar la mantiene privada y retirar oculta la ficha pública.
8. Un patrón aprobado tiene página/enlace compartible y se puede copiar al espacio privado de otro usuario sin copiar avance ajeno.
9. `+Patrones` conserva sus enlaces Ko-fi, muestra contenido gratuito estático y presenta patrones comunitarios aprobados.
10. Al simular límite de cuota/API no disponible, la app informa el estado, conserva guardado local y permite exportar.
11. Cada feature se prueba en `dev`; solo tras pasar sus verificaciones se integra a `main`.

## Estrategia de entregas

El plan de implementación detallado se presenta junto con este diseño para revisión en `docs/superpowers/plans/2026-10-05-pixel-crochet-community-sync.md`. Como orden de entregas:

1. Diagnóstico/backup: exportar e importar datos locales versionados y agregar protección ante reemplazos accidentales.
2. Fundamentos de cuenta: Supabase Auth, Google OAuth, esquema, RLS y configuración de Vercel Preview.
3. Cuenta opcional y sincronización privada: Google sign-in, migración guest→cuenta, restauración y conflictos.
4. Catálogo estático: sección de patrones gratuitos, conservando Ko-fi.
5. Moderación: enviar patrón estructurado, bandeja privada, aprobación/rechazo/retirada y rol administrador.
6. Galería y enlaces: navegación pública, detalle, copia a biblioteca y reportes.
7. Ensayo de cuotas, actualización de privacidad/licencias y activación gradual en producción.

Cada slice debe quedar implementado y probado en `dev` antes de su merge a `main`. Los merges serán fast-forward o PR según el estado remoto; no se integrará un slice que no pase sus verificaciones. El plan detallado especificará pruebas unitarias, de API, de sincronización y un recorrido manual web/PWA donde corresponda.

## Decisiones pendientes para cerrar el diseño

1. Crear un proyecto Supabase en Free y configurar el proveedor Google y URLs de redirección; no compartir claves administrativas.
2. Elegir y aprobar el texto de permiso/licencia/atribución que se acepta al publicar.
3. Configurar la identidad Google administradora (no mostrar ni codificar datos sensibles en el cliente).
4. Acordar límites iniciales de tamaño para un proyecto, un patrón compartido y metadatos.
5. Probar en la tableta Fire HD 8 y navegador exacto cuando se pueda reproducir la pérdida de proyectos; este diagnóstico no se considera resuelto por la arquitectura nueva.
