import 'dart:async';

import 'package:adviser/adviser/fca/data/enums/app_status.dart';
import 'package:adviser/adviser/fca/data/repository/app_repository.dart';
import 'package:adviser/adviser/fca/domain/app_entity/error_entity.dart';
import 'package:adviser/adviser/fca/domain/app_entity/user_profile_entity.dart';

import '../app_use_case.dart';

///Params
class UpdateProfileParams {
  final String lastName;
  final String firstName;
  final String username;
  final String phone;
  final String email;

  const UpdateProfileParams({
    required this.lastName,
    required this.firstName,
    required this.username,
    required this.phone,
    required this.email,
  });
}

///Response [AppCaseResponse]

///UseCase
class UpdateProfileCase extends AppUseCase<AppCaseResponse, UpdateProfileParams> {
  static const tag = 'UpdateProfile';

  @override
  buildUseCase(
      StreamController<AppCaseResponse> controller,
      UpdateProfileParams params,
      ) async {
    UserProfileEntity user =
    await AppRepository.user.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      username: params.username,
      email: params.email,
    );
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
      UpdateProfileParams? params,
      ErrorEntity error,
      ) {
    controller.addError(AppCaseError.from(error, caseTag: tag));
  }
}
