import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/home/home_screen_controller.dart';
import 'package:outdoor_therapy/features/views/now_playing/player_controller.dart';

class AppBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(HomeScreenController(),permanent: true);
    Get.put(PlayerController(),permanent: true);
  }

}