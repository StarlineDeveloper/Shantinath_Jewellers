// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';
import '../Widgets/custom_text.dart';

class DialogUtil {
  static final DialogUtil _instance = DialogUtil.internal();

  DialogUtil.internal();

  factory DialogUtil() => _instance;

  static void showAlertDialog(BuildContext context,
      {required String content,
      required String title,
      required String okBtnText,
      required String cancelBtnText,
      Function? okBtnFunction}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        var size = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)), //this right here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: size.width * 0.11,
                width: size.width,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                        text: title,
                        size: 15.0,
                        textColor: AppColors.defaultColor,
                        fontWeight: FontWeight.bold)),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                      text: content,
                      size: 15.0,
                      textColor: AppColors.textColor,
                      fontWeight: FontWeight.w500)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: Container(
                    height: size.width * 0.11,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                        text: okBtnText,
                        size: 15.0,
                        textColor: AppColors.defaultColor,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // okBtnFunction!();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showConfirmDialog(BuildContext context,
      {required String title,
      required String content,
      required okBtnText,
      required cancelBtnText,
      required Function okBtnFunctionConfirm,
      required bool isVisible}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        var size = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)), //this right here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: size.width * 0.11,
                width: size.width,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                        text: title,
                        size: 15.0,
                        textColor: AppColors.defaultColor,
                        fontWeight: FontWeight.bold)),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                      text: content,
                      size: 15.0,
                      textColor: AppColors.textColor,
                      fontWeight: FontWeight.w500)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: InkWell(
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          alignment: Alignment.center,
                          child: Stack(children: [
                            Visibility(
                                visible: !isVisible,
                                child: CustomText(
                                    text: okBtnText,
                                    size: 15.0,
                                    textColor: AppColors.defaultColor,
                                    fontWeight: FontWeight.bold)),
                            Visibility(
                              visible: isVisible,
                              child: SizedBox(
                                height: 20.0,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.defaultColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ]),
                        ),
                        onTap: () {
                          okBtnFunctionConfirm();
                        },
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                            margin: EdgeInsets.only(left: 5),
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLightColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            alignment: Alignment.center,
                            child: CustomText(
                                text: cancelBtnText,
                                size: 15.0,
                                textColor: AppColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
