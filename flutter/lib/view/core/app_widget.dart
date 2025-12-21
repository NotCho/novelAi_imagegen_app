import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../application/core/global_controller.dart';
import '../../infra/core/environment.dart';
import 'loading.dart';
import 'pages.dart';
import 'util/app_snackbar.dart';

class AppWidget extends GetView<GlobalController> {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),

      useInheritedMediaQuery: true,
      // 이거 추가!
      splitScreenMode: true,
      // 이것도!
      builder: (context, child) {
        // Wrap the app with WithForegroundTask to maintain the service
        return child!;
      },
      child: Builder(builder: (context) {
        return GetMaterialApp(
          enableLog: true,
          // 이걸로!
          builder: tcBuilder,
          scaffoldMessengerKey: appScaffoldMessengerKey,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Colors.transparent),
            ),
          ),
          debugShowCheckedModeBanner: EnvironmentConfig.isDev,
          getPages: allPages,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko')],
        );
      }),
    );
  }
}

Widget tcBuilder(BuildContext ctx, Widget? child) {
  return MediaQuery(
    data: MediaQuery.of(ctx).copyWith(
      textScaler: const TextScaler.linear(1.0),
    ),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.focusScope?.unfocus(),
      child: SkeletonLoadingOverlay(
        child: child!,
      ),
    ),
  );
}
