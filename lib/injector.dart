import 'package:get/get.dart';
import 'package:tasklist_lite/core/state/current_app_info.dart';
import 'package:tasklist_lite/core/state/current_auth_info.dart';
import 'package:tasklist_lite/presentation/controllers/common_dropdown_controller.dart';
import 'package:tasklist_lite/presentation/state/auth_state.dart';

import 'data/auth/auth_service.dart';
import 'data/fixture/comments_fixtures.dart';
import 'data/fixture/mark_fixtures.dart';
import 'data/fixture/notification_fixtures.dart';
import 'data/fixture/task_fixtures.dart';
import 'data/repositories/close_code_repository.dart';
import 'data/repositories/comments_repository.dart';
import 'data/repositories/idle_time_reason_repository.dart';
import 'data/repositories/mark_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/work_repository.dart';
import 'presentation/state/application_state.dart';

/// место, где задается начальная конфигурация dependency injection
/// Доложно по идее жить в conf, но не может, т.к. зависит от всех-всех
/// "бинов" и их конкретных реализаций
/// Сделано по образу и подобию инжектора из clean-arch семпла,
/// https://github.com/devmuaz/flutter_clean_architecture/blob/master/lib/src/injector.dart
void initializeDependencies() {
// порядок инициализации зависимостей важен. Впрочем, это и так очевидно
  ApplicationState applicationState = ApplicationState();
  Get.put(applicationState);
  Get.put<CurrentAppInfo>(applicationState);
  AuthState authState = AuthState();
  // эта зависимость нужна для работы со state в слое представления
  Get.put(authState);
  // а эта для работы с CurrentAuthInfo в слое доступа к данным
  Get.put<CurrentAuthInfo>(authState);
  Get.put(TaskRepository());
  Get.put(TaskFixtures());
  Get.put(AuthService());
  Get.put(NotificationRepository());
  Get.put(NotificationFixtures());
  Get.put(IdleTimeReasonRepository());
  Get.put(WorkRepository());
  Get.put(CloseCodeRepository());
  Get.put(CommentsFixtures());
  Get.put(CommentRepository());
  Get.put(CommonDropdownController());
  Get.put(MarkRepository());
  Get.put(MarkFixtures());
}
