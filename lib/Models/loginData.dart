// To parse this JSON data, do
//
//     final loginData = loginDataFromJson(jsonString);

import 'dart:convert';

LoginData loginDataFromJson(String str) => LoginData.fromJson(json.decode(str));

String loginDataToJson(LoginData data) => json.encode(data.toJson());

class LoginData {
  String returnCode;
  String returnMsg;
  List<UserDetails> data;
  String token;
  int loginId;
  List<Group> group;
  List<GroupDetail> groupDetail;

  LoginData({
    required this.returnCode,
    required this.returnMsg,
    required this.data,
    required this.token,
    required this.loginId,
    required this.group,
    required this.groupDetail,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        returnCode: json["ReturnCode"],
        returnMsg: json["ReturnMsg"],
        data: List<UserDetails>.from(json["Data"].map((x) => UserDetails.fromJson(x))),
        token: json["Token"],
        loginId: json["LoginId"],
        group: List<Group>.from(jsonDecode(json['Group']).map((x) => Group.fromJson(x))),
        groupDetail: List<GroupDetail>.from(jsonDecode(json['GroupDetail']).map((x) => GroupDetail.fromJson(x))),
      );

  factory LoginData.getJson(Map<String, dynamic> json) => LoginData(
        returnCode: json["ReturnCode"],
        returnMsg: json["ReturnMsg"],
        data: List<UserDetails>.from(
            json["Data"].map((x) => UserDetails.fromJson(x))),
        token: json["Token"],
        loginId: json["LoginId"],
        group: List<Group>.from(json['Group'].map((x) => Group.fromJson(x))),
        groupDetail: List<GroupDetail>.from(
            json['GroupDetail'].map((x) => GroupDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ReturnCode": returnCode,
        "ReturnMsg": returnMsg,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
        "Token": token,
        "LoginId": loginId,
        "Group": List<dynamic>.from(group.map((x) => x.toJson())),
        "GroupDetail": List<dynamic>.from(groupDetail.map((x) => x.toJson())),
      };
}

class UserDetails {
  int? accountId;
  int? clientId;
  String? name;
  String? loginId;
  String? number;
  String? email;
  String? city;
  int? groupId;
  bool? status;
  String? gst;
  dynamic balance;
  int? access;
  String? statusCode;
  String? groupName;
  String? userName;
  String? password;
  String? firmname;

  UserDetails({
    this.accountId,
    this.clientId,
    this.name,
    this.loginId,
    this.number,
    this.email,
    this.city,
    this.groupId,
    this.status,
    this.gst,
    this.balance,
    this.access,
    this.statusCode,
    this.groupName,
    this.userName,
    this.password,
    this.firmname,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        accountId: json["AccountID"],
        clientId: json["ClientId"],
        name: json["Name"],
        loginId: json["LoginId"],
        number: json["Number"],
        email: json["Email"],
        city: json["City"],
        groupId: json["GroupID"],
        status: json["Status"],
        gst: json["GST"],
        balance: json["Balance"],
        access: json["Access"],
        statusCode: json["status_code"],
        groupName: json["GroupName"],
        userName: json["UserName"],
        password: json["password"],
        firmname: json["Firmname"],
      );

  Map<String, dynamic> toJson() => {
        "AccountID": accountId,
        "ClientId": clientId,
        "Name": name,
        "LoginId": loginId,
        "Number": number,
        "Email": email,
        "City": city,
        "GroupID": groupId,
        "Status": status,
        "GST": gst,
        "Balance": balance,
        "Access": access,
        "status_code": statusCode,
        "GroupName": groupName,
        "UserName": userName,
        "password": password,
        "Firmname": firmname,
      };
}

class Group {
  dynamic groupSymbolId;
  dynamic groupId;
  dynamic symbolId;
  dynamic clientId;
  dynamic buyPremium;
  dynamic sellPremium;
  dynamic oneClick;
  dynamic inTotal;
  String? groupName;
  String? symbolName;

  Group({
    this.groupSymbolId,
    this.groupId,
    this.symbolId,
    this.clientId,
    this.buyPremium,
    this.sellPremium,
    this.oneClick,
    this.inTotal,
    this.groupName,
    this.symbolName,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        groupSymbolId: json["GroupSymbolID"],
        groupId: json["GroupID"],
        symbolId: json["SymbolID"],
        clientId: json["ClientId"],
        buyPremium: json["BuyPremium"],
        sellPremium: json["SellPremium"],
        oneClick: json["OneClick"],
        inTotal: json["InTotal"],
        groupName: json["GroupName"],
        symbolName: json["SymbolName"],
      );

  Map<String, dynamic> toJson() => {
        "GroupSymbolID": groupSymbolId,
        "GroupID": groupId,
        "SymbolID": symbolId,
        "ClientId": clientId,
        "BuyPremium": buyPremium,
        "SellPremium": sellPremium,
        "OneClick": oneClick,
        "InTotal": inTotal,
        "GroupName": groupName,
        "SymbolName": symbolName,
      };
}

class GroupDetail {
  int? groupId;
  int? clientId;
  String? groupName;
  bool? status;
  bool? trade;
  dynamic goldBuyPremium;
  dynamic goldSellPremium;
  dynamic silverBuyPremium;
  dynamic silverSellPremium;

  GroupDetail({
    this.groupId,
    this.clientId,
    this.groupName,
    this.status,
    this.trade,
    this.goldBuyPremium,
    this.goldSellPremium,
    this.silverBuyPremium,
    this.silverSellPremium,
  });

  factory GroupDetail.fromJson(Map<String, dynamic> json) => GroupDetail(
        groupId: json["GroupID"],
        clientId: json["ClientId"],
        groupName: json["GroupName"],
        status: json["Status"],
        trade: json["trade"],
        goldBuyPremium: json["GoldBuyPremium"],
        goldSellPremium: json["GoldSellPremium"],
        silverBuyPremium: json["SilverBuyPremium"],
        silverSellPremium: json["SilverSellPremium"],
      );

  Map<String, dynamic> toJson() => {
        "GroupID": groupId,
        "ClientId": clientId,
        "GroupName": groupName,
        "Status": status,
        "trade": trade,
        "GoldBuyPremium": goldBuyPremium,
        "GoldSellPremium": goldSellPremium,
        "SilverBuyPremium": silverBuyPremium,
        "SilverSellPremium": silverSellPremium,
      };
}
