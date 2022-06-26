import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    Key? key,
    required this.enabled,
    required this.onSubmitted,
    required this.labelText,
    this.focusNode,
    this.obscureText = false,
    this.controller,
    this.maxLenght,
    this.keyboardType,
  }) : super(key: key);

  final bool enabled;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final bool obscureText;
  final Function(String) onSubmitted;
  final String labelText;
  final int? maxLenght;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      obscureText: obscureText,
      focusNode: focusNode,
      controller: controller,
      maxLength: maxLenght,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        counterText: '',
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Constants.mainColor,
            width: 2,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
