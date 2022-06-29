import 'package:Esse3/constants.dart';
import 'package:Esse3/models/studente_model.dart';
import 'package:flutter/material.dart';

class DrawerHeaderHome extends StatelessWidget {
  const DrawerHeaderHome({Key? key, required this.studenteModel})
      : super(key: key);

  final StudenteModel studenteModel;
  @override
  Widget build(BuildContext context) {
    final hasProfilePic = studenteModel.datiPersonali?.profilePicture != null;
    final hasTextAvatar = studenteModel.datiPersonali?.textAvatar != null;
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
            backgroundImage: hasProfilePic
                ? MemoryImage(
                    studenteModel.datiPersonali!.profilePictureBytes!,
                  )
                : null,
            child: hasProfilePic
                ? const SizedBox.shrink()
                : hasTextAvatar
                    ? Text(
                        studenteModel.datiPersonali!.textAvatar,
                        style: const TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )
                    : null,
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                studenteModel.datiPersonali?.nomeCompleto ?? 'null',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 5),
              Text(
                'Matr. ${studenteModel.datiPersonali?.matricola ?? 'null'}',
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ],
    );
  }
}
