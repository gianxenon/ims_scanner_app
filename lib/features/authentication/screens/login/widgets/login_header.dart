import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/constants/images_strings.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
import 'package:ims_scanner_app/utils/constants/text_strings.dart';
import 'package:ims_scanner_app/utils/helpers/helper_functions.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSizes.spaceBtwItems),
          Image(
            image: AssetImage(
              dark ? AppImages.storeLogoWhite2 : AppImages.storeLogoBlack2,
            ),
            height: 150,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
      
          Text(
            AppTextStrings.onBoardingTitle1,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            AppTextStrings.onBoardingsubTitle1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
