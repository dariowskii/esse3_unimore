import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/widgets/shimmer_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Animazione di caricamento per la pagina [TasseScreen]
/// e [ProssimiAppelliScreen].
class ShimmerLoader extends StatelessWidget {
  final bool? isTablet;
  final double? deviceWidth;
  final double shimmerHeight;
  final Color colorCircular;

  const ShimmerLoader(
      {Key? key,
      this.isTablet,
      this.deviceWidth,
      this.shimmerHeight = 200,
      this.colorCircular = Constants.mainColorLighter})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (Platform.isIOS)
                  const CupertinoActivityIndicator()
                else
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorCircular),
                  ),
                const SizedBox(width: 20),
                const Text(
                  'Sto scaricando i dati...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Padding(
            padding: isTablet!
                ? EdgeInsets.symmetric(horizontal: deviceWidth! / 6)
                : const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
            child: Column(
              children: [
                ShimmerCustom(height: shimmerHeight),
                const SizedBox(height: 10),
                ShimmerCustom(height: shimmerHeight),
                if (isTablet!) ...[
                  const SizedBox(height: 10),
                  ShimmerCustom(height: shimmerHeight)
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
