import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../Models/api_response.dart';

class RegisterService {
  Future<APIResponse<String>> registerUser(String register) async {
    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<insertRegister xmlns="http://tempuri.org/">',
      '<Obj>$register</Obj>',
      '</insertRegister>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();
    debugPrint(envelope);

    return await http
        .post(Uri.parse('${Constants.baseUrlTerminal}?op=insertRegister'),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
              //"Accept": "text/xml"
            },
            body: envelope)
        .then((response) {
      if (response.statusCode == 200) {
        var rawXmlResponse = response.body;
        XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);
        debugPrint(parsedXml.text);
        String jsonData = parsedXml.text;
        Map<String, dynamic> data = jsonDecode(jsonData);
       var returnMsgList = data['ReturnMsg'];
        List<Map<String, dynamic>> returnMsg = jsonDecode(returnMsgList).cast<Map<String, dynamic>>();
        var loginId ;
        for (var loginData in returnMsg){
          loginId=  loginData["LoginId"];
        }
        // if(loginId!=0){
        //   return APIResponse<String>(data: 'Registration Successful!');
        // }else{
        //   return APIResponse<String>(data: 'Mobile Number Already Exist.');
        //
        // }
        return APIResponse<String>(data: loginId.toString());
      } else {
        return APIResponse<String>(
            isError: true, errorMessage: Constants.serverError);
      }
    }).catchError((error) {
      return APIResponse<String>(isError: true, errorMessage: '$error');
    });
  }
}
