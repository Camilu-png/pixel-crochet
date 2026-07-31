// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pixel Crochet';

  @override
  String get homeWelcome => 'Welcome to Pixel Crochet';

  @override
  String get homeDescription => 'Handmade crochet with love';

  @override
  String get importPattern => 'Import Pattern';

  @override
  String get importPatternDescription => 'Import a crochet pattern';

  @override
  String get importPatternHint =>
      'Select a .txt file or paste your pattern text';

  @override
  String get selectFile => 'Select File';

  @override
  String get or => 'or';

  @override
  String get pastePattern => 'Paste pattern text';

  @override
  String get pastePatternHint => 'Paste your pattern text here...';

  @override
  String get importText => 'Import Pattern';

  @override
  String get project => 'Project';

  @override
  String get projectNotFound => 'Project not found';

  @override
  String get previousRow => 'Previous';

  @override
  String get nextRow => 'Next';

  @override
  String get delete => 'Delete';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String deleteProjectConfirm(Object name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String get goToRow => 'Go to Row';

  @override
  String get cancel => 'Cancel';

  @override
  String get rowLabel => 'Row';

  @override
  String get importImage => 'Import Image';

  @override
  String get importImageDescription =>
      'Select a PNG or JPG image of a pixel art or cross-stitch pattern';

  @override
  String get selectImage => 'Select Image';

  @override
  String get dimensionsImage => 'Image';

  @override
  String get stitchesWide => 'Stitches wide';

  @override
  String get stitchesHigh => 'Stitches high';

  @override
  String get totalStitches => 'Stitches';

  @override
  String maxStitchesExceeded(Object max) {
    return 'Maximum is $max stitches';
  }

  @override
  String get previewPattern => 'Preview Pattern';

  @override
  String get processing => 'Processing…';

  @override
  String get patternPreview => 'Pattern Preview';

  @override
  String get dimensions => 'Dimensions';

  @override
  String detectedColors(Object count) {
    return 'Colors ($count)';
  }

  @override
  String get confirmImport => 'Import Pattern';

  @override
  String get imageFormatError =>
      'Unsupported format. Please select a PNG or JPG file.';

  @override
  String get invalidImageDimensions => 'Invalid image dimensions.';

  @override
  String get invalidStitchCount => 'Invalid stitch count.';

  @override
  String get corruptedImage => 'The image file appears to be corrupted.';

  @override
  String imageDimensionsExceeded(Object max) {
    return 'Image dimensions exceed ${max}px.';
  }

  @override
  String get importError => 'Error importing pattern';
}
