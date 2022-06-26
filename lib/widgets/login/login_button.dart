import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: Constants.buttonDisabled,
      onPressed: onPressed,
      padding: const EdgeInsets.all(16),
      color: Constants.mainColor,
      textColor: Colors.white,
      disabledTextColor: Colors.black26,
      minWidth: double.infinity,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: const Text(
        'ACCEDI',
        style: Constants.fontBold,
      ),
    );
  }
}
