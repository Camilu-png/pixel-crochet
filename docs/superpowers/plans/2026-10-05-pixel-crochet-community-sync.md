# Pixel Crochet: cuentas, respaldo y patrones de la comunidad — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mantener Pixel Crochet útil como invitada, proteger y sincronizar proyectos opcionalmente, y ampliar `+Patrones` con contenido gratuito y publicaciones comunitarias moderadas.

**Architecture:** Flutter seguirá guardando primero en el dispositivo. La web añadirá endpoints Node/TypeScript en Vercel que validan sesiones de Google y acceden a Neon; los secretos no llegan al cliente. Los patrones gratuitos versionados viven en los assets Flutter, mientras que los comunitarios solo se sirven públicamente después de aprobación manual.

**Tech Stack:** Flutter/Dart, Riverpod, go_router, Flutter Web, TypeScript en Vercel Functions, PostgreSQL en Neon, Google OAuth/OpenID Connect, `flutter_test` y pruebas Node para API.

**Spec:** `docs/superpowers/specs/2026-10-05-pixel-crochet-community-sync-design.md`

## Restricciones globales

- El trabajo de producto se realiza en `dev`; `main` recibe una feature solo después de que sus verificaciones pasen.
- El modo invitado y el guardado local siguen funcionando sin cuenta, API, red ni base de datos.
- Guardar localmente precede a sincronizar; un error remoto nunca elimina ni reemplaza silenciosamente datos locales.
- No incluir secretos de Google, Neon ni administración en Flutter, assets, logs o respuestas públicas.
- No activar upgrades, overages, facturación automática ni recursos de pago.
- Mantener intactos los enlaces de Ko-fi actuales.
- En la primera versión, solo patrones estructurados; no aceptar imágenes ni archivos arbitrarios en envíos comunitarios.
- No exponer email, avance privado ni proyectos en rutas públicas.
- Antes de desplegar bajo Vercel Hobby, confirmar elegibilidad de acuerdo con sus términos; si no es elegible, detener el despliegue cloud y seleccionar una opción gratuita compatible.
- No aceptar envíos comunitarios hasta aprobar el texto de permiso/atribución y configurar una identidad administradora.

## Enfoque de revisión

- Datos locales corruptos o con versión futura: importación/exportación debe rechazar el respaldo sin tocar la biblioteca.
- Proyectos locales y remotos con el mismo ID pero distinto avance: preservar ambas revisiones y pedir resolución explícita.
- Invitado sin conexión o API fuera de servicio: lectura, edición, avance y exportación locales siguen disponibles.
- Cookie ausente, vencida o alterada: la API responde sin datos privados y Flutter no asume una sesión válida.
- Envío pendiente, rechazado, retirado o reportado: no se filtra a galería ni a la ruta pública; cada transición requiere autorización.

---

## Mapa de archivos previsto

Las rutas existentes que se modificarán siguen la organización actual del repositorio. Los archivos `api/`, la configuración Node/TypeScript y las nuevas áreas Flutter son nuevos.

- `lib/core/models/crochet_project.dart`: serialización/versionado y copia de datos de patrón sin avance.
- `lib/core/storage/project_storage_service.dart`: repositorio local; interfaz estable para respaldo y sincronización.
- `lib/features/home/providers/home_provider.dart`: biblioteca visible y acciones de migración/restauración.
- `lib/core/router/app_router.dart`: rutas account, admin, catálogo y detalle compartible.
- `lib/features/more_patterns/presentation/more_patterns_screen.dart`: secciones Ko-fi, gratuitos y comunidad.
- `assets/patterns/` y `pubspec.yaml`: patrones estáticos curados.
- `lib/features/account/`, `lib/core/sync/`, `lib/features/community/`: presentación y lógica Flutter separadas por responsabilidad.
- `api/_lib/`: helpers privados de sesión, validación, límites, acceso Neon y autorización; cada archivo empieza con `_` para Vercel.
- `api/auth/`, `api/projects/`, `api/patterns/`, `api/admin/`: funciones HTTP agrupadas por recurso.
- `api/migrations/`: migraciones SQL versionadas; `api/tests/`: pruebas de handlers/repositorio/autorización.
- `vercel.json`, `package.json`, `tsconfig.json`: configuración para servir Flutter y desplegar funciones.
- `test/`: pruebas Flutter para importación/exportación, estado, navegación y widgets.

## Entregas y tareas

