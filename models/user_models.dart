import 'package:adviser/adviser/fca/data/api/api_models/post_models/post_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';

import '../api_models.dart';

part 'user_models.g.dart';

class ApiUserRequestModel {
  String username;

  ApiUserRequestModel({required this.username});
}

class ApiUserPostsRequestModel implements DataMap {
  int id;
  int? page;

  ApiUserPostsRequestModel({required this.id, this.page});

  @override
  Map<String, Object> get map => {if (page != null) 'page': page!};
}

class ApiUserUpdateRequestModel implements DataMap {
  String? firstName;
  String? lastName;
  String? phone;
  String? username;
  String? email;
  XFile? avatar;
  String? description;
  String? bornAt;
  int? cityId;
  int? gender;

  ApiUserUpdateRequestModel({
    this.firstName,
    this.lastName,
    this.phone,
    this.username,
    this.email,
    this.avatar,
    this.description,
    this.bornAt,
    this.cityId,
    this.gender,
  });

  @override
  Map<String, Object> get map => {
    if (firstName != null) 'firstName': firstName!,
    if (lastName != null) 'lastName': lastName!,
    if (phone != null && phone!.isNotEmpty) 'phone': phone!,
    if (username != null) 'username': username!,
    if (email != null && email!.isNotEmpty) 'email': email!,
    if (avatar != null) 'avatar': avatar!,
    if (description != null) 'description': description!,
    if (bornAt != null) 'born_at': bornAt!,
    if (cityId != null) 'city_id': cityId!,
    if (gender != null) 'gender': gender!,
  };
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ApiUserResponse {
  final int id;
  final int? categoryId;
  final int? cityId;
  final String? avatar;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? phone;
  final String? email;
  final String? description;
  final DateTime? bornAt;
  final int? gender;
  final int? account;
  final int? role;
  final int? isActive;
  final int? isBlocked;
  final int? isDeleted;
  final String? rememberMeToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? isAllowed;
  final String? fullName;
  ApiUserData? data;
  List<ApiPostResponse>? posts;

  ApiUserResponse({
    required this.id,
    this.cityId,
    this.categoryId,
    this.avatar,
    this.firstName,
    this.lastName,
    this.username,
    this.phone,
    this.email,
    this.description,
    this.bornAt,
    this.gender,
    this.account,
    this.role,
    this.isActive,
    this.isBlocked,
    this.isDeleted,
    this.rememberMeToken,
    this.createdAt,
    this.updatedAt,
    this.isAllowed,
    this.fullName,
    this.data,
    this.posts,
  });

  factory ApiUserResponse.fromJson(Map<String, dynamic> data) =>
      _$ApiUserResponseFromJson(data);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ApiUserData {
  final double? rating;
  final int? postCount;
  final int? subscriberCount;
  final int? subscriptionCount;

  ApiUserData({
    this.rating,
    this.postCount,
    this.subscriberCount,
    this.subscriptionCount,
  });

  factory ApiUserData.fromJson(Map<String, dynamic> data) =>
      _$ApiUserDataFromJson(data);
}