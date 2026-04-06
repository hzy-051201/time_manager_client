//
//  Generated code. Do not modify.
//  source: task.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use taskDescriptor instead')
const Task$json = {
  '1': 'Task',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'summary', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'summary', '17': true},
    {'1': 'startTime', '3': 3, '4': 1, '5': 3, '9': 1, '10': 'startTime', '17': true},
    {'1': 'startTimePrecision', '3': 4, '4': 1, '5': 5, '9': 2, '10': 'startTimePrecision', '17': true},
    {'1': 'endTime', '3': 5, '4': 1, '5': 3, '9': 3, '10': 'endTime', '17': true},
    {'1': 'endTimePrecision', '3': 6, '4': 1, '5': 5, '9': 4, '10': 'endTimePrecision', '17': true},
    {'1': 'importance', '3': 7, '4': 1, '5': 5, '9': 5, '10': 'importance', '17': true},
    {'1': 'location', '3': 8, '4': 1, '5': 9, '9': 6, '10': 'location', '17': true},
    {'1': 'participant', '3': 9, '4': 1, '5': 9, '9': 7, '10': 'participant', '17': true},
    {'1': 'note', '3': 10, '4': 1, '5': 9, '9': 8, '10': 'note', '17': true},
    {'1': 'source', '3': 11, '4': 1, '5': 9, '9': 9, '10': 'source', '17': true},
    {'1': 'content', '3': 12, '4': 1, '5': 9, '9': 10, '10': 'content', '17': true},
    {'1': 'status', '3': 13, '4': 1, '5': 5, '9': 11, '10': 'status', '17': true},
    {'1': 'noticeTimes', '3': 14, '4': 3, '5': 3, '10': 'noticeTimes'},
    {'1': 'tags', '3': 15, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'lat', '3': 16, '4': 1, '5': 1, '9': 12, '10': 'lat', '17': true},
    {'1': 'lng', '3': 17, '4': 1, '5': 1, '9': 13, '10': 'lng', '17': true},
    {'1': 'autoTask', '3': 20, '4': 1, '5': 11, '6': '.time_manager.AutoTask', '9': 14, '10': 'autoTask', '17': true},
    {'1': 'updateTimestampAt', '3': 100, '4': 1, '5': 3, '10': 'updateTimestampAt'},
  ],
  '8': [
    {'1': '_summary'},
    {'1': '_startTime'},
    {'1': '_startTimePrecision'},
    {'1': '_endTime'},
    {'1': '_endTimePrecision'},
    {'1': '_importance'},
    {'1': '_location'},
    {'1': '_participant'},
    {'1': '_note'},
    {'1': '_source'},
    {'1': '_content'},
    {'1': '_status'},
    {'1': '_lat'},
    {'1': '_lng'},
    {'1': '_autoTask'},
  ],
};

/// Descriptor for `Task`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDescriptor = $convert.base64Decode(
    'CgRUYXNrEhQKBXRpdGxlGAEgASgJUgV0aXRsZRIdCgdzdW1tYXJ5GAIgASgJSABSB3N1bW1hcn'
    'mIAQESIQoJc3RhcnRUaW1lGAMgASgDSAFSCXN0YXJ0VGltZYgBARIzChJzdGFydFRpbWVQcmVj'
    'aXNpb24YBCABKAVIAlISc3RhcnRUaW1lUHJlY2lzaW9uiAEBEh0KB2VuZFRpbWUYBSABKANIA1'
    'IHZW5kVGltZYgBARIvChBlbmRUaW1lUHJlY2lzaW9uGAYgASgFSARSEGVuZFRpbWVQcmVjaXNp'
    'b26IAQESIwoKaW1wb3J0YW5jZRgHIAEoBUgFUgppbXBvcnRhbmNliAEBEh8KCGxvY2F0aW9uGA'
    'ggASgJSAZSCGxvY2F0aW9uiAEBEiUKC3BhcnRpY2lwYW50GAkgASgJSAdSC3BhcnRpY2lwYW50'
    'iAEBEhcKBG5vdGUYCiABKAlICFIEbm90ZYgBARIbCgZzb3VyY2UYCyABKAlICVIGc291cmNliA'
    'EBEh0KB2NvbnRlbnQYDCABKAlIClIHY29udGVudIgBARIbCgZzdGF0dXMYDSABKAVIC1IGc3Rh'
    'dHVziAEBEiAKC25vdGljZVRpbWVzGA4gAygDUgtub3RpY2VUaW1lcxISCgR0YWdzGA8gAygJUg'
    'R0YWdzEhUKA2xhdBgQIAEoAUgMUgNsYXSIAQESFQoDbG5nGBEgASgBSA1SA2xuZ4gBARI3Cghh'
    'dXRvVGFzaxgUIAEoCzIWLnRpbWVfbWFuYWdlci5BdXRvVGFza0gOUghhdXRvVGFza4gBARIsCh'
    'F1cGRhdGVUaW1lc3RhbXBBdBhkIAEoA1IRdXBkYXRlVGltZXN0YW1wQXRCCgoIX3N1bW1hcnlC'
    'DAoKX3N0YXJ0VGltZUIVChNfc3RhcnRUaW1lUHJlY2lzaW9uQgoKCF9lbmRUaW1lQhMKEV9lbm'
    'RUaW1lUHJlY2lzaW9uQg0KC19pbXBvcnRhbmNlQgsKCV9sb2NhdGlvbkIOCgxfcGFydGljaXBh'
    'bnRCBwoFX25vdGVCCQoHX3NvdXJjZUIKCghfY29udGVudEIJCgdfc3RhdHVzQgYKBF9sYXRCBg'
    'oEX2xuZ0ILCglfYXV0b1Rhc2s=');

