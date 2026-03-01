
import 'package:flutter/material.dart';
//import 'package:ims_scanner_app/common/widget/products_cart/cart_menu_icon.dart';
import 'package:ims_scanner_app/common/widget/reusable_appbar/appbar.dart'; 
import 'package:ims_scanner_app/utils/constants/text_strings.dart'; 
class AppHomeAppBar extends StatelessWidget {
  const AppHomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
     // final dark = AppHelperFunctions.isDarkMode(context);
    return AppReusableAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppTextStrings.homeAppBarTitle,style: Theme.of(context).textTheme.labelMedium!.apply(color: Theme.of(context).colorScheme.onSurface),),
          Text(AppTextStrings.homeAppBarSubTitle,style: Theme.of(context).textTheme.headlineSmall!.apply(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),),
        ],
      ),
      actions: [
     //   AppCartCounterIcon(onPressed: (){},iconColor: AppColors.white), 
      ],
    );
  }
}