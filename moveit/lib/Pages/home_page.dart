import 'package:flutter/material.dart';
import 'package:moveit/widgets/custom_dropdown.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          padding: EdgeInsets.symmetric(
            horizontal: deviceWidth * 0.05,
            vertical: deviceHeight * 0.02,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pageTitle(),
                  _moveitWidget(deviceHeight, deviceWidth),
                ],
              ),
              _movitImageWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return const Text(
      "Move It!",
      style: TextStyle(
        color: Colors.white,
        fontSize: 56,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _movitImageWidget() {
    return Stack(
      children: [
        Positioned(
          top: 44,
          left: 66,
          child: Image.asset("assets/images/moveit.png", height: 530),
        ),
      ],
    );
  }

  Widget _buttonWidget(double deviceWidth) {
    return SizedBox(
      height: 45,
      width: deviceWidth,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Let's Go",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  Widget _moveitWidget(double deviceHeight, double deviceWidth) {
    return SizedBox(
      height: deviceHeight * 0.23,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomDropDownButton(
            title: 'Workout Type',
            values: const ['Cardio', 'Strength', 'Flexibility'],
            width: deviceWidth,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomDropDownButton(
                title: 'Intensity Level',
                values: const ['Low', 'Medium', 'High'],
                width: deviceWidth * 0.45,
              ),
              CustomDropDownButton(
                title: 'Duration',
                values: const ['10 min', '20 min', '30 min'],
                width: deviceWidth * 0.40,
              ),
            ],
          ),
          _buttonWidget(deviceWidth),
        ],
      ),
    );
  }
}
