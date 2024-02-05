import 'package:flutter/material.dart';

import '../Constants/app_colors.dart';
import 'custom_text.dart';


class ContactDetailContainer extends StatelessWidget {
  const ContactDetailContainer({
    required this.descriptionText,
    required this.descriptionSize,
    required this.color,
    required this.descriptionFontWeight,
    required this.onTap,
    this.isVisible = false,
    super.key,
  });

  final bool isVisible;
  final String descriptionText;
  final double descriptionSize;
  final Color color;
  final FontWeight descriptionFontWeight;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          margin: const EdgeInsets.only(
            top: 10,
          ),
          child: CustomText(
            text: descriptionText,
            size: descriptionSize,
            textColor: color,
            fontWeight: descriptionFontWeight,
          ),
        ),
      ),
    );
  }
}

class AddressContainer extends StatelessWidget {
  const AddressContainer({
    required this.descriptionText,
    required this.descriptionSize,
    required this.color,
    required this.descriptionFontWeight,
    required this.titleText,
    required this.titleSize,
    required this.titleFontWeight,
    this.isVisible = false,
    super.key,
  });

  final bool isVisible;
  final String titleText;
  final double titleSize;
  final String descriptionText;
  final double descriptionSize;
  final Color color;
  final FontWeight titleFontWeight;
  final FontWeight descriptionFontWeight;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: const EdgeInsets.only(
          top: 10,
        ),
        color: AppColors.defaultColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: titleText,
              size: titleSize,
              textColor: color,
              fontWeight: titleFontWeight,
            ),
            CustomText(
              text: descriptionText,
              size: descriptionSize,
              textColor: color,
              fontWeight: descriptionFontWeight,
            ),
          ],
        ),
      ),
    );
  }
}
