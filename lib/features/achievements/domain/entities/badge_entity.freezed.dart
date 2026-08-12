// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BadgeEntity {

 String get badgeId; String get title; String get icon; AchievementRarity get rarity; bool get featured; DateTime get earnedAt;
/// Create a copy of BadgeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadgeEntityCopyWith<BadgeEntity> get copyWith => _$BadgeEntityCopyWithImpl<BadgeEntity>(this as BadgeEntity, _$identity);

  /// Serializes this BadgeEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BadgeEntity&&(identical(other.badgeId, badgeId) || other.badgeId == badgeId)&&(identical(other.title, title) || other.title == title)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.featured, featured) || other.featured == featured)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,badgeId,title,icon,rarity,featured,earnedAt);

@override
String toString() {
  return 'BadgeEntity(badgeId: $badgeId, title: $title, icon: $icon, rarity: $rarity, featured: $featured, earnedAt: $earnedAt)';
}


}

/// @nodoc
abstract mixin class $BadgeEntityCopyWith<$Res>  {
  factory $BadgeEntityCopyWith(BadgeEntity value, $Res Function(BadgeEntity) _then) = _$BadgeEntityCopyWithImpl;
@useResult
$Res call({
 String badgeId, String title, String icon, AchievementRarity rarity, bool featured, DateTime earnedAt
});




}
/// @nodoc
class _$BadgeEntityCopyWithImpl<$Res>
    implements $BadgeEntityCopyWith<$Res> {
  _$BadgeEntityCopyWithImpl(this._self, this._then);

  final BadgeEntity _self;
  final $Res Function(BadgeEntity) _then;

/// Create a copy of BadgeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? badgeId = null,Object? title = null,Object? icon = null,Object? rarity = null,Object? featured = null,Object? earnedAt = null,}) {
  return _then(BadgeEntity(
badgeId: null == badgeId ? _self.badgeId : badgeId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,earnedAt: null == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BadgeEntity].
extension BadgeEntityPatterns on BadgeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BadgeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BadgeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BadgeEntity value)  $default,){
final _that = this;
switch (_that) {
case _BadgeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BadgeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _BadgeEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String badgeId,  String title,  String icon,  AchievementRarity rarity,  bool featured,  DateTime earnedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BadgeEntity() when $default != null:
return $default(_that.badgeId,_that.title,_that.icon,_that.rarity,_that.featured,_that.earnedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String badgeId,  String title,  String icon,  AchievementRarity rarity,  bool featured,  DateTime earnedAt)  $default,) {final _that = this;
switch (_that) {
case _BadgeEntity():
return $default(_that.badgeId,_that.title,_that.icon,_that.rarity,_that.featured,_that.earnedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String badgeId,  String title,  String icon,  AchievementRarity rarity,  bool featured,  DateTime earnedAt)?  $default,) {final _that = this;
switch (_that) {
case _BadgeEntity() when $default != null:
return $default(_that.badgeId,_that.title,_that.icon,_that.rarity,_that.featured,_that.earnedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BadgeEntity implements BadgeEntity {
  const _BadgeEntity({required this.badgeId, required this.title, required this.icon, required this.rarity, this.featured = false, required this.earnedAt});
  factory _BadgeEntity.fromJson(Map<String, dynamic> json) => _$BadgeEntityFromJson(json);

@override final  String badgeId;
@override final  String title;
@override final  String icon;
@override final  AchievementRarity rarity;
@override@JsonKey() final  bool featured;
@override final  DateTime earnedAt;

/// Create a copy of BadgeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadgeEntityCopyWith<_BadgeEntity> get copyWith => __$BadgeEntityCopyWithImpl<_BadgeEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BadgeEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadgeEntity&&(identical(other.badgeId, badgeId) || other.badgeId == badgeId)&&(identical(other.title, title) || other.title == title)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.featured, featured) || other.featured == featured)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,badgeId,title,icon,rarity,featured,earnedAt);

@override
String toString() {
  return 'BadgeEntity(badgeId: $badgeId, title: $title, icon: $icon, rarity: $rarity, featured: $featured, earnedAt: $earnedAt)';
}


}

/// @nodoc
abstract mixin class _$BadgeEntityCopyWith<$Res> implements $BadgeEntityCopyWith<$Res> {
  factory _$BadgeEntityCopyWith(_BadgeEntity value, $Res Function(_BadgeEntity) _then) = __$BadgeEntityCopyWithImpl;
@override @useResult
$Res call({
 String badgeId, String title, String icon, AchievementRarity rarity, bool featured, DateTime earnedAt
});




}
/// @nodoc
class __$BadgeEntityCopyWithImpl<$Res>
    implements _$BadgeEntityCopyWith<$Res> {
  __$BadgeEntityCopyWithImpl(this._self, this._then);

  final _BadgeEntity _self;
  final $Res Function(_BadgeEntity) _then;

/// Create a copy of BadgeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? badgeId = null,Object? title = null,Object? icon = null,Object? rarity = null,Object? featured = null,Object? earnedAt = null,}) {
  return _then(_BadgeEntity(
badgeId: null == badgeId ? _self.badgeId : badgeId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,earnedAt: null == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
