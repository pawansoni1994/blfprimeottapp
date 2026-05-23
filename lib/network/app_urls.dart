class AppUrls {
  static String baseUrl = 'https://blf-backend.vercel.app';
  // static String baseUrl = 'http://192.168.1.5:3000';

  static String login = '/api/auth/login';
  static String register = '/api/auth/register';
  static String forgotPassword = '/api/auth/forgot-password';
  static String verifyOtp = '/api/auth/verify-otp';
  static String sendOtp = '/api/auth/send-otp';
  static String updateProfile(String id) => '/api/users/$id';
  static String changeLanguage = '/api/profile/change-language';
  static String changePassword = '/api/profile/change-password';
  static String categories = '/api/categories';
  static String languages = '/api/languages';
  static String banners = '/api/banners/active';
  static String extraBanners = '/api/extra-banners/active';
  static String movies = '/api/movies';
  static String series = '/api/series';
  static String latestMovies = '/api/movies/latest';
  static String latestSeries = '/api/series/latest';
  static String songs = '/api/songs';
  static String latestSongs = '/api/songs/latest';
  static String movieDetails(String id) => '/api/movies/$id';
  static String seriesDetails(String id) => '/api/series/$id';
  static String songDetails(String id) => '/api/songs/$id';
  static String comingSoonDetails(String id) => '/api/coming-soon/$id';
  static String resetPassword = '/api/auth/reset-password';
  static String subscriptionPlans = '/api/subscription-plans?page=1&limit=10';
  static String purchaseSubscription = '/api/payments/purchase';
  static String upgradeSubscription = '/api/payments/upgrade';
  static String cancelSubscription = '/api/payments/cancel';
  static String profile = '/api/auth/profile';
  static String favorites = '/api/favorite';
  static String toggleFavorite = '/api/favorite/toggle';
  static String watchlist = '/api/watchlist';
  static String toggleWatchlist = '/api/watchlist/toggle';
  static String audition = '/api/audition';
  static String comingSoon = '/api/coming-soon';
  static String checkAuditionUploaded = '/api/audition/check/audition-uploaded';
  static String purchase = '/api/purchase';
  static String continueWatchingStart = '/api/continue-watching/start';
  static String continueWatchingUpdate = '/api/continue-watching/update';
  static String continueWatchingLatest(int limit) =>
      '/api/continue-watching/latest?limit=$limit';
  static String continueWatching(int page, int limit) =>
      '/api/continue-watching?page=$page&limit=$limit';
}
