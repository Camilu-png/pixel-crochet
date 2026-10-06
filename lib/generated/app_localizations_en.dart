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
  String get imageTooLarge =>
      'The image is too large. Please use a smaller image.';

  @override
  String importErrorDetail(Object error) {
    return 'Error importing pattern: $error';
  }

  @override
  String errorOccurred(Object error) {
    return 'Something went wrong: $error';
  }

  @override
  String saveError(Object error) {
    return 'Could not save changes: $error';
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
  String get menuAccount => 'Account & backup';

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
  String get morePatternsFreeTitle => 'Free patterns';

  @override
  String get morePatternsFreeDescription =>
      'Practice with these patterns before browsing the Ko-fi shop.';

  @override
  String get freePatternBlueGuyTitle => 'Blue Guy';

  @override
  String get freePatternBlueGuyDescription =>
      'A cheerful 32 × 32 pixel character.';

  @override
  String get freePatternButterflyTitle => 'Yellow Butterfly';

  @override
  String get freePatternButterflyDescription =>
      'A detailed butterfly tapestry pattern, 82 × 213 stitches.';

  @override
  String get freePatternUse => 'Add to my projects';

  @override
  String get freePatternAdded => 'Pattern added to your projects.';

  @override
  String freePatternAddError(Object error) {
    return 'Could not add this pattern: $error';
  }

  @override
  String get freePatternAttribution => 'Created by Camilú · MIT License';

  @override
  String get morePatternsPaidTitle => 'Ready-made patterns on Ko-fi';

  @override
  String get morePatternsHowToUpload =>
      'To import a pattern, tap the + button on the home screen and select an image or text file.';

  @override
  String get morePatternsVisitKofi => 'Visit Ko-fi Shop';

  @override
  String get morePatternsKofiUrl => 'https://ko-fi.com/pixel_crochet/shop';

  @override
  String get productMariposaTitle => 'Mariposa Cardigan — Size L';

  @override
  String get productMariposaDesc =>
      'Become a beautiful forest butterfly with this lovely cardigan.';

  @override
  String get productSalchipletoTitle => 'Salchipleto';

  @override
  String get productSalchipletoDesc =>
      'A delicious friend that is always by your side.';

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
  String get suggestEmail => 'mypixelcrochet@gmail.com';

  @override
  String get suggestSubjectLabel => 'Subject';

  @override
  String get suggestSubjectDefault => 'Pixel Crochet - Suggestion';

  @override
  String get appTitleTagline => 'Made stitch by stitch';

  @override
  String get welcomeTitle => 'Welcome to Pixel Crochet';

  @override
  String get welcomeSubtitle =>
      'Turn your favorite images into tapestry crochet patterns and follow them row by row.';

  @override
  String get importFirstPattern => 'Import my first pattern';

  @override
  String get browsePatterns => 'Browse Ko-fi patterns';

  @override
  String get hintPng => 'PNG image';

  @override
  String get hintTxt => '.txt file';

  @override
  String get hintKofi => 'Ko-fi patterns';

  @override
  String rowCounter(Object current, Object percent, Object total) {
    return 'Row $current/$total · $percent%';
  }

  @override
  String get optionsLabel => 'Options';

  @override
  String get projectBackup => 'Project backup';

  @override
  String get exportLocalBackup => 'Export local backup';

  @override
  String get importLocalBackup => 'Import local backup';

  @override
  String get backupExported => 'Your backup file was downloaded.';

  @override
  String backupImported(int count) {
    return 'Imported $count projects without replacing existing work.';
  }

  @override
  String get backupImportNoNewProjects =>
      'All projects in this backup are already in your library.';

  @override
  String backupImportConfirm(int count) {
    return 'Add $count projects from this backup? Existing projects will not be overwritten.';
  }

  @override
  String backupImportError(Object error) {
    return 'Could not import this backup: $error';
  }

  @override
  String backupExportError(Object error) {
    return 'Could not export your backup: $error';
  }

  @override
  String get backupImportInvalidFile =>
      'Choose a valid Pixel Crochet JSON backup file.';

  @override
  String get accountCloudUnavailableTitle => 'Cloud backup unavailable';

  @override
  String get accountCloudUnavailableBody =>
      'Your projects are still saved on this device. Cloud access is not configured or is temporarily unavailable.';

  @override
  String get accountGuestTitle => 'Using Pixel Crochet as a guest';

  @override
  String get accountGuestDescription =>
      'Your projects stay saved on this device. Sign in with Google to back them up and access them on another device.';

  @override
  String get accountSignInGoogle => 'Sign in with Google';

  @override
  String get accountSignInError =>
      'Could not start Google sign-in. Check the Supabase Google provider and redirect URLs.';

  @override
  String get accountSignedInTitle => 'Google account connected';

  @override
  String accountSignedInAs(Object email) {
    return 'Signed in as $email';
  }

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignOutError =>
      'Could not sign out. Your local projects are unchanged.';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncLocalOnly => 'Projects are saved on this device only.';

  @override
  String get syncPending => 'Syncing projects…';

  @override
  String get migrationRequiredLabel =>
      'Your local projects have not been uploaded.';

  @override
  String get migrationDialogTitle => 'Back up local projects?';

  @override
  String migrationDialogBody(int count) {
    return 'This will upload $count projects from this device to your Google account. Their local copies will be kept. Continue?';
  }

  @override
  String get migrationApprove => 'Back up projects';

  @override
  String get migrationCancel => 'Keep using locally';

  @override
  String get migrationStillRequired =>
      'Your local projects are still only on this device.';

  @override
  String get syncComplete => 'Cloud backup is up to date.';

  @override
  String get syncConflict =>
      'Both versions were kept. Review the local copy before deleting either version.';

  @override
  String get syncUnavailable =>
      'Cloud sync is unavailable. Your local projects are unchanged.';

  @override
  String get backupCancel => 'Cancel';

  @override
  String get backupConfirm => 'Add projects';

  @override
  String get deletePatternTitle => 'Delete pattern?';

  @override
  String deletePatternBody(Object name) {
    return 'Are you sure you want to delete \'$name\'? This cannot be undone.';
  }

  @override
  String get yourName => 'Your name';

  @override
  String get yourSuggestion => 'Your suggestion';

  @override
  String get suggestSubtitle =>
      'Tell us what you\'d love to see next — every idea is read and appreciated.';

  @override
  String get requiredField => 'This field is required';

  @override
  String get tooShort => 'Please write a little more (at least 10 characters)';

  @override
  String get supportKeepApp => 'Keep the app alive';

  @override
  String get supportNewPatterns => 'New patterns';

  @override
  String get supportShare => 'Share the app';

  @override
  String get morePatternsPriceBadge => 'Ready-made';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get onboardingGotIt => 'Got it';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingImportTitle => 'Import a pattern';

  @override
  String get onboardingImportDesc =>
      'Upload a .txt crochet pattern or paste its text. Each row looks like this: \"R1: 10 red, 5 white\" — a row number followed by the colors and stitch counts.';

  @override
  String get onboardingImportImageTitle => 'Turn an image into stitches';

  @override
  String get onboardingImportImageSelectDesc =>
      'Choose a PNG or JPG image with a design you like. It should be simple and use few colors. Make sure it is good quality before importing.';

  @override
  String get onboardingImportImageEditDesc =>
      'You can adjust the pattern name and the number of stitches it will have. Preview the pattern to see the detected colors. You can change them freely.';

  @override
  String get onboardingImportImageButtonTitle => 'Import from an image';

  @override
  String get onboardingImportImageButtonDesc =>
      'Tap \"Import Image\" to turn a picture into stitches. Upload a PNG or JPG image of your pixel art or cross-stitch pattern.';

  @override
  String get onboardingImportPasteTitle => 'Paste a pattern';

  @override
  String get onboardingImportPasteDesc =>
      'Paste your pattern text into the box below and tap \"Import Pattern\". Each row looks like: \"R1: 10 red, 5 white\" — a row number followed by the colors and stitch counts.';

  @override
  String get onboardingProjectDirectionTitle => 'Which way to read';

  @override
  String get onboardingProjectDirectionDesc =>
      'The arrow shows the direction to read each row, left-to-right or right-to-left. Reading left-to-right means you are now crocheting on the wrong (reverse) side of the fabric.';

  @override
  String get onboardingProjectBlocksTitle => 'Mark your progress';

  @override
  String get onboardingProjectBlocksDesc =>
      'Tap a color block to mark it as finished — it gets crossed out. Tap again to unmark it.';

  @override
  String get onboardingProjectProgressTitle => 'Track your progress';

  @override
  String get onboardingProjectProgressDesc =>
      'The bar and the percentage show how much of the pattern you have finished so far.';

  @override
  String get doubleKnitting => 'Double knitting';

  @override
  String get doubleKnittingRequiresTwoColors =>
      'Double knitting needs exactly 2 colors. Change the pattern colors to enable it.';

  @override
  String get doubleKnittingTurnedOff =>
      'Double knitting was turned off because the pattern no longer has exactly 2 colors.';
}
