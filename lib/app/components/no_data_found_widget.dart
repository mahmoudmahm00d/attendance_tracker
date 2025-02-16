import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoDataFoundWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final Function()? action;

  const NoDataFoundWidget({
    super.key,
    required this.title,
    required this.message,
    required this.action,
    required this.icon,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 60 * context.width * 0.01),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (action != null)
          SizedBox(
            width: 240,
            height: 40,
            child: ElevatedButton(
              child: Text(buttonText),
              onPressed: action,
            ),
          )
        else
          const SizedBox.shrink()
      ],
    );
  }
}
