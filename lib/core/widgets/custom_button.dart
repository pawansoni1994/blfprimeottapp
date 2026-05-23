import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledColor;
  final double? borderRadius;
  final double? elevation;
  final Widget? icon;
  final ButtonSize size;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.disabledColor,
    this.borderRadius,
    this.elevation,
    this.icon,
    this.size = ButtonSize.medium,
    this.width,
  });

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40.h;
      case ButtonSize.medium:
        return 50.h;
      case ButtonSize.large:
        return 60.h;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontSize: 14.sp);
      case ButtonSize.medium:
        return Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontSize: 16.sp);
      case ButtonSize.large:
        return Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontSize: 18.sp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _getHeight(),
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? (backgroundColor ?? Theme.of(context).primaryColor)
              : (disabledColor ?? Colors.grey.shade400),
          elevation: elevation ?? 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: _getTextStyle(context).copyWith(
                      color: textColor ?? Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
