import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField(
      {super.key,
      required this.hintText,
      this.validator,
      this.formatters,
      this.padding,
      this.controller});

  final String hintText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? formatters;
  final EdgeInsets? padding;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding ?? const EdgeInsets.all(4),
        child: TextFormField(
          controller: controller,
          inputFormatters: formatters,
          validator: validator,
          decoration: InputDecoration(hintText: hintText),
        ));
  }
}

class MyUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
