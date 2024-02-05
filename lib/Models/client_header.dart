// To parse this JSON data, do
//
//     final clientHeade = clientHeadeFromJson(jsonString);

import 'dart:convert';

ClientHeaderData clientHeadeFromJson(String str) => ClientHeaderData.fromJson(json.decode(str));

String clientHeadeToJson(ClientHeaderData data) => json.encode(data.toJson());

class ClientHeaderData {
  int? bullionId;
  String? firmName;
  String? personName1;
  String? personName2;
  bool? active;
  String? userName;
  String? mobile1;
  String? mobile2;
  String? landline;
  String? address;
  String? domain;
  bool? bullion;
  bool? mainProduct;
  bool? coin;
  bool? terminal;
  bool? status;
  bool? rateDisplay;
  bool? coinRateDisplay;
  String? bookingNo1;
  String? bookingNo2;
  String? bookingNo3;
  String? email1;
  String? email2;
  String? addressClient;
  String? marquee;
  String? goldCoinHeader;
  String? silverCoinHeader;
  bool? goldCoinIsDisplay;
  bool? silverCoinIsDisplay;
  bool? highRate;
  bool? lowRate;
  String? bannerWeb;
  String? bannerApp;
  int? symbolCount;
  int? coinCount;
  String? whatsappNo1;
  String? bannerApp1;
  String? bannerWeb1;
  bool? diff;
  bool? buyRate;
  bool? sellRate;
  String? marquee2;
  String? bookingNo4;
  String? bookingNo5;
  String? bookingNo6;
  String? bookingNo7;
  String? addressClient2;
  String? addressClient3;
  int? widgetCount;
  int? goldRateDiff;
  int? silverRateDiff;

  ClientHeaderData({
    this.bullionId,
    this.firmName,
    this.personName1,
    this.personName2,
    this.active,
    this.userName,
    this.mobile1,
    this.mobile2,
    this.landline,
    this.address,
    this.domain,
    this.bullion,
    this.mainProduct,
    this.coin,
    this.terminal,
    this.status,
    this.rateDisplay,
    this.coinRateDisplay,
    this.bookingNo1,
    this.bookingNo2,
    this.bookingNo3,
    this.email1,
    this.email2,
    this.addressClient,
    this.marquee,
    this.goldCoinHeader,
    this.silverCoinHeader,
    this.goldCoinIsDisplay,
    this.silverCoinIsDisplay,
    this.highRate,
    this.lowRate,
    this.bannerWeb,
    this.bannerApp,
    this.symbolCount,
    this.coinCount,
    this.whatsappNo1,
    this.bannerApp1,
    this.bannerWeb1,
    this.diff,
    this.buyRate,
    this.sellRate,
    this.marquee2,
    this.bookingNo4,
    this.bookingNo5,
    this.bookingNo6,
    this.bookingNo7,
    this.addressClient2,
    this.addressClient3,
    this.widgetCount,
    this.goldRateDiff,
    this.silverRateDiff,
  });

  factory ClientHeaderData.fromJson(Map<String, dynamic> json) => ClientHeaderData(
    bullionId: json["BullionID"],
    firmName: json["FirmName"],
    personName1: json["PersonName1"],
    personName2: json["PersonName2"],
    active: json["Active"],
    userName: json["UserName"],
    mobile1: json["Mobile1"],
    mobile2: json["Mobile2"],
    landline: json["Landline"],
    address: json["Address"],
    domain: json["Domain"],
    bullion: json["Bullion"],
    mainProduct: json["MainProduct"],
    coin: json["Coin"],
    terminal: json["Terminal"],
    status: json["Status"],
    rateDisplay: json["RateDisplay"],
    coinRateDisplay: json["CoinRateDisplay"],
    bookingNo1: json["BookingNo1"],
    bookingNo2: json["BookingNo2"],
    bookingNo3: json["BookingNo3"],
    email1: json["Email1"],
    email2: json["Email2"],
    addressClient: json["Address_client"],
    marquee: json["Marquee"],
    goldCoinHeader: json["GoldCoinHeader"],
    silverCoinHeader: json["SilverCoinHeader"],
    goldCoinIsDisplay: json["GoldCoinIsDisplay"],
    silverCoinIsDisplay: json["SilverCoinIsDisplay"],
    highRate: json["HighRate"],
    lowRate: json["LowRate"],
    bannerWeb: json["BannerWeb"],
    bannerApp: json["BannerApp"],
    symbolCount: json["SYMBOL_COUNT"],
    coinCount: json["COIN_COUNT"],
    whatsappNo1: json["whatsapp_no1"],
    bannerApp1: json["BannerApp1"],
    bannerWeb1: json["BannerWeb1"],
    diff: json["diff"],
    buyRate: json["BuyRate"],
    sellRate: json["SellRate"],
    marquee2: json["Marquee2"],
    bookingNo4: json["BookingNo4"],
    bookingNo5: json["BookingNo5"],
    bookingNo6: json["BookingNo6"],
    bookingNo7: json["BookingNo7"],
    addressClient2: json["Address_client2"],
    addressClient3: json["Address_client3"],
    widgetCount: json["WIDGET_COUNT"],
    goldRateDiff: json["GoldRateDiff"],
    silverRateDiff: json["SilverRateDiff"],
  );

  Map<String, dynamic> toJson() => {
    "BullionID": bullionId,
    "FirmName": firmName,
    "PersonName1": personName1,
    "PersonName2": personName2,
    "Active": active,
    "UserName": userName,
    "Mobile1": mobile1,
    "Mobile2": mobile2,
    "Landline": landline,
    "Address": address,
    "Domain": domain,
    "Bullion": bullion,
    "MainProduct": mainProduct,
    "Coin": coin,
    "Terminal": terminal,
    "Status": status,
    "RateDisplay": rateDisplay,
    "CoinRateDisplay": coinRateDisplay,
    "BookingNo1": bookingNo1,
    "BookingNo2": bookingNo2,
    "BookingNo3": bookingNo3,
    "Email1": email1,
    "Email2": email2,
    "Address_client": addressClient,
    "Marquee": marquee,
    "GoldCoinHeader": goldCoinHeader,
    "SilverCoinHeader": silverCoinHeader,
    "GoldCoinIsDisplay": goldCoinIsDisplay,
    "SilverCoinIsDisplay": silverCoinIsDisplay,
    "HighRate": highRate,
    "LowRate": lowRate,
    "BannerWeb": bannerWeb,
    "BannerApp": bannerApp,
    "SYMBOL_COUNT": symbolCount,
    "COIN_COUNT": coinCount,
    "whatsapp_no1": whatsappNo1,
    "BannerApp1": bannerApp1,
    "BannerWeb1": bannerWeb1,
    "diff": diff,
    "BuyRate": buyRate,
    "SellRate": sellRate,
    "Marquee2": marquee2,
    "BookingNo4": bookingNo4,
    "BookingNo5": bookingNo5,
    "BookingNo6": bookingNo6,
    "BookingNo7": bookingNo7,
    "Address_client2": addressClient2,
    "Address_client3": addressClient3,
    "WIDGET_COUNT": widgetCount,
    "GoldRateDiff": goldRateDiff,
    "SilverRateDiff": silverRateDiff,
  };
}
