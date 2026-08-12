// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AchievementEntity {

 String get achievementId; String get title; String get description; AchievementCategory get category; AchievementRarity get rarity; double get progress; double get target; bool get completed; int get rewardXP; String? get badgeId; bool get hidden; DateTime? get completedAt; DateTime get createdAt;
/// Create a copy of AchievementEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementEntityCopyWith<AchievementEntity> get copyWith => _$AchievementEntityCopyWithImpl<AchievementEntity>(this as AchievementEntity, _$identity);

  /// Serializes this AchievementEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AchievementEntity&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.target, target) || other.target == target)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.rewardXP, rewardXP) || other.rewardXP == rewardXP)&&(identical(other.badgeId, badgeId) || other.badgeId == badgeId)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,achievementId,title,description,category,rarity,progress,target,completed,rewardXP,badgeId,hidden,completedAt,createdAt);

@override
String toString() {
  return 'AchievementEntity(achievementId: $achievementId, title: $title, description: $description, category: $category, rarity: $rarity, progress: $progress, target: $target, completed: $completed, rewardXP: $rewardXP, badgeId: $badgeId, hidden: $hidden, completedAt: $completedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AchievementEntityCopyWith<$Res>  {
  factory $AchievementEntityCopyWith(AchievementEntity value, $Res Function(AchievementEntity) _then) = _$AchievementEntityCopyWithImpl;
@useResult
$Res call({
 String achievementId, String title, String description, AchievementCategory category, AchievementRarity rarity, double progress, double target, bool completed, int rewardXP, String? badgeId, bool hidden, DateTime? completedAt, DateTime createdAt
});




}
/// @nodoc
class _$AchievementEntityCopyWithImpl<$Res>
    implements $AchievementEntityCopyWith<$Res> {
  _$AchievementEntityCopyWithImpl(this._self, this._then);

  final AchievementEntity _self;
  final $Res Function(AchievementEntity) _then;

/// Create a copy of AchievementEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? achievementId = null,Object? title = null,Object? description = null,Object? category = null,Object? rarity = null,Object? progress = null,Object? target = null,Object? completed = null,Object? rewardXP = null,Object? badgeId = freezed,Object? hidden = null,Object? completedAt = freezed,Object? createdAt = null,}) {
  return _then(AchievementEntity(
achievementId: null == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AchievementCategory,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,rewardXP: null == rewardXP ? _self.rewardXP : rewardXP // ignore: cast_nullable_to_non_nullable
as int,badgeId: freezed == badgeId ? _self.badgeId : badgeId // ignore: cast_nullable_to_non_nullable
as String?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AchievementEntity].
extension AchievementEntityPatterns on AchievementEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AchievementEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AchievementEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AchievementEntity value)  $default,){
final _that = this;
switch (_that) {
case _AchievementEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AchievementEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AchievementEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String achievementId,  String title,  String description,  AchievementCategory category,  AchievementRarity rarity,  double progress,  double target,  bool completed,  int rewardXP,  String? badgeId,  bool hidden,  DateTime? completedAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AchievementEntity() when $default != null:
return $default(_that.achievementId,_that.title,_that.description,_that.category,_that.rarity,_that.progress,_that.target,_that.completed,_that.rewardXP,_that.badgeId,_that.hidden,_that.completedAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String achievementId,  String title,  String description,  AchievementCategory category,  AchievementRarity rarity,  double progress,  double target,  bool completed,  int rewardXP,  String? badgeId,  bool hidden,  DateTime? completedAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AchievementEntity():
return $default(_that.achievementId,_that.title,_that.description,_that.category,_that.rarity,_that.progress,_that.target,_that.completed,_that.rewardXP,_that.badgeId,_that.hidden,_that.completedAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String achievementId,  String title,  String description,  AchievementCategory category,  AchievementRarity rarity,  double progress,  double target,  bool completed,  int rewardXP,  String? badgeId,  bool hidden,  DateTime? completedAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AchievementEntity() when $default != null:
return $default(_that.achievementId,_that.title,_that.description,_that.category,_that.rarity,_that.progress,_that.target,_that.completed,_that.rewardXP,_that.badgeId,_that.hidden,_that.completedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AchievementEntity implements AchievementEntity {
  const _AchievementEntity({required this.achievementId, required this.title, required this.description, required this.category, required this.rarity, this.progress = 0.0, required this.target, this.completed = false, this.rewardXP = 0, this.badgeId, this.hidden = false, this.completedAt, required this.createdAt});
  factory _AchievementEntity.fromJson(Map<String, dynamic> json) => _$AchievementEntityFromJson(json);

@override final  String achievementId;
@override final  String title;
@override final  String description;
@override final  AchievementCategory category;
@override final  AchievementRarity rarity;
@override@JsonKey() final  double progress;
@override final  double target;
@override@JsonKey() final  bool completed;
@override@JsonKey() final  int rewardXP;
@override final  String? badgeId;
@override@JsonKey() final  bool hidden;
@override final  DateTime? completedAt;
@override final  DateTime createdAt;

/// Create a copy of AchievementEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementEntityCopyWith<_AchievementEntity> get copyWith => __$AchievementEntityCopyWithImpl<_AchievementEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AchievementEntity&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.target, target) || other.target == target)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.rewardXP, rewardXP) || other.rewardXP == rewardXP)&&(identical(other.badgeId, badgeId) || other.badgeId == badgeId)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,achievementId,title,description,category,rarity,progress,target,completed,rewardXP,badgeId,hidden,completedAt,createdAt);

@override
String toString() {
  return 'AchievementEntity(achievementId: $achievementId, title: $title, description: $description, category: $category, rarity: $rarity, progress: $progress, target: $target, completed: $completed, rewardXP: $rewardXP, badgeId: $badgeId, hidden: $hidden, completedAt: $completedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AchievementEntityCopyWith<$Res> implements $AchievementEntityCopyWith<$Res> {
  factory _$AchievementEntityCopyWith(_AchievementEntity value, $Res Function(_AchievementEntity) _then) = __$AchievementEntityCopyWithImpl;
@override @useResult
$Res call({
 String achievementId, String title, String description, AchievementCategory category, AchievementRarity rarity, double progress, double target, bool completed, int rewardXP, String? badgeId, bool hidden, DateTime? completedAt, DateTime createdAt
});




}
/// @nodoc
class __$AchievementEntityCopyWithImpl<$Res>
    implements _$AchievementEntityCopyWith<$Res> {
  __$AchievementEntityCopyWithImpl(this._self, this._then);

  final _AchievementEntity _self;
  final $Res Function(_AchievementEntity) _then;

/// Create a copy of AchievementEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? achievementId = null,Object? title = null,Object? description = null,Object? category = null,Object? rarity = null,Object? progress = null,Object? target = null,Object? completed = null,Object? rewardXP = null,Object? badgeId = freezed,Object? hidden = null,Object? completedAt = freezed,Object? createdAt = null,}) {
  return _then(_AchievementEntity(
achievementId: null == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AchievementCategory,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,rewardXP: null == rewardXP ? _self.rewardXP : rewardXP // ignore: cast_nullable_to_non_nullable
as int,badgeId: freezed == badgeId ? _self.badgeId : badgeId // ignore: cast_nullable_to_non_nullable
as String?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
