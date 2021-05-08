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
    return CircleAvatar(
      backgroundColor: Constants.mainColorLighter,
      radius: (animation.value as double) * 50,
      backgroundImage: userData['profile_pic'] == 'no'
          ? null
          : MemoryImage(base64Decode(userData['profile_pic'] as String)),
      child: userData['profile_pic'] == 'no'
          ? Text(
              userData['text_avatar'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w100,
                fontSize: (animation.value as double) * 40,
                color: Colors.white,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
