# Play Store Release Guide

Este documento describe la configuración necesaria para publicar Pixel Crochet en
Google Play. La mayoría de los pasos requieren **una única vez** antes del primer
lanzamiento.

## 1. Application ID

Ya configurado: `com.pixelcrochet.app` (en `android/app/build.gradle.kts`, campos
`namespace` y `applicationId`).

> **Importante:** la ID de aplicación es **permanente** una vez publicada. No
> puede cambiarse después. `com.pixelcrochet.app` sigue la convención
> reverse-domain y es válida aunque no poseas el dominio `pixelcrochet.com`.

## 2. Keystore de firma (upload key)

Google Play requiere que el APK/AAB esté firmado con una clave de subida
(Upload Key). Esta clave NO debe subirse al repositorio.

### 2.1 Generar el keystore

```bash
keytool -genkeypair -v \
  -keystore ~/keystores/pixel-crochet-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Guarda el keystore y las contraseñas en un lugar seguro. Si lo pierdes, no
podrás actualizar la app. (Opcional: mantén una copia de seguridad cifrada.)

### 2.2 Crear `android/key.properties`

Este archivo **ya está en `.gitignore`**, nunca se sube al repositorio. Créalo
con la ruta **absoluta** al keystore:

```properties
storePassword=TU_CONTRASENA
keyPassword=TU_CONTRASENA
keyAlias=upload
storeFile=/ruta/absoluta/a/pixel-crochet-upload.jks
```

Con este archivo presente, `flutter build appbundle` firmará automáticamente
con tu clave (`signingConfig "release"`). Sin él, los builds de release usan la
clave de debug como fallback (útil para desarrollo, NO publicable).

### 2.3 Verificar la firma

```bash
flutter build appbundle
# El AAB queda en build/app/outputs/bundle/release/app-release.aab
```

## 3. Icono de la app y splash

Actualmente se usa el icono por defecto de Flutter. Antes de publicar debes
añadir un launcher icon adaptativo (Android 8+) y configurar el splash screen.

Cuando tengas los assets de marca, se recomienda:

- Generar el icono con `flutter_launcher_icons` (o `flutter_launcher_icons` +
  `flutter_native_splash`).
- Configurar la pantalla de arranque con `flutter_native_splash`.

## 4. Checklist previo a la publicación

- [ ] Crear el keystore de upload (sección 2) y `android/key.properties`.
- [ ] `flutter analyze` sin issues y `flutter test` en verde.
- [ ] Icono adaptativo y splash con la marca final.
- [ ] Revisar los textos de la Play Store (nombre, descripción, categoría).
- [ ] Prueba en un dispositivo real (Android 8+).
- [ ] Incrementar `version` en `pubspec.yaml` (ej. `1.0.1+2`) en cada release.

## 5. Subir a Google Play

1. Crear el proyecto en [Google Play Console](https://play.google.com/console).
2. Crear la app con el nombre "Pixel Crochet" y la ID `com.pixelcrochet.app`.
3. En **Configuración de la app > Integridad de la app**, subir la clave
   pública de la Upload Key (obtenida con `keytool -exportcert ... -rfc`).
4. Crear una release interna/cerrada y subir `app-release.aab`.
5. Completar el formulario de clasificación de contenido y privacidad.
6. Promover la release a producción cuando esté lista.
