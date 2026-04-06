//
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userAccountTypeDescriptor instead')
const UserAccountType$json = {
  '1': 'UserAccountType',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'PHONE', '2': 1},
    {'1': 'WECHAT_OPENID', '2': 2},
  ],
};

/// Descriptor for `UserAccountType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userAccountTypeDescriptor = $convert.base64Decode(
    'Cg9Vc2VyQWNjb3VudFR5cGUSCwoHVU5LTk9XThAAEgkKBVBIT05FEAESEQoNV0VDSEFUX09QRU'
    '5JRBAC');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'accounts', '3': 10, '4': 3, '5': 11, '6': '.time_manager.UserAccount', '10': 'accounts'},
    {'1': 'prompt', '3': 11, '4': 1, '5': 9, '9': 0, '10': 'prompt', '17': true},
  ],
  '8': [
    {'1': '_prompt'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgDUgJpZBI1CghhY2NvdW50cxgKIAMoCzIZLnRpbWVfbWFuYWdlci'
    '5Vc2VyQWNjb3VudFIIYWNjb3VudHMSGwoGcHJvbXB0GAsgASgJSABSBnByb21wdIgBAUIJCgdf'
    'cHJvbXB0');

@$core.Deprecated('Use userAccountDescriptor instead')
const UserAccount$json = {
  '1': 'UserAccount',
  '2': [
    {'1': 'account', '3': 1, '4': 1, '5': 9, '10': 'account'},
    {'1': 'type', '3': 2, '4': 1, '5': 14, '6': '.time_manager.UserAccountType', '10': 'type'},
  ],
};

/// Descriptor for `UserAccount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userAccountDescriptor = $convert.base64Decode(
    'CgtVc2VyQWNjb3VudBIYCgdhY2NvdW50GAEgASgJUgdhY2NvdW50EjEKBHR5cGUYAiABKA4yHS'
    '50aW1lX21hbmFnZXIuVXNlckFjY291bnRUeXBlUgR0eXBl');

