 
import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
import 'package:ims_scanner_app/utils/helpers/helper_functions.dart';

class AppSectionHeader extends StatelessWidget{
  const AppSectionHeader({super.key, required this.title}); 
  final String title;
  @override
  Widget build(BuildContext context) {
     final dark = AppHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall!.apply(color: dark ? AppColors.white : AppColors.black) ,),
        ],
      ));
  }
}