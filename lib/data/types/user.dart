import 'package:time_manager_client/data/types/user_account.dart';
import 'package:time_manager_client/data/proto.gen/user.pb.dart' as p;
import 'package:time_manager_client/helper/extension.dart';

class User {
  int id;
  List<UserAccount> accounts = [];
  String icon = "😀";

  String? prompt;

  static int getControllerId = 01000;

  User({
    required this.id,
    this.accounts = const [],
  });

  p.User toProto() => p.User(
        id: id.toInt64(),
        accounts: accounts.map((e) => e.toProto()),
        prompt: prompt,
      );

  User.fromProto(p.User proto)
      : id = proto.id.toInt(),
        accounts = proto.accounts.map((e) => UserAccount.fromProto(e)).toList(),
        prompt = proto.hasPrompt() ? proto.prompt : null;
}
