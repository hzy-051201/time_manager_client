//
//  Generated code. Do not modify.
//  source: auto_task.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class AutoTask extends $pb.GeneratedMessage {
  factory AutoTask({
    $fixnum.Int64? executeAt,
    $core.String? demand,
    $core.bool? executed,
    $core.bool? successed,
    $core.String? log,
  }) {
    final $result = create();
    if (executeAt != null) {
      $result.executeAt = executeAt;
    }
    if (demand != null) {
      $result.demand = demand;
    }
    if (executed != null) {
      $result.executed = executed;
    }
    if (successed != null) {
      $result.successed = successed;
    }
    if (log != null) {
      $result.log = log;
    }
    return $result;
  }
  AutoTask._() : super();
  factory AutoTask.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AutoTask.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AutoTask', package: const $pb.PackageName(_omitMessageNames ? '' : 'time_manager'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'executeAt', protoName: 'executeAt')
    ..aOS(2, _omitFieldNames ? '' : 'demand')
    ..aOB(3, _omitFieldNames ? '' : 'executed')
    ..aOB(4, _omitFieldNames ? '' : 'successed')
    ..aOS(5, _omitFieldNames ? '' : 'log')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AutoTask clone() => AutoTask()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AutoTask copyWith(void Function(AutoTask) updates) => super.copyWith((message) => updates(message as AutoTask)) as AutoTask;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AutoTask create() => AutoTask._();
  AutoTask createEmptyInstance() => create();
  static $pb.PbList<AutoTask> createRepeated() => $pb.PbList<AutoTask>();
  @$core.pragma('dart2js:noInline')
  static AutoTask getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AutoTask>(create);
  static AutoTask? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get executeAt => $_getI64(0);
  @$pb.TagNumber(1)
  set executeAt($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasExecuteAt() => $_has(0);
  @$pb.TagNumber(1)
  void clearExecuteAt() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get demand => $_getSZ(1);
  @$pb.TagNumber(2)
  set demand($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDemand() => $_has(1);
  @$pb.TagNumber(2)
  void clearDemand() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get executed => $_getBF(2);
  @$pb.TagNumber(3)
  set executed($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasExecuted() => $_has(2);
  @$pb.TagNumber(3)
  void clearExecuted() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get successed => $_getBF(3);
  @$pb.TagNumber(4)
  set successed($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSuccessed() => $_has(3);
  @$pb.TagNumber(4)
  void clearSuccessed() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get log => $_getSZ(4);
  @$pb.TagNumber(5)
  set log($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLog() => $_has(4);
  @$pb.TagNumber(5)
  void clearLog() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
