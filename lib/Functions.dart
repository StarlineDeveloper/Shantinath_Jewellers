import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:terminal_demo/Constants/app_colors.dart';

import 'Widgets/custom_text.dart';

class Functions {
  //check internet
  static Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      return true;
    }else {
      return false;
    }
  }

  static showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 4,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        textColor: AppColors.defaultColor,
        fontSize: 16.0);
  }

  static showSnackBar(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryColor,
        duration: const Duration(seconds: 3),
        content:
        CustomText(text: content,fontWeight: FontWeight.bold,textColor: AppColors.defaultColor,size: 16.0,align: TextAlign.center,),

        // Text(
        //   textScaleFactor: 1.0,
        //   content,
        //   textAlign: TextAlign.center,
        //   style: const TextStyle(
        //     color: AppColors.defaultColor,
        //     fontWeight: FontWeight.bold,
        //     fontSize: 16.0,
        //   ),
        // ),
      ),
    );
  }

//email validation
  static velidateEmail(String email) {
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

//calender Style
  static calenderStyle(BuildContext context) {
    return Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryColor,
          onPrimary: AppColors.defaultColor,
          onSurface: AppColors.primaryColor,

        ),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
          textStyle: MaterialStateProperty.all(TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.poppins().fontFamily)),

          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          minimumSize: MaterialStateProperty.all(const Size(80, 40)),
          foregroundColor: MaterialStateProperty.all(AppColors.defaultColor),
        ))
        // textButtonTheme: TextButtonThemeData(
        //   style: TextButton.styleFrom(
        //     foregroundColor: AppColors.primaryColor, textStyle: GoogleFonts.poppins(),
        //
        //   ),
        // ),
        );
  }

  //format number
  static String formatNum(var num) {
    return num == 0 ? '0' : NumberFormat('#,##,000').format(num);
  }

  //format dynamic
  static bool isDecimal(String input) {
    final RegExp decimalRegExp = RegExp(r'^\d+\.\d+$');
    return decimalRegExp.hasMatch(input);
  }

  //format dynamic
  static bool isNumeric(String s) {
    if (s.isEmpty || s == '--' || s == '-') {
      return false;
    }
    return true;
  }

  //replace alpha with number
  static String alphaNum(String num) {
    return num.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static extractNumber(String inputString) {
    // Define a regular expression to match numeric values (including decimal points)
    RegExp regExp = RegExp(r"(\d+\.\d+|\d+)");

    // Extract the first match from the input string
    Match match = regExp.firstMatch(inputString) as Match;

    // Check if a match is found and extract the matched value
    if (match != null) {
      String? matchedValue = match.group(0);

      // Parse the matched value to a double
      try {
        return matchedValue!;
      } catch (e) {
        debugPrint("Error parsing double: $e");
      }
    }
  }

  static inflateData(var response) {
    var inflated = zlib.decode(response);
    var data = utf8.decode(inflated);
    return json.decode(data);
  }
  //Formate date and time

static formateDate(String inputDate){
  DateTime dateTime = DateFormat("dd MMM yyyy HH:mm:ss:S").parse(inputDate);

  return  DateFormat.yMMMd().add_jm().format(dateTime);

}

}
