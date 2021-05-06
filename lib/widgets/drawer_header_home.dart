import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class DrawerHeaderHome extends StatelessWidget {
  const DrawerHeaderHome({Key key, @required this.user})
      : assert(user != null),
        super(key: key);

  final Map<String, dynamic> user;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(1),
          child: CircleAvatar(
            backgroundColor: Constants.mainColor.withOpacity(0.9),
            radius: 30,
            backgroundImage: user['profile_pic'] == 'no'
                ? null
                : MemoryImage(base64Decode(user['profile_pic'] as String)),
            child: user['profile_pic'] == 'no'
                ? Text(
                    user['text_avatar'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w100,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${user['nome']}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 5),
              Text(
                'Matr. ${user['matricola']}',
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ],
    );
  }
}