Cada entrega marcada **integración** es un punto de revisión independiente. Tras ejecutar las verificaciones de esa entrega en `dev`, revisar el diff, hacer commit de sus archivos y fusionar únicamente esa entrega en `main`; después volver a `dev` para empezar la siguiente. No mezclar cambios personales preexistentes.

### Task 1: Respaldo local seguro para invitados

**Archivos:** `lib/core/models/crochet_project.dart`, nuevo `lib/core/storage/project_backup_service.dart`, `lib/features/home/presentation/home_screen.dart`, nuevos diálogos de respaldo bajo `lib/features/home/presentation/widgets/`, `test/crochet_project_test.dart`, nuevo `test/project_backup_service_test.dart`, pruebas de widget pertinentes.

**Interfaces:** `ProjectBackupService.exportProjects(List<CrochetProject>) -> String`; `ProjectBackupService.parseBackup(String) -> BackupImportResult`. Resultado de importación contiene proyectos validados y versión de formato; analizar no escribe almacenamiento.

- [x] Añadir pruebas de serialización para versión actual, campos opcionales/antiguos y datos inválidos; validar que no se pierden `currentRowIndex` ni `completedBlocks`.
- [x] Añadir pruebas para exportación/importación vacía, biblioteca completa, JSON malformado y versión desconocida. En los dos últimos casos afirmar que el almacenamiento no cambia.
- [x] Implementar formato JSON con `formatVersion`, fecha de exportación y proyectos. Importar debe ofrecer combinar por ID; si un ID colisiona con contenido distinto, crear una copia con ID nuevo y conservar ambas versiones.
- [x] Añadir controles accesibles para exportar/importar en la biblioteca y confirmación previa a combinar; conservar almacenamiento existente como fuente primaria.
- [x] Ejecutar `flutter test test/crochet_project_test.dart test/project_backup_service_test.dart` y pruebas de widgets nuevas; después `flutter analyze`.
- [x] **Integración:** revisión del diff y commit de respaldo; merge de esta entrega a `main` solo si todas las verificaciones pasan.

### Task 2: Catálogo gratuito estático en `+Patrones`

**Archivos:** `example/blue_guy.txt` y `example/mariposa_amarilla.txt` como assets estáticos ya existentes; `pubspec.yaml`; nuevo `lib/features/more_patterns/data/free_pattern_catalog.dart`; `lib/features/more_patterns/presentation/more_patterns_screen.dart`; `lib/core/l10n/app_{es,en}.arb` y localizaciones generadas; nuevas pruebas `test/free_pattern_catalog_test.dart` y `test/more_patterns_screen_test.dart`.

**Interfaces:** catálogo inmutable de patrones gratuitos con ID, título localizado, atribución/licencia y datos parseables por el modelo actual. Al seleccionar, crea un `CrochetProject` independiente con avance inicial.

- [x] Probar que cada asset declarado se puede decodificar y que su patrón tiene dimensiones, filas y colores consistentes.
- [x] Añadir contenido gratuito empaquetado en el build y un grupo visible separado de productos Ko-fi y comunidad.
- [x] Probar que Ko-fi conserva los mismos destinos, los gratuitos aparecen sin red y copiar un patrón produce avance limpio sin mutar el asset.
- [x] Ejecutar las pruebas de catálogo/pantalla, `flutter gen-l10n`, `flutter analyze` y `flutter build web`.
- [x] **Integración:** revisión/commit y merge de solo catálogo estático a `main` si las verificaciones pasan.

### Task 3: Base Vercel/Neon y sesiones Google

**Archivos:** nuevos `package.json`, `package-lock.json`, `tsconfig.json`, `api/_lib/_{auth,db,errors,google_oidc,handlers,validation}.ts`, `api/auth/google/{start,callback,logout,me}.ts`, `api/health.ts`, `api/migrations/001_initial.sql`, pruebas auxiliares `api/tests/_*.test.ts`; `vercel.json`; documentación nueva `docs/deployment/vercel-api.md`.

**Interfaces:** handlers HTTP tipados con Web `Request`/`Response`; consultas PostgreSQL parametrizadas con Neon; cookie de sesión opaca y aleatoria (`HttpOnly`, `Secure`, `SameSite=Lax`) cuyo hash se guarda en DB; endpoint `GET /api/auth/google/me` solo devuelve estado autenticado, sin correo ni tokens.

