import 'dart:convert';
import 'dart:ui';

import '../Constants/app_colors.dart';

//RegisterRequest
//----------------------------------

String registerRequestToJson(RegisterRequest data) =>
    json.encode(data.toJson());

class RegisterRequest {
  int? accountId;
  String? name;
  String? firmname;
  String? number;
  String? email;
  String? city;
  String? gst;
  String? flag;
  String? clientId;

  RegisterRequest({
    this.accountId,
    this.name,
    this.firmname,
    this.number,
    this.email,
    this.city,
    this.gst,
    this.flag,
    this.clientId,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        accountId: json["AccountId"],
        name: json["Name"],
        firmname: json["Firmname"],
        number: json["Number"],
        email: json["Email"],
        city: json["City"],
        gst: json["GST"],
        flag: json["Flag"],
        clientId: json["ClientId"],
      );

  Map<String, dynamic> toJson() => {
        "AccountId": accountId,
        "Name": name,
        "Firmname": firmname,
        "Number": number,
        "Email": email,
        "City": city,
        "GST": gst,
        "Flag": flag,
        "ClientId": clientId,
      };
}

//Login Request
//----------------------------------
String loginRequestToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  int? loginid;
  String? password;
  int? clientId;
  String? firmname;

  LoginRequest({
    this.loginid,
    this.password,
    this.clientId,
    this.firmname,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        loginid: json["loginid"],
        password: json["Password"],
        clientId: json["ClientId"],
        firmname: json["Firmname"],
      );

  Map<String, dynamic> toJson() => {
        "loginid": loginid,
        "Password": password,
        "ClientId": clientId,
        "Firmname": firmname,
      };
}

//Delete Account
String deleteAccRequestToJson(DeleteAccRequest data) =>
    json.encode(data.toJson());

class DeleteAccRequest {
  int? clientId;
  int? loginid;

  DeleteAccRequest({
    this.clientId,
    this.loginid,
  });

  factory DeleteAccRequest.fromJson(Map<String, dynamic> json) =>
      DeleteAccRequest(
        clientId: json["ClientId"],
        loginid: json["loginid"],
      );

  Map<String, dynamic> toJson() => {
        "ClientId": clientId,
        "loginid": loginid,
      };
}

//OpenOrder Request
//----------------------------------
String openOrderReqToJson(OpenOrderRequest data) => json.encode(data.toJson());

class OpenOrderRequest {
  int? loginid;
  String? firmname;
  int? clientId;
  String? fromdate;
  String? todate;

  OpenOrderRequest({
    this.loginid,
    this.firmname,
    this.clientId,
    this.fromdate,
    this.todate,
  });

  factory OpenOrderRequest.fromJson(Map<String, dynamic> json) =>
      OpenOrderRequest(
        loginid: json["loginid"],
        firmname: json["Firmname"],
        clientId: json["ClientID"],
        fromdate: json["Fromdate"],
        todate: json["Todate"],
      );

  Map<String, dynamic> toJson() => {
        "loginid": loginid,
        "Firmname": firmname,
        "ClientID": clientId,
        "Fromdate": fromdate,
        "Todate": todate,
      };
}

//AccountDetail
//----------------------------------
class Accountdetails {
  String? msg;
  dynamic balance;
  dynamic freeMargin;
  dynamic usedMargin;

  Accountdetails({
    this.msg,
    this.balance,
    this.freeMargin,
    this.usedMargin,
  });

  factory Accountdetails.fromJson(Map<String, dynamic> json) => Accountdetails(
        msg: json["Msg"],
        balance: json["Balance"],
        freeMargin: json["FreeMargin"],
        usedMargin: json["UsedMargin"],
      );

  Map<String, dynamic> toJson() => {
        "Msg": msg,
        "Balance": balance,
        "FreeMargin": freeMargin,
        "UsedMargin": usedMargin,
      };
}

//OpenOrder Response List
//----------------------------------

class OpenOrder {
  List<OpenOrderElement> openOrder;

