import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:ims_scanner_app/routers/app_route_paths.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';

class CategoriesContainer extends StatelessWidget {
  const CategoriesContainer({super.key});

  final List<Map<String, dynamic>> modules = const [
    {"title": "Inventory", "icon": Icons.inventory_2, "route": AppRoutePaths.dashboard}, 
    {"title": "Settings", "icon": Icons.settings, "route": AppRoutePaths.settings},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        itemCount: modules.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = modules[index];

          return Padding(
            padding: const EdgeInsets.only(left: AppSizes.spaceBtwItems),
            child: Column(
              children: [
                InkWell(
                 onTap: () {
                  context.push(item["route"]);
                },
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      item["icon"],
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 70,
                  child: Text(
                    item["title"],
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
