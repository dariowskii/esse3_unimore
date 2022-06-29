import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:Esse3/models/studente_model.dart';
import 'package:flutter/material.dart';

class AnimatedAvatar extends StatelessWidget {
  const AnimatedAvatar({
    Key? key,
    required this.animation,
    required this.studenteModel,
  }) : super(key: key);

  final Animation? animation;
  final StudenteModel studenteModel;

  @override
  Widget build(BuildContext context) {
    final hasProfilePic = studenteModel.datiPersonali?.profilePicture != null;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      width: 100,
      height: 100,
      child: Container(
        width: (animation!.value as double) * 100,
        height: (animation!.value as double) * 100,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12
                  .withOpacity((animation!.value as double) * 0.12),
              blurRadius: 10,
              offset: const Offset(0, 5),
              spreadRadius: 3,
            )
          ],
        ),
        child: CircleAvatar(
          backgroundColor: Constants.mainColorLighter,
          radius: (animation!.value as double) * 50,
          backgroundImage: hasProfilePic
              ? MemoryImage(studenteModel.datiPersonali!.profilePictureBytes!)
              : null,
          child: hasProfilePic
              ? const SizedBox.shrink()
              : Text(
                  studenteModel.datiPersonali!.textAvatar,
                  style: const TextStyle(
                    fontWeight: FontWeight.w100,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