  OpenOrder({
    required this.openOrder,
  });

  factory OpenOrder.fromJson(Map<String, dynamic> json) => OpenOrder(
        openOrder: List<OpenOrderElement>.from(
            json["OpenOrder"].map((x) => OpenOrderElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "OpenOrder": List<dynamic>.from(openOrder.map((x) => x.toJson())),
      };
}

class OpenOrderElement {
  int? openOrderId;
  int? clientId;
  int? dealNo;
  String? loginId;
  String? userName;
  int? symbolId;
  String? symbolName;
  dynamic rate;
  dynamic total;
  String? ip;
  String? mac;
  dynamic volume;
  String? symbolDisplayRateType;
  dynamic premiumValue;
  String? tradeType;
  String? tradeFrom;
  dynamic closeDateTime;
  dynamic closePrice;
  dynamic pL;
  String? comment;
  dynamic margin;
  dynamic exchange;
  dynamic limitRate;
  String? limitCondition;
  bool? isLimitToOpen;
  String? modifiedDate;
  String? regId;
  String? openTradeDateTime;
  String? source;
  String? total1;
  dynamic prize;
  String? orders;
  String? tradeMode;

  OpenOrderElement({
    this.openOrderId,
    this.clientId,
    this.dealNo,
    this.loginId,
    this.userName,
    this.symbolId,
    this.symbolName,
    this.rate,
    this.total,
    this.ip,
    this.mac,
    this.volume,
    this.symbolDisplayRateType,
    this.premiumValue,
    this.tradeType,
    this.tradeFrom,
    this.closeDateTime,
    this.closePrice,
    this.pL,
    this.comment,
    this.margin,
    this.exchange,
    this.limitRate,
    this.limitCondition,
    this.isLimitToOpen,
    this.modifiedDate,
    this.regId,
    this.openTradeDateTime,
    this.source,
    this.total1,
    this.prize,
    this.orders,
    this.tradeMode,
  });

  factory OpenOrderElement.fromJson(Map<String, dynamic> json) =>
      OpenOrderElement(
        openOrderId: json["OpenOrderID"],
        clientId: json["ClientId"],
        dealNo: json["DealNo"],
        loginId: json["LoginID"],
        userName: json["UserName"],
        symbolId: json["SymbolID"],
        symbolName: json["SymbolName"],
        rate: json["Rate"],
        total: json["Total"],
        ip: json["IP"],
        mac: json["Mac"],
        volume: json["Volume"],
        symbolDisplayRateType: json["SymbolDisplayRateType"],
        premiumValue: json["PremiumValue"],
        tradeType: json["TradeType"],
        tradeFrom: json["TradeFrom"],
        closeDateTime: json["CloseDateTime"],
        closePrice: json["ClosePrice"],
        pL: json["P_L"],
        comment: json["Comment"],
        margin: json["Margin"],
        exchange: json["Exchange"],
        limitRate: json["LimitRate"],
        limitCondition: json["LimitCondition"],
        isLimitToOpen: json["IsLimitToOpen"],
        modifiedDate: json["ModifiedDate"],
        regId: json["RegID"],
        openTradeDateTime: json["OpenTradeDateTime"],
        source: json["Source"],
        total1: json["Total1"],
        prize: json["Prize"].toDouble(),
        orders: json["Orders"],
        tradeMode: json["TradeMode"],
      );

  Map<String, dynamic> toJson() => {
        "OpenOrderID": openOrderId,
        "ClientId": clientId,
        "DealNo": dealNo,
        "LoginID": loginId,
        "UserName": userName,
        "SymbolID": symbolId,
        "SymbolName": symbolName,
        "Rate": rate,
        "Total": total,
        "IP": ip,
        "Mac": mac,
        "Volume": volume,
        "SymbolDisplayRateType": symbolDisplayRateType,
        "PremiumValue": premiumValue,
        "TradeType": tradeType,
        "TradeFrom": tradeFrom,
        "CloseDateTime": closeDateTime,
        "ClosePrice": closePrice,
        "P_L": pL,
        "Comment": comment,
        "Margin": margin,
        "Exchange": exchange,
        "LimitRate": limitRate,
        "LimitCondition": limitCondition,
        "IsLimitToOpen": isLimitToOpen,
        "ModifiedDate": modifiedDate,
        "RegID": regId,
        "OpenTradeDateTime": openTradeDateTime,
        "Source": source,
        "Total1": total1,
        "Prize": prize,
        "Orders": orders,
        "TradeMode": tradeMode,
      };
}

//Delete Limit Request
//----------------------------------

String deleteLimitReqToJson(DeleteLimitRequest data) =>
    json.encode(data.toJson());

class DeleteLimitRequest {
  int? loginid;
  int? dealNo;
  int? clientId;
  String? token;

  DeleteLimitRequest({
    this.loginid,
    this.dealNo,
    this.clientId,
    this.token,
  });

  factory DeleteLimitRequest.fromJson(Map<String, dynamic> json) =>
      DeleteLimitRequest(
        loginid: json["LoginId"],
        dealNo: json["DealNo"],
        clientId: json["ClientId"],
        token: json["Token"],
      );

  Map<String, dynamic> toJson() => {
        "LoginId": loginid,
        "DealNo": dealNo,
        "ClientId": clientId,
        "Token": token,
      };
}

//Update Limit Request
//----------------------------------

String updateLimitReqToJson(UpdateLimitRequest data) =>
    json.encode(data.toJson());

class UpdateLimitRequest {
  String? dealNo;
  String? volume;
  String? rate;
  String? token;
  String? openOrderId;
  String? symbolId;
  String? tradeType;

  UpdateLimitRequest({
    this.dealNo,
    this.volume,
    this.rate,
    this.token,
    this.openOrderId,
    this.symbolId,
    this.tradeType,
  });
//let updateLimit = new Object();
  // updateLimit["DealNo"] = $("#mdlDeal").val();
  // updateLimit["Volume"] = $("#mdlVol").val();
  // updateLimit["Rate"] = $("#mdlPrice").val();
  // updateLimit["Token"] = ObjClient.Token;
  // updateLimit["OpenOrderID"] = $("#mdlhdnOpenOrderID").val();
  // updateLimit["SymbolID"] = $("#mdlhdnSymbolID").val()
  factory UpdateLimitRequest.fromJson(Map<String, dynamic> json) =>
      UpdateLimitRequest(
        dealNo: json["DealNo"],
        volume: json["Volume"],
        rate: json["Rate"],
        token: json["Token"],
        openOrderId: json["OpenOrderID"],
        symbolId: json["SymbolID"],
        tradeType: json["TradeType"],
      );

  Map<String, dynamic> toJson() => {
        "DealNo": dealNo,
        "Volume": volume,
        "Rate": rate,
        "Token": token,
        "OpenOrderID": openOrderId,
        "SymbolID": symbolId,
        "TradeType": tradeType,
      };
}

//Update Request
//----------------------------------

String updateToJson(UpdateRequest data) => json.encode(data.toJson());

class UpdateRequest {
  String? startDate;
  String? endDate;
  String? client;

  UpdateRequest({
    this.startDate,
    this.endDate,
    this.client,
  });

  factory UpdateRequest.fromJson(Map<String, dynamic> json) => UpdateRequest(
        startDate: json["StartDate"],
        endDate: json["EndDate"],
        client: json["Client"],
      );

  Map<String, dynamic> toJson() => {
        "StartDate": startDate,
        "EndDate": endDate,
        "Client": client,
      };
}

//Update Response
//----------------------------------
class UpdateList {
  String? day;
  int? year;
  String? time;
  String? month;
  String? title;
  String? description;
  int? newsId;
  String? sortnews;
  String? cdate;
  String? mdate;
  dynamic ipAdd;
  dynamic status;
  String? errorMsg;
  String? errorCode;

  UpdateList({
    this.day,
    this.year,
    this.time,
    this.month,
    this.title,
    this.description,
    this.newsId,
    this.sortnews,
    this.cdate,
    this.mdate,
    this.ipAdd,
    this.status,
    this.errorMsg,
    this.errorCode,
  });

  factory UpdateList.fromJson(Map<String, dynamic> json) => UpdateList(
        day: json["Day"],
        year: json["Year"],
        time: json["Time"],
        month: json["Month"],
        title: json["Title"],
        description: json["Description"],
        newsId: json["NewsId"],
        sortnews: json["Sortnews"],
        cdate: json["Cdate"],
        mdate: json["Mdate"],
        ipAdd: json["IpAdd"],
        status: json["Status"],
        errorMsg: json["ERROR_MSG"],
        errorCode: json["ERROR_CODE"],
      );

  Map<String, dynamic> toJson() => {
        "Day": day,
        "Year": year,
        "Time": time,
        "Month": month,
        "Title": title,
        "Description": description,
        "NewsId": newsId,
        "Sortnews": sortnews,
        "Cdate": cdate,
        "Mdate": mdate,
        "IpAdd": ipAdd,
        "Status": status,
        "ERROR_MSG": errorMsg,
        "ERROR_CODE": errorCode,
      };
}

//Bank List Response
//----------------------------------
class BankList {
  int? bankId;
  int? clientId;
  String? accountName;
  String? bankName;
  String? accountNo;
  String? ifsc;
  String? branchName;
  String? mdate;
  String? onlyDate;
  String? onlyTime;
  String? bankLogo;

  BankList({
    this.bankId,
    this.clientId,
    this.accountName,
    this.bankName,
    this.accountNo,
    this.ifsc,
    this.branchName,
    this.mdate,
    this.onlyDate,
    this.onlyTime,
    this.bankLogo,
  });

  factory BankList.fromJson(Map<String, dynamic> json) => BankList(
        bankId: json["BankID"],
        clientId: json["ClientID"],
        accountName: json["AccountName"],
        bankName: json["BankName"],
        accountNo: json["AccountNo"],
        ifsc: json["Ifsc"],
        branchName: json["BranchName"],
        mdate: json["Mdate"],
        onlyDate: json["OnlyDate"],
        onlyTime: json["OnlyTime"],
        bankLogo: json["BankLogo"],
      );

  Map<String, dynamic> toJson() => {
        "BankID": bankId,
        "ClientID": clientId,
        "AccountName": accountName,
        "BankName": bankName,
        "AccountNo": accountNo,
        "Ifsc": ifsc,
        "BranchName": branchName,
        "Mdate": mdate,
        "OnlyDate": onlyDate,
        "OnlyTime": onlyTime,
        "BankLogo": bankLogo,
      };
}

//Feedback Request
//----------------------------------
String feedbackToJson(FeedbackRequest data) => json.encode(data.toJson());

class FeedbackRequest {
  FeedbackRequest({
    this.name,
    this.email,
    this.phone,
    this.client,
    this.message,
    this.sub,
  });

  String? name;
  String? email;
  String? phone;
  int? client;
  String? message;
  String? sub;

  factory FeedbackRequest.fromJson(Map<String, dynamic> json) =>
      FeedbackRequest(
        name: json["Name"],
        email: json["Email"],
        phone: json["Phone"],
        client: json["Client"],
        message: json["Message"],
        sub: json["Sub"],
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "Email": email,
        "Phone": phone,
        "Client": client,
        "Message": message,
        "Sub": sub,
      };
}

//InsertOpenOrderDetailRequest Request
//----------------------------------
InsertOpenOrderDetailRequest insertOpenOrderDetailRequestFromJson(String str) =>
    InsertOpenOrderDetailRequest.fromJson(json.decode(str));

String insertOpenOrderDetailRequestToJson(InsertOpenOrderDetailRequest data) =>
    json.encode(data.toJson());

class InsertOpenOrderDetailRequest {
  String? symbolId;
  String? token;
  String? quantity;
  String? tradeFrom;
  String? tradeType;
  String? deviceToken;
  String? buyLimitPrice;
  String? sellLimitPrice;

  InsertOpenOrderDetailRequest({
    this.symbolId,
    this.token,
    this.quantity,
    this.tradeFrom,
    this.tradeType,
    this.deviceToken,
    this.buyLimitPrice,
    this.sellLimitPrice,
  });

  factory InsertOpenOrderDetailRequest.fromJson(Map<String, dynamic> json) =>
      InsertOpenOrderDetailRequest(
        symbolId: json["SymbolId"],
        token: json["Token"],
        quantity: json["Quantity"],
        tradeFrom: json["TradeFrom"],
        tradeType: json["TradeType"],
        deviceToken: json["DeviceToken"],
        buyLimitPrice: json["BuyLimitPrice"],
        sellLimitPrice: json["SellLimitPrice"],
      );

  Map<String, dynamic> toJson() => {
        "SymbolId": symbolId,
        "Token": token,
        "Quantity": quantity,
        "TradeFrom": tradeFrom,
        "TradeType": tradeType,
        "DeviceToken": deviceToken,
        "BuyLimitPrice": buyLimitPrice,
        "SellLimitPrice": sellLimitPrice,
      };
}

//Group Details buy sell Response
//----------------------------------
class GroupDetailsBuySell {
  int? groupId;
  int? clientId;
  String? groupName;
  bool? status;
  bool? trade;
  dynamic goldBuyPremium;
  dynamic goldSellPremium;
  dynamic silverBuyPremium;
  dynamic silverSellPremium;
  String? clientName;

  GroupDetailsBuySell({
    this.groupId,
    this.clientId,
    this.groupName,
    this.status,
    this.trade,
    this.goldBuyPremium,
    this.goldSellPremium,
    this.silverBuyPremium,
    this.silverSellPremium,
    this.clientName,
  });

  factory GroupDetailsBuySell.fromJson(Map<String, dynamic> json) =>
      GroupDetailsBuySell(
        groupId: json["GroupID"],
        clientId: json["ClientId"],
        groupName: json["GroupName"],
        status: json["Status"],
        trade: json["trade"],
        goldBuyPremium: json["GoldBuyPremium"],
        goldSellPremium: json["GoldSellPremium"],
        silverBuyPremium: json["SilverBuyPremium"],
        silverSellPremium: json["SilverSellPremium"],
        clientName: json["ClientName"],
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
        "ClientName": clientName,
      };
}

//Group Details drop down Response
//----------------------------------
class GroupDetailsDropDown {
  dynamic groupId;
  dynamic symbolId;
  String? userName;
  dynamic buyPremium;
  dynamic sellPremium;
  dynamic oneClick;
  dynamic inTotal;
  dynamic step;
  dynamic goldBuyGp;
  dynamic goldSellGp;
  dynamic silverBuyGp;
  dynamic silverSellGp;
  String? groupName;
  String? symbolName;
  bool? status;

  GroupDetailsDropDown({
    this.groupId,
    this.symbolId,
    this.userName,
    this.buyPremium,
    this.sellPremium,
    this.oneClick,
    this.inTotal,
    this.step,
    this.goldBuyGp,
    this.goldSellGp,
    this.silverBuyGp,
    this.silverSellGp,
    this.groupName,
    this.symbolName,
    this.status,
  });

  factory GroupDetailsDropDown.fromJson(Map<String, dynamic> json) =>
      GroupDetailsDropDown(
        groupId: json["groupId"],
        symbolId: json["SymbolID"],
        userName: json["userName"],
        buyPremium: json["BuyPremium"],
        sellPremium: json["SellPremium"],
        oneClick: json["OneClick"],
        inTotal: json["InTotal"],
        step: json["Step"],
        goldBuyGp: json["GoldBuy_GP"],
        goldSellGp: json["GoldSell_GP"],
        silverBuyGp: json["SilverBuy_GP"],
        silverSellGp: json["SilverSell_GP"],
        groupName: json["GroupName"],
        symbolName: json["SymbolName"],
        status: json["Status"],
      );

  Map<String, dynamic> toJson() => {
    "groupId": groupId,
    "SymbolID": symbolId,
    "userName": userName,
    "BuyPremium": buyPremium,
    "SellPremium": sellPremium,
    "OneClick": oneClick,
    "InTotal": inTotal,
    "Step": step,
    "GoldBuy_GP": goldBuyGp,
    "GoldSell_GP": goldSellGp,
    "SilverBuy_GP": silverBuyGp,
    "SilverSell_GP": silverSellGp,
    "GroupName": groupName,
    "SymbolName": symbolName,
    "Status": status,
      };
}

//Profile Details drop down Response
//----------------------------------

class ProfileDetails {
  String? name;
  String? loginId;
  int? officeId;
  String? number;
  String? email;
  String? city;
  int? groupId;
  String? gst;
  dynamic balance;
  String? userName;
  String? firmname;

  ProfileDetails({
    this.name,
    this.loginId,
    this.officeId,
    this.number,
    this.email,
    this.city,
    this.groupId,
    this.gst,
    this.balance,
    this.userName,
    this.firmname,
  });

  factory ProfileDetails.fromJson(Map<String, dynamic> json) => ProfileDetails(
    name: json["Name"],
    loginId: json["loginId"],
    officeId: json["officeId"],
    number: json["Number"],
    email: json["Email"],
    city: json["City"],
    groupId: json["groupId"],
    gst: json["GST"],
    balance: json["Balance"],
    userName: json["userName"],
    firmname: json["Firmname"],
      );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "loginId": loginId,
    "officeId": officeId,
    "Number": number,
    "Email": email,
    "City": city,
    "groupId": groupId,
    "GST": gst,
    "Balance": balance,
    "userName": userName,
    "Firmname": firmname,
      };
}

//Coins response
Coins coinsFromJson(String str) => Coins.fromJson(json.decode(str));

String coinsToJson(Coins data) => json.encode(data.toJson());

class Coins {
  String? coinsId;
  String? cleintId;
  String? coinsName;
  String? coinsBase;
  String? description;
  String? userName;
  dynamic ask;
  dynamic bid;
  String? retail;
  // dynamic weight;
  // dynamic purity;
  dynamic stock;
  String? headerType;
  Color askBGColor;
  Color askTextColor;


