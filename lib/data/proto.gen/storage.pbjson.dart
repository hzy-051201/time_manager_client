//
//  Generated code. Do not modify.
//  source: storage.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use storageDescriptor instead')
const Storage$json = {
  '1': 'Storage',
  '2': [
    {'1': 'tasks', '3': 1, '4': 3, '5': 11, '6': '.time_manager.Storage.TasksEntry', '10': 'tasks'},
    {'1': 'groups', '3': 2, '4': 3, '5': 11, '6': '.time_manager.Storage.GroupsEntry', '10': 'groups'},
    {'1': 'groupIds', '3': 3, '4': 3, '5': 4, '10': 'groupIds'},
    {'1': 'currentGroupId', '3': 4, '4': 1, '5': 4, '10': 'currentGroupId'},
    {'1': 'user', '3': 5, '4': 1, '5': 11, '6': '.time_manager.User', '9': 0, '10': 'user', '17': true},
  ],
  '3': [Storage_TasksEntry$json, Storage_GroupsEntry$json],
  '8': [
    {'1': '_user'},
  ],
};

@$core.Deprecated('Use storageDescriptor instead')
const Storage_TasksEntry$json = {
  '1': 'TasksEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 4, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.time_manager.Task', '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use storageDescriptor instead')
const Storage_GroupsEntry$json = {
  '1': 'GroupsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 4, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.time_manager.Group', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Storage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storageDescriptor = $convert.base64Decode(
    'CgdTdG9yYWdlEjYKBXRhc2tzGAEgAygLMiAudGltZV9tYW5hZ2VyLlN0b3JhZ2UuVGFza3NFbn'
    'RyeVIFdGFza3MSOQoGZ3JvdXBzGAIgAygLMiEudGltZV9tYW5hZ2VyLlN0b3JhZ2UuR3JvdXBz'
    'RW50cnlSBmdyb3VwcxIaCghncm91cElkcxgDIAMoBFIIZ3JvdXBJZHMSJgoOY3VycmVudEdyb3'
    'VwSWQYBCABKARSDmN1cnJlbnRHcm91cElkEisKBHVzZXIYBSABKAsyEi50aW1lX21hbmFnZXIu'
    'VXNlckgAUgR1c2VyiAEBGkwKClRhc2tzRW50cnkSEAoDa2V5GAEgASgEUgNrZXkSKAoFdmFsdW'
    'UYAiABKAsyEi50aW1lX21hbmFnZXIuVGFza1IFdmFsdWU6AjgBGk4KC0dyb3Vwc0VudHJ5EhAK'
    'A2tleRgBIAEoBFIDa2V5EikKBXZhbHVlGAIgASgLMhMudGltZV9tYW5hZ2VyLkdyb3VwUgV2YW'
    'x1ZToCOAFCBwoFX3VzZXI=');

