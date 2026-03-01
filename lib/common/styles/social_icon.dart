 
// import 'package:flutter/material.dart';
// import 'package:ims_scanner_app/utils/helpers/helper_functions.dart'; 
// import 'package:ims_scanner_app/utils/constants/colors.dart';
// import 'package:ims_scanner_app/utils/constants/sizes.dart';
// class AppSocialFooter extends StatelessWidget {
//   const AppSocialFooter({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//        final dark = AppHelperFunctions.isDarkMode(context);
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//        Container(
//          decoration: BoxDecoration( border: Border.all(color: dark ? AppColors.darkGrey : AppColors.grey), borderRadius: BorderRadius.circular(100)),
//          child: IconButton(onPressed: () {}, icon: const Image(width: AppSizes.iconMd, image: AssetImage(AppImages.googleIcon))),
//        ),
//        const SizedBox(width: AppSizes.spaceBtwItems),
//          Container(
//          decoration: BoxDecoration( border: Border.all(color: dark ? AppColors.darkGrey : AppColors.grey), borderRadius: BorderRadius.circular(100)),
//          child: IconButton(onPressed: () {}, icon: const Image(width: AppSizes.iconMd, image: AssetImage(AppImages.facebookIcon))),
//        ),
//       ],
//     );
//   }
// }