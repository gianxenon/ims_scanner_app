import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart';

class AppCircularContainer extends StatelessWidget {
  const AppCircularContainer({
    super.key,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.padding = 0,
    this.margin   ,
    this.child,
    this.backgroundColor = AppColors.textWhite,
  });

  final double? width;
  final double? height;
  final double radius;
  final double padding; 
  final EdgeInsets? margin;
  final Widget? child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ,
      width: width,
      padding: EdgeInsets.all(padding),
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}
