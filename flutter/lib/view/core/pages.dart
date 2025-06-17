import 'package:naiapp/view/home/home_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:naiapp/view/parser/parser_page.dart';
import 'package:naiapp/view/parser/parser_page_binding.dart';
import 'package:naiapp/view/setting/setting_page.dart';
import 'package:naiapp/view/setting/setting_page_binding.dart';

import '../home/home_page_binding.dart';
import '../image/image_page.dart';
import '../image/image_page_binding.dart';
import '../login/login_page.dart';
import '../login/login_page_binding.dart';

import '../splash/splash_page.dart';
import '../splash/splash_page_binding.dart';

List<GetPage> allPages = [
  GetPage(
      name: "/splash",
      binding: SplashPageBinding(),
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200)),
  GetPage(
      name: "/login",
      page: () => const LoginPage(),
      binding: LoginPageBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200)),
  GetPage(
      name: "/",
      page: () => HomePage(),
      binding: HomePageBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200)),
  GetPage(
      name: "/home/parse",
      page: () => const ParserPage(),
      binding: ParserPageBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200)),
  GetPage(
      name: "/home/image",
      page: () => ImagePage(),
      binding: ImagePageBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200)),
  GetPage(
      name: "/home/setting",
      page: () => const SettingPage(),
      binding: SettingPageBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200)),
];
