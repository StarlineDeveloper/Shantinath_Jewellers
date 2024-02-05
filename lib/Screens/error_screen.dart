import 'package:flutter/material.dart';

import '../Widgets/custom_text.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child:
          CustomText(
            text: 'Invalid Route Name..',
            size: 20.0,
            textColor:  Colors.grey,
            fontWeight: FontWeight.bold,
          ),

      /*    Text(
        'Invalid Route Name..',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 20.0,
        ),
      )*/),
    );
  }
}
