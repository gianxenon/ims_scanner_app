import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
import 'package:ims_scanner_app/utils/constants/text_strings.dart';
import 'package:ims_scanner_app/common/styles/divider.dart';
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///Title
              Text(
                AppTextStrings.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: AppSizes.spaceBtwSections),

              ///Form
             // AppSignUpForm(),

              const SizedBox(height: AppSizes.spaceBtwSections),

              ///Divider
              AppDivider(dividerText: AppTextStrings.orSignInWith),
              const SizedBox(height: AppSizes.spaceBtwSections),

              ///Social Icons
            //  const AppSocialFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
