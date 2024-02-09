import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:terminal_demo/Constants/constant.dart';
import 'package:terminal_demo/Functions.dart';
import 'package:terminal_demo/Models/CommonRequestModel.dart';
import '../Constants/notify_socket_update.dart';
import '../Models/loginData.dart';
import '../Models/client_header.dart';
import '../Models/liverate.dart';
import '../Models/reference_data.dart';
import '../Models/reference_data_rate.dart';
import '../Providers/liveRate_Provider.dart';
import '../Utils/shared.dart';

class SocketService {
  static getLiveRateData(BuildContext context) async {
    Shared shared = Shared();
    bool isLogin = false;
    late LoginData userData;
    final provider = Provider.of<LiveRateProvider>(context, listen: false);

    Socket socket = io(
        Constants.socketUrl,
        OptionBuilder().setTransports(
            ['websocket']).build()); // Set socket url for connection
    socket.disconnect();
    debugPrint('Socket Disconnect');
    socket.connect();
    debugPrint('Socket Connect');
    socket.onConnect((_) async {
      socket.emit('client', [Constants.projectName]);
      socket.emit('room', [Constants.projectName]);
      debugPrint('Client And Room Emit');
      shared.getIsLogin().then((login) async {
        if (login) {
          final loginData = await shared.getLoginData();
          if (loginData.isNotEmpty) {
            userData = LoginData.getJson(json.decode(loginData));
            socket.emit(
                "endUser", "${Constants.projectName}_${userData.loginId}");
            debugPrint('End User Emit');
          }
        }
      });
    });

    socket.on('clientDetails', (response) {
      var data = Functions.inflateData(response);
      if (data['messageType'] == 'header') {
        // var responseData = jsonDecode(data["data"]);
        // List<ClientHeaderData> listData = [];
        // for (var data in data["data"]) {
        //   final clientHeaderData = ClientHeaderData.fromJson(data);
        //   listData.add(clientHeaderData);
        // }
        // provider.addClientHeaderData(listData);
        final List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(data['data']);

        final listData =
            dataList.map((data) => ClientHeaderData.fromJson(data)).toList();

        provider.addClientHeaderData(listData);

        _addToControllerIfNotClosed(
            listData, NotifySocketUpdate.controllerClientData);
        _addToControllerIfNotClosed(
            listData, NotifySocketUpdate.controllerHome);
      }
    });

    socket.on('refDetails', (response) {
      var responseData = Functions.inflateData(response);
      // var responseData = jsonDecode(data);
      List<ReferenceData> listData = [];
      for (var data in responseData) {
        final liveRate = ReferenceData.fromJson(data);
        listData.add(liveRate);
      }
      provider.addReferenceData(listData);
      // debugPrint('ClientData' + responseData.toString());
    });

    socket.on('refProduct', (refProduct) {
      var responseData = Functions.inflateData(refProduct);

      List<ReferenceDataRate> referenceDataRate = [];
      for (var item in responseData) {
        referenceDataRate.add(ReferenceDataRate.fromJson(item));
      }
      provider.addReferenceDataRate(referenceDataRate);
      _addToControllerIfNotClosed(
          referenceDataRate, NotifySocketUpdate.controllerMainData);
    });

    socket.on('mainProduct', (messageResponse) async {
      List<Liverate> liveRate = [];
      isLogin = await shared.getIsLogin();
      var responseData = Functions.inflateData(messageResponse);

      // var responseData = data['Rate'];

      if (isLogin) {
        // List<GroupDetailsBuySell> premiData = provider.getPremiumData();
        List<GroupDetailsDropDown> groupDetails = provider.getDropDownData();
        for (var item in responseData) {
          if (item['isTerminal'] == true) {
            for (var grpDet in groupDetails) {
              if (grpDet.symbolId == int.parse(item['id'])) {
                if (groupDetails.isNotEmpty && grpDet.status != false) {
                  final source = item['src'].toLowerCase();
                  dynamic goldBuyPremium = grpDet.goldBuyGp ?? 0;
                  dynamic goldSellPremium = grpDet.goldSellGp ?? 0;
                  dynamic silverBuyPremium = grpDet.silverBuyGp ?? 0;
                  dynamic silverSellPremium = grpDet.silverSellGp ?? 0;
                  //group filter premium buy sell
                  dynamic buyPremium = grpDet.buyPremium;
                  dynamic sellPremium = grpDet.sellPremium;
                  dynamic bid, ask, high, low, premSell, premBuy;

                  if (source == 'gold' || source == 'goldnext') {
                    bid = !Functions.isNumeric(item['bid'])
                        ? '--'
                        : (Functions.isDecimal(item['bid'])
                                ? double.parse(item['bid'])
                                : int.parse(item['bid'])) +
                            goldBuyPremium +
                            buyPremium;
                    ask = !Functions.isNumeric(item['ask'])
                        ? '--'
                        : (Functions.isDecimal(item['ask'])
                                ? double.parse(item['ask'])
                                : int.parse(item['ask'])) +
                            goldSellPremium +
                            sellPremium;
                    high = !Functions.isNumeric(item['high'])
                        ? '--'
                        : (Functions.isDecimal(item['high'])
                                ? double.parse(item['high'])
                                : int.parse(item['high'])) +
                            goldSellPremium +
                            sellPremium;
                    low = !Functions.isNumeric(item['low'])
                        ? '--'
                        : (Functions.isDecimal(item['low'])
                                ? double.parse(item['low'])
                                : int.parse(item['low'])) +
                            goldBuyPremium +
                            buyPremium;

                    // premSell = !Functions.isNumeric(item['Premium'])
                    //     ? '--'
                    //     : (Functions.isDecimal(item['Premium'])
                    //             ? double.parse(item['Premium'])
                    //             : int.parse(item['Premium'])) +
                    //         sellPremium +
                    //         goldSellPremium;
                    // premBuy = !Functions.isNumeric(item['PremiumBuy'])
                    //     ? '--'
                    //     : (Functions.isDecimal(item['PremiumBuy'])
                    //             ? double.parse(item['PremiumBuy'])
                    //             : int.parse(item['PremiumBuy'])) +
                    //         buyPremium +
                    //         goldBuyPremium;
                  } else {
                    bid = !Functions.isNumeric(item['bid'])
                        ? '--'
                        : (Functions.isDecimal(item['bid'])
                                ? double.parse(item['bid'])
                                : int.parse(item['bid'])) +
                            silverBuyPremium +
                            buyPremium;
                    ask = !Functions.isNumeric(item['ask'])
                        ? '--'
                        : (Functions.isDecimal(item['ask'])
                                ? double.parse(item['ask'])
                                : int.parse(item['ask'])) +
                            silverSellPremium +
                            sellPremium;
                    high = !Functions.isNumeric(item['high'])
                        ? '--'
                        : (Functions.isDecimal(item['high'])
                                ? double.parse(item['high'])
                                : int.parse(item['high'])) +
                            silverSellPremium +
                            sellPremium;
                    low = !Functions.isNumeric(item['low'])
                        ? '--'
                        : (Functions.isDecimal(item['low'])
                                ? double.parse(item['low'])
                                : int.parse(item['low'])) +
                            silverBuyPremium +
                            sellPremium;
                    // premSell = !Functions.isNumeric(item['Premium'])
                    //     ? '--'
                    //     : (Functions.isDecimal(item['Premium'])
                    //             ? double.parse(item['Premium'])
                    //             : int.parse(item['Premium'])) +
                    //         sellPremium +
                    //         silverSellPremium;
                    // premBuy = !Functions.isNumeric(item['PremiumBuy'])
                    //     ? '--'
                    //     : (Functions.isDecimal(item['PremiumBuy'])
                    //             ? double.parse(item['PremiumBuy'])
                    //             : int.parse(item['PremiumBuy'])) +
                    //         buyPremium +
                    //         silverBuyPremium;
                  }
                  liveRate.add(Liverate(
                    id: item["id"],
                    name: item["name"],
                    src: item["src"],
                    usr: item["usr"],
                    isView: item["isView"],
                    isTerminal: item["isTerminal"],
                    type: item["type"],
                    time: item["time"],
                    bid: bid.toString(),
                    ask: ask.toString(),
                    high: high.toString(),
                    low: low.toString(),
                  ));
                } else {
                  provider.addLiveRateData([]);
                }
              }
            }
          }
        }
        provider.addLiveRateData(liveRate);
      } else {
        for (var item in responseData) {
          if (item['isView'] == true) {
            liveRate.add(Liverate.fromJson(item));
          }
        }
        provider.addLiveRateData(liveRate);
      }
      // _addToControllerIfNotClosed(liveRate, NotifySocketUpdate.controllerMainData);
    });

    socket.on('accountDetails', (accountDetails) {
      if (accountDetails[0]["Status"] == false) {
        shared.setIsLogin(false);
        Constants.isLogin = false;
      } else {
        var responseData = Functions.inflateData(accountDetails[1]);
        ProfileDetails account = ProfileDetails.fromJson(responseData[0]);
        Constants.loginName = account.name!;
        provider.addAccountData(account);
        socket.emit('group', '${Constants.projectName}_${account.groupId}');
        _addToControllerIfNotClosed(
            accountDetails, NotifySocketUpdate.controllerAccountDetails);
      }
    });

    socket.on('Orders', (orders) {
      if (orders != "" && orders == "true" && orders.split("~~")[0] == "true") {
        _addToControllerIfNotClosed(
            orders, NotifySocketUpdate.controllerOrderDetails);
      } else if (orders != "" &&
              orders.split("~~")[0] ==
                  "true" /*&&
          orders.split("~~")[2].trim() == userData.loginId*/
          ) {
        _addToControllerIfNotClosed(
            orders, NotifySocketUpdate.controllerOrderDetails);
      }
    });

    socket.on('groupDetails', (groupDetails) {
      var responseData = Functions.inflateData(groupDetails);
      // debugPrint('groupDetails------------------------------$groupDetails');
      List<GroupDetailsDropDown> dropDown = [];
      for (var item in responseData) {
        debugPrint('groupDetails$item');
        dropDown.add(GroupDetailsDropDown.fromJson(item));
        // if (item is List) {
        //   List<GroupDetailsBuySell> premiumData = [];
        //   List<GroupDetailsDropDown> dropDown = [];
        //   for (var item in groupDetails[0]) {
        //     premiumData.add(GroupDetailsBuySell.fromJson(item));
        //   }
        //   for (var item in groupDetails[1]) {
        //     dropDown.add(GroupDetailsDropDown.fromJson(item));
        //   }
        //
        //   socket.emit("GroupDetails",
        //       "${Constants.projectName}_${premiumData[0].groupName!}");
        //
        //   provider.addPremiumData(premiumData);
        //   provider.addDropDownData(dropDown);
        //   _addToControllerIfNotClosed(
        //       groupDetails[1], NotifySocketUpdate.dropDown);
        // } else if (item is Map) {
        //   provider.addPremiumData([]);
        //   provider.addDropDownData([]);
        //   debugPrint('Map');
        // }
      }
      provider.addDropDownData(dropDown);
      _addToControllerIfNotClosed(responseData, NotifySocketUpdate.dropDown);
    });

    socket.on('isLogin', (isLogin) {
      var responseData = Functions.inflateData(isLogin);
      if (responseData == false) {
        shared.setIsLogin(false);
        Constants.isLogin = false;
      }
    });

    // socket.on('coin', (response) {
    //   List<Coins> coinData = [];
    //   if (response['CoinRate']!=null) {
    //     for (var item in response['CoinRate']) {
    //       coinData.add(Coins.fromJson(item));
    //     }
    //   }
    //   provider.addCoinData(coinData);
    //   _addToControllerIfNotClosed(coinData, NotifySocketUpdate.controllerCoin);
    //   debugPrint('coinRate-$response.toString()');
    // });

    socket.onConnectError((err) => debugPrint('$err'));
    socket.onError((err) {
      debugPrint('$err');
    });
  }

  static void _addToControllerIfNotClosed<T>(T data, StreamController<T>? controller) {
    if (controller != null && !controller.isClosed) {
      controller.sink.add(data);
    }
  }
}
