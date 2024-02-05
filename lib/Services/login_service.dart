import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:terminal_demo/Services/socket_service.dart';

import 'package:terminal_demo/Utils/shared.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../Functions.dart';
import '../Models/loginData.dart';
import '../Models/api_response.dart';

class LoginService {
  Shared shared = Shared();

  Future<APIResponse<String>> loginUser(
      String login, BuildContext context) async {
    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<GetLoginDetails xmlns="http://tempuri.org/">',
      '<Obj>$login</Obj>',
      '</GetLoginDetails>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();

    return await http
        .post(Uri.parse('${Constants.baseUrlTerminal}?op=GetLoginDetails'),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
            },
            body: envelope)
        .then((response) {
      if (response.statusCode == 200) {
        var rawXmlResponse = response.body;
        XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);
        debugPrint(parsedXml.text);
        String jsonData = parsedXml.text;
        Map<String, dynamic> data = jsonDecode(jsonData);
        if (data['ReturnCode'] == '200') {
          var logData = LoginData.fromJson(data);
          String user = json.encode(logData);
          shared.setLoginData('');
          shared.setLoginData(user);
          Constants.isLogin = true;
          shared.setIsLogin(true);
          SocketService.getLiveRateData(context);
          return APIResponse<String>(data: data['ReturnCode']);
        }
        Platform.isIOS
            ? Functions.showSnackBar(context, data['ReturnMsg'])
            : Functions.showToast(data['ReturnMsg']);
        // Functions.showToast(data['ReturnMsg']);

        return APIResponse<String>(data: data['ReturnCode']);
      } else {
        return APIResponse<String>(isError: true, errorMessage: Constants.serverError);
      }
    }).catchError((error) {
      return APIResponse<String>(isError: true, errorMessage: '$error');
    });
  }
}
