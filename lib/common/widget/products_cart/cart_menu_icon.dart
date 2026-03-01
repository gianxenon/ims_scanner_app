import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart';

class AppCartCounterIcon extends StatelessWidget {
  const AppCartCounterIcon({
    super.key, required this.iconColor,  this.onPressed,
  });

  final Color iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(onPressed: onPressed, icon:   Icon(Iconsax.shopping_bag, color: iconColor)),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(
                alpha: 0.8,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('2',style: TextStyle(color: AppColors.white,fontSize: 10),)),
          ),
        )
      ] 
    );
  }
}

