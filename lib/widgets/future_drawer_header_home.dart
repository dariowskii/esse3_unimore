import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class FutureDrawerHeaderHome extends StatelessWidget {
  const FutureDrawerHeaderHome({Key key, @required this.userFuture})
      : assert(userFuture != null),
        super(key: key);

  final Future<Map<String, dynamic>> userFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: userFuture,
      builder: (context, userData) {
        switch (userData.connectionState) {
          case ConnectionState.none:
            return const Text('Nessuna connessione.');
          case ConnectionState.waiting:
            return const LinearProgressIndicator();
          case ConnectionState.active:
          case ConnectionState.done:
            if (!userData.hasData) {
              return const Text('Errore nel recuperare i dati.');
            }
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
                    backgroundImage: userData.data['profile_pic'] == 'no'
                        ? null
                        : MemoryImage(base64Decode(
                            userData.data['profile_pic'] as String)),
                    child: userData.data['profile_pic'] == 'no'
                        ? Text(
                            userData.data['text_avatar'] as String,
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
                        '${userData.data['nome_studente']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Matr. ${userData.data['matricola']}',
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
            );
          default:
            return const Text('Errore builder.');
        }
      },
    );
  }
}
