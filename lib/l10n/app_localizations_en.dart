// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Movie Discovery App';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get ukrainian => 'Ukrainian';

  @override
  String get english => 'English';

  @override
  String get appLanguage => 'App Language';

  @override
  String get appTheme => 'App Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get aboutApp => 'About App';

  @override
  String appVersion(String version) {
    return 'App Version: $version';
  }

  @override
  String version(String version) {
    return 'Version: $version';
  }

  @override
  String get aboutAppDescription =>
      'In this app you can discover new movies and TV series, manage your favorites and browse personal collections.';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get minPasswordLength => 'Minimum 6 characters';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Register';

  @override
  String get noAccount => 'No account? Register';

  @override
  String get hasAccount => 'Already have an account? Sign In';

  @override
  String get skip => 'Skip';

  @override
  String get returnToStories => 'Return to your stories';

  @override
  String get createAccount => 'Create account and discover new';

  @override
  String get login => 'Login';

  @override
  String get returnToViewing => 'Return to viewing';

  @override
  String get createAccountQuick => 'Create account in a minute';

  @override
  String get successfulLogin => 'Successful login!';

  @override
  String get successfulRegistration => 'Registration successful!';

  @override
  String get watched => 'Watched';

  @override
  String get favorites => 'Favorites';

  @override
  String get signOut => 'Sign Out';

  @override
  String get editProfileButton => 'Edit Profile';

  @override
  String get username => 'Username';

  @override
  String get canBeEmpty => 'Can be left empty';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fillAllFields => 'Fill all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get saving => 'Saving...';

  @override
  String get save => 'Save';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String profileUpdated(String email) {
    return 'Profile updated ($email)';
  }

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get authorizeFirst => 'Authorize first';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get deleteAvatar => 'Delete Avatar';

  @override
  String get appThemeTitle => 'App Theme';

  @override
  String get loading => 'Loading...';

  @override
  String get favoritesEmpty => 'Favorites list is empty';

  @override
  String get favoritesLoginPrompt =>
      'Sign in to save your favorite movies and TV series.';

  @override
  String get watchlistEmpty => 'Nothing watched yet';

  @override
  String get watchlistUnavailable => 'Watched unavailable';

  @override
  String get watchlistLoginPrompt =>
      'Sign in to see your watched movies and TV series.';

  @override
  String get searchHistory => 'Search History';

  @override
  String get clear => 'Clear';

  @override
  String get searchHistoryEmpty => 'Search history is empty';

  @override
  String get searchHistoryUnavailable => 'Search history unavailable';

  @override
  String get searchHistoryLoginPrompt =>
      'Sign in to save and view search history.';

  @override
  String get search => 'Search';

  @override
  String get searchWithFilters => 'Search with filters';

  @override
  String get authorizationRequired => 'Authorization Required';

  @override
  String get loginToAddToFavorites => 'Sign in to add to favorites.';

  @override
  String get loginToAddMediaToFavorites => 'Sign in to add media to favorites.';

  @override
  String get popularMovies => 'Popular Movies';

  @override
  String get popularTvShows => 'Popular TV Shows';

  @override
  String get allMovies => 'All Movies';

  @override
  String get allTvShows => 'All TV Shows';

  @override
  String get more => 'More';

  @override
  String get noData => 'No data';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get loadMore => 'Load more';

  @override
  String get headerSubtitle => 'We\'ve picked what to watch today';

  @override
  String get headerDescription =>
      'Continue discovering stories, add to favorites and come back for recommendations.';

  @override
  String get explore => 'Explore';

  @override
  String get trailer => 'Trailer';

  @override
  String get overview => 'Overview';

  @override
  String get noOverview => 'No overview available';

  @override
  String get characteristics => 'Characteristics';

  @override
  String get releaseDate => 'Release Date';

  @override
  String get genres => 'Genres';

  @override
  String get status => 'Status';

  @override
  String get voteCount => 'Vote Count';

  @override
  String get reviews => 'Reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get recommended => 'Recommended';

  @override
  String get trailerUnavailable => 'Trailer unavailable';

  @override
  String get videoUnavailable => 'Video unavailable';

  @override
  String get tryingToFindAnotherVideo => 'Trying to find another video...';

  @override
  String get enterTitle => 'Enter title...';

  @override
  String get genre => 'Genre';

  @override
  String get genreExample => 'Genre (e.g.: Action, Comedy)';

  @override
  String get year => 'Year';

  @override
  String get rating => 'Rating';

  @override
  String get noInternetConnection =>
      'No internet connection. Check your network connection.';

  @override
  String get timeoutError => 'Request timeout. Check your internet connection.';

  @override
  String get connectionError =>
      'Connection error to server. Please try again later.';

  @override
  String get insufficientPermissions =>
      'Insufficient permissions. Please sign in.';

  @override
  String get nothingFoundWithFilters =>
      'Nothing found with the specified filters. Try other search parameters.';

  @override
  String get searchFailed =>
      'Failed to perform search. Please try again later.';

  @override
  String get cancel => 'Cancel';

  @override
  String get home => 'Home';

  @override
  String votes(int count) {
    return '$count votes';
  }

  @override
  String minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String seasons(int count) {
    return 'Seasons: $count';
  }
}
