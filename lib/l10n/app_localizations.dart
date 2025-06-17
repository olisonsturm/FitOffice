import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @tNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get tNo;

  /// No description provided for @tYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get tYes;

  /// No description provided for @tNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tNext;

  /// No description provided for @tLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get tLogin;

  /// No description provided for @tEmail.
  ///
  /// In en, this message translates to:
  /// **'E-Mail'**
  String get tEmail;

  /// No description provided for @tSignup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get tSignup;

  /// No description provided for @tLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get tLogout;

  /// No description provided for @tSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get tSuccess;

  /// No description provided for @tFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get tFullName;

  /// No description provided for @tContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get tContinue;

  /// No description provided for @tPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get tPassword;

  /// No description provided for @tUserName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get tUserName;

  /// No description provided for @tGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get tGetStarted;

  /// No description provided for @tForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get tForgotPassword;

  /// No description provided for @tSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign-In with Google'**
  String get tSignInWithGoogle;

  /// No description provided for @tEmailCannotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get tEmailCannotEmpty;

  /// No description provided for @tInvalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get tInvalidEmailFormat;

  /// No description provided for @tOnlyDHBWEmailAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only DHBW students or employees are allowed to sign up'**
  String get tOnlyDHBWEmailAllowed;

  /// No description provided for @tNoRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No record found'**
  String get tNoRecordFound;

  /// No description provided for @tPasswordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8 characters, with an uppercase letter, number and symbol'**
  String get tPasswordRequirements;

  /// No description provided for @tInvalidUserName.
  ///
  /// In en, this message translates to:
  /// **'Username must be alphanumeric with small letters, numbers, dots or underscores'**
  String get tInvalidUserName;

  /// No description provided for @tUserNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Username already exists'**
  String get tUserNameAlreadyExists;

  /// No description provided for @tUserNameLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 4 characters'**
  String get tUserNameLength;

  /// No description provided for @tUserNameCannotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get tUserNameCannotEmpty;

  /// No description provided for @tInvalidFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name must be alphabetic'**
  String get tInvalidFullName;

  /// No description provided for @tAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get tAlert;

  /// No description provided for @tOhSnap.
  ///
  /// In en, this message translates to:
  /// **'Oh Snap'**
  String get tOhSnap;

  /// No description provided for @tEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Hurray!!! Email is on its way.'**
  String get tEmailSent;

  /// No description provided for @tCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get tCongratulations;

  /// No description provided for @tEmailLinkToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Email Link To Reset Password'**
  String get tEmailLinkToResetPassword;

  /// No description provided for @tAccountCreateVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Account Create Verify Email'**
  String get tAccountCreateVerifyEmail;

  /// No description provided for @tAppName.
  ///
  /// In en, this message translates to:
  /// **'FitOffice@DHBW'**
  String get tAppName;

  /// No description provided for @tAppTagLine.
  ///
  /// In en, this message translates to:
  /// **'Get fit. Stay focused. Thrive at DHBW.'**
  String get tAppTagLine;

  /// No description provided for @tOnBoardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Willkommen bei FitOffice!'**
  String get tOnBoardingTitle1;

  /// No description provided for @tOnBoardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Fit bleiben trotz Bürojob'**
  String get tOnBoardingTitle2;

  /// No description provided for @tOnBoardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Gemeinsam dranbleiben'**
  String get tOnBoardingTitle3;

  /// No description provided for @tOnBoardingSubTitle1.
  ///
  /// In en, this message translates to:
  /// **'Hi! Ich bin FittyFuchs – dein smarter Begleiter in der App FitOffice. Hier dreht sich alles darum, wie du mehr Bewegung, Fokus und Wohlbefinden in deinen Büroalltag bringst. Los geht’s!'**
  String get tOnBoardingSubTitle1;

  /// No description provided for @tOnBoardingSubTitle2.
  ///
  /// In en, this message translates to:
  /// **'FitOffice hilft dir, gesunde Routinen in deinen Arbeitsalltag einzubauen. Ob kurze Bewegungspausen, Augenentspannung oder Trink-Erinnerungen – ich sorge dafür, dass du nichts vergisst.'**
  String get tOnBoardingSubTitle2;

  /// No description provided for @tOnBoardingSubTitle3.
  ///
  /// In en, this message translates to:
  /// **'Ich begleite dich mit Motivation, Tipps und kleinen Challenges – ganz ohne Druck. Mach dein Büro zu einem Ort, der gut für Körper und Kopf ist. Bereit? Dann starten wir gemeinsam!'**
  String get tOnBoardingSubTitle3;

  /// No description provided for @tOnBoardingCounter1.
  ///
  /// In en, this message translates to:
  /// **'1/3'**
  String get tOnBoardingCounter1;

  /// No description provided for @tOnBoardingCounter2.
  ///
  /// In en, this message translates to:
  /// **'2/3'**
  String get tOnBoardingCounter2;

  /// No description provided for @tOnBoardingCounter3.
  ///
  /// In en, this message translates to:
  /// **'3/3'**
  String get tOnBoardingCounter3;

  /// No description provided for @tWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'FitOffice@DHBW'**
  String get tWelcomeTitle;

  /// No description provided for @tWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay fit during your office day. Join us now!'**
  String get tWelcomeSubtitle;

  /// No description provided for @tLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back,'**
  String get tLoginTitle;

  /// No description provided for @tLoginSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Boost your health, power your mind!'**
  String get tLoginSubTitle;

  /// No description provided for @tRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me?'**
  String get tRememberMe;

  /// No description provided for @tDontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an Account'**
  String get tDontHaveAnAccount;

  /// No description provided for @tEnterYour.
  ///
  /// In en, this message translates to:
  /// **'Enter your'**
  String get tEnterYour;

  /// No description provided for @tResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get tResetPassword;

  /// No description provided for @tOR.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get tOR;

  /// No description provided for @tConnectWith.
  ///
  /// In en, this message translates to:
  /// **'Connect With'**
  String get tConnectWith;

  /// No description provided for @tFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get tFacebook;

  /// No description provided for @tGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get tGoogle;

  /// No description provided for @tSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Get On Board!'**
  String get tSignUpTitle;

  /// No description provided for @tSignUpSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile to start your healthy Journey.'**
  String get tSignUpSubTitle;

  /// No description provided for @tAlreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an Account'**
  String get tAlreadyHaveAnAccount;

  /// No description provided for @tForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Make Selection!'**
  String get tForgotPasswordTitle;

  /// No description provided for @tForgotPasswordSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset your password?'**
  String get tForgotPasswordSubTitle;

  /// No description provided for @tResetViaEMail.
  ///
  /// In en, this message translates to:
  /// **'Reset via Mail Verification'**
  String get tResetViaEMail;

  /// No description provided for @tResetViaPhone.
  ///
  /// In en, this message translates to:
  /// **'Reset via Phone Verification'**
  String get tResetViaPhone;

  /// No description provided for @tForgetMailSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered E-Mail to receive OTP'**
  String get tForgetMailSubTitle;

  /// No description provided for @tOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'CO\nDE'**
  String get tOtpTitle;

  /// No description provided for @tOtpSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get tOtpSubTitle;

  /// No description provided for @tOtpMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent at '**
  String get tOtpMessage;

  /// No description provided for @tEmailVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email address'**
  String get tEmailVerificationTitle;

  /// No description provided for @tEmailVerificationSubTitle.
  ///
  /// In en, this message translates to:
  /// **'We have just sent an email verification link on your email. Please check email and click on that link to verify your Email address. \n\n If not auto redirected after verification, click on the Continue button.'**
  String get tEmailVerificationSubTitle;

  /// No description provided for @tResendEmailLink.
  ///
  /// In en, this message translates to:
  /// **'Resend E-Mail Link'**
  String get tResendEmailLink;

  /// No description provided for @tBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get tBackToLogin;

  /// No description provided for @tDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Hey,'**
  String get tDashboardTitle;

  /// No description provided for @tDashboardHeading.
  ///
  /// In en, this message translates to:
  /// **'Explore Exercises'**
  String get tDashboardHeading;

  /// No description provided for @tDashboardSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tDashboardSearch;

  /// No description provided for @tDashboardBannerTitle2.
  ///
  /// In en, this message translates to:
  /// **'Energieschub für Zwischendurch'**
  String get tDashboardBannerTitle2;

  /// No description provided for @tDashboardBannerTitle1.
  ///
  /// In en, this message translates to:
  /// **'Unterstütze deine langfristige Gesundheit'**
  String get tDashboardBannerTitle1;

  /// No description provided for @tDashboardBannerSubTitle.
  ///
  /// In en, this message translates to:
  /// **'10 Lessons'**
  String get tDashboardBannerSubTitle;

  /// No description provided for @tDashboardButton.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get tDashboardButton;

  /// No description provided for @tDashboardStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tDashboardStatistics;

  /// No description provided for @tDashboardPhysicalExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises for your physical health'**
  String get tDashboardPhysicalExercisesTitle;

  /// No description provided for @tDashboardPsychologicalExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises for your mental health'**
  String get tDashboardPsychologicalExercisesTitle;

  /// No description provided for @tDashboardInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get tDashboardInformation;

  /// No description provided for @tDashboardFavouriteExercises.
  ///
  /// In en, this message translates to:
  /// **'Favorite Exercises'**
  String get tDashboardFavouriteExercises;

  /// No description provided for @tDashboardNoInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get tDashboardNoInternetConnection;

  /// No description provided for @tDashboardDatabaseException.
  ///
  /// In en, this message translates to:
  /// **'Database Exception'**
  String get tDashboardDatabaseException;

  /// No description provided for @tDashboardUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error.'**
  String get tDashboardUnexpectedError;

  /// No description provided for @tDashboardNoValidDate.
  ///
  /// In en, this message translates to:
  /// **'No valid date available'**
  String get tDashboardNoValidDate;

  /// No description provided for @tDashboardNoExercisesDone.
  ///
  /// In en, this message translates to:
  /// **'No exercises done yet.'**
  String get tDashboardNoExercisesDone;

  /// No description provided for @tDashboardExceptionLoadingExercise.
  ///
  /// In en, this message translates to:
  /// **'Could not load last exercise'**
  String get tDashboardExceptionLoadingExercise;

  /// No description provided for @tDashboardTimestampsMissing.
  ///
  /// In en, this message translates to:
  /// **'Timestamps are missing.'**
  String get tDashboardTimestampsMissing;

  /// No description provided for @tDashboardNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises were found'**
  String get tDashboardNoResultsFound;

  /// No description provided for @tDashboardAllExercises.
  ///
  /// In en, this message translates to:
  /// **'All Exercises'**
  String get tDashboardAllExercises;

  /// No description provided for @tDashboardExerciseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tDashboardExerciseCategory;

  /// No description provided for @tDashboardExerciseVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get tDashboardExerciseVideo;

  /// No description provided for @tDashboardExerciseDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get tDashboardExerciseDescription;

  /// No description provided for @tDashboardExerciseUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get tDashboardExerciseUnits;

  /// No description provided for @tDashboardExerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'The exercise you are looking for was not found.'**
  String get tDashboardExerciseNotFound;

  /// No description provided for @tDashboardExerciseSearchNoInput.
  ///
  /// In en, this message translates to:
  /// **'Please enter a search term.'**
  String get tDashboardExerciseSearchNoInput;

  /// No description provided for @tUpdateFavoriteException.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get favorites.'**
  String get tUpdateFavoriteException;

  /// No description provided for @tLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get tLoading;

  /// No description provided for @tActiveStreak.
  ///
  /// In en, this message translates to:
  /// **'Active Streak'**
  String get tActiveStreak;

  /// No description provided for @tNoActiveStreak.
  ///
  /// In en, this message translates to:
  /// **'No active streak'**
  String get tNoActiveStreak;

  /// No description provided for @tProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tProfile;

  /// No description provided for @tEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get tEditProfile;

  /// No description provided for @tSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get tSaveProfile;

  /// No description provided for @tLogoutDialogHeading.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get tLogoutDialogHeading;

  /// No description provided for @tNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes made'**
  String get tNoChanges;

  /// No description provided for @tMenu5.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get tMenu5;

  /// No description provided for @tMenu1.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tMenu1;

  /// No description provided for @tMenu4.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get tMenu4;

  /// No description provided for @tMenu2.
  ///
  /// In en, this message translates to:
  /// **'Billing Details'**
  String get tMenu2;

  /// No description provided for @tMenu3.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get tMenu3;

  /// No description provided for @tDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tDelete;

  /// No description provided for @tJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get tJoined;

  /// No description provided for @tJoinedAt.
  ///
  /// In en, this message translates to:
  /// **' 31 October 2022'**
  String get tJoinedAt;

  /// No description provided for @tFriendsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for friends'**
  String get tFriendsSearchHint;

  /// No description provided for @tAccountGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get tAccountGreeting;

  /// No description provided for @tNoResults.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get tNoResults;

  /// No description provided for @tAddFriendsButton.
  ///
  /// In en, this message translates to:
  /// **'ADD FRIENDS'**
  String get tAddFriendsButton;

  /// No description provided for @tSearchError.
  ///
  /// In en, this message translates to:
  /// **'Search error'**
  String get tSearchError;

  /// No description provided for @tAddFriendsHeader.
  ///
  /// In en, this message translates to:
  /// **'Add Friends'**
  String get tAddFriendsHeader;

  /// No description provided for @tEndExercisePopUp.
  ///
  /// In en, this message translates to:
  /// **'End exercise'**
  String get tEndExercisePopUp;

  /// No description provided for @tEndExerciseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish the exercise?'**
  String get tEndExerciseConfirmation;

  /// No description provided for @tEndExercisePositive.
  ///
  /// In en, this message translates to:
  /// **'Finish exercise'**
  String get tEndExercisePositive;

  /// No description provided for @tEndExerciseNegative.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tEndExerciseNegative;

  /// No description provided for @tStartExercisePopUp.
  ///
  /// In en, this message translates to:
  /// **'Start exercise'**
  String get tStartExercisePopUp;

  /// No description provided for @tStartExerciseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start this exercise:'**
  String get tStartExerciseConfirmation;

  /// No description provided for @tStartExercisePositive.
  ///
  /// In en, this message translates to:
  /// **'Start exercise'**
  String get tStartExercisePositive;

  /// No description provided for @tStartExerciseNegative.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tStartExerciseNegative;

  /// No description provided for @tUpperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper-Body'**
  String get tUpperBody;

  /// No description provided for @tLowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower-Body'**
  String get tLowerBody;

  /// No description provided for @tFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full-Body'**
  String get tFullBody;

  /// No description provided for @tMind.
  ///
  /// In en, this message translates to:
  /// **'Mind'**
  String get tMind;

  /// No description provided for @tFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tFavorites;

  /// No description provided for @tAbbreviationUpperBody.
  ///
  /// In en, this message translates to:
  /// **'UB'**
  String get tAbbreviationUpperBody;

  /// No description provided for @tAbbreviationLowerBody.
  ///
  /// In en, this message translates to:
  /// **'LB'**
  String get tAbbreviationLowerBody;

  /// No description provided for @tAbbreviationFullBody.
  ///
  /// In en, this message translates to:
  /// **'FB'**
  String get tAbbreviationFullBody;

  /// No description provided for @tAbbreviationMind.
  ///
  /// In en, this message translates to:
  /// **'🧠'**
  String get tAbbreviationMind;

  /// No description provided for @tAbbreviationFavorites.
  ///
  /// In en, this message translates to:
  /// **'❤️'**
  String get tAbbreviationFavorites;

  /// No description provided for @tActiveExercise.
  ///
  /// In en, this message translates to:
  /// **'Active Exercise'**
  String get tActiveExercise;

  /// No description provided for @tActiveExerciseDialogMessageStart.
  ///
  /// In en, this message translates to:
  /// **'An exercise is already running. Please finish or cancel it before you start a new one.'**
  String get tActiveExerciseDialogMessageStart;

  /// No description provided for @tActiveExerciseAnswer.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get tActiveExerciseAnswer;

  /// No description provided for @tActiveExerciseDialogMessageDelete.
  ///
  /// In en, this message translates to:
  /// **'Please finish the current exercise before you can delete an exercise.'**
  String get tActiveExerciseDialogMessageDelete;

  /// No description provided for @tActiveExerciseDialogMessageDefault.
  ///
  /// In en, this message translates to:
  /// **'Please finish the current exercise!'**
  String get tActiveExerciseDialogMessageDefault;

  /// No description provided for @tActiveExerciseDialogMessageEdit.
  ///
  /// In en, this message translates to:
  /// **'Please finish the current exercise before you can edit an exercise.'**
  String get tActiveExerciseDialogMessageEdit;

  /// No description provided for @tActiveExerciseDialogMessageAddFriends.
  ///
  /// In en, this message translates to:
  /// **'Please finish your active exercise first to add new friends.'**
  String get tActiveExerciseDialogMessageAddFriends;

  /// No description provided for @tActiveExerciseDialogMessageEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Please complete your active exercise first before editing your profile.'**
  String get tActiveExerciseDialogMessageEditProfile;

  /// No description provided for @tActiveExerciseDialogMessageLogout.
  ///
  /// In en, this message translates to:
  /// **'Please complete your active exercise before you can log out.'**
  String get tActiveExerciseDialogMessageLogout;

  /// No description provided for @tActiveExerciseDialogMessageViewFriends.
  ///
  /// In en, this message translates to:
  /// **'Please complete your active exercise before you can view your friends list.'**
  String get tActiveExerciseDialogMessageViewFriends;

  /// No description provided for @tActiveExerciseDialogMessageAdmin.
  ///
  /// In en, this message translates to:
  /// **'Please complete your active exercise first before continuing with administrative tasks.'**
  String get tActiveExerciseDialogMessageAdmin;

  /// No description provided for @tAddExercises.
  ///
  /// In en, this message translates to:
  /// **'Add Exercises'**
  String get tAddExercises;

  /// No description provided for @tAddExercisesHeader.
  ///
  /// In en, this message translates to:
  /// **'Add Exercises'**
  String get tAddExercisesHeader;

  /// No description provided for @tFillOutAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill out all fields.'**
  String get tFillOutAllFields;

  /// No description provided for @tExerciseAdded.
  ///
  /// In en, this message translates to:
  /// **'Exercise has been successfully added.'**
  String get tExerciseAdded;

  /// No description provided for @tDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get tDescription;

  /// No description provided for @tCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tCategory;

  /// No description provided for @tAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tAdd;

  /// No description provided for @tMental.
  ///
  /// In en, this message translates to:
  /// **'Mental'**
  String get tMental;

  /// No description provided for @tChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes have been saved successfully!'**
  String get tChangesSaved;

  /// No description provided for @tEditExerciseHeading.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get tEditExerciseHeading;

  /// No description provided for @tSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tSave;

  /// No description provided for @tGotDeleted.
  ///
  /// In en, this message translates to:
  /// **'Exercise got deleted.'**
  String get tGotDeleted;

  /// No description provided for @tDeleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get tDeleteExercise;

  /// No description provided for @tCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tCancel;

  /// No description provided for @tDeleteEditUser.
  ///
  /// In en, this message translates to:
  /// **'DELETE/EDIT USER'**
  String get tDeleteEditUser;

  /// No description provided for @tDeleteEditUserHeading.
  ///
  /// In en, this message translates to:
  /// **'Delete/Edit User'**
  String get tDeleteEditUserHeading;

  /// No description provided for @tAllUsers.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get tAllUsers;

  /// No description provided for @tNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get tNoUsersFound;

  /// No description provided for @tAddUser.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW USER'**
  String get tAddUser;

  /// No description provided for @tSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get tSaveChanges;

  /// No description provided for @tCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get tCreateUser;

  /// No description provided for @tSaveChangesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save the changes?'**
  String get tSaveChangesQuestion;

  /// No description provided for @tName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tName;

  /// No description provided for @tVideoURL.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get tVideoURL;

  /// No description provided for @tRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get tRequired;

  /// No description provided for @tPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get tPasswordLength;

  /// No description provided for @tPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get tPasswordRequired;

  /// No description provided for @tEditUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get tEditUser;

  /// No description provided for @tUserCreated.
  ///
  /// In en, this message translates to:
  /// **'User created'**
  String get tUserCreated;

  /// No description provided for @tUserUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated'**
  String get tUserUpdated;

  /// No description provided for @tSaveExerciseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you like to add this exercise?'**
  String get tSaveExerciseConfirmation;

  /// No description provided for @tUploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get tUploadVideo;

  /// No description provided for @tUploadVideoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded successfully'**
  String get tUploadVideoSuccess;

  /// No description provided for @tNoVideoSelected.
  ///
  /// In en, this message translates to:
  /// **'No video has been selected'**
  String get tNoVideoSelected;

  /// No description provided for @tVideoDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video deleted successfully'**
  String get tVideoDeleteSuccess;

  /// No description provided for @tUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get tUnknown;

  /// No description provided for @tAskDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Do you like to delete the user '**
  String get tAskDeleteUser;

  /// No description provided for @tDeleteUserConsequence.
  ///
  /// In en, this message translates to:
  /// **'? The user can\'t be restored and will be deleted globally.'**
  String get tDeleteUserConsequence;

  /// No description provided for @tDiscardChangesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get tDiscardChangesQuestion;

  /// No description provided for @tDiscardChangesText.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to leave the page and discard the changes? Changes won\'t be saved.'**
  String get tDiscardChangesText;

  /// No description provided for @tDiscardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get tDiscardChanges;

  /// No description provided for @tVideoSelected.
  ///
  /// In en, this message translates to:
  /// **'Video selected'**
  String get tVideoSelected;

  /// No description provided for @tShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get tShowAll;

  /// No description provided for @tShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get tShowLess;

  /// No description provided for @tFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get tFriends;

  /// No description provided for @tFriendNow.
  ///
  /// In en, this message translates to:
  /// **'is your friend now.'**
  String get tFriendNow;

  /// No description provided for @tNoFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any friends yet.'**
  String get tNoFriendsYet;

  /// No description provided for @tExceptionAddingFriend.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add friend'**
  String get tExceptionAddingFriend;

  /// No description provided for @tFriendDeleted.
  ///
  /// In en, this message translates to:
  /// **'isn\'t your friend anymore'**
  String get tFriendDeleted;

  /// No description provided for @tFriendDeleteException.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete friend'**
  String get tFriendDeleteException;

  /// No description provided for @tIsAlreadyYourFriend.
  ///
  /// In en, this message translates to:
  /// **'is already your friends'**
  String get tIsAlreadyYourFriend;

  /// No description provided for @tFriendshipRequests.
  ///
  /// In en, this message translates to:
  /// **'Friendships Requests'**
  String get tFriendshipRequests;

  /// No description provided for @tNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests'**
  String get tNoRequests;

  /// No description provided for @tNoFriendsFound.
  ///
  /// In en, this message translates to:
  /// **'No friends found.'**
  String get tNoFriendsFound;

  /// No description provided for @tClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tClose;

  /// No description provided for @tNoUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found.'**
  String get tNoUserFound;

  /// No description provided for @tAllResults.
  ///
  /// In en, this message translates to:
  /// **'All results'**
  String get tAllResults;

  /// No description provided for @tRemoved.
  ///
  /// In en, this message translates to:
  /// **' removed'**
  String get tRemoved;

  /// No description provided for @tExceptionRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove friend.'**
  String get tExceptionRemoveFriend;

  /// No description provided for @tFriendshipRequestWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Friendship request for following user has been withdrawn: '**
  String get tFriendshipRequestWithdraw;

  /// No description provided for @tDeleteFriend.
  ///
  /// In en, this message translates to:
  /// **'Delete friend'**
  String get tDeleteFriend;

  /// No description provided for @tSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send friendship request'**
  String get tSendRequest;

  /// No description provided for @tFriendshipDeleted.
  ///
  /// In en, this message translates to:
  /// **'Friend deleted'**
  String get tFriendshipDeleted;

  /// No description provided for @tRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get tRequestSent;

  /// No description provided for @tSentRequestToUser.
  ///
  /// In en, this message translates to:
  /// **'You sent a request to following user: '**
  String get tSentRequestToUser;

  /// No description provided for @tRequestPending.
  ///
  /// In en, this message translates to:
  /// **'Request pending'**
  String get tRequestPending;

  /// No description provided for @tDeleteVideoFailed.
  ///
  /// In en, this message translates to:
  /// **'Video could not be deleted'**
  String get tDeleteVideoFailed;

  /// No description provided for @tDeleteExerciseMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this exercise? It will be permanently removed for all users.'**
  String get tDeleteExerciseMessage;

  /// No description provided for @tExerciseAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tExerciseAbout;

  /// No description provided for @tExerciseHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tExerciseHistory;

  /// No description provided for @tExerciseVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get tExerciseVideo;

  /// No description provided for @tExerciseDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get tExerciseDescription;

  /// No description provided for @tExerciseNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get tExerciseNoDescription;

  /// No description provided for @tExerciseResume.
  ///
  /// In en, this message translates to:
  /// **'Resume exercise'**
  String get tExerciseResume;

  /// No description provided for @tExerciseStart.
  ///
  /// In en, this message translates to:
  /// **'Start exercise'**
  String get tExerciseStart;

  /// No description provided for @tExercisePause.
  ///
  /// In en, this message translates to:
  /// **'Pause exercise'**
  String get tExercisePause;

  /// No description provided for @tExerciseFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish exercise'**
  String get tExerciseFinish;

  /// No description provided for @tExerciseAbort.
  ///
  /// In en, this message translates to:
  /// **'Abort exercise'**
  String get tExerciseAbort;

  /// No description provided for @tNoVideoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No video available'**
  String get tNoVideoAvailable;

  /// No description provided for @tCancelExercise.
  ///
  /// In en, this message translates to:
  /// **'Cancel Exercise'**
  String get tCancelExercise;

  /// No description provided for @tCancelExerciseMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to cancel the exercise? Your progress will be lost!'**
  String get tCancelExerciseMessage;

  /// No description provided for @tCancelExercisePositive.
  ///
  /// In en, this message translates to:
  /// **'Cancel, exercise'**
  String get tCancelExercisePositive;

  /// No description provided for @tCancelExerciseNegative.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get tCancelExerciseNegative;

  /// No description provided for @tDeleteVideo.
  ///
  /// In en, this message translates to:
  /// **'Delete Video'**
  String get tDeleteVideo;

  /// No description provided for @tDeleteVideoMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the video? This action cannot be undone.'**
  String get tDeleteVideoMessage;

  /// No description provided for @tDeleteVideoPositive.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete'**
  String get tDeleteVideoPositive;

  /// No description provided for @tDeleteVideoNegative.
  ///
  /// In en, this message translates to:
  /// **'No, go back'**
  String get tDeleteVideoNegative;

  /// No description provided for @tReplaceVideo.
  ///
  /// In en, this message translates to:
  /// **'Replace Video'**
  String get tReplaceVideo;

  /// No description provided for @tReplaceVideoMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to replace the current video?'**
  String get tReplaceVideoMessage;

  /// No description provided for @tReplaceVideoPositive.
  ///
  /// In en, this message translates to:
  /// **'Yes, replace'**
  String get tReplaceVideoPositive;

  /// No description provided for @tReplaceVideoNegative.
  ///
  /// In en, this message translates to:
  /// **'No, go back'**
  String get tReplaceVideoNegative;

  /// No description provided for @tLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get tLogoutMessage;

  /// No description provided for @tLogoutPositive.
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get tLogoutPositive;

  /// No description provided for @tLogoutNegative.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tLogoutNegative;

  /// No description provided for @tTop3Exercises.
  ///
  /// In en, this message translates to:
  /// **'Top 3 Exercises'**
  String get tTop3Exercises;

  /// No description provided for @tNoExercisesDone.
  ///
  /// In en, this message translates to:
  /// **'No exercises have been done yet.'**
  String get tNoExercisesDone;

  /// No description provided for @tError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get tError;

  /// No description provided for @tLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load user data.'**
  String get tLoadingError;

  /// No description provided for @tLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get tLongestStreak;

  /// No description provided for @tNoStreak.
  ///
  /// In en, this message translates to:
  /// **'No streak found.'**
  String get tNoStreak;

  /// No description provided for @tStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date: '**
  String get tStartDate;

  /// No description provided for @tEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date: '**
  String get tEndDate;

  /// No description provided for @tDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: '**
  String get tDuration;

  /// No description provided for @tDays.
  ///
  /// In en, this message translates to:
  /// **' days'**
  String get tDays;

  /// No description provided for @tStreakStillActive.
  ///
  /// In en, this message translates to:
  /// **'Streak is still active.'**
  String get tStreakStillActive;

  /// No description provided for @tPasswordEmptyException.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get tPasswordEmptyException;

  /// No description provided for @tPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get tPasswordsDoNotMatch;

  /// No description provided for @tPleaseRepeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Please repeat your password'**
  String get tPleaseRepeatPassword;

  /// No description provided for @tCompletedWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Completed Workouts'**
  String get tCompletedWorkouts;

  /// No description provided for @tViewFriends.
  ///
  /// In en, this message translates to:
  /// **'View Friends'**
  String get tViewFriends;

  /// No description provided for @tSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tSettings;

  /// No description provided for @tNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tNotifications;

  /// No description provided for @tAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tAbout;

  /// No description provided for @tHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get tHelpSupport;

  /// No description provided for @tReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get tReportBug;

  /// No description provided for @tTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get tTerms;

  /// No description provided for @tPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get tPrivacyPolicy;

  /// No description provided for @tLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get tLicenses;

  /// No description provided for @tAdminSettings.
  ///
  /// In en, this message translates to:
  /// **'Admin Settings'**
  String get tAdminSettings;

  /// No description provided for @tProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tProgress;

  /// No description provided for @tLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get tLibrary;

  /// No description provided for @tStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tStatistics;

  /// No description provided for @tChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get tChapter;

  /// No description provided for @tLastExerciseDuration.
  ///
  /// In en, this message translates to:
  /// **'Last Exercise Duration'**
  String get tLastExerciseDuration;

  /// No description provided for @tNoExercisesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exercises available'**
  String get tNoExercisesAvailable;

  /// No description provided for @tLastExerciseTime.
  ///
  /// In en, this message translates to:
  /// **'Last Exercise Time'**
  String get tLastExerciseTime;

  /// No description provided for @tProgressTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you can find your progress.'**
  String get tProgressTutorial;

  /// No description provided for @tLibraryTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you can find all exercises.'**
  String get tLibraryTutorial;

  /// No description provided for @tStatisticsTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you can see all your statistics.'**
  String get tStatisticsTutorial;

  /// No description provided for @tProfileTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you can find your profile, friends and settings.'**
  String get tProfileTutorial;

  /// No description provided for @tBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tBack;

  /// No description provided for @tGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tGotIt;

  /// No description provided for @tTutorialLanguage.
  ///
  /// In en, this message translates to:
  /// **'Hi, my name is FittyFuchs. I\'d like to show you FitOffice. Choose your tutorial language.'**
  String get tTutorialLanguage;

  /// No description provided for @tLanguageChange.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in your profile.'**
  String get tLanguageChange;

  /// No description provided for @tTutorialCategories.
  ///
  /// In en, this message translates to:
  /// **'You can choose between exercises of different categories. Click anywhere to continue.'**
  String get tTutorialCategories;

  /// No description provided for @tTutorialSteps.
  ///
  /// In en, this message translates to:
  /// **'Here you can see your steps. If you do exercises of 5 minutes per day, you will make one step forward. Click to continue.'**
  String get tTutorialSteps;

  /// No description provided for @tTutorialStatistics.
  ///
  /// In en, this message translates to:
  /// **'Here you will find all the important statistics. You can activate a streak by doing one exercise per day for 5 minutes. You will receive one step for each day. The number of steps is displayed at the top left of the flame. But beware: the streak will be reset to 0 if you exercise for less than 5 minutes! Click to continue.'**
  String get tTutorialStatistics;

  /// No description provided for @tTutorialStatistics1.
  ///
  /// In en, this message translates to:
  /// **'Here you will find all the important statistics. You can activate a streak by doing one exercise per day for 5 minutes.'**
  String get tTutorialStatistics1;

  /// No description provided for @tTutorialStatistics2.
  ///
  /// In en, this message translates to:
  /// **'You will receive one step for each day. The number of steps is displayed at the top left of the flame.'**
  String get tTutorialStatistics2;

  /// No description provided for @tTutorialStatistics3.
  ///
  /// In en, this message translates to:
  /// **'But beware: the streak will be reset to 0 if you exercise for less than 5 minutes! Click to continue.'**
  String get tTutorialStatistics3;

  /// No description provided for @tLastExercise.
  ///
  /// In en, this message translates to:
  /// **'Last exercise done'**
  String get tLastExercise;

  /// No description provided for @tDurationLastExercise.
  ///
  /// In en, this message translates to:
  /// **'Duration of last exercise'**
  String get tDurationLastExercise;

  /// No description provided for @tTutorialProfile.
  ///
  /// In en, this message translates to:
  /// **'That\'s the profile site. Here you can edit your profile and make friends. All necessary settings can be found here.'**
  String get tTutorialProfile;

  /// No description provided for @tTutorialProfile2.
  ///
  /// In en, this message translates to:
  /// **'That\'s all from me. I wish you much fun exploring the app. There are many interesting functionalities to explore! See you!'**
  String get tTutorialProfile2;

  /// No description provided for @tSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tSkip;

  /// No description provided for @tLoadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading progress...'**
  String get tLoadingProgress;

  /// No description provided for @tCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get tCancelRequest;

  /// No description provided for @tCancelRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the friendship request with'**
  String get tCancelRequestConfirm;

  /// No description provided for @tRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get tRemoveFriend;

  /// No description provided for @tRemoveFriendConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to end your friendship with'**
  String get tRemoveFriendConfirm;

  /// No description provided for @tFriendRequestSentTo.
  ///
  /// In en, this message translates to:
  /// **'Friendship request sent to'**
  String get tFriendRequestSentTo;

  /// No description provided for @tFriendshipAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Friendship already exists with'**
  String get tFriendshipAlreadyExists;

  /// No description provided for @tRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get tRemove;

  /// No description provided for @tInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get tInfo;

  /// No description provided for @tFriendRequestDenied.
  ///
  /// In en, this message translates to:
  /// **'Friendship request denied'**
  String get tFriendRequestDenied;

  /// No description provided for @tFriendRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friendship request accepted'**
  String get tFriendRequestAccepted;

  /// No description provided for @tMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get tMinutes;

  /// No description provided for @tSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get tSeconds;

  /// No description provided for @tHistoryNoUserData.
  ///
  /// In en, this message translates to:
  /// **'User data not found.'**
  String get tHistoryNoUserData;

  /// No description provided for @tHistoryNoExercise1.
  ///
  /// In en, this message translates to:
  /// **'No exercise history found for'**
  String get tHistoryNoExercise1;

  /// No description provided for @tHistoryNoExercise2.
  ///
  /// In en, this message translates to:
  /// **'. Start tracking your exercises to see them here.'**
  String get tHistoryNoExercise2;

  /// No description provided for @tGerman.
  ///
  /// In en, this message translates to:
  /// **' (German)'**
  String get tGerman;

  /// No description provided for @tEnglish.
  ///
  /// In en, this message translates to:
  /// **' (English)'**
  String get tEnglish;

  /// No description provided for @tRemoveAccount.
  ///
  /// In en, this message translates to:
  /// **'Remove Account'**
  String get tRemoveAccount;

  /// No description provided for @tRemoveAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your account? This action cannot be undone.'**
  String get tRemoveAccountConfirm;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
