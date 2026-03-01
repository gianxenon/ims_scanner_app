import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart';
import 'package:ims_scanner_app/utils/constants/images_strings.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
import 'package:ims_scanner_app/utils/constants/text_strings.dart';
import 'package:ims_scanner_app/utils/helpers/helper_functions.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              ///Image
              Image(
                image: AssetImage(AppImages.sentEmail),
                width: AppHelperFunctions.screenWidth(context) * 0.8,
              ),

              const SizedBox(height: AppSizes.spaceBtwItems),

              ///Title & Subtitle
              Text(
                AppTextStrings.resetEmailSentTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              Text(
                AppTextStrings.resetEmailSentSubTitle,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.spaceBtwItems),

              ///Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(AppTextStrings.tdone),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    AppTextStrings.resendEmail,
                    style: TextStyle(
                      color: dark ? AppColors.white : AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
