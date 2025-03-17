import 'package:flutter/material.dart';

class CustomDropDownButton extends StatelessWidget {
  final String title;
  final List<String> values;
  final double width;
  const CustomDropDownButton({
    super.key,
    required this.title,
    required this.values,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.07),
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton(
        style: TextStyle(color: Colors.white),
        underline: Container(),
        onChanged: (_) {},
        dropdownColor: const Color(0xFF353535),
        hint: Text(title, style: TextStyle(color: Colors.white)),
        items:
            values.map((element) {
              return DropdownMenuItem(value: element, child: Text(element));
            }).toList(),
      ),
    );
  }
}
