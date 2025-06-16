import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:naiapp/view/core/app_widget.dart';

import 'application/core/MyTaskHandler.dart';
import 'infra/core/dependency.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await injectDependencies();
  // if()
  runApp(WithForegroundTask(child: const AppWidget()));
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}
