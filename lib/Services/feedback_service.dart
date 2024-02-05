import 'package:flutter/cupertino.dart';
import 'package:terminal_demo/Models/CommonRequestModel.dart';

import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../Constants/constant.dart';
import '../Models/api_response.dart';

class FeedbackService {
  Future<APIResponse<String>> feedbackService(FeedbackRequest feedback) async {
    var objVariable = feedbackToJson(feedback);
    List<String> fieldList = [
      '<?xml version="1.0" encoding="utf-8"?>',
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
      '<soap:Body>',
      '<Feedback xmlns="http://tempuri.org/">',
      '<Obj>$objVariable</Obj>',
      '</Feedback>',
      '</soap:Body>',
      '</soap:Envelope>'
    ];
    var envelope = fieldList.map((v) => v).join();
    debugPrint(envelope);

    return await http
        .post(Uri.parse('${Constants.baseUrl}?op=Feedback'),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
              //"Accept": "text/xml"
            },
            body: envelope)
        .then((response) {
      if (response.statusCode == 200) {
        var rawXmlResponse = response.body;
        XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);
        debugPrint('$parsedXml');
        return APIResponse<String>(data: 'Feedback Sended Success.');
      } else {
        return APIResponse<String>(
            isError: true, errorMessage: 'Some error occur.');
      }
    }).catchError((error) {
      return APIResponse<String>(isError: true, errorMessage: '$error');
    });
  }
}
