import 'package:ai_based_smart_energy_meter/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:ai_based_smart_energy_meter/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:ai_based_smart_energy_meter/ui/views/home/home_view.dart';
import 'package:ai_based_smart_energy_meter/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:ai_based_smart_energy_meter/services/database_service.dart';
import 'package:ai_based_smart_energy_meter/ui/views/devices/devices_view.dart';
import 'package:ai_based_smart_energy_meter/ui/views/predict/predict_view.dart';

import '../services/firebase_service.dart';
// @stacked-import

@StackedApp(routes: [
  MaterialRoute(page: HomeView),
  MaterialRoute(page: StartupView),
  MaterialRoute(page: DevicesView),
  MaterialRoute(page: PredictView),
// @stacked-route
], dependencies: [
  LazySingleton(classType: BottomSheetService),
  LazySingleton(classType: DialogService),
  LazySingleton(classType: NavigationService),
  LazySingleton(classType: DatabaseService),
  LazySingleton(classType: SnackbarService),
  LazySingleton(classType: FirebaseService),
// @stacked-service
], bottomsheets: [
  StackedBottomsheet(classType: NoticeSheet),
  // @stacked-bottom-sheet
], dialogs: [
  StackedDialog(classType: InfoAlertDialog),
  // @stacked-dialog
], logger: StackedLogger())
class App {}
