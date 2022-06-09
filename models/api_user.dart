import 'dart:convert';

import 'api.dart';
import 'api_models/api_models.dart';
import 'api_models/post_models/post_models.dart';
import 'api_models/user_models/user_models.dart';

class ApiUser {
  final Api api;

  Future<List<ApiPostResponse>> getUserPosts(
    ApiUserPostsRequestModel model, {
    required String token,
  }) async {
    ApiResponse<String> response = await api.get(
      route: '/users/${model.id}/posts',
      query: model,
      token: token,
    );
    List<dynamic> array = jsonDecode(response.body!);

    return ApiPostResponse.fromJsonArray(array);
  }

  Future<ApiUserResponse> getProfile(ApiUserRequestModel model,
      {required String token}) async {
    ApiResponse<String> response = await api.get(
      route: '/users/${model.username}',
      token: token,
    );
    Map<String, dynamic> json = jsonDecode(response.body!);
    return ApiUserResponse.fromJson(json);
  }

  Future<ApiUserResponse> getMyProfile({required String token}) async {
    ApiResponse<String> response = await api.get(
      route: '/me',
      token: token,
    );
    Map<String, dynamic> json = jsonDecode(response.body!);
    return ApiUserResponse.fromJson(json);
  }

  Future<ApiUserResponse> updateProfile(ApiUserUpdateRequestModel body,
      {required String token}) async {
    ApiResponse<String> response = await api.put(
      route: '/users',
      body: body,
      token: token,
    );
    Map<String, dynamic> json = jsonDecode(response.body!);
    return ApiUserResponse.fromJson(json);
  }



  const ApiUser(this.api);
}
