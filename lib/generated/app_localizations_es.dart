// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pixel Crochet';

  @override
  String get homeWelcome => 'Bienvenido a Pixel Crochet';

  @override
  String get homeDescription => 'Ganchillo hecho a mano con amor';

  @override
  String get importPattern => 'Importar Patrón';

  @override
  String get importPatternDescription => 'Importar un patrón de ganchillo';

  @override
  String get importPatternHint =>
      'Selecciona un archivo .txt o pega el texto del patrón';

  @override
  String get selectFile => 'Seleccionar Archivo';

  @override
  String get or => 'o';

  @override
  String get pastePattern => 'Pegar texto del patrón';

  @override
  String get pastePatternHint => 'Pega el texto de tu patrón aquí...';

  @override
  String get importText => 'Importar Patrón';

  @override
  String get project => 'Proyecto';

  @override
  String get projectNotFound => 'Proyecto no encontrado';

  @override
  String get previousRow => 'Anterior';

  @override
  String get nextRow => 'Siguiente';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteProject => 'Eliminar Proyecto';

  @override
  String deleteProjectConfirm(Object name) {
    return '¿Estás seguro de que quieres eliminar \'$name\'?';
  }

  @override
  String get goToRow => 'Ir a Fila';

  @override
  String get cancel => 'Cancelar';

  @override
  String get rowLabel => 'Fila';

  @override
  String get importImage => 'Importar Imagen';

  @override
  String get importImageDescription =>
      'Selecciona una imagen PNG o JPG de un patrón de pixel art o punto cruz';

  @override
  String get selectImage => 'Seleccionar Imagen';

  @override
  String get dimensionsImage => 'Imagen';

  @override
  String get stitchesWide => 'Puntos ancho';

  @override
  String get stitchesHigh => 'Puntos alto';

  @override
  String get totalStitches => 'Puntos';

  @override
  String maxStitchesExceeded(Object max) {
    return 'El máximo es $max puntos';
  }

  @override
  String get previewPattern => 'Vista Previa';

  @override
  String get processing => 'Procesando…';

  @override
  String get patternPreview => 'Vista Previa del Patrón';

  @override
  String get dimensions => 'Dimensiones';

  @override
  String detectedColors(Object count) {
    return 'Colores ($count)';
  }

  @override
  String get confirmImport => 'Importar Patrón';

  @override
  String get imageFormatError =>
      'Formato no compatible. Selecciona un archivo PNG o JPG.';

  @override
  String get invalidImageDimensions => 'Dimensiones de imagen inválidas.';

  @override
  String get invalidStitchCount => 'Cantidad de puntos inválida.';

  @override
  String get corruptedImage => 'El archivo de imagen parece estar corrupto.';

  @override
  String importErrorDetail(Object error) {
    return 'Error al importar el patrón: $error';
  }

  @override
  String errorOccurred(Object error) {
    return 'Algo salió mal: $error';
  }

  @override
  String get noPatternData => 'Sin datos de patrón';

  @override
  String get filePathError => 'No se pudo acceder al archivo seleccionado.';

  @override
  String rowCount(Object current, Object total) {
    return '$current/$total filas';
  }

  @override
  String get changeColor => 'Cambiar';

  @override
  String get yarnColors => 'Colores de estambre';

  @override
  String get projectName => 'Nombre del proyecto';

  @override
  String get rows => 'filas';

  @override
  String get editProject => 'Editar Proyecto';

  @override
  String get save => 'Guardar';

  @override
  String get usedColors => 'Colores del Patrón';

  @override
  String get menuMyPatterns => 'Mis Patrones';

  @override
  String get menuMorePatterns => '+ Patrones';

  @override
  String get menuSupport => 'Apoyar';

  @override
  String get menuSuggest => 'Sugerir';

  @override
  String get morePatternsTitle => '+ Patrones';

  @override
  String get morePatternsDescription =>
      'Puedes importar tus propios patrones de pixel art o comprar listos para usar.';

  @override
  String get morePatternsHowToUpload =>
      'Para importar un patrón, toca el botón + en la pantalla principal y selecciona una imagen o archivo de texto.';

  @override
  String get morePatternsVisitKofi => 'Visitar Ko-fi';

  @override
  String get supportTitle => 'Sobre Pixel Crochet';

  @override
  String get supportDescription =>
      'Pixel Crochet es un proyecto personal hecho con amor y dedicación. Cada patrón está diseñado para alegrar tus proyectos de ganchillo.';

  @override
  String get supportDonate => 'Apoyar en Ko-fi';

  @override
  String get suggestTitle => 'Sugerir';

  @override
  String get suggestNameLabel => 'Tu Nombre';

  @override
  String get suggestNameHint => 'Ingresa tu nombre';

  @override
  String get suggestMessageLabel => 'Tu Sugerencia';

  @override
  String get suggestMessageHint => 'Cuéntanos qué te gustaría ver...';

  @override
  String get suggestSend => 'Enviar';

  @override
  String get suggestSucces => '¡Gracias! Tu sugerencia ha sido enviada.';

  @override
  String get suggestValidationName => 'Por favor, ingresa tu nombre';

  @override
  String get suggestValidationMessage => 'Por favor, ingresa tu sugerencia';
}
