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
  String importErrorDetail(Object error) {
    return 'Error importing pattern: $error';
  }

  @override
  String errorOccurred(Object error) {
    return 'Something went wrong: $error';
  }

  @override
  String get noPatternData => 'No pattern data';

  @override
  String get filePathError => 'Could not resolve the selected file.';

  @override
  String rowCount(Object current, Object total) {
    return '$current/$total rows';
  }

  @override
  String get changeColor => 'Change';

  @override
  String get yarnColors => 'Yarn colors';

  @override
  String get projectName => 'Project name';

  @override
  String get rows => 'rows';

  @override
  String get editProject => 'Edit Project';

  @override
  String get save => 'Save';

  @override
  String get usedColors => 'Pattern Colors';

  @override
  String get menuMyPatterns => 'My Patterns';

  @override
  String get menuMorePatterns => 'More Patterns';

  @override
  String get menuSupport => 'Support';

  @override
  String get menuSuggest => 'Suggest';

  @override
  String get morePatternsTitle => 'More Patterns';

  @override
  String get morePatternsDescription =>
      'You can import your own pixel art patterns or purchase ready-made ones.';

  @override
  String get morePatternsHowToUpload =>
      'To import a pattern, tap the + button on the home screen and select an image or text file.';

  @override
  String get morePatternsVisitKofi => 'Visit Ko-fi Shop';

  @override
  String get morePatternsKofiUrl => 'https://ko-fi.com/pixel_crochet/shop';

  @override
  String get supportTitle => 'About Pixel Crochet';

  @override
  String get supportDescription =>
      'Pixel Crochet is an independent, free project. If you find it useful and want to help me continue developing it, you can support the project on Ko-fi.\n\nYour support helps me maintain the app and devote time to creating new features and patterns.\n\nYou can also help simply by sharing Pixel Crochet with someone who crochets. 💜';

  @override
  String get supportDonate => 'Support on Ko-fi';

  @override
  String get supportKofiUrl => 'https://ko-fi.com/pixel_crochet';

  @override
  String get suggestTitle => 'Suggest';

  @override
  String get suggestNameLabel => 'Your Name';

  @override
  String get suggestNameHint => 'Enter your name';

  @override
  String get suggestMessageLabel => 'Your Suggestion';

  @override
  String get suggestMessageHint => 'Tell us what you\'d like to see...';

  @override
  String get suggestSend => 'Send';

  @override
  String get suggestSuccess => 'Thank you! Your suggestion has been sent.';

  @override
  String get suggestValidationName => 'Please enter your name';

  @override
  String get suggestValidationMessage => 'Please enter your suggestion';

  @override
  String get openUrlMessage => 'Could not open the link';

  @override
  String get suggestEmail => 'camila.arancibia@proton.me';

  @override
  String get suggestSubjectLabel => 'Subject';

  @override
  String get suggestSubjectDefault => 'Pixel Crochet - Suggestion';
}