- [x] Añadir pruebas Node para callback OAuth inválido, `state`/nonce faltante, cookie vencida/falsificada, origin no permitido, límites de tasa y endpoint de identidad sin sesión.
- [x] Crear migración inicial para usuarios, estados OAuth, sesiones y límites; `sub` de Google es identificador estable. No guardar tokens OAuth ni correo.
- [x] Implementar flujo OIDC con verificación de firma/issuer/audience/nonce, protección CSRF y cookie de sesión. Ningún endpoint acepta un ID de usuario proporcionado por el cliente como identidad.
- [x] Añadir health check genérico, límite de tamaño JSON reutilizable, límites de tasa persistentes, consultas parametrizadas y manejo uniforme de errores.
- [x] Configurar TypeScript y ejecución de pruebas con scripts reproducibles. Documentar variables secretas y configuración manual sin incluir valores.
- [x] Probar localmente con almacén de sesión OAuth simulado, sin DB ni llamadas a Google; pruebas de integración con credenciales reales quedan para entorno de preview después de que la propietaria configure secretos y confirme elegibilidad del proveedor.
- [x] Ejecutar `npm test`, `npm run typecheck`, `flutter analyze`, `flutter test` y `flutter build web` para comprobar que API y hosting coexisten.
- [ ] **Gate de activación:** no crear/deployar recursos reales hasta confirmar términos, cuotas sin upgrades, proyecto Neon gratuito y credenciales. Tras el gate, deploy preview y smoke test OAuth.
- [ ] **Integración:** merge de los fundamentos a `main` después del preview validado; mantener endpoints cloud desactivados para usuarios hasta completar sync.

### Task 4: Sincronización privada y migración opcional

**Archivos:** `api/projects/{index,[id]}.ts`, migración de revisiones; nuevos `lib/core/sync/{sync_client,sync_repository,sync_state}.dart`, `lib/features/account/{data,presentation,providers}/`; ajustes a `lib/core/storage/project_storage_service.dart`, `lib/features/home/providers/home_provider.dart`, router y localizaciones; pruebas Flutter y API.

**Interfaces:** API: `GET/PUT /api/projects`, `PUT/DELETE /api/projects/:id` con `revision` monotónica. Flutter: `SyncRepository.syncPending()`, `SyncState` (`localOnly`, `pending`, `synced`, `conflict`, `unavailable`). Escrituras remotas autenticadas por cookie, no por `userId` del cuerpo.

- [ ] Probar aislamiento entre dos usuarios, operaciones CRUD, límite de tamaño, revisión obsoleta (409) y cuota/API caída.
- [ ] Probar cola offline, reintento, estado guardado local primero y que timeout/401/5xx no borren ni sobrescriban la biblioteca local.
- [ ] Añadir inicio de sesión opcional y flujo de migración repetible: preservar copia local hasta comprobar IDs/revisiones en remoto; volver a intentarlo no duplica proyectos.
- [ ] En conflictos conservar las dos revisiones como copias recuperables y ofrecer resolución explícita; no aplicar “última escritura gana”.
- [ ] Añadir restauración en navegador nuevo y desconexión de cuenta sin borrar datos locales. Presentar estados local/sincronizando/respaldado con mensajes localizados.
- [ ] Ejecutar pruebas específicas de sync (unitarias, provider/widget, API), `flutter analyze`, `flutter test` y `flutter build web`.
- [ ] Probar preview en dos perfiles de navegador, invitado offline y cuenta autenticada; verificar exportación antes/después de sincronizar.
- [ ] **Integración:** merge a `main` solo después de pasar API, Flutter y recorrido preview; habilitar cuenta por configuración de despliegue documentada.

### Task 5: Envíos y panel de moderación

**Archivos:** migración `community_patterns`/`pattern_reports`; `api/patterns/submit.ts`, `api/admin/patterns.ts`, `api/admin/reports.ts`; `lib/features/community/{data,providers,presentation}/`; pantalla/route de administración; localizaciones y pruebas.

**Interfaces:** transiciones de patrón `pending -> published | rejected -> removed`; solo admin puede aprobar/rechazar/retirar, autor puede retirar sus propios publicados. Un envío contiene snapshot del patrón, título, descripción corta, etiquetas, alias/atribución y aceptación de permiso con versión del texto.

