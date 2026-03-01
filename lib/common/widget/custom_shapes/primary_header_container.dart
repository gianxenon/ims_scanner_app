import 'package:flutter/material.dart';
import 'package:ims_scanner_app/common/widget/curved_edges/curver_edges_widgets.dart';
import 'package:ims_scanner_app/common/widget/custom_shapes/circular_container.dart'; 
class AppPrimaryHeaderWidget extends StatelessWidget {
  const AppPrimaryHeaderWidget({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; 
    return AppCurvedEdgeWidget(
      child: Container(
        color: cs.surface  ,  
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 400,
          child: Stack(
            children: [
              Positioned(
                top: -150,
                right: -250,
                child: AppCircularContainer(
                  backgroundColor: cs.onSurface.withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                top: 100,
                right: -300,
                child: AppCircularContainer(
                  backgroundColor: cs.onSurface.withValues(alpha: 0.10),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}