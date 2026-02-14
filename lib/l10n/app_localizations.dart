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
  /// **'Kalorina'**
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
  /// **'calories'**
  String get calories;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
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

  /// No description provided for @generateYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Generate Your Plan'**
  String get generateYourPlan;

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

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creatingAccount;

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

  /// No description provided for @logStreak.
  ///
  /// In en, this message translates to:
  /// **'Log Streak'**
  String get logStreak;

  /// No description provided for @caloriesMoreToGo.
  ///
  /// In en, this message translates to:
  /// **'Calories to go!'**
  String get caloriesMoreToGo;

  /// No description provided for @todaysLunchTotals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s lunch totals'**
  String get todaysLunchTotals;

  /// No description provided for @mealTotals.
  ///
  /// In en, this message translates to:
  /// **'Meal totals'**
  String get mealTotals;

  /// No description provided for @consistencyMatters.
  ///
  /// In en, this message translates to:
  /// **'Consistency matters for achieving your goals!'**
  String get consistencyMatters;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @kalorina.
  ///
  /// In en, this message translates to:
  /// **'Kalorina'**
  String get kalorina;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @cardioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log runs, cycling, HIIT, or any endurance activity'**
  String get cardioSubtitle;

  /// No description provided for @weightTraining.
  ///
  /// In en, this message translates to:
  /// **'Weight Training'**
  String get weightTraining;

  /// No description provided for @weightTrainingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track gym sessions, sets, and strength exercises'**
  String get weightTrainingSubtitle;

  /// No description provided for @describeExercise.
  ///
  /// In en, this message translates to:
  /// **'Describe Exercise'**
  String get describeExercise;

  /// No description provided for @describeExerciseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let AI calculate calories burned'**
  String get describeExerciseSubtitle;

  /// No description provided for @directInput.
  ///
  /// In en, this message translates to:
  /// **'Direct Input'**
  String get directInput;

  /// No description provided for @directInputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manual entry of calories burned'**
  String get directInputSubtitle;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @myMeals.
  ///
  /// In en, this message translates to:
  /// **'My Meals'**
  String get myMeals;

  /// No description provided for @myMealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build a meal from your saved foods'**
  String get myMealsSubtitle;

  /// No description provided for @myFoods.
  ///
  /// In en, this message translates to:
  /// **'My Foods'**
  String get myFoods;

  /// No description provided for @myFoodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your own food database'**
  String get myFoodsSubtitle;

  /// No description provided for @savedScans.
  ///
  /// In en, this message translates to:
  /// **'Saved Scans'**
  String get savedScans;

  /// No description provided for @savedScansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find all previously saved foods'**
  String get savedScansSubtitle;

  /// No description provided for @directInputFood.
  ///
  /// In en, this message translates to:
  /// **'Direct Input'**
  String get directInputFood;

  /// No description provided for @directInputFoodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manual entry of calories and macronutrients'**
  String get directInputFoodSubtitle;

  /// No description provided for @howDoesItWork.
  ///
  /// In en, this message translates to:
  /// **'How does it work?'**
  String get howDoesItWork;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get longestStreak;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @successfulDay.
  ///
  /// In en, this message translates to:
  /// **'Successful day'**
  String get successfulDay;

  /// No description provided for @failedDay.
  ///
  /// In en, this message translates to:
  /// **'Failed day'**
  String get failedDay;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @failedToCreateStreak.
  ///
  /// In en, this message translates to:
  /// **'Failed to create streak'**
  String get failedToCreateStreak;

  /// No description provided for @streakUndoneFor.
  ///
  /// In en, this message translates to:
  /// **'Streak undone for'**
  String get streakUndoneFor;

  /// No description provided for @noStreakToUndoFor.
  ///
  /// In en, this message translates to:
  /// **'No streak to undo for'**
  String get noStreakToUndoFor;

  /// No description provided for @howDoesItWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'How does it work?'**
  String get howDoesItWorkTitle;

  /// No description provided for @howDoesItWorkDescription.
  ///
  /// In en, this message translates to:
  /// **'Every day, you can log your fire to reflect on whether you felt like you truly achieved what you wanted.'**
  String get howDoesItWorkDescription;

  /// No description provided for @successfulDescription.
  ///
  /// In en, this message translates to:
  /// **'Successful → You reached your daily goal or feel satisfied with your progress.'**
  String get successfulDescription;

  /// No description provided for @failedDescription.
  ///
  /// In en, this message translates to:
  /// **'Failed → You didn\'t meet your goal or the day didn\'t go as planned.'**
  String get failedDescription;

  /// No description provided for @streakExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your fires build streaks that show your consistency. The longer you log honestly, the clearer you\'ll see your real progress.'**
  String get streakExplanation;

  /// No description provided for @logExercise.
  ///
  /// In en, this message translates to:
  /// **'Log Exercise'**
  String get logExercise;

  /// No description provided for @weightTrainingTab.
  ///
  /// In en, this message translates to:
  /// **'Weight Training'**
  String get weightTrainingTab;

  /// No description provided for @describeTab.
  ///
  /// In en, this message translates to:
  /// **'Describe'**
  String get describeTab;

  /// No description provided for @directInputTab.
  ///
  /// In en, this message translates to:
  /// **'Direct Input'**
  String get directInputTab;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @fifteenMin.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get fifteenMin;

  /// No description provided for @thirtyMin.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get thirtyMin;

  /// No description provided for @fortyFiveMin.
  ///
  /// In en, this message translates to:
  /// **'45 min'**
  String get fortyFiveMin;

  /// No description provided for @sixtyMin.
  ///
  /// In en, this message translates to:
  /// **'60 min'**
  String get sixtyMin;

  /// No description provided for @logging.
  ///
  /// In en, this message translates to:
  /// **'Logging...'**
  String get logging;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @aiPowered.
  ///
  /// In en, this message translates to:
  /// **'AI Powered'**
  String get aiPowered;

  /// No description provided for @explainWorkoutPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Explain workout duration, effort, etc.'**
  String get explainWorkoutPlaceholder;

  /// No description provided for @workoutExample.
  ///
  /// In en, this message translates to:
  /// **'Example: \"Upper body session, 45 mins, medium effort\"'**
  String get workoutExample;

  /// No description provided for @estimating.
  ///
  /// In en, this message translates to:
  /// **'Estimating...'**
  String get estimating;

  /// No description provided for @aiEstimate.
  ///
  /// In en, this message translates to:
  /// **'AI Estimate'**
  String get aiEstimate;

  /// No description provided for @whyThisEstimate.
  ///
  /// In en, this message translates to:
  /// **'Why this estimate'**
  String get whyThisEstimate;

  /// No description provided for @typeCaloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Type in calories burned yourself'**
  String get typeCaloriesBurned;

  /// No description provided for @zeroPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get zeroPlaceholder;

  /// No description provided for @nearSprintingDescription.
  ///
  /// In en, this message translates to:
  /// **'Near sprinting, hard to sustain for long'**
  String get nearSprintingDescription;

  /// No description provided for @steadyRunDescription.
  ///
  /// In en, this message translates to:
  /// **'Steady run, manageable effort'**
  String get steadyRunDescription;

  /// No description provided for @briskWalkDescription.
  ///
  /// In en, this message translates to:
  /// **'Brisk walk, comfortable breathing'**
  String get briskWalkDescription;

  /// No description provided for @heavyWeightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Heavy weights, close to max effort'**
  String get heavyWeightsDescription;

  /// No description provided for @moderateWeightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Moderate weights, breaking a sweat'**
  String get moderateWeightsDescription;

  /// No description provided for @lightWeightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Light weights, no sweat'**
  String get lightWeightsDescription;

  /// No description provided for @logFood.
  ///
  /// In en, this message translates to:
  /// **'Log Food'**
  String get logFood;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchMeals.
  ///
  /// In en, this message translates to:
  /// **'Search meals...'**
  String get searchMeals;

  /// No description provided for @searchFoods.
  ///
  /// In en, this message translates to:
  /// **'Search foods...'**
  String get searchFoods;

  /// No description provided for @searchScannedMeals.
  ///
  /// In en, this message translates to:
  /// **'Search scanned meals...'**
  String get searchScannedMeals;

  /// No description provided for @chickenBr.
  ///
  /// In en, this message translates to:
  /// **'Chicken br'**
  String get chickenBr;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @noSuggestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No suggestions available'**
  String get noSuggestionsAvailable;

  /// No description provided for @noMealsSavedYet.
  ///
  /// In en, this message translates to:
  /// **'No meals saved yet'**
  String get noMealsSavedYet;

  /// No description provided for @noFoodsCreatedYet.
  ///
  /// In en, this message translates to:
  /// **'No foods created yet'**
  String get noFoodsCreatedYet;

  /// No description provided for @createFood.
  ///
  /// In en, this message translates to:
  /// **'Create Food'**
  String get createFood;

  /// No description provided for @yourSavedScansWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your saved scans will appear here'**
  String get yourSavedScansWillAppearHere;

  /// No description provided for @savedScansContentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Saved Scans content coming soon'**
  String get savedScansContentComingSoon;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @caloriesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'512'**
  String get caloriesPlaceholder;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @saveFood.
  ///
  /// In en, this message translates to:
  /// **'Save Food'**
  String get saveFood;

  /// No description provided for @createAMeal.
  ///
  /// In en, this message translates to:
  /// **'Create a Meal'**
  String get createAMeal;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @enterAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmountPlaceholder;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get name;

  /// No description provided for @enterIngredientName.
  ///
  /// In en, this message translates to:
  /// **'Enter ingredient name'**
  String get enterIngredientName;

  /// No description provided for @quantityUnit.
  ///
  /// In en, this message translates to:
  /// **'Quantity & Unit'**
  String get quantityUnit;

  /// No description provided for @amountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountPlaceholder;

  /// No description provided for @unitPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Unit (g, cup, tbsp)'**
  String get unitPlaceholder;

  /// No description provided for @nutritionOptional.
  ///
  /// In en, this message translates to:
  /// **'Nutrition (Optional)'**
  String get nutritionOptional;

  /// No description provided for @caloriesPlaceholder2.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesPlaceholder2;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @carbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsG;

  /// No description provided for @fatG.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatG;

  /// No description provided for @editIngredient.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get editIngredient;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @scannedMeal.
  ///
  /// In en, this message translates to:
  /// **'Scanned Meal'**
  String get scannedMeal;

  /// No description provided for @setName.
  ///
  /// In en, this message translates to:
  /// **'Set Name'**
  String get setName;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @dailyStepsGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Steps Goal'**
  String get dailyStepsGoal;

  /// No description provided for @addBurnedCaloriesToGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Burned Calories to Goal'**
  String get addBurnedCaloriesToGoal;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @manageYourProfileAndAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile and account settings'**
  String get manageYourProfileAndAccountSettings;

  /// No description provided for @healthTracking.
  ///
  /// In en, this message translates to:
  /// **'Health Tracking'**
  String get healthTracking;

  /// No description provided for @viewYourHealthConsistencyAndProgress.
  ///
  /// In en, this message translates to:
  /// **'View your health consistency and progress'**
  String get viewYourHealthConsistencyAndProgress;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @configureYourNotificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Configure your notification preferences'**
  String get configureYourNotificationPreferences;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersionAndInformation.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get appVersionAndInformation;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get steps;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @myWeight.
  ///
  /// In en, this message translates to:
  /// **'My Weight'**
  String get myWeight;

  /// No description provided for @logWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get logWeight;

  /// No description provided for @targetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get targetWeight;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @toTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'To target weight'**
  String get toTargetWeight;

  /// No description provided for @weightGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Goal Progress'**
  String get weightGoalProgress;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get thirtyDays;

  /// No description provided for @ninetyDays.
  ///
  /// In en, this message translates to:
  /// **'90 Days'**
  String get ninetyDays;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get sixMonths;

  /// No description provided for @oneYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get oneYear;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @avgDailyProgress.
  ///
  /// In en, this message translates to:
  /// **'Avg daily progress'**
  String get avgDailyProgress;

  /// No description provided for @avgDailyLost.
  ///
  /// In en, this message translates to:
  /// **'Avg daily lost'**
  String get avgDailyLost;

  /// No description provided for @avgDailyGained.
  ///
  /// In en, this message translates to:
  /// **'Avg daily gained'**
  String get avgDailyGained;

  /// No description provided for @addProgressPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Progress Photo'**
  String get addProgressPhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @progressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Progress Photos'**
  String get progressPhotos;

  /// No description provided for @seeProgress.
  ///
  /// In en, this message translates to:
  /// **'See progress'**
  String get seeProgress;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @stepsToday.
  ///
  /// In en, this message translates to:
  /// **'Steps Today'**
  String get stepsToday;

  /// No description provided for @tapToEnableHealthPermissions.
  ///
  /// In en, this message translates to:
  /// **'Tap to enable health permissions'**
  String get tapToEnableHealthPermissions;

  /// No description provided for @addBurnedCaloriesToDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Add burned calories to daily goal'**
  String get addBurnedCaloriesToDailyGoal;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned'**
  String get caloriesBurned;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @sinceLastWeighIn.
  ///
  /// In en, this message translates to:
  /// **'since last weigh in'**
  String get sinceLastWeighIn;

  /// No description provided for @kgPerDay.
  ///
  /// In en, this message translates to:
  /// **'kg/day'**
  String get kgPerDay;

  /// No description provided for @kgToGo.
  ///
  /// In en, this message translates to:
  /// **'kg to go'**
  String get kgToGo;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great Job'**
  String get greatJob;

  /// No description provided for @youGained.
  ///
  /// In en, this message translates to:
  /// **'You gained'**
  String get youGained;

  /// No description provided for @weighInDue.
  ///
  /// In en, this message translates to:
  /// **'Weigh-in due'**
  String get weighInDue;

  /// No description provided for @nextWeighIn.
  ///
  /// In en, this message translates to:
  /// **'Next weigh-in: {days}d'**
  String nextWeighIn(Object days);

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @rolloverLeftOverCalories.
  ///
  /// In en, this message translates to:
  /// **'Rollover up to 200 Left Over Calories From Yesterday'**
  String get rolloverLeftOverCalories;

  /// No description provided for @addBurnedCalories.
  ///
  /// In en, this message translates to:
  /// **'Add Burned Calories'**
  String get addBurnedCalories;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @adjustMacronutrients.
  ///
  /// In en, this message translates to:
  /// **'Adjust Macronutrients'**
  String get adjustMacronutrients;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountTitle;

  /// No description provided for @accountWillBePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account will be permanently deleted'**
  String get accountWillBePermanentlyDeleted;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// No description provided for @areYouSureYouWantToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogOut;

  /// No description provided for @recentlyUploaded.
  ///
  /// In en, this message translates to:
  /// **'Recently Uploaded'**
  String get recentlyUploaded;

  /// No description provided for @recentlyLogged.
  ///
  /// In en, this message translates to:
  /// **'Recently Logged'**
  String get recentlyLogged;

  /// No description provided for @cannotLogFutureStreak.
  ///
  /// In en, this message translates to:
  /// **'Can\'t Log Future Dates'**
  String get cannotLogFutureStreak;

  /// No description provided for @cannotLogFutureStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'You can only log streaks for today and past dates. Future dates will unlock as they arrive!'**
  String get cannotLogFutureStreakDescription;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day {count} Streak'**
  String dayStreak(int count);

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get keepGoing;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @whatWouldYouLikeToAchieve.
  ///
  /// In en, this message translates to:
  /// **'What would you like to achieve?'**
  String get whatWouldYouLikeToAchieve;

  /// No description provided for @stayMotivatedAndDisciplined.
  ///
  /// In en, this message translates to:
  /// **'Stay motivated and disciplined'**
  String get stayMotivatedAndDisciplined;

  /// No description provided for @feelBetterAboutYourBody.
  ///
  /// In en, this message translates to:
  /// **'Feel better about your body'**
  String get feelBetterAboutYourBody;

  /// No description provided for @improveHealthLongTerm.
  ///
  /// In en, this message translates to:
  /// **'Improve health long-term'**
  String get improveHealthLongTerm;

  /// No description provided for @increaseMoodAndEnergy.
  ///
  /// In en, this message translates to:
  /// **'Increase mood and energy'**
  String get increaseMoodAndEnergy;

  /// No description provided for @youHaveGreatPotential.
  ///
  /// In en, this message translates to:
  /// **'You have great potential to achieve your goal'**
  String get youHaveGreatPotential;

  /// No description provided for @yourJourneyToBetterHealth.
  ///
  /// In en, this message translates to:
  /// **'Your journey to better health starts now'**
  String get yourJourneyToBetterHealth;

  /// No description provided for @youTookFirstStepToHealthier.
  ///
  /// In en, this message translates to:
  /// **'You\'ve taken the first step towards a healthier you'**
  String get youTookFirstStepToHealthier;

  /// No description provided for @trackYourFoodAndExercise.
  ///
  /// In en, this message translates to:
  /// **'Track your food and exercise'**
  String get trackYourFoodAndExercise;

  /// No description provided for @focusOnNutrientDenseFoods.
  ///
  /// In en, this message translates to:
  /// **'Focus on nutrient-dense foods'**
  String get focusOnNutrientDenseFoods;

  /// No description provided for @maintainYourHealthyHabits.
  ///
  /// In en, this message translates to:
  /// **'Maintain your healthy habits'**
  String get maintainYourHealthyHabits;

  /// No description provided for @balanceCarbsProteinAndFats.
  ///
  /// In en, this message translates to:
  /// **'Balance carbs, protein and fats'**
  String get balanceCarbsProteinAndFats;

  /// No description provided for @stickToYourPersonalizedPlan.
  ///
  /// In en, this message translates to:
  /// **'Stick to your personalized plan'**
  String get stickToYourPersonalizedPlan;

  /// No description provided for @focusOnWholeUnprocessedFoods.
  ///
  /// In en, this message translates to:
  /// **'Focus on whole, unprocessed foods'**
  String get focusOnWholeUnprocessedFoods;

  /// No description provided for @followYourPersonalizedMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Follow your personalized meal plan'**
  String get followYourPersonalizedMealPlan;

  /// No description provided for @focusOnPortionControlAndNutrition.
  ///
  /// In en, this message translates to:
  /// **'Focus on portion control and nutrition'**
  String get focusOnPortionControlAndNutrition;

  /// No description provided for @followYourPersonalizedPlan.
  ///
  /// In en, this message translates to:
  /// **'Follow your personalized plan'**
  String get followYourPersonalizedPlan;

  /// No description provided for @stayConsistentSeeRealResults.
  ///
  /// In en, this message translates to:
  /// **'Stay consistent, see real results'**
  String get stayConsistentSeeRealResults;

  /// No description provided for @enableNotificationsForBetterResults.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications for better results'**
  String get enableNotificationsForBetterResults;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'(Recommended)'**
  String get recommended;

  /// No description provided for @kalorinaHelpsYouKeepTrack.
  ///
  /// In en, this message translates to:
  /// **'Kalorina helps you keep track — Get daily reminders'**
  String get kalorinaHelpsYouKeepTrack;

  /// No description provided for @dontAllow.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Allow'**
  String get dontAllow;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @countBurnedCaloriesTowardsGoal.
  ///
  /// In en, this message translates to:
  /// **'Count burned calories towards your daily goal?'**
  String get countBurnedCaloriesTowardsGoal;

  /// No description provided for @todaysGoal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal:'**
  String get todaysGoal;

  /// No description provided for @stepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps:'**
  String get stepsLabel;

  /// No description provided for @transferExtraCaloriesToNextDay.
  ///
  /// In en, this message translates to:
  /// **'Transfer extra calories to the next day?'**
  String get transferExtraCaloriesToNextDay;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @caloriesLeft.
  ///
  /// In en, this message translates to:
  /// **'Calories Left'**
  String get caloriesLeft;

  /// No description provided for @everydayLogFireReflect.
  ///
  /// In en, this message translates to:
  /// **'Every day, you can log your 🔥 to reflect on whether you truly achieved what you wanted. Your fires build streaks that show your consistency.'**
  String get everydayLogFireReflect;

  /// No description provided for @longLastingHealthEffects.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see long-lasting effects on your health'**
  String get longLastingHealthEffects;

  /// No description provided for @ninetyPercent.
  ///
  /// In en, this message translates to:
  /// **'90%'**
  String get ninetyPercent;

  /// No description provided for @usersStayConsistentMaintainWeight.
  ///
  /// In en, this message translates to:
  /// **' of users who stay consistent maintain their weight even '**
  String get usersStayConsistentMaintainWeight;

  /// No description provided for @twelveMonthsLater.
  ///
  /// In en, this message translates to:
  /// **'12 months later'**
  String get twelveMonthsLater;

  /// No description provided for @leaveUsReview.
  ///
  /// In en, this message translates to:
  /// **'Leave us a review'**
  String get leaveUsReview;

  /// No description provided for @joinOver10000People.
  ///
  /// In en, this message translates to:
  /// **'Join over 10,000\npeople just like you'**
  String get joinOver10000People;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @howItWorksUniqueApproach.
  ///
  /// In en, this message translates to:
  /// **'How Kalorina\'s unique\napproach works'**
  String get howItWorksUniqueApproach;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyze;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @heightAndWeight.
  ///
  /// In en, this message translates to:
  /// **'Height and Weight'**
  String get heightAndWeight;

  /// No description provided for @heightWeightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This information helps us personalize your daily caloric and nutritional goals.'**
  String get heightWeightSubtitle;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @whenWereYouBorn.
  ///
  /// In en, this message translates to:
  /// **'When were you born?'**
  String get whenWereYouBorn;

  /// No description provided for @birthDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will be taken into account when calculating your daily nutritional goals.'**
  String get birthDateSubtitle;

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthLabel;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @selectYourGender.
  ///
  /// In en, this message translates to:
  /// **'Select your Gender'**
  String get selectYourGender;

  /// No description provided for @genderSelectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Select the gender that matches your body\'s physiology for accurate calorie tracking'**
  String get genderSelectionInfo;

  /// No description provided for @maleGender.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get maleGender;

  /// No description provided for @femaleGender.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femaleGender;

  /// No description provided for @howManyWorkoutsPerWeek.
  ///
  /// In en, this message translates to:
  /// **'How many workouts do you do per week'**
  String get howManyWorkoutsPerWeek;

  /// No description provided for @selectBestOption.
  ///
  /// In en, this message translates to:
  /// **'Select the option that suits you best'**
  String get selectBestOption;

  /// No description provided for @noWorkouts.
  ///
  /// In en, this message translates to:
  /// **'I don\'t work out'**
  String get noWorkouts;

  /// No description provided for @occasionalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Occasional workouts'**
  String get occasionalWorkouts;

  /// No description provided for @severalWorkoutsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Several workouts weekly'**
  String get severalWorkoutsWeekly;

  /// No description provided for @dedicatedAthlete.
  ///
  /// In en, this message translates to:
  /// **'Dedicated athlete'**
  String get dedicatedAthlete;

  /// No description provided for @whereDidYouHearAboutUs.
  ///
  /// In en, this message translates to:
  /// **'Where did you hear about us?'**
  String get whereDidYouHearAboutUs;

  /// No description provided for @googlePlay.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get googlePlay;

  /// No description provided for @youtube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get youtube;

  /// No description provided for @tiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get tiktok;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @influencer.
  ///
  /// In en, this message translates to:
  /// **'Influencer'**
  String get influencer;

  /// No description provided for @friendsOrFamily.
  ///
  /// In en, this message translates to:
  /// **'Friends or Family'**
  String get friendsOrFamily;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @wellDoneBigStep.
  ///
  /// In en, this message translates to:
  /// **'Well done! You just took\na big step.'**
  String get wellDoneBigStep;

  /// No description provided for @calorieTrackingPart1.
  ///
  /// In en, this message translates to:
  /// **'Did you know that calorie tracking is a '**
  String get calorieTrackingPart1;

  /// No description provided for @scientificallyProvenMethod.
  ///
  /// In en, this message translates to:
  /// **'scientifically proven method'**
  String get scientificallyProvenMethod;

  /// No description provided for @calorieTrackingPart2.
  ///
  /// In en, this message translates to:
  /// **' to achieve your goals – and up to '**
  String get calorieTrackingPart2;

  /// No description provided for @twiceFaster.
  ///
  /// In en, this message translates to:
  /// **'twice as fast'**
  String get twiceFaster;

  /// No description provided for @calorieTrackingPart3.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get calorieTrackingPart3;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get yourProgress;

  /// No description provided for @withKalorina.
  ///
  /// In en, this message translates to:
  /// **'With Kalorina'**
  String get withKalorina;

  /// No description provided for @withoutKalorina.
  ///
  /// In en, this message translates to:
  /// **'Without Kalorina'**
  String get withoutKalorina;

  /// No description provided for @twiceMultiplier.
  ///
  /// In en, this message translates to:
  /// **'+2x'**
  String get twiceMultiplier;

  /// No description provided for @whatIsYourGoal.
  ///
  /// In en, this message translates to:
  /// **'What is your goal'**
  String get whatIsYourGoal;

  /// No description provided for @selectGoalThatSuitsYou.
  ///
  /// In en, this message translates to:
  /// **'Select the goal that suits you best'**
  String get selectGoalThatSuitsYou;

  /// No description provided for @loseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// No description provided for @maintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get maintainWeight;

  /// No description provided for @gainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain Weight'**
  String get gainWeight;

  /// No description provided for @howMuchWeightToLose.
  ///
  /// In en, this message translates to:
  /// **'How much weight do you want to lose?'**
  String get howMuchWeightToLose;

  /// No description provided for @howMuchWeightToGain.
  ///
  /// In en, this message translates to:
  /// **'How much weight do you want to gain?'**
  String get howMuchWeightToGain;

  /// No description provided for @whatIsDesiredWeight.
  ///
  /// In en, this message translates to:
  /// **'What is your desired weight?'**
  String get whatIsDesiredWeight;

  /// No description provided for @isRealisticGoal.
  ///
  /// In en, this message translates to:
  /// **'is a realistic goal.'**
  String get isRealisticGoal;

  /// No description provided for @youHaveGreatPotentialLose.
  ///
  /// In en, this message translates to:
  /// **'You have great potential to achieve your goal!\nLet\'s make it happen together!'**
  String get youHaveGreatPotentialLose;

  /// No description provided for @youHaveGreatPotentialGain.
  ///
  /// In en, this message translates to:
  /// **'Building muscle takes dedication!\nWe\'re here to support your journey!'**
  String get youHaveGreatPotentialGain;

  /// No description provided for @youveGotThis.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got this!'**
  String get youveGotThis;

  /// No description provided for @stayStrong.
  ///
  /// In en, this message translates to:
  /// **'Stay strong!'**
  String get stayStrong;

  /// No description provided for @nineOutOfTenUsers.
  ///
  /// In en, this message translates to:
  /// **'9 out of 10 users say they\nsee results in first week of\nusing Kalorina'**
  String get nineOutOfTenUsers;

  /// No description provided for @pickWeightLossSpeed.
  ///
  /// In en, this message translates to:
  /// **'Pick your weight loss speed'**
  String get pickWeightLossSpeed;

  /// No description provided for @pickWeightGainSpeed.
  ///
  /// In en, this message translates to:
  /// **'Pick your weight gain speed'**
  String get pickWeightGainSpeed;

  /// No description provided for @theSafestOption.
  ///
  /// In en, this message translates to:
  /// **'The Safest Option'**
  String get theSafestOption;

  /// No description provided for @balancedApproach.
  ///
  /// In en, this message translates to:
  /// **'Balanced Approach'**
  String get balancedApproach;

  /// No description provided for @aggressivePlan.
  ///
  /// In en, this message translates to:
  /// **'Aggressive Plan'**
  String get aggressivePlan;

  /// No description provided for @doYouFollowDiet.
  ///
  /// In en, this message translates to:
  /// **'Do you follow a specific diet?'**
  String get doYouFollowDiet;

  /// No description provided for @helpTrackCaloriesDiet.
  ///
  /// In en, this message translates to:
  /// **'We\'ll help you track calories according to your diet'**
  String get helpTrackCaloriesDiet;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @carnivore.
  ///
  /// In en, this message translates to:
  /// **'Carnivore'**
  String get carnivore;

  /// No description provided for @keto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get keto;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @wereHereForYou.
  ///
  /// In en, this message translates to:
  /// **'We\'re here for you!'**
  String get wereHereForYou;

  /// No description provided for @journeySupportMessage.
  ///
  /// In en, this message translates to:
  /// **'The journey to your goal might be challenging at times, but we\'re here to support you every step of the way. You won\'t have to face it alone.'**
  String get journeySupportMessage;

  /// No description provided for @starsAcrossApps.
  ///
  /// In en, this message translates to:
  /// **'Stars Across Applications'**
  String get starsAcrossApps;

  /// No description provided for @testimonial1Name.
  ///
  /// In en, this message translates to:
  /// **'James L.'**
  String get testimonial1Name;

  /// No description provided for @testimonial1Review.
  ///
  /// In en, this message translates to:
  /// **'I never thought tracking calories could be this easy. I lost 15 pounds in less than 2 months.'**
  String get testimonial1Review;

  /// No description provided for @testimonial2Name.
  ///
  /// In en, this message translates to:
  /// **'Sarah M.'**
  String get testimonial2Name;

  /// No description provided for @testimonial2Review.
  ///
  /// In en, this message translates to:
  /// **'The accuracy is incredible. Finally, I know exactly what I\'m eating and feel so much better.'**
  String get testimonial2Review;

  /// No description provided for @testimonial3Name.
  ///
  /// In en, this message translates to:
  /// **'Michael R.'**
  String get testimonial3Name;

  /// No description provided for @testimonial3Review.
  ///
  /// In en, this message translates to:
  /// **'Perfect for my daily routine. I scan my meals quickly and feel progress within a week.'**
  String get testimonial3Review;

  /// No description provided for @testimonial4Name.
  ///
  /// In en, this message translates to:
  /// **'Emma K.'**
  String get testimonial4Name;

  /// No description provided for @testimonial4Review.
  ///
  /// In en, this message translates to:
  /// **'Simple, accurate, and useful. I track calories without hassle and feel lighter throughout the day.'**
  String get testimonial4Review;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authenticationError;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get registrationFailed;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @networkErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your internet connection and try again.'**
  String get networkErrorDescription;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error'**
  String get unexpectedError;

  /// No description provided for @unexpectedErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get unexpectedErrorDescription;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @deleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise?'**
  String get deleteExerciseTitle;

  /// No description provided for @exerciseWillBePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Exercise will be permanently deleted'**
  String get exerciseWillBePermanentlyDeleted;

  /// No description provided for @failedToDeleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete exercise. Please try again.'**
  String get failedToDeleteExercise;

  /// No description provided for @deleteMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal?'**
  String get deleteMealTitle;

  /// No description provided for @mealWillBePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal will be permanently deleted'**
  String get mealWillBePermanentlyDeleted;

  /// No description provided for @howToScanProperly.
  ///
  /// In en, this message translates to:
  /// **'How to scan properly'**
  String get howToScanProperly;

  /// No description provided for @keepFoodInsideFrame.
  ///
  /// In en, this message translates to:
  /// **'Keep food fully inside the frame'**
  String get keepFoodInsideFrame;

  /// No description provided for @holdPhoneSteady.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone steady for a clear photo'**
  String get holdPhoneSteady;

  /// No description provided for @takePictureStraight.
  ///
  /// In en, this message translates to:
  /// **'Take the picture straight, not at an angle'**
  String get takePictureStraight;

  /// No description provided for @successfullyAddedToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Successfully added to dashboard'**
  String get successfullyAddedToDashboard;
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
