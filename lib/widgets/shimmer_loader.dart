import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/widgets/shimmer_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Animazione di caricamento per la pagina [TasseScreen]
/// e [ProssimiAppelliScreen].
class ShimmerLoader extends StatelessWidget {
  final bool isTablet;
  final double deviceWidth;
  final double shimmerHeight;
  final Color colorCircular;

  const ShimmerLoader(
      {Key key,
      this.isTablet,
      this.deviceWidth,
      this.shimmerHeight = 200,
      this.colorCircular = Constants.mainColorLighter})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Platform.isIOS
                    ? CupertinoActivityIndicator()
                    : CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorCircular),
                      ),
                SizedBox(width: 20),
                Text(
                  'Sto scaricando i dati...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Padding(
            padding: isTablet
                ? EdgeInsets.symmetric(horizontal: deviceWidth / 6)
                : EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
            child: Column(
              children: [
                ShimmerCustom(height: shimmerHeight),
                SizedBox(height: 10),
                ShimmerCustom(height: shimmerHeight),
                isTablet ? SizedBox(height: 10) : SizedBox.shrink(),
                isTablet
                    ? ShimmerCustom(height: shimmerHeight)
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
