import 'package:get_storage/get_storage.dart';

class Box {
  static String settingKey = "Get-Settings";
  static GetStorage setting = GetStorage(settingKey);

  static String simpleDataKey = "Simple-Data";
  static GetStorage simpleData = GetStorage(simpleDataKey);
}
