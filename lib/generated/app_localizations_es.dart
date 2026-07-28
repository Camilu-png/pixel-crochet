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
  String get homeCallToAction => 'Explora nuestra colección';

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
}
