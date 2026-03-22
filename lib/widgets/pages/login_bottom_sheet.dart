import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:time_manager_client/helper/helper.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  static Future<int?> show(BuildContext context) =>
      Helper.showModalBottomSheetWithTextField<int>(
          context, LoginBottomSheet());

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  bool _showManualInput = false;

  Future<int?> getPhoneNumber() async {
    // 在Web环境下，直接显示手动输入
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS || kIsWeb) {
      _showManualInput = true;
      return null;
    }

    // 移动端尝试获取手机号
    var p = await MobileNumber.hasPhonePermission;
    if (!p) {
      await MobileNumber.requestPhonePermission;
      p = await MobileNumber.hasPhonePermission;
      if (!p) {
        Get.back();
        Get.snackbar("权限申请失败", "请重新尝试登陆");
        return null;
      }
    }

    var s = await MobileNumber.mobileNumber;
    return Helper.formatPhoneNumber(s);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
        future: getPhoneNumber(),
        builder: (context, snapshot) {
          var phoneNumber = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 24),
                Text("欢迎用户", style: textTheme.titleLarge),
                const SizedBox(height: 32),

                // Web环境显示手动输入框
                if (_showManualInput)
                  Column(
                    children: [
                      Text("请在下方输入您的手机号", style: textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "请输入11位手机号",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                // 移动端显示自动获取的手机号
                else if (phoneNumber == null)
                  Text("请允许应用获取手机号码\n完成授权后，请重新登录", style: textTheme.bodyLarge)
                else
                  Text(phoneNumber.toString(), style: textTheme.displaySmall),

                const SizedBox(height: 24),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: _getLoginButtonEnabled(phoneNumber)
                        ? () => _handleLogin(phoneNumber)
                        : null,
                    child: Text("登陆"),
                  ),
                ),
                Row(children: [Expanded(child: SizedBox())]),
                SizedBox(height: 24),
              ],
            ),
          );
        });
  }

  bool _getLoginButtonEnabled(int? phoneNumber) {
    if (_showManualInput) {
      // 检查手动输入的手机号是否有效
      final manualPhone = _phoneController.text.trim();
      return manualPhone.length == 11 && manualPhone.startsWith('1');
    } else {
      return phoneNumber != null;
    }
  }

  void _handleLogin(int? phoneNumber) {
    if (_showManualInput) {
      final manualPhone = _phoneController.text.trim();
      final formattedPhone = int.tryParse(manualPhone);
      if (formattedPhone != null) {
        Get.back(result: formattedPhone);
      }
    } else {
      Get.back(result: phoneNumber);
    }
  }
}
