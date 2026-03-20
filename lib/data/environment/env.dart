import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'DS_KEY')
  static const String dsApiKey = _Env.dsApiKey;

  @EnviedField(varName: 'SUPA_URL')
  static const String supaUrl = _Env.supaUrl;

  @EnviedField(varName: 'SUPA_ANON')
  static const String supaAnon = _Env.supaAnon;

  @EnviedField(varName: 'AMAP_KEY')
  static const String amapKey = _Env.amapKey;
}

// dart run build_runner build

// 调试方法：检查环境变量是否加载正确
void debugEnv() {
  print('🔍 环境变量调试信息:');
  print('SUPA_URL: ${Env.supaUrl}');
  print('SUPA_ANON: ${Env.supaAnon}');
  print('SUPA_URL 是否为空: ${Env.supaUrl.isEmpty}');
  print('SUPA_ANON 是否为空: ${Env.supaAnon.isEmpty}');
}
