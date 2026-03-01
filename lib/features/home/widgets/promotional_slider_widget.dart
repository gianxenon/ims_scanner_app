import 'package:flutter/material.dart' hide CarouselController, CarouselView;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ims_scanner_app/common/widget/carousel/app_rounded_image.dart'; 
import 'package:ims_scanner_app/features/home/controllers/home_dot_navigator_provider.dart';
import 'package:ims_scanner_app/utils/constants/images_strings.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
 
class PromotionalSlider extends ConsumerWidget {
  const PromotionalSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> images = [
      AppImages.banner1,
      AppImages.banner2,
      AppImages.banner2,
    ];
 
    final currentIndex = ref.watch(homeDotNavigatorProvider);

    return Padding(
      
      padding: const EdgeInsets.all(AppSizes.defaultSpace),
      child: Column(
        
        children: [
          CarouselSlider.builder(
            itemCount: images.length,
            itemBuilder: (context, index, realIndex) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AppRoundedImage(imageUrl: images[index]),
              );
            },
            options: CarouselOptions(
              viewportFraction: 1,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) { 
                ref
                    .read(homeDotNavigatorProvider.notifier)
                    .updatePageIndicator(index);
              },
            ),
          ),

          const SizedBox(height: AppSizes.spaceBtwItems),
 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < images.length; i++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == i ? Colors.green : Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}