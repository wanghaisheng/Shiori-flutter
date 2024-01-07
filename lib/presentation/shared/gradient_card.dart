// https://github.com/bluemix/Gradient-Widgets/blob/master/lib/src/gradient_card.dart

import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final EdgeInsetsGeometry margin;
  final bool semanticContainer;
  final Widget? child;
  final LinearGradient gradient;
  final double? elevation;

  const GradientCard({
    super.key,
    required this.gradient,
    this.shape,
    this.margin = const EdgeInsets.all(4),
    this.clipBehavior = Clip.hardEdge,
    this.child,
    this.elevation,
    this.semanticContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: semanticContainer,
      explicitChildNodes: !semanticContainer,
      child: Container(
        margin: margin,
        child: Material(
          type: MaterialType.card,
          color: Colors.transparent,
          elevation: elevation ?? 0,
          shape: shape ?? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          clipBehavior: clipBehavior,
          child: Container(
            decoration: ShapeDecoration(
              shape: shape ?? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
