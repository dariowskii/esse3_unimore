import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class AnimatedAvatar extends StatelessWidget {
  const AnimatedAvatar({
    Key key,
    @required this.animation,
    @required this.userData,
  })  : assert(userData != null),
        super(key: key);

  final Animation animation;
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      width: 100,
      height: 100,
      child: Container(
        width: (animation.value as double) * 100,
        height: (animation.value as double) * 100,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12
                  .withOpacity((animation.value as double) * 0.12),
              blurRadius: 10,
              offset: const Offset(0, 5),
              spreadRadius: 3,
            )
          ],
        ),
        child: CircleAvatar(
          backgroundColor: Constants.mainColorLighter,
          radius: (animation.value as double) * 50,
          backgroundImage: userData['profile_pic'] == 'no'
              ? null
              : MemoryImage(base64Decode(userData['profile_pic'] as String)),
          child: userData['profile_pic'] == 'no'
              ? Text(
                  userData['text_avatar'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w100,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
