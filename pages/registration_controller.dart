import 'package:adviser/adviser/fca/app/pages/base/controller.dart';
import 'package:adviser/adviser/fca/app/pages/login/registration/registration_presenter.dart';
import 'package:adviser/adviser/fca/data/enums/app_enums.dart';

class RegistrationArguments {
  String username;
  String firstName;
  String email;
  String phone;
  String? password;
  ConfirmType confirmType;

  RegistrationArguments({
    required this.username,
    required this.firstName,
    required this.confirmType,
    required this.email,
    required this.phone,
    this.password,
  }) : assert((confirmType == ConfirmType.email && email.isNotEmpty) ||
            (confirmType == ConfirmType.phone && phone.length > 6));
}

abstract class RegistrationDelegate {
  void next();
}

abstract class RegistrationController extends BaseController
    implements RegistrationDelegate, RegistrationPresenterDelegate {
  late RegistrationPresenter presenter;

  RegistrationController() : super() {
    presenter = createPresenter();
  }

  RegistrationPresenter createPresenter();

  int get stepIndex;

  @override
  void initListeners() {}

  @override
  void next();
}
