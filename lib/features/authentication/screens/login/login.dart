 
import 'package:flutter/material.dart';
import 'package:ims_scanner_app/common/styles/spacing_styles.dart';
import 'package:ims_scanner_app/features/authentication/screens/login/widgets/login_form.dart';
import 'package:ims_scanner_app/features/authentication/screens/login/widgets/login_header.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart'; 
 

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarheight, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Logo , Title, & Subtitle 
                    const LoginHeader(),

                    const SizedBox(height: AppSizes.spaceBtwSections),
                     
                    const LoginForm(),  

                    const SizedBox(height: AppSizes.spaceBtwSections), 
              ], 
          ),
        ),
      ),
    );
  }
}




