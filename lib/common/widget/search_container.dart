 
import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
import 'package:ims_scanner_app/utils/helpers/helper_functions.dart';

class AppSearchContainer extends StatelessWidget {
  const AppSearchContainer({
    super.key,
    this.icon,
    this.showBackground = true,
    this.showBorder = true,
    required this.title,
  });

  final String title;
  final IconData? icon;
  final bool showBackground, showBorder;

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Container(
       // width: AppDeviceUtils.getScreenHeight(context),
     //   padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color:
              showBackground
                  ? dark
                      ? AppColors.dark
                      : AppColors.white
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg), 
        ),
         child: TextFormField(
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .apply(color: AppColors.darkerGrey),
          decoration: InputDecoration( 
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.darkerGrey)
                : null,
            border: InputBorder.none,
            hintText: title,
            hintStyle: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: AppColors.darkerGrey),
          ),
        ),
      ),
    );
  }
}
