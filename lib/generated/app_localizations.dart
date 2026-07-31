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

  /// No description provided for @imageDimensionsExceeded.
  ///
  /// In en, this message translates to:
  /// **'Image dimensions exceed {max}px.'**
  String imageDimensionsExceeded(Object max);

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Error importing pattern'**
  String get importError;
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
