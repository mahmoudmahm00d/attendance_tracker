import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const NumericStepButton({
    Key? key,
    this.minValue = 0,
    this.maxValue = 10,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<NumericStepButton> createState() => _NumericStepButtonState();
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(PhosphorIconsBold.minus),
          onPressed: () {
            setState(() {
              if (counter > widget.minValue) {
                counter--;
                widget.onChanged(counter);
              }
            });
          },
        ),
        Text('$counter'),
        IconButton(
          icon: const Icon(PhosphorIconsBold.plus),
          onPressed: () {
            setState(() {
              if (counter < widget.maxValue) {
                counter++;
                widget.onChanged(counter);
              }
            });
          },
        ),
      ],
    );
  }
}
