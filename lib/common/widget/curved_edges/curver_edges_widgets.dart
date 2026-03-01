import 'package:flutter/material.dart';
import 'package:ims_scanner_app/common/widget/curved_edges/curved_edges.dart';

class AppCurvedEdgeWidget extends StatelessWidget {
  const AppCurvedEdgeWidget({
    super.key, this.child
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AppCustomCurvedEdges(),
      child: child,
    );
  }
}
