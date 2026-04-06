//
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'user.pbenum.dart';

export 'user.pbenum.dart';

class User extends $pb.GeneratedMessage {
  factory User({
    $fixnum.Int64? id,
    $core.Iterable<UserAccount>? accounts,
    $core.String? prompt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (accounts != null) {
      $result.accounts.addAll(accounts);
    }
    if (prompt != null) {
      $result.prompt = prompt;
    }
    return $result;
  }
  User._() : super();
  factory User.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory User.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'User', package: const $pb.PackageName(_omitMessageNames ? '' : 'time_manager'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..pc<UserAccount>(10, _omitFieldNames ? '' : 'accounts', $pb.PbFieldType.PM, subBuilder: UserAccount.create)
    ..aOS(11, _omitFieldNames ? '' : 'prompt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  User clone() => User()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  User copyWith(void Function(User) updates) => super.copyWith((message) => updates(message as User)) as User;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  User createEmptyInstance() => create();
  static $pb.PbList<User> createRepeated() => $pb.PbList<User>();
  @$core.pragma('dart2js:noInline')
  static User getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(10)
  $core.List<UserAccount> get accounts => $_getList(1);

  @$pb.TagNumber(11)
  $core.String get prompt => $_getSZ(2);
  @$pb.TagNumber(11)
  set prompt($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(11)
  $core.bool hasPrompt() => $_has(2);
  @$pb.TagNumber(11)
  void clearPrompt() => clearField(11);
}

class UserAccount extends $pb.GeneratedMessage {
  factory UserAccount({
    $core.String? account,
    UserAccountType? type,
  }) {
    final $result = create();
    if (account != null) {
      $result.account = account;
    }
    if (type != null) {
      $result.type = type;
    }
    return $result;
  }
  UserAccount._() : super();
  factory UserAccount.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserAccount.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserAccount', package: const $pb.PackageName(_omitMessageNames ? '' : 'time_manager'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'account')
    ..e<UserAccountType>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: UserAccountType.UNKNOWN, valueOf: UserAccountType.valueOf, enumValues: UserAccountType.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserAccount clone() => UserAccount()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserAccount copyWith(void Function(UserAccount) updates) => super.copyWith((message) => updates(message as UserAccount)) as UserAccount;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserAccount create() => UserAccount._();
  UserAccount createEmptyInstance() => create();
  static $pb.PbList<UserAccount> createRepeated() => $pb.PbList<UserAccount>();
  @$core.pragma('dart2js:noInline')
  static UserAccount getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserAccount>(create);
  static UserAccount? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get account => $_getSZ(0);
  @$pb.TagNumber(1)
  set account($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => clearField(1);

  @$pb.TagNumber(2)
  UserAccountType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(UserAccountType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
