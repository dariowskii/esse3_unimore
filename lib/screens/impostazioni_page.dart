import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImpostazioniPage extends StatefulWidget {
  @override
  _ImpostazioniPageState createState() => _ImpostazioniPageState();
}

class _ImpostazioniPageState extends State<ImpostazioniPage> {
  bool _enabled = true;

  void _onClickEnable(enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = enabled;
      prefs.setBool("enableNotifications", enabled);
    });
    if (enabled) {
      BackgroundFetch.start();
    } else {
      BackgroundFetch.stop();
    }
  }

  void _initEnabledNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool("enableNotifications") ?? true;
    });
    prefs.setBool("enableNotifications", _enabled);
    print(_enabled);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initEnabledNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Impostazioni app"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifiche",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Divider(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text("Notifiche per le nuove tasse e voti")),
                  Switch(value: _enabled, onChanged: _onClickEnable),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
