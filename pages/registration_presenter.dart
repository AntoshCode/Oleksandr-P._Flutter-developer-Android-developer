import 'package:adviser/adviser/fca/data/api/api_models/auth_models.dart';
import 'package:adviser/adviser/fca/data/enums/app_enums.dart';
import 'package:adviser/adviser/fca/domain/use_cases/app_use_case.dart';
import 'package:adviser/adviser/fca/domain/use_cases/auth/register_account_use_case.dart';
import 'package:adviser/adviser/fca/domain/use_cases/auth/register_name_use_case.dart';
import 'package:adviser/adviser/fca/domain/use_cases/auth/register_password_use_case.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

abstract class RegistrationPresenterDelegate {
  void onRegistrationSuccess();

  void onRegistrationError(String message);
}

class RegistrationPresenter extends Presenter
    implements Observer<AppCaseResponse> {
  final RegisterNameUseCase _registerNameUseCase = RegisterNameUseCase();
  final RegisterPasswordUseCase _registerPasswordUseCase =
      RegisterPasswordUseCase();
  final RegisterAccountUseCase _registerAccountUseCase =
      RegisterAccountUseCase();
  final RegistrationPresenterDelegate delegate;
  bool registerSuccess = false;

  RegistrationPresenter(this.delegate);

  void registerNameWithEmail(
    String username,
    String firstName,
    String email,
  ) {
    registerSuccess = false;
    _registerNameUseCase.execute(
      this,
      ApiRegisterNameEmailModel(
        email: email,
        username: username,
        firstName: firstName,
      ),
    );
  }

  void registerNameWithPhone(
    String username,
    String firstName,
    String phone,
  ) {
    registerSuccess = false;
    _registerNameUseCase.execute(
      this,
      ApiRegisterNamePhoneModel(
        phone: phone,
        username: username,
        firstName: firstName,
      ),
    );
  }

  void registerPassword(String password) {
    registerSuccess = false;
    _registerPasswordUseCase.execute(
      this,
      ApiRegisterPasswordModel(password: password),
    );
  }

  void registerAccountWithEmail(
    String email,
    String username,
    String firstName,
    String password,
    AccountType account,
  ) {
    registerSuccess = false;
    _registerAccountUseCase.execute(
      this,
      ApiRegisterAccountEmailModel(
        email: email,
        username: username,
        firstName: firstName,
        password: password,
        account: account,
      ),
    );
  }

  void registerAccountWithPhone(
    String phone,
    String username,
    String firstName,
    String password,
    AccountType account,
  ) {
    registerSuccess = false;
    _registerAccountUseCase.execute(
      this,
      ApiRegisterAccountPhoneModel(
        phone: phone,
        username: username,
        firstName: firstName,
        password: password,
        account: account,
      ),
    );
  }

  @override
  void dispose() {
    _registerNameUseCase.dispose();
    _registerPasswordUseCase.dispose();
    _registerAccountUseCase.dispose();
  }

  @override
  void onComplete() {
    if (registerSuccess) delegate.onRegistrationSuccess();
  }

  @override
  void onError(e) {
    if (e is AppCaseError) delegate.onRegistrationError(e.message);
  }

  @override
  void onNext(AppCaseResponse? response) {
    registerSuccess = true;
  }
}
