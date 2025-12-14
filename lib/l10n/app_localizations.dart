import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

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
    Locale('en'),
    Locale('uk'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Movie Discovery App'**
  String get appName;

  /// Title for language selection modal
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Ukrainian language option
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get ukrainian;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// App language setting title
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// App theme setting title
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// About app page title
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// App version text
  ///
  /// In en, this message translates to:
  /// **'App Version: {version}'**
  String appVersion(String version);

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String version(String version);

  /// About app description
  ///
  /// In en, this message translates to:
  /// **'In this app you can discover new movies and TV series, manage your favorites and browse personal collections.'**
  String get aboutAppDescription;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Edit profile page title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// Invalid email validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// Minimum password length validation error
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minPasswordLength;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get signUp;

  /// No account prompt
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccount;

  /// Has account prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get hasAccount;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Login subtitle
  ///
  /// In en, this message translates to:
  /// **'Return to your stories'**
  String get returnToStories;

  /// Sign up subtitle
  ///
  /// In en, this message translates to:
  /// **'Create account and discover new'**
  String get createAccount;

  /// Login page title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Profile login subtitle
  ///
  /// In en, this message translates to:
  /// **'Return to viewing'**
  String get returnToViewing;

  /// Profile sign up subtitle
  ///
  /// In en, this message translates to:
  /// **'Create account in a minute'**
  String get createAccountQuick;

  /// Success notification for login
  ///
  /// In en, this message translates to:
  /// **'Successful login!'**
  String get successfulLogin;

  /// Success notification for registration
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get successfulRegistration;

  /// Watched button label
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watched;

  /// Favorites button label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileButton;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Username helper text
  ///
  /// In en, this message translates to:
  /// **'Can be left empty'**
  String get canBeEmpty;

  /// Save changes button
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Change password button
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Current password field
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// New password field
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Validation error for empty fields
  ///
  /// In en, this message translates to:
  /// **'Fill all fields'**
  String get fillAllFields;

  /// Password mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Saving state text
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Password change success message
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated ({email})'**
  String profileUpdated(String email);

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Authorization required message
  ///
  /// In en, this message translates to:
  /// **'Authorize first'**
  String get authorizeFirst;

  /// Select image from gallery option
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Delete avatar option
  ///
  /// In en, this message translates to:
  /// **'Delete Avatar'**
  String get deleteAvatar;

  /// App theme modal title
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appThemeTitle;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Empty favorites list message
  ///
  /// In en, this message translates to:
  /// **'Favorites list is empty'**
  String get favoritesEmpty;

  /// Favorites login prompt message
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your favorite movies and TV series.'**
  String get favoritesLoginPrompt;

  /// Empty watchlist message
  ///
  /// In en, this message translates to:
  /// **'Nothing watched yet'**
  String get watchlistEmpty;

  /// Watchlist unavailable title
  ///
  /// In en, this message translates to:
  /// **'Watched unavailable'**
  String get watchlistUnavailable;

  /// Watchlist login prompt message
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your watched movies and TV series.'**
  String get watchlistLoginPrompt;

  /// Search history title
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get searchHistory;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Empty search history message
  ///
  /// In en, this message translates to:
  /// **'Search history is empty'**
  String get searchHistoryEmpty;

  /// Search history unavailable title
  ///
  /// In en, this message translates to:
  /// **'Search history unavailable'**
  String get searchHistoryUnavailable;

  /// Search history login prompt message
  ///
  /// In en, this message translates to:
  /// **'Sign in to save and view search history.'**
  String get searchHistoryLoginPrompt;

  /// Search title
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search with filters title
  ///
  /// In en, this message translates to:
  /// **'Search with filters'**
  String get searchWithFilters;

  /// Authorization required dialog title
  ///
  /// In en, this message translates to:
  /// **'Authorization Required'**
  String get authorizationRequired;

  /// Login prompt to add to favorites
  ///
  /// In en, this message translates to:
  /// **'Sign in to add to favorites.'**
  String get loginToAddToFavorites;

  /// Login prompt to add media to favorites
  ///
  /// In en, this message translates to:
  /// **'Sign in to add media to favorites.'**
  String get loginToAddMediaToFavorites;

  /// Popular movies section title
  ///
  /// In en, this message translates to:
  /// **'Popular Movies'**
  String get popularMovies;

  /// Popular TV shows section title
  ///
  /// In en, this message translates to:
  /// **'Popular TV Shows'**
  String get popularTvShows;

  /// All movies section title
  ///
  /// In en, this message translates to:
  /// **'All Movies'**
  String get allMovies;

  /// All TV shows section title
  ///
  /// In en, this message translates to:
  /// **'All TV Shows'**
  String get allTvShows;

  /// See more button
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Nothing found message
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// Load more button
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// Home header subtitle
  ///
  /// In en, this message translates to:
  /// **'We\'ve picked what to watch today'**
  String get headerSubtitle;

  /// Home header description
  ///
  /// In en, this message translates to:
  /// **'Continue discovering stories, add to favorites and come back for recommendations.'**
  String get headerDescription;

  /// Explore button
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Trailer section title
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get trailer;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No overview message
  ///
  /// In en, this message translates to:
  /// **'No overview available'**
  String get noOverview;

  /// Characteristics section title
  ///
  /// In en, this message translates to:
  /// **'Characteristics'**
  String get characteristics;

  /// Release date label
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get releaseDate;

  /// Genres label
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Vote count label
  ///
  /// In en, this message translates to:
  /// **'Vote Count'**
  String get voteCount;

  /// Reviews section title
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No reviews message
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// Anonymous author name
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// Recommended section title
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// Trailer unavailable message
  ///
  /// In en, this message translates to:
  /// **'Trailer unavailable'**
  String get trailerUnavailable;

  /// Video unavailable message
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get videoUnavailable;

  /// Trying to find another video message
  ///
  /// In en, this message translates to:
  /// **'Trying to find another video...'**
  String get tryingToFindAnotherVideo;

  /// Search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter title...'**
  String get enterTitle;

  /// Genre label
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// Genre input label with example
  ///
  /// In en, this message translates to:
  /// **'Genre (e.g.: Action, Comedy)'**
  String get genreExample;

  /// Year label
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No internet connection error message
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network connection.'**
  String get noInternetConnection;

  /// Timeout error message
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Check your internet connection.'**
  String get timeoutError;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection error to server. Please try again later.'**
  String get connectionError;

  /// Insufficient permissions error message
  ///
  /// In en, this message translates to:
  /// **'Insufficient permissions. Please sign in.'**
  String get insufficientPermissions;

  /// Nothing found with filters error message
  ///
  /// In en, this message translates to:
  /// **'Nothing found with the specified filters. Try other search parameters.'**
  String get nothingFoundWithFilters;

  /// General search error message
  ///
  /// In en, this message translates to:
  /// **'Failed to perform search. Please try again later.'**
  String get searchFailed;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Vote count with number
  ///
  /// In en, this message translates to:
  /// **'{count} votes'**
  String votes(int count);

  /// Duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutes(int minutes);

  /// Number of seasons
  ///
  /// In en, this message translates to:
  /// **'Seasons: {count}'**
  String seasons(int count);
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