- [ ] Probar permisos por transición: anónimo/otro usuario no puede enviar como autor; usuario no admin no puede moderar; autor solo puede retirar lo propio.
- [ ] Probar validación de filas/colores, límite de tamaño y campos de texto; descartar progreso privado, imagen y campos inesperados al formar snapshot.
- [ ] Añadir formulario de envío desde copia de patrón con confirmación explícita de licencia/permiso y alias público; mantener pendiente hasta decisión admin.
- [ ] Crear cola privada de revisión con preview derivada de datos estructurados, acciones aprobar/rechazar con motivo privado y retirar publicación.
- [ ] Añadir acción para reportar patrón publicado y bandeja de reportes; solo admin ve reportes, usuarios no ven motivos privados.
- [ ] Probar que solicitudes pendientes/rechazadas/retiradas nunca responden en endpoint público.
- [ ] Ejecutar suite API, suite Flutter, `npm run typecheck`, `flutter analyze` y `flutter build web`; prueba manual con cuentas autor/admin distintas en preview.
- [ ] **Gate de publicación:** exigir texto de licencia/atribución aprobado y configuración de identidad administradora en servidor antes de aceptar envíos.
- [ ] **Integración:** merge de moderación a `main` tras pruebas de preview y gates aprobados; los envíos permanecen deshabilitados si falta configuración.

### Task 6: Galería pública, detalle y enlaces compartibles

**Archivos:** `api/patterns/index.ts`, `api/patterns/[slug].ts`; migración de slug/índice público; pantallas/data/providers de galería y detalle bajo `lib/features/community/`; `lib/core/router/app_router.dart`; `lib/features/more_patterns/presentation/more_patterns_screen.dart`; pruebas.

- [ ] Probar paginación acotada, búsqueda/etiquetas normalizadas, slug duplicado y acceso anónimo a solo registros `published`.
- [ ] Añadir galería pública y detalle con alias/atribución; no devolver correo, usuario interno, estado de revisión, reportes ni proyectos.
- [ ] Añadir `go_router` URL estable para patrones aprobados y probar apertura directa/refresh en Vercel rewrite.
- [ ] Permitir copiar a la biblioteca local o sincronizada como proyecto nuevo con avance limpio; comprobar que modificar/cerrar la copia no afecta al patrón publicado.
- [ ] Integrar la galería en `+Patrones` sin quitar Ko-fi ni catálogo gratuito estático; mostrar fallback claro ante API offline.
- [ ] Ejecutar pruebas de rutas, catálogo, permisos API, `flutter analyze`, `flutter test` y `flutter build web`; smoke test de enlace copiado en navegador limpio.
- [ ] **Integración:** merge de galería a `main` tras verificaciones completas de preview.

### Task 7: Cuotas, privacidad y activación gradual

**Archivos:** documentación de despliegue/privacidad, pruebas de límites en API/sync, configuración de Vercel y runbook de recuperación.

- [ ] Simular Neon fuera de cuota, API 429/5xx, sesión expirada y pérdida de red; confirmar guardado y exportación local disponibles y estado remoto honesto.
- [ ] Confirmar límites iniciales documentados para bytes por proyecto, patrón y solicitud; probar rechazo antes de persistir un tamaño excedido.
- [ ] Revisar minimización de datos, retención/eliminación de cuenta, cookies, texto de publicación, reporte/retirada y exposición de endpoints.
- [ ] Documentar backup/export de base de datos, rollback de migraciones, desactivar cloud y recuperación con export JSON.
- [ ] Hacer recorrido end-to-end en `dev`/preview: invitado, backup, cuenta nueva, migración, segundo navegador, envío, moderación, enlace público, reporte y retirada.
- [ ] Ejecutar suite completa Flutter/API, análisis estático y build web; guardar resultados y checklist de release.
- [ ] **Integración final:** revisión de cambios acumulados y merge a `main` solo con gates, verificaciones y smoke tests en verde. Confirmar publicación de producción sin habilitar cobros automáticos.

## Verificación por feature y política de integración

Una feature no se integra por el mero hecho de compilar. Su checklist de aceptación y pruebas automatizadas deben pasar en `dev`, se revisa su diff y se prueba el flujo manual de navegador/preview descrito en su entrega. Cada feature aprobada se fusiona por separado a `main` y se comprueba la URL de producción antes de comenzar una feature que dependa de ella. Si una verificación falla, se corrige en `dev` y se repite la suite afectada; `main` no recibe esa entrega hasta entonces.

La configuración real de OAuth, Neon y la elegibilidad de Vercel son dependencias externas: el plan implementa y valida código/configuración en preview primero, pero la activación con secretos requiere que la propietaria complete esos gates. No se contratará un plan ni se habilitarán cobros para sortearlos.
