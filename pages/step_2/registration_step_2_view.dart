import 'package:adviser/adviser/fca/app/components/app_bar/auth.dart';
import 'package:adviser/adviser/fca/app/components/app_buttons/app_button.dart';
import 'package:adviser/adviser/fca/app/components/app_divider/app_divider.dart';
import 'package:adviser/adviser/fca/app/components/app_image/app_image.dart';
import 'package:adviser/adviser/fca/app/components/app_preferred_size_container/app_preferred_size_container.dart';
import 'package:adviser/adviser/fca/app/components/app_toast/app_alert.dart';
import 'package:adviser/adviser/fca/app/components/carousel/dots_widget.dart';
import 'package:adviser/adviser/fca/app/components/inputs/input.dart';
import 'package:adviser/adviser/fca/app/pages/login/registration/registration_controller.dart';
import 'package:adviser/adviser/fca/app/pages/login/registration/step_2/registration_step_2_controller.dart';
import 'package:adviser/adviser/fca/app/styles/text_styles/app_text_style.dart';
import 'package:adviser/adviser/fca/app/styles/text_styles/auth_text_styles.dart';
import 'package:adviser/adviser/fca/app/styles/ui_style/base_style.dart';
import 'package:adviser/adviser/fca/app/styles/ui_style/icon/icon.dart';
import 'package:adviser/adviser/resources/constants/colors.dart';
import 'package:adviser/adviser/resources/constants/theme.dart';
import 'package:adviser/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegistrationStepTwoPage extends View {
  final RegistrationArguments arguments;

  RegistrationStepTwoPage({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  _RegistrationPageState createState() {
    return _RegistrationPageState(RegistrationStepTwoController(arguments));
  }
}

class _RegistrationPageState
    extends ViewState<RegistrationStepTwoPage, RegistrationStepTwoController> {
  final RegistrationStepTwoController controller;

  _RegistrationPageState(this.controller) : super(controller);

  @override
  Widget get view {
    return body(
      content: [
        title(
          text: "Вы почти\nу цели",
          margins: EdgeInsets.fromLTRB(20, 50, 20, 0),
        ),
        error(
          margin: EdgeInsets.fromLTRB(20, 24, 20, 0),
        ),
        passwordGlyphs(
          margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
        ),
        password(
          hint: 'Введите пароль',
          margins: EdgeInsets.fromLTRB(20, 15, 20, 0),
        ),
        passwordRepeat(
          hint: 'Подтвердите пароль',
          margins: EdgeInsets.fromLTRB(20, 30, 20, 0),
        ),
      ],
      bottom: SizedList(
        size: Size.fromHeight(70 + 26 + 10 + 5),
        items: [
          DotsWidget(
            page: 2,
            size: 3,
            margins: EdgeInsets.only(top: 5, bottom: 26),
          ),
          btnNext(
            text: "Продолжить",
            margins: EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      ),
    );
  }

  body({required List<Widget> content, required SizedList<Widget> bottom}) {
    return Scaffold(
      appBar: MainAppBar(context: context),
      backgroundColor: AppTheme.colors.primaryToneB,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: true,
        bottom: true,
        child: BlocProvider(
          create: (BuildContext context) {
            controller.context = context;
            return controller.cubit;
          },
          child: Stack(children: [
            Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: AppTheme.colors.primaryToneB,
              body: ScrollConfiguration(
                behavior: const EmptyBehavior(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottom.size.height),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: bottom.items,
            ),
          ]),
        ),
      ),
    );
  }

  Widget title({text, margins}) {
    return Container(
      margin: margins,
      alignment: Alignment.topLeft,
      child: Text(text, style: AuthTitleTextStyle()),
    );
  }

  Widget error({EdgeInsets? margin}) {
    return BlocBuilder<RegisterPasswordCubit, RegisterPasswordState>(
      buildWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
      builder: (context, state) {
        controller.context = context;
        return AppMessageAlert(
          message: state.errorMessage,
          margin: margin,
        );
      },
    );
  }

  Widget passwordGlyphs({EdgeInsets? margin}) {
    return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<RegisterPasswordCubit, RegisterPasswordState>(
              buildWhen: (prev, curr) =>
                  prev.passwordState.hasLowercase !=
                  curr.passwordState.hasLowercase,
              builder: (context, state) {
                return PasswordGlyph(
                  icon: AppIconStyle(
                    width: 12,
                    height: 12,
                    path: 'assets/icons/password_glyphs/lowercase.svg',
                  ),
                  title: 'Lowercase',
                  active: state.passwordState.hasLowercase,
                );
              },
            ),
            AppDashedDivider(length: 74),
            BlocBuilder<RegisterPasswordCubit, RegisterPasswordState>(
              buildWhen: (prev, curr) =>
                  prev.passwordState.hasUppercase !=
                  curr.passwordState.hasUppercase,
              builder: (context, state) {
                return PasswordGlyph(
                  icon: AppIconStyle(
                    width: 15,
                    height: 15,
                    path: 'assets/icons/password_glyphs/uppercase.svg',
                  ),
                  title: 'Uppercase',
                  active: state.passwordState.hasUppercase,
                );
              },
            ),
            AppDashedDivider(length: 74),
            BlocBuilder<RegisterPasswordCubit, RegisterPasswordState>(
              buildWhen: (prev, curr) =>
                  prev.passwordState.hasSpecial !=
                  curr.passwordState.hasSpecial,
              builder: (context, state) {
                return PasswordGlyph(
                  icon: AppIconStyle(
                    width: 15,
                    height: 15,
                    path: 'assets/icons/password_glyphs/special.svg',
                  ),
                  title: 'Special',
                  active: state.passwordState.hasSpecial,
                );
              },
            ),
            AppDashedDivider(length: 74),
            BlocBuilder<RegisterPasswordCubit, RegisterPasswordState>(
              buildWhen: (prev, curr) =>
                  prev.passwordState.hasPasswordLength !=
                  curr.passwordState.hasPasswordLength,
              builder: (context, state) {
                return PasswordGlyph(
                  icon: AppIconStyle(
                    width: 13,
                    height: 15,
                    path: 'assets/icons/password_glyphs/characters.svg',
                  ),
                  title: 'Characters',
                  active: state.passwordState.hasPasswordLength,
                );
              },
            ),
          ],
        ));
  }

  Widget password({
    required String hint,
    EdgeInsets? margins,
  }) {
    return Container(
      margin: margins,
      child: BlocBuilder<RegisterPasswordCubit, RegisterPasswordState>(
          buildWhen: (prev, curr) => prev.password != curr.password,
          builder: (context, state) {
            return AppInput(
              hint: hint,
              text: state.password.text,
              error: state.password.isShowError,
              focus: controller.focusPassword,
              nextFocus: controller.focusRepeatPassword,
              maxLength: 180,
              inputAction: TextInputAction.next,
              onChange: controller.cubit.onChangePassword,
              approve: false,
              hideTitle: true,
              type: TextInputType.visiblePassword,
            );
          }),
    );
  }

  Widget passwordRepeat({
    required String hint,
    EdgeInsets? margins,
  }) {
    return Container(
      margin: margins,
      child: BlocBuilder<RegisterPasswordCubit, RegisterPasswordState>(
        buildWhen: (prev, curr) => prev.passwordRepeat != curr.passwordRepeat,
        builder: (context, state) {
          return AppInput(
            hint: hint,
            text: state.passwordRepeat.text,
            error: state.passwordRepeat.isShowError,
            focus: controller.focusRepeatPassword,
            inputAction: TextInputAction.done,
            maxLength: 180,
            onChange: controller.cubit.onChangePasswordRepeat,
            approve: false,
            hideTitle: true,
            type: TextInputType.visiblePassword,
          );
        },
      ),
    );
  }

  Widget btnNext({text, margins}) {
    return Container(
      margin: margins,
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(BaseStyle.defaultRadiusCard)),
        color: AppTheme.colors.primaryToneB,
      ),
      child: BlocBuilder<RegisterPasswordCubit, RegisterPasswordState>(
          buildWhen: (prev, curr) => prev.isNotValid != curr.isNotValid,
          builder: (context, state) {
            return AppButton(
              text: text,
              disabled: state.isNotValid,
              onPressed: controller.next,
            );
          }),
    );
  }
}

class PasswordGlyph extends StatelessWidget {
  final AppIconStyle icon;
  final String title;
  final bool active;

  const PasswordGlyph({
    required this.icon,
    required this.title,
    required this.active,
  });

  Color get colorGlyph =>
      active ? AppTheme.colorSecondary : AppTheme.colors.primaryToneA;

  Color get colorBorder =>
      active ? AppTheme.colorAccept : AppTheme.colors.primary;

  Color get colorTitle =>
      active ? AppColors.colorAuthGray : AppTheme.colors.primaryToneA;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 42,
          width: 61,
          margin: const EdgeInsets.only(bottom: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BaseStyle.defaultRadiusCard),
            border: Border.all(width: 1, color: colorBorder),
          ),
          child: AppImage(imageStyle: icon, color: colorGlyph),
        ),
        Text(title, style: AppTextStyle(fontSize: 11, color: colorTitle))
      ],
    );
  }
}
