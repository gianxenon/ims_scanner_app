import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ riverpod
import 'package:iconsax/iconsax.dart';
import 'package:ims_scanner_app/common/styles/section_header.dart';
import 'package:ims_scanner_app/common/widget/custom_shapes/primary_header_container.dart';
import 'package:ims_scanner_app/common/widget/search_container.dart';
import 'package:ims_scanner_app/features/home/widgets/categories_widget.dart';
import 'package:ims_scanner_app/features/home/widgets/home_appbar.dart';
import 'package:ims_scanner_app/features/home/widgets/promotional_slider_widget.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
import 'package:ims_scanner_app/utils/constants/text_strings.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optional: watch here only if HomeScreen needs it.
    // final dotIndex = ref.watch(homeDotNavigatorProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppPrimaryHeaderWidget(
              child: Column(
                children: [
                  const AppHomeAppBar(),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  AppSearchContainer(
                    title: AppTextStrings.searchTitle,
                    icon: Iconsax.search_normal_1,
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSections),
                  const AppSectionHeader(title: "What do you want to do?", ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  const CategoriesContainer(),
                ],
              ),
            ),
 
            const PromotionalSlider(),
          ],
        ),
      ),
    );
  }
}