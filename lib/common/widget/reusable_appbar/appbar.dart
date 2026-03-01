import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ims_scanner_app/utils/device/device_utility.dart';

class AppReusableAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppReusableAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.actions,
    this.onLeadingPressed,
    this.showBackArrow = false,
    this.fallbackRoute = '/login',
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: title,
      actions: actions,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      toolbarHeight: AppDeviceUtils.getAppBarHeight(),
      leading: showBackArrow
          ? IconButton(
              icon: const Icon(Iconsax.arrow_left),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(fallbackRoute);
                }
              },
            )
          : (leadingIcon != null
              ? IconButton(
                  icon: Icon(leadingIcon),
                  onPressed: onLeadingPressed, // ✅ fixed
                )
              : null),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppDeviceUtils.getAppBarHeight());
}