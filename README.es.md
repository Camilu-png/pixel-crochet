# Pixel Crochet

[English](README.md) · **Español**

<p align="center">
  <img src="assets/favicon/favicon-96x96.png" width="96" alt="Logo de Pixel Crochet">
</p>

<p align="center">
  <b>Hecho puntada a puntada.</b><br> Nadie se sienta a tejer para hacer cuentas. Pixel Crochet cuenta por ti.
</p>

Pixel Crochet es una app gratuita y de código abierto para **tapestry crochet** que convierte la parte más difícil del oficio —llevar la cuenta— en algo que apenas notas. Pega un patrón estilo Stitch Fiddle, o importa una imagen de pixel art o de punto de cruz, y la app construye una guía interactiva. Sigue fila por fila, toca los bloques que terminas y tu progreso se guarda solo.

**Pruébala en web:** [pixel-crochet.vercel.app](https://pixel-crochet.vercel.app/)

## Capturas

<p align="center">
  <img src="screenshots/home+patterns.png" width="820" alt="Pixel Crochet — inicio y patrones listos">
</p>

| Inicio | Más patrones | Acerca de | Sugerir |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/home.png" width="330" alt="Inicio"> | <img src="screenshots/+patterns.png" width="330" alt="Más patrones"> | <img src="screenshots/about.png" width="330" alt="Acerca de Pixel Crochet"> | <img src="screenshots/suggest.png" width="330" alt="Sugerir una función"> |

## Por qué existe

El tapestry crochet es perfecto hasta la fila 47 de 213. Ahí pierdes el sitio, entrecierras los ojos con los números diminutos, cuentas por cuarta vez y aceptas en silencio que esa fila hay que destejerla.

Pixel Crochet es ese problema, eliminado. Te muestra solo lo que necesitas mientras tejes: la fila actual, en qué dirección leerla y los bloques de color de este momento. Marcas, avanzas, descansas.

## Características

**Importa una imagen y generará el patrón.** Carga un PNG o JPG de pixel art o de punto de cruz y la app lo convierte en patrón: detecta la paleta de colores, sugiere las dimensiones en puntadas y te deja cambiar cualquier color por el estambre que de verdad tienes en tu cajón.

**Pega o sube patrones de Stitch Fiddle.** Los patrones de texto en el formato clásico `Fila N: 10 rojo, 5 blanco` se parsean por ti —pega el texto o selecciona un archivo `.txt`.

**Una guía, no un muro de números.** La fila actual se divide en bloques de color, con una flecha que respeta la dirección de lectura (de izquierda a derecha o de derecha a izquierda) —ese detalle que acaba con más proyectos de los que debería.

**Progreso con un toque.** Terminas un bloque, lo tocas, listo — queda tachado. ¿Perdiste la cuenta? Retrocede una fila o salta a donde quieras del patrón.

**Guardado automático.** Cierra la app a medianoche; a la noche siguiente se abre exactamente donde la dejaste. Sin exportar, sin imprimir, sin memoria.

**Hecha para el sofá.** Toda la interfaz está pensada para llevarla con una mano mientras la otra está a media puntada. Sin menús escondidos a tres niveles de profundidad.

## Cómo funciona

1. **Importa** — pega el texto del patrón, selecciona un archivo `.txt` o elige una imagen PNG/JPG.
2. **Ajústala** — ponle nombre al proyecto, define las dimensiones en puntadas y remapea los colores a tu estambre. Todo se previsualiza antes de confirmar.
3. **Teje** — sigue la fila, marca los bloques sobre la marcha y deja que la app lleve la cuenta.

## Patrones de ejemplo

Listos para probar en `example/`:

- `mariposa_amarilla.txt` — una mariposa de 82 × 213, un proyecto grande de verdad
- `blue_guy.txt` — un mosaico de 32 × 32

## Apoya el proyecto

Pixel Crochet es gratis y está hecho con amor por una sola persona. Si realmente te gusta, hay varias formas honestas de dar las gracias:

- [Tienda de patrones](https://ko-fi.com/pixel_crochet/shop) — patrones de pixel listos para tejer, incluyendo *Salchipleto*, el perrito salchicha que siempre está a tu lado.
- [Ko-fi](https://ko-fi.com/pixel_crochet) — para mantener viva la app.
- [Sugerencias](mailto:mypixelcrochet@gmail.com) — cuéntanos qué te encantaría ver a continuación.
- O simplemente compártela con alguien que teje. Eso ayuda de verdad.

## Desarrollo

**Requisitos:** Flutter con el Dart SDK `^3.8.1`.

```bash
flutter pub get
flutter run                 # Android / iOS / escritorio
flutter run -d chrome       # web
flutter test
flutter analyze
```

**Stack:** Flutter · Riverpod (estado) · Go Router (navegación) · `intl` + `flutter_localizations` (i18n en inglés y español) · `google_fonts` · `shared_preferences` (persistencia) · `file_picker` + `image` (imagen → patrón).

Mapa rápido de `lib/`:

```
lib/
  core/        modelos, tema, constantes, almacenamiento, claves i18n
  features/    home, project, import (texto), import_image, more_patterns, support, suggest
  shared/      widgets y utilidades reutilizadas entre features
  generated/   localizaciones generadas
```

## Licencia

[MIT](LICENSE) © 2026 Camilú

Hecho puntada a puntada con amor.
