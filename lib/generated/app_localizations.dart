import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pixel Crochet'**
  String get appTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pixel Crochet'**
  String get homeWelcome;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'Handmade crochet with love'**
  String get homeDescription;

  /// No description provided for @importPattern.
  ///
  /// In en, this message translates to:
  /// **'Import Pattern'**
  String get importPattern;

  /// No description provided for @importPatternDescription.
  ///
  /// In en, this message translates to:
  /// **'Import a crochet pattern'**
  String get importPatternDescription;

  /// No description provided for @importPatternHint.
  ///
  /// In en, this message translates to:
  /// **'Select a .txt file or paste your pattern text'**
  String get importPatternHint;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @pastePattern.
  ///
  /// In en, this message translates to:
  /// **'Paste pattern text'**
  String get pastePattern;

  /// No description provided for @pastePatternHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your pattern text here...'**
  String get pastePatternHint;

  /// No description provided for @importText.
  ///
  /// In en, this message translates to:
  /// **'Import Pattern'**
  String get importText;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @projectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get projectNotFound;

  /// No description provided for @previousRow.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousRow;

  /// No description provided for @nextRow.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextRow;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get deleteProject;

  /// No description provided for @deleteProjectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'?'**
  String deleteProjectConfirm(Object name);

  /// No description provided for @goToRow.
  ///
  /// In en, this message translates to:
  /// **'Go to Row'**
  String get goToRow;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @rowLabel.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get rowLabel;

  /// No description provided for @importImage.
  ///
  /// In en, this message translates to:
  /// **'Import Image'**
  String get importImage;

  /// No description provided for @importImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a PNG or JPG image of a pixel art or cross-stitch pattern'**
  String get importImageDescription;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @dimensionsImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get dimensionsImage;

  /// No description provided for @stitchesWide.
  ///
  /// In en, this message translates to:
  /// **'Stitches wide'**
  String get stitchesWide;

  /// No description provided for @stitchesHigh.
  ///
  /// In en, this message translates to:
  /// **'Stitches high'**
  String get stitchesHigh;

  /// No description provided for @totalStitches.
  ///
  /// In en, this message translates to:
  /// **'Stitches'**
  String get totalStitches;

  /// No description provided for @maxStitchesExceeded.
  ///
  /// In en, this message translates to:
  /// **'Maximum is {max} stitches'**
  String maxStitchesExceeded(Object max);

  /// No description provided for @previewPattern.
  ///
  /// In en, this message translates to:
  /// **'Preview Pattern'**
  String get previewPattern;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @patternPreview.
  ///
  /// In en, this message translates to:
  /// **'Pattern Preview'**
  String get patternPreview;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @detectedColors.
  ///
  /// In en, this message translates to:
  /// **'Colors ({count})'**
  String detectedColors(Object count);

  /// No description provided for @confirmImport.
  ///
  /// In en, this message translates to:
  /// **'Import Pattern'**
  String get confirmImport;

  /// No description provided for @imageFormatError.
  ///
  /// In en, this message translates to:
  /// **'Unsupported format. Please select a PNG or JPG file.'**
  String get imageFormatError;

  /// No description provided for @invalidImageDimensions.
  ///
  /// In en, this message translates to:
  /// **'Invalid image dimensions.'**
  String get invalidImageDimensions;

  /// No description provided for @invalidStitchCount.
  ///
  /// In en, this message translates to:
  /// **'Invalid stitch count.'**
  String get invalidStitchCount;

  /// No description provided for @corruptedImage.
  ///
  /// In en, this message translates to:
  /// **'The image file appears to be corrupted.'**
  String get corruptedImage;

  /// No description provided for @importErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error importing pattern: {error}'**
  String importErrorDetail(Object error);

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @noPatternData.
  ///
  /// In en, this message translates to:
  /// **'No pattern data'**
  String get noPatternData;

  /// No description provided for @filePathError.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve the selected file.'**
  String get filePathError;

  /// No description provided for @rowCount.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total} rows'**
  String rowCount(Object current, Object total);

  /// No description provided for @changeColor.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeColor;

  /// No description provided for @yarnColors.
  ///
  /// In en, this message translates to:
  /// **'Yarn colors'**
  String get yarnColors;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @rows.
  ///
  /// In en, this message translates to:
  /// **'rows'**
  String get rows;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProject;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @usedColors.
  ///
  /// In en, this message translates to:
  /// **'Pattern Colors'**
  String get usedColors;

  /// No description provided for @menuMyPatterns.
  ///
  /// In en, this message translates to:
  /// **'My Patterns'**
  String get menuMyPatterns;

  /// No description provided for @menuMorePatterns.
  ///
  /// In en, this message translates to:
  /// **'More Patterns'**
  String get menuMorePatterns;

  /// No description provided for @menuSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get menuSupport;

  /// No description provided for @menuSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest'**
  String get menuSuggest;

  /// No description provided for @morePatternsTitle.
  ///
  /// In en, this message translates to:
  /// **'More Patterns'**
  String get morePatternsTitle;

  /// No description provided for @morePatternsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can import your own pixel art patterns or purchase ready-made ones.'**
  String get morePatternsDescription;

  /// No description provided for @morePatternsHowToUpload.
  ///
  /// In en, this message translates to:
  /// **'To import a pattern, tap the + button on the home screen and select an image or text file.'**
  String get morePatternsHowToUpload;

  /// No description provided for @morePatternsVisitKofi.
  ///
  /// In en, this message translates to:
  /// **'Visit Ko-fi Shop'**
  String get morePatternsVisitKofi;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'About Pixel Crochet'**
  String get supportTitle;

  /// No description provided for @supportDescription.
  ///
  /// In en, this message translates to:
  /// **'Pixel Crochet is a personal project made with love and dedication. Every pattern is designed to bring joy to your crochet projects.'**
  String get supportDescription;

  /// No description provided for @supportDonate.
  ///
  /// In en, this message translates to:
  /// **'Support on Ko-fi'**
  String get supportDonate;

  /// No description provided for @suggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggest'**
  String get suggestTitle;

  /// No description provided for @suggestNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get suggestNameLabel;

  /// No description provided for @suggestNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get suggestNameHint;

  /// No description provided for @suggestMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Suggestion'**
  String get suggestMessageLabel;

  /// No description provided for @suggestMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you\'d like to see...'**
  String get suggestMessageHint;

  /// No description provided for @suggestSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get suggestSend;

  /// No description provided for @suggestSucces.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your suggestion has been sent.'**
  String get suggestSucces;

  /// No description provided for @suggestValidationName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get suggestValidationName;

  /// No description provided for @suggestValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your suggestion'**
  String get suggestValidationMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
