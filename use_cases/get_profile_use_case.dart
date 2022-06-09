import 'dart:async';

import 'package:adviser/adviser/fca/data/enums/app_status.dart';
import 'package:adviser/adviser/fca/data/repository/app_repository.dart';
import 'package:adviser/adviser/fca/domain/app_entity/error_entity.dart';
import 'package:adviser/adviser/fca/domain/app_entity/user_profile_entity.dart';

import '../app_use_case.dart';

///Params
class ProfileParams {
  final String? username;

  const ProfileParams({this.username});
}

///Response [AppCaseResponse]

///UseCase
class ProfileCase extends AppUseCase<AppCaseResponse, ProfileParams> {
  static const tag = 'Profile';

  @override
  buildUseCase(
    StreamController<AppCaseResponse> controller,
    ProfileParams params,
  ) async {
    UserProfileEntity user =
        await AppRepository.user.getProfile(username: params.username);
    controller.add(
      AppCaseResponse<UserProfileEntity>(
        caseTag: tag,
        status: AppStatus.success,
        data: user,
      ),
    );
  }

  @override
  errorReceiving(
    StreamController<AppCaseResponse> controller,
    ProfileParams? params,
    ErrorEntity error,
  ) {
    controller.addError(AppCaseError.from(error, caseTag: tag));
  }
}
