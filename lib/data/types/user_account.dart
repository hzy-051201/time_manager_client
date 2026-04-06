import 'package:flutter/material.dart';
import 'package:time_manager_client/data/proto.gen/user.pb.dart' as p;

class UserAccount {
  const UserAccount();

  String get account => throw UnimplementedError();
  IconData get icon => throw UnimplementedError();
  p.UserAccount toProto() => throw UnimplementedError();

  static UserAccount fromProto(p.UserAccount proto) {
    switch (proto.type) {
      case p.UserAccountType.PHONE:
        return UserAccountPhone.fromProto(proto);
      case p.UserAccountType.WECHAT_OPENID:
        return UserAccountWechatOpenId.fromProto(proto);
      default:
        throw Exception("Unknown UserAccountType");
    }
  }
}

class UserAccountPhone extends UserAccount {
  final int phone;
  const UserAccountPhone(this.phone);

  @override
  String get account => phone.toString();

  @override
  IconData get icon => Icons.phone;

  @override
  p.UserAccount toProto() => p.UserAccount(
        account: phone.toString(),
        type: p.UserAccountType.PHONE,
      );

  @override
  UserAccountPhone.fromProto(p.UserAccount proto) : phone = int.parse(proto.account);
}

class UserAccountWechatOpenId extends UserAccount {
  final String openId;
  const UserAccountWechatOpenId(this.openId);

  @override
  String get account => openId;

  @override
  IconData get icon => Icons.wechat;

  @override
  p.UserAccount toProto() => p.UserAccount(
        account: openId,
        type: p.UserAccountType.WECHAT_OPENID,
      );

  @override
  UserAccountWechatOpenId.fromProto(p.UserAccount proto) : openId = proto.account;
}