  Coins({
     this.coinsId,
     this.cleintId,
     this.coinsName,
     this.coinsBase,
     this.description,
     this.userName,
    this.ask,
    this.bid,
     this.retail,
    // this.weight,
    // this.purity,
    this.stock,
     this.headerType,
    this.askBGColor = AppColors.defaultColor,
    this.askTextColor = AppColors.textColor,
  });

  factory Coins.fromJson(Map<String, dynamic> json) => Coins(
        coinsId: json["CoinsId"],
        cleintId: json["CleintId"],
        coinsName: json["CoinsName"],
        coinsBase: json["CoinsBase"],
        description: json["Description"],
        userName: json["UserName"],
        ask: json["Ask"],
        bid: json["Bid"],
        retail: json["Retail"],
        // weight: json["Weight"],
        // purity: json["Purity"],
        stock: json["Stock"],
        headerType: json["HeaderType"],
      );

  Map<String, dynamic> toJson() => {
        "CoinsId": coinsId,
        "CleintId": cleintId,
        "CoinsName": coinsName,
        "CoinsBase": coinsBase,
        "Description": description,
        "UserName": userName,
        "Ask": ask,
        "Bid": bid,
        "Retail": retail,
        // "Weight": weight,
        // "Purity": purity,
        "Stock": stock,
        "HeaderType": headerType,
      };
}
