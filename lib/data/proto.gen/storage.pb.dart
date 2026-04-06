//
//  Generated code. Do not modify.
//  source: storage.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'group.pb.dart' as $2;
import 'task.pb.dart' as $1;
import 'user.pb.dart' as $0;

class Storage extends $pb.GeneratedMessage {
  factory Storage({
    $core.Map<$fixnum.Int64, $1.Task>? tasks,
    $core.Map<$fixnum.Int64, $2.Group>? groups,
    $core.Iterable<$fixnum.Int64>? groupIds,
    $fixnum.Int64? currentGroupId,
    $0.User? user,
  }) {
    final $result = create();
    if (tasks != null) {
      $result.tasks.addAll(tasks);
    }
    if (groups != null) {
      $result.groups.addAll(groups);
    }
    if (groupIds != null) {
      $result.groupIds.addAll(groupIds);
    }
    if (currentGroupId != null) {
      $result.currentGroupId = currentGroupId;
    }
    if (user != null) {
      $result.user = user;
    }
    return $result;
  }
  Storage._() : super();
  factory Storage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Storage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Storage', package: const $pb.PackageName(_omitMessageNames ? '' : 'time_manager'), createEmptyInstance: create)
    ..m<$fixnum.Int64, $1.Task>(1, _omitFieldNames ? '' : 'tasks', entryClassName: 'Storage.TasksEntry', keyFieldType: $pb.PbFieldType.OU6, valueFieldType: $pb.PbFieldType.OM, valueCreator: $1.Task.create, valueDefaultOrMaker: $1.Task.getDefault, packageName: const $pb.PackageName('time_manager'))
    ..m<$fixnum.Int64, $2.Group>(2, _omitFieldNames ? '' : 'groups', entryClassName: 'Storage.GroupsEntry', keyFieldType: $pb.PbFieldType.OU6, valueFieldType: $pb.PbFieldType.OM, valueCreator: $2.Group.create, valueDefaultOrMaker: $2.Group.getDefault, packageName: const $pb.PackageName('time_manager'))
    ..p<$fixnum.Int64>(3, _omitFieldNames ? '' : 'groupIds', $pb.PbFieldType.KU6, protoName: 'groupIds')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'currentGroupId', $pb.PbFieldType.OU6, protoName: 'currentGroupId', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.User>(5, _omitFieldNames ? '' : 'user', subBuilder: $0.User.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Storage clone() => Storage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Storage copyWith(void Function(Storage) updates) => super.copyWith((message) => updates(message as Storage)) as Storage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Storage create() => Storage._();
  Storage createEmptyInstance() => create();
  static $pb.PbList<Storage> createRepeated() => $pb.PbList<Storage>();
  @$core.pragma('dart2js:noInline')
  static Storage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Storage>(create);
  static Storage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$fixnum.Int64, $1.Task> get tasks => $_getMap(0);

  @$pb.TagNumber(2)
  $core.Map<$fixnum.Int64, $2.Group> get groups => $_getMap(1);

  @$pb.TagNumber(3)
  $core.List<$fixnum.Int64> get groupIds => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get currentGroupId => $_getI64(3);
  @$pb.TagNumber(4)
  set currentGroupId($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCurrentGroupId() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrentGroupId() => clearField(4);

  @$pb.TagNumber(5)
  $0.User get user => $_getN(4);
  @$pb.TagNumber(5)
  set user($0.User v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasUser() => $_has(4);
  @$pb.TagNumber(5)
  void clearUser() => clearField(5);
  @$pb.TagNumber(5)
  $0.User ensureUser() => $_ensure(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
