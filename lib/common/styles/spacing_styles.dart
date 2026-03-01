  
import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';

class AppSpacingStyle {
  static const EdgeInsetsGeometry paddingWithAppBarheight = EdgeInsets.only(
    top: AppSizes.appBarHeight,
    left: AppSizes.defaultSpace,
    right: AppSizes.defaultSpace,
    bottom: AppSizes.defaultSpace
  );
}