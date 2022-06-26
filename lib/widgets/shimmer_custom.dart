import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Animazione di caricamento custom da [Shimmer].
class ShimmerCustom extends StatelessWidget {
  final double height;

  const ShimmerCustom({Key? key, this.height = 200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[400]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
            color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
