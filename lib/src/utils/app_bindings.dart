import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/repository/firebase_storage/storage_service.dart';
import 'package:fit_office/src/utils/services/deep_link_service.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/controllers/login_controller.dart';
import 'package:fit_office/src/features/authentication/controllers/on_boarding_controller.dart';
import 'package:fit_office/src/features/authentication/controllers/signup_controller.dart';
import 'package:fit_office/src/repository/user_repository/user_repository.dart';
import '../repository/authentication_repository/authentication_repository.dart';

/// Initial binding for the application
class InitialBinding extends Bindings{

  /// This method is called when the application starts.
  /// It initializes all the necessary services and controllers to be used throughout the app.
  @override
  void dependencies() {
    Get.lazyPut(() => AuthenticationRepository(), fenix: true);
    Get.lazyPut(() => UserRepository(), fenix: true);
    Get.lazyPut(() => StorageService(), fenix: true);

    Get.lazyPut(() => OnBoardingController(), fenix: true);

    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);

    Get.lazyPut(() => ExerciseTimerController(), fenix: true);

    Get.lazyPut(() => DeepLinkService(), fenix: true);
  }

}