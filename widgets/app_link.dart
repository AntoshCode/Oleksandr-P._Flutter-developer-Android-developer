import 'package:adviser/adviser/fca/app/components/app_image/app_image.dart';
import 'package:adviser/adviser/fca/app/components/margin/margin.dart';
import 'package:adviser/adviser/fca/app/styles/text_styles/app_text_style.dart';
import 'package:adviser/adviser/fca/app/styles/ui_style/base_style.dart';
import 'package:adviser/adviser/fca/app/styles/ui_style/icon/icon.dart';
import 'package:adviser/adviser/resources/constants/theme.dart';
import 'package:flutter/cupertino.dart';

class AppLinkStyle extends BaseStyle {
  Color get color => AppTheme.colorAccept;

  double get height => 24;

  AppTextStyle get textStyle => AppTextStyle(fontSize: 16, color: color);

  EdgeInsets get marginIcon => EdgeInsets.only(left: 10);

  EdgeInsets get defaultPadding => EdgeInsets.zero;

  const AppLinkStyle();
}

class AppLinkPickerStyle extends AppLinkStyle {
  Color get color => AppTheme.colors.primaryToneA;

  double get height => 23;

  AppTextStyle get textStyle =>
      AppTextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w600);

  EdgeInsets get marginIcon => EdgeInsets.only(left: 10);

  EdgeInsets get defaultPadding => EdgeInsets.zero;

  const AppLinkPickerStyle();
}

class AppLink extends StatelessWidget {
  final AppLinkStyle style;
  final AppIconStyle icon;
  final EdgeInsets? margin;
  final EdgeInsets? _padding;

  final String text;
  final VoidCallback? onPressed;
  final bool showIcon;

  EdgeInsets get padding => _padding ?? style.defaultPadding;

  const AppLink({
    this.text = '',
    this.showIcon = true,
    this.style = const AppLinkStyle(),
    this.icon = const AppIconStyle(
      width: 6,
      height: 18,
      path: 'assets/icons/arrow_next_link.svg',
    ),
    this.onPressed,
    this.margin,
    EdgeInsets? padding,
  }) : _padding = padding;

  @override
  Widget build(BuildContext context) {
    return Margin(
      margin: margin,
      child: CupertinoButton(
        onPressed: onPressed,
        pressedOpacity: 0.8,
        minSize: style.height,
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: style.textStyle),
            if (showIcon)
              AppImage(
                color: style.color,
                margin: style.marginIcon,
                imageStyle: icon,
              )
          ],
        ),
      ),
    );
  }
}
