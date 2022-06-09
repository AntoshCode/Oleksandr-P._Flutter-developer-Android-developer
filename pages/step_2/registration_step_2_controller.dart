import 'package:adviser/adviser/fca/app/components/app_toast/app_toast.dart';
import 'package:adviser/adviser/fca/app/navigator/base_route.dart';
import 'package:adviser/adviser/fca/app/pages/login/registration/registration_controller.dart';
import 'package:adviser/adviser/fca/app/pages/login/registration/step_2/registration_step_2_presenter.dart';
import 'package:adviser/adviser/fca/data/helpers/bloc_field.dart';
import 'package:adviser/adviser/fca/data/helpers/validators/app_validators.dart';
import 'package:adviser/adviser/fca/data/helpers/debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../registration_presenter.dart';

const _messagePasswordNotMatch = 'Пароли не совпадают';
const _messagePasswordIncorrect = 'Ненадежный пароль.';
const _messagePasswordEmpty = 'Введите пароль';
const _messagePasswordEmptyRepeat = 'Подтвердите пароль';

class PasswordState {
  final bool hasLowercase;
  final bool hasUppercase;
  final bool hasSpecial;
  final bool hasPasswordLength;

  bool get correct =>
      hasLowercase && hasUppercase && hasSpecial && hasPasswordLength;

  const PasswordState({
    required this.hasLowercase,
    required this.hasUppercase,
    required this.hasSpecial,
    required this.hasPasswordLength,
  });
}

class RegisterPasswordState {
  final FieldState password;
  final FieldState passwordRepeat;
  final PasswordState passwordState;
  final String error;

  bool get isNotMatch => passwordRepeat.text != password.text;

  bool get isNotValid => !passwordState.correct || isNotMatch;

  String get errorMessage {
    if (error.isNotEmpty)
      return error;
    else if (password.errorMessage.isNotEmpty)
      return password.errorMessage;
    else if (passwordRepeat.errorMessage.isNotEmpty)
      return passwordRepeat.errorMessage;
    else
      return '';
  }

  RegisterPasswordState change({
    FieldState? password,
    FieldState? passwordRepeat,
    PasswordState? passwordState,
    String? error,
  }) {
    return RegisterPasswordState(
      password: password ?? this.password,
      passwordRepeat: passwordRepeat ?? this.passwordRepeat,
      passwordState: passwordState ?? this.passwordState,
      error: error ?? this.error,
    );
  }

  const RegisterPasswordState({
    this.password = const FieldState(),
    this.passwordRepeat = const FieldState(),
    this.passwordState = const PasswordState(
      hasLowercase: false,
      hasUppercase: false,
      hasSpecial: false,
      hasPasswordLength: false,
    ),
    this.error = '',
  });
}

class RegisterPasswordCubit extends Cubit<RegisterPasswordState> {
  Debounce debounce = Debounce();

  RegisterPasswordCubit() : super(RegisterPasswordState());

  setError(String? error, {
    FieldStatus? passwordState,
    FieldStatus? passwordRepeatState,
  }) =>
      emit(state.change(
        error: error,
        password: state.password.copyWith(status: passwordState),
        passwordRepeat: state.passwordRepeat.copyWith(status: passwordRepeatState),
      ));

  onChangePassword(String text) {
    bool match = text == state.passwordRepeat.text;
    PasswordState passwordState = PasswordState(
      hasLowercase: PasswordValidator.hasLowercase(text) ||
          PasswordValidator.hasDigits(text),
      hasUppercase: PasswordValidator.hasUppercase(text),
      hasSpecial: PasswordValidator.hasSpecial(text),
      hasPasswordLength: PasswordValidator.hasPasswordLength(text),
    );

    ///password errors
    String _passwordError;
    if (text.isEmpty)
      _passwordError = _messagePasswordEmpty;
    else if (!passwordState.correct)
      _passwordError = _messagePasswordIncorrect;
    else
      _passwordError = '';

    ///repeat password errors
    String _passwordRepeatError;
    if (state.passwordRepeat.isNotEmpty && !match)
      _passwordRepeatError = _messagePasswordNotMatch;
    else
      _passwordRepeatError = '';

    ///changes
    emit(state.change(
      passwordState: passwordState,
      password: state.password.copyWith(
        text: text,
        status: FieldState.errorWhen(_passwordError.isNotEmpty),
        error: _passwordError,
      ),
      passwordRepeat: state.passwordRepeat.copyWith(
        status: FieldState.errorWhen(_passwordRepeatError.isNotEmpty),
        error: _passwordRepeatError,
      ),
    ));
    if (!state.password.dirty)
      debounce.run(
        tag: 'password',
        action: () =>
            emit(state.change(password: state.password.copyWith(dirty: true))),
        milliseconds: 2000,
      );
  }

  onChangePasswordRepeat(String text) {
    bool match = text == state.password.text;
    String _passwordRepeatError;
    if (!match)
      _passwordRepeatError = _messagePasswordNotMatch;
    else if (state.passwordRepeat.isEmpty)
      _passwordRepeatError = _messagePasswordEmptyRepeat;
    else
      _passwordRepeatError = '';
    emit(state.change(
      passwordRepeat: state.passwordRepeat.copyWith(
        text: text,
        status: FieldState.errorWhen(_passwordRepeatError.isNotEmpty),
        error: _passwordRepeatError,
      ),
    ));
    if (!state.passwordRepeat.dirty)
      debounce.run(
        tag: 'passwordRepeat',
        action: () =>
            emit(state.change(
                passwordRepeat: state.passwordRepeat.copyWith(dirty: true))),
        milliseconds: 2000,
      );
  }
}

class RegistrationStepTwoController extends RegistrationController
    implements RegistrationPresenterDelegate {
  final RegistrationArguments arguments;
  final RegisterPasswordCubit cubit = RegisterPasswordCubit();

  final FocusNode focusPassword = FocusNode();
  final FocusNode focusRepeatPassword = FocusNode();

  late String? savePassword;

  RegistrationStepTwoController(this.arguments);

  @override
  RegistrationPresenter createPresenter() {
    return RegistrationStepTwoPresenter(this);
  }

  @override
  void next() {
    if (cubit.state.isNotValid) return;
    savePassword = cubit.state.password.text;
    presenter.registerPassword(savePassword!);
  }

  @override
  get stepIndex => 0;

  @override
  void onRegistrationError(String message) {
    AppToast.show(
      context: context,
      text: message,
      type: AppToastType.negative,
    );
  }

  @override
  void onRegistrationSuccess() {
    arguments.password = savePassword!;
    NavigationRoutes.openRegistration(context, page: 2, args: arguments);
  }
}
