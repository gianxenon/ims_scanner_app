import 'package:flutter/material.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';

class AppRoundedImage extends StatelessWidget {
  const AppRoundedImage({
    super.key,
    this.border,
    this.padding ,
    this.onPressed,
    this.width,
    this.height,
    required this.imageUrl,
    this.applyImageRadius = true, 
    this.backgroundColor = AppColors.light,
    this.fit = BoxFit.fill, 
    this.isNetworkImage = false,
    
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit? fit; 
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height, 

        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.md),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.md),

          child: Image(
            fit: fit,
            image:
                isNetworkImage
                    ? NetworkImage(imageUrl)
                    : AssetImage(imageUrl),
          ),
        ),
      ),
    );
  }
}