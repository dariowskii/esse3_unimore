import 'package:Esse3/constants.dart';
import 'package:Esse3/widgets/login/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Pagina iniziale di login.
class LoginScreen extends StatelessWidget {
  static const String id = 'loginScreen';

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final isTablet = deviceWidth > Constants.tabletWidth;
    return Stack(
      children: [
        const Scaffold(),
        SvgPicture.asset(
          isTablet
              ? 'assets/img/backgroundLoginTablet.svg'
              : 'assets/img/backgroundLogin.svg',
          width: deviceWidth,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Builder(builder: (BuildContext context) {
              return Padding(
                padding: isTablet
                    ? EdgeInsets.symmetric(horizontal: deviceWidth / 6)
                    : const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Esse3 Unimore',
                        style: Constants.fontBold32,
                      ),
                      const Text(
                        'App non (ancora) ufficiale',
                        style: Constants.font20,
                      ),
                      const SizedBox(height: 30),
                      LoginForm(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
