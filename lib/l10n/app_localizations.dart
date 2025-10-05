import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_bs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_it.dart';
import 'app_localizations_mk.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('bg'),
    Locale('bs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hr'),
    Locale('hu'),
    Locale('it'),
    Locale('mk'),
    Locale('ro'),
    Locale('sl'),
    Locale('sr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Karolina'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbs;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @fats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fats;

  /// No description provided for @setYourGoals.
  ///
  /// In en, this message translates to:
  /// **'Set Your Goals'**
  String get setYourGoals;

  /// No description provided for @autoGenerate.
  ///
  /// In en, this message translates to:
  /// **'Auto Generate'**
  String get autoGenerate;

  /// No description provided for @autoGenerateDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically generate goals using expert nutritional algorithms'**
  String get autoGenerateDescription;

  /// No description provided for @noFoodLogged.
  ///
  /// In en, this message translates to:
  /// **'No food logged'**
  String get noFoodLogged;

  /// No description provided for @tapPlusToTrack.
  ///
  /// In en, this message translates to:
  /// **'Tap + to track your progress and achieve your goals'**
  String get tapPlusToTrack;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing food...'**
  String get analyzing;

  /// No description provided for @achievedGoal.
  ///
  /// In en, this message translates to:
  /// **'You have achieved {percent}% of your goal!'**
  String achievedGoal(int percent);

  /// No description provided for @database.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Log Workout'**
  String get workout;

  /// No description provided for @scanFood.
  ///
  /// In en, this message translates to:
  /// **'Scan Food'**
  String get scanFood;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @consistencyBuildsHealth.
  ///
  /// In en, this message translates to:
  /// **'Consistency builds health'**
  String get consistencyBuildsHealth;

  /// No description provided for @healthHabitsDescription.
  ///
  /// In en, this message translates to:
  /// **'To hit your goals and keep the weight, set a routine and make a healthy habits. Challenge your and work on it every day.'**
  String get healthHabitsDescription;

  /// No description provided for @positiveHealthEffects.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see positive effects\non your health soon'**
  String get positiveHealthEffects;

  /// No description provided for @healthBenefits.
  ///
  /// In en, this message translates to:
  /// **'Reduced risk of diabetes, lower blood\npressure, improved cholesterol levels'**
  String get healthBenefits;

  /// No description provided for @enterReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code'**
  String get enterReferralCode;

  /// No description provided for @notRequired.
  ///
  /// In en, this message translates to:
  /// **'(not required)'**
  String get notRequired;

  /// No description provided for @influencerCode.
  ///
  /// In en, this message translates to:
  /// **'Influencer Code'**
  String get influencerCode;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @generatingYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Generating your\ncustom plan'**
  String get generatingYourPlan;

  /// No description provided for @preparingFor.
  ///
  /// In en, this message translates to:
  /// **'Preparing for'**
  String get preparingFor;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @startTrackingToday.
  ///
  /// In en, this message translates to:
  /// **'Start tracking with\nKalorina today.'**
  String get startTrackingToday;

  /// No description provided for @photoYourMeal.
  ///
  /// In en, this message translates to:
  /// **'JUST PHOTO\nYOUR MEAL'**
  String get photoYourMeal;

  /// No description provided for @photoYourMealDesc.
  ///
  /// In en, this message translates to:
  /// **'Simply take a photo of your meal and automatically get calorie information'**
  String get photoYourMealDesc;

  /// No description provided for @totalCalories.
  ///
  /// In en, this message translates to:
  /// **'CONTROL\nCALORIES EFFORTLESSLY'**
  String get totalCalories;

  /// No description provided for @controlCaloriesEffortlessly.
  ///
  /// In en, this message translates to:
  /// **'Track calories without stress and achieve your goals easier than ever'**
  String get controlCaloriesEffortlessly;

  /// No description provided for @achieveGoalsFaster.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVE GOALS FASTER\nTHAN EVER'**
  String get achieveGoalsFaster;

  /// No description provided for @achieveGoalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Our AI technology will guide you step by step to your goals'**
  String get achieveGoalsDesc;

  /// No description provided for @notificationReminder.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you before\nyour free trial ends.'**
  String get notificationReminder;

  /// No description provided for @freeTrialInfo.
  ///
  /// In en, this message translates to:
  /// **'Try for €0.00 - No charge if you cancel on\ntime. Cancel at any time.'**
  String get freeTrialInfo;

  /// No description provided for @tryForFree.
  ///
  /// In en, this message translates to:
  /// **'Try for FREE'**
  String get tryForFree;

  /// No description provided for @pricingTitle.
  ///
  /// In en, this message translates to:
  /// **'3 days free, then €39.99\nper year.'**
  String get pricingTitle;

  /// No description provided for @day1.
  ///
  /// In en, this message translates to:
  /// **'Day 1'**
  String get day1;

  /// No description provided for @day1Title.
  ///
  /// In en, this message translates to:
  /// **'Unlock Kalorina Pro'**
  String get day1Title;

  /// No description provided for @day1Description.
  ///
  /// In en, this message translates to:
  /// **'Unlock Kalorina Pro and explore everything.'**
  String get day1Description;

  /// No description provided for @day2.
  ///
  /// In en, this message translates to:
  /// **'Day 2'**
  String get day2;

  /// No description provided for @day2Title.
  ///
  /// In en, this message translates to:
  /// **'Friendly Reminder'**
  String get day2Title;

  /// No description provided for @day2Description.
  ///
  /// In en, this message translates to:
  /// **'Get a friendly reminder before your trial ends.'**
  String get day2Description;

  /// No description provided for @day3.
  ///
  /// In en, this message translates to:
  /// **'Day 3'**
  String get day3;

  /// No description provided for @day3Title.
  ///
  /// In en, this message translates to:
  /// **'Continue with Plan'**
  String get day3Title;

  /// No description provided for @day3Description.
  ///
  /// In en, this message translates to:
  /// **'Continue with your chosen plan.'**
  String get day3Description;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly - 3 Day Free Trial'**
  String get yearlyPlan;

  /// No description provided for @yearlyPrice.
  ///
  /// In en, this message translates to:
  /// **'€2.91 /mo'**
  String get yearlyPrice;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly - No Free Trial'**
  String get monthlyPlan;

  /// No description provided for @startTrialButton.
  ///
  /// In en, this message translates to:
  /// **'Start My 3-Day Trial For €0.00'**
  String get startTrialButton;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel at any time'**
  String get cancelAnytime;

  /// No description provided for @smarterWayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your smarter way to track\nwhat you eat starts here'**
  String get smarterWayTitle;

  /// No description provided for @noCalorieMath.
  ///
  /// In en, this message translates to:
  /// **'No more calorie math'**
  String get noCalorieMath;

  /// No description provided for @noCalorieMathDesc.
  ///
  /// In en, this message translates to:
  /// **'We do the numbers, you enjoy the food.'**
  String get noCalorieMathDesc;

  /// No description provided for @scanTrackDone.
  ///
  /// In en, this message translates to:
  /// **'Scan. Track. Done'**
  String get scanTrackDone;

  /// No description provided for @scanTrackDoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Logging food takes seconds.'**
  String get scanTrackDoneDesc;

  /// No description provided for @stayOnTopEffortlessly.
  ///
  /// In en, this message translates to:
  /// **'Stay on top effortlessly'**
  String get stayOnTopEffortlessly;

  /// No description provided for @stayOnTopEffortlesslyDesc.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders keep you consistent.'**
  String get stayOnTopEffortlesslyDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hrvatski.
  ///
  /// In en, this message translates to:
  /// **'Hrvatski'**
  String get hrvatski;

  /// No description provided for @srpski.
  ///
  /// In en, this message translates to:
  /// **'Srpski'**
  String get srpski;

  /// No description provided for @bosanski.
  ///
  /// In en, this message translates to:
  /// **'Bosanski'**
  String get bosanski;

  /// No description provided for @slovenscina.
  ///
  /// In en, this message translates to:
  /// **'Slovenščina'**
  String get slovenscina;

  /// No description provided for @crnogorski.
  ///
  /// In en, this message translates to:
  /// **'Crnogorski'**
  String get crnogorski;

  /// No description provided for @makedonski.
  ///
  /// In en, this message translates to:
  /// **'Македонски'**
  String get makedonski;

  /// No description provided for @bulgarski.
  ///
  /// In en, this message translates to:
  /// **'Български'**
  String get bulgarski;

  /// No description provided for @romana.
  ///
  /// In en, this message translates to:
  /// **'Română'**
  String get romana;

  /// No description provided for @magyar.
  ///
  /// In en, this message translates to:
  /// **'Magyar'**
  String get magyar;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @wantToSignInLater.
  ///
  /// In en, this message translates to:
  /// **'Want to sign in later? '**
  String get wantToSignInLater;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @byContinuingAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our\nTerms of Service and Privacy Policy'**
  String get byContinuingAgree;

  /// No description provided for @haveYouCountedCalories.
  ///
  /// In en, this message translates to:
  /// **'Have you counted\ncalories before?'**
  String get haveYouCountedCalories;

  /// No description provided for @triedButStopped.
  ///
  /// In en, this message translates to:
  /// **'I\'ve tried but stopped.'**
  String get triedButStopped;

  /// No description provided for @neverSeemComplex.
  ///
  /// In en, this message translates to:
  /// **'Never. It seems complex.'**
  String get neverSeemComplex;

  /// No description provided for @yesStillDoing.
  ///
  /// In en, this message translates to:
  /// **'Yes, and I\'m still doing it.'**
  String get yesStillDoing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bg',
    'bs',
    'de',
    'en',
    'es',
    'fr',
    'hr',
    'hu',
    'it',
    'mk',
    'ro',
    'sl',
    'sr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'bs':
      return AppLocalizationsBs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'it':
      return AppLocalizationsIt();
    case 'mk':
      return AppLocalizationsMk();
    case 'ro':
      return AppLocalizationsRo();
    case 'sl':
      return AppLocalizationsSl();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
