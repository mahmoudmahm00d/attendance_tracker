import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final String? heading;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  const MyTextFormField({
    super.key,
    required this.controller,
    required this.hint,
    this.heading,
    this.isPassword = false,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading != null && heading!.isNotEmpty) Text(heading!),
        if (heading != null && heading!.isNotEmpty) const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          obscureText: isPassword,
          obscuringCharacter: '*',
          decoration: InputDecoration(
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            label: Text(
              hint,
              style: Theme.of(context).inputDecorationTheme.hintStyle!,
            ),
          ),
        )
      ],
    );
  }
}
