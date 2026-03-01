
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
import 'package:ims_scanner_app/utils/constants/text_strings.dart';
import 'package:ims_scanner_app/utils/helpers/helper_functions.dart';

class ForgetPasswordScreen  extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///Headings
              Text(AppTextStrings.forgotPasswordTitle, style: Theme.of(context).textTheme.headlineMedium,),
              const SizedBox(height: AppSizes.spaceBtwItems,),
              Text(AppTextStrings.forgotPasswordSubTitle, style: Theme.of(context).textTheme.headlineMedium,),
              const SizedBox(height: AppSizes.spaceBtwItems * 2),
              ///Text fields
              TextFormField(
                decoration:   InputDecoration(
                  labelText: AppTextStrings.emailAddress,
                  prefixIcon: Icon(Iconsax.direct),
                  floatingLabelStyle: TextStyle( color: dark ? AppColors.white : AppColors.black, ),
              )),
              const SizedBox(height: AppSizes.spaceBtwItems,),
              ///Submit button
              ElevatedButton(onPressed: () => context.push('/verify_reset_password'), child: SizedBox(width: double.infinity, child: Center(child: Text(AppTextStrings.continueTitle))))
            ],
          ),
        ),
      ),
    ) ;
  }
}