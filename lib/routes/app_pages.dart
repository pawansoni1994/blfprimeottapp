import 'package:get/get.dart';

import '../screens/main/main_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/otp_verification/otp_verification_screen.dart';
import '../screens/reset_password/reset_password_screen.dart';
import '../screens/my_profile/my_profile_screen.dart';
import '../screens/edit_profile/edit_profile_screen.dart';
import '../screens/movie_details/movie_details_screen.dart';
import '../screens/series_details/series_details_screen.dart';
import '../screens/song_details/song_details_screen.dart';
import '../screens/coming_soon_details/coming_soon_details_screen.dart';
import '../screens/video_player_screen.dart';
import '../screens/view_all/view_all_screen.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/add_audition/add_audition_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/watchlist/watchlist_screen.dart';
import '../screens/favorite_list/favorite_list_screen.dart';
import '../screens/about_us/about_us_screen.dart';
import '../screens/contact_us/contact_us_screen.dart';
import '../screens/languages/languages_screen.dart';
import '../screens/audition_list/audition_list_screen.dart';
import '../screens/genres/genres_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/continue_watching_view_all/continue_watching_view_all_screen.dart';
import '../screens/subscription_purchase/subscription_purchase_screen.dart';
import '../screens/subscription_manage/subscription_manage_screen.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => OtpVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => ResetPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.myProfile,
      page: () => MyProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.movieDetails,
      page: () => MovieDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.seriesDetails,
      page: () => SeriesDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.songDetails,
      page: () => SongDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.comingSoonDetails,
      page: () => ComingSoonDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.viewAllMovies,
      page: () => ViewAllScreen(),
      parameters: {'type': 'movie'},
    ),
    GetPage(
      name: AppRoutes.viewAllSeries,
      page: () => ViewAllScreen(),
      parameters: {'type': 'series'},
    ),
    GetPage(
      name: AppRoutes.viewAll,
      page: () => ViewAllScreen(),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => SubscriptionScreen(),
    ),
    GetPage(
      name: AppRoutes.addAudition,
      page: () => AddAuditionScreen(),
    ),
    GetPage(
      name: AppRoutes.downloads,
      page: () => DownloadsScreen(),
    ),
    GetPage(
      name: AppRoutes.watchlist,
      page: () => WatchlistScreen(),
    ),
    GetPage(
      name: AppRoutes.favoriteList,
      page: () => FavoriteListScreen(),
    ),
    GetPage(
      name: AppRoutes.videoPlayer,
      page: () => VideoPlayerScreen(),
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => AboutUsScreen(),
    ),
    GetPage(
      name: AppRoutes.contactUs,
      page: () => ContactUsScreen(),
    ),
    GetPage(
      name: AppRoutes.languages,
      page: () => LanguagesScreen(),
    ),
    GetPage(
      name: AppRoutes.auditionList,
      page: () => AuditionListScreen(),
    ),
    GetPage(
      name: AppRoutes.genres,
      page: () => GenresScreen(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => SearchScreen(),
    ),
    GetPage(
      name: AppRoutes.continueWatchingViewAll,
      page: () => ContinueWatchingViewAllScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => MainScreen(),
    ),
    GetPage(
      name: AppRoutes.subscriptionPurchase,
      page: () => SubscriptionPurchaseScreen(),
    ),
    GetPage(
      name: AppRoutes.subscriptionManage,
      page: () => SubscriptionManageScreen(),
    ),
  ];
}
