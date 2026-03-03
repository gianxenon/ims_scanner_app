import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ims_scanner_app/common/widget/reusable_appbar/appbar.dart'; 
import 'package:ims_scanner_app/routers/app_route_paths.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme; 
    final modules = [
      {"title": "Receiving", "icon": Iconsax.arrow_down_1, "route": AppRoutePaths.receiving},
      {"title": "Put Away", "icon": Iconsax.box_add, "route": "/putaway"},
      {"title": "Check", "icon": Iconsax.scan_barcode, "route": "/check"},
      {"title": "Dispatch", "icon": Iconsax.truck, "route": "/dispatch"},
      {"title": "Transfer Tag", "icon": Iconsax.tag, "route": "/transfer-tag"},
      {"title": "Transfer Pallet", "icon": Iconsax.box, "route": "/transfer-pallet"},
      {"title": "Recount", "icon": Iconsax.refresh, "route": "/recount"},
      {"title": "Pallet Compression", "icon": Iconsax.box_24, "route": "/compression"},
    ];

    return Scaffold(
     appBar: AppReusableAppBar(
      title: Text("Cold Storage Dashboard" ),
      showBackArrow: true,
       
    ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,  
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, index) {
            final item = modules[index];

            return InkWell(
              onTap: () => context.push(item["route"] as String),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cs.outline.withValues(alpha: 0.2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item["icon"] as IconData,
                      size: 40,
                      color: cs.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item["title"] as String,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
