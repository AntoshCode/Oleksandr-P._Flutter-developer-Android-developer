// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiUserResponse _$ApiUserResponseFromJson(Map<String, dynamic> json) =>
    ApiUserResponse(
      id: json['id'] as int,
      cityId: json['city_id'] as int?,
      categoryId: json['category_id'] as int?,
      avatar: json['avatar'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      bornAt: json['born_at'] == null
          ? null
          : DateTime.parse(json['born_at'] as String),
      gender: json['gender'] as int?,
      account: json['account'] as int?,
      role: json['role'] as int?,
      isActive: json['is_active'] as int?,
      isBlocked: json['is_blocked'] as int?,
      isDeleted: json['is_deleted'] as int?,
      rememberMeToken: json['remember_me_token'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isAllowed: json['is_allowed'] as int?,
      fullName: json['full_name'] as String?,
      data: json['data'] == null
          ? null
          : ApiUserData.fromJson(json['data'] as Map<String, dynamic>),
      posts: (json['posts'] as List<dynamic>?)
          ?.map((e) => ApiPostResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ApiUserResponseToJson(ApiUserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'city_id': instance.cityId,
      'avatar': instance.avatar,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'username': instance.username,
      'phone': instance.phone,
      'email': instance.email,
      'description': instance.description,
      'born_at': instance.bornAt?.toIso8601String(),
      'gender': instance.gender,
      'account': instance.account,
      'role': instance.role,
      'is_active': instance.isActive,
      'is_blocked': instance.isBlocked,
      'is_deleted': instance.isDeleted,
      'remember_me_token': instance.rememberMeToken,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_allowed': instance.isAllowed,
      'full_name': instance.fullName,
      'data': instance.data,
      'posts': instance.posts,
    };

ApiUserData _$ApiUserDataFromJson(Map<String, dynamic> json) => ApiUserData(
      rating: (json['rating'] as num?)?.toDouble(),
      postCount: json['post_count'] as int?,
      subscriberCount: json['subscriber_count'] as int?,
      subscriptionCount: json['subscription_count'] as int?,
    );

Map<String, dynamic> _$ApiUserDataToJson(ApiUserData instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'post_count': instance.postCount,
      'subscriber_count': instance.subscriberCount,
      'subscription_count': instance.subscriptionCount,
    };
