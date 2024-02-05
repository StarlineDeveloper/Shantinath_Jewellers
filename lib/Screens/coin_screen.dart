import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Constants/app_colors.dart';
import '../Constants/images.dart';
import '../Constants/notify_socket_update.dart';
import '../Models/CommonRequestModel.dart';
import '../Providers/liveRate_Provider.dart';
import '../Routes/page_route.dart';
import '../Widgets/custom_text.dart';

class Coin_Screen extends StatefulWidget {
  static const String routeName = PageRoutes.coinScreen;

  const Coin_Screen({super.key});

  @override
  State<Coin_Screen> createState() => _Coin_ScreenState();
}

class _Coin_ScreenState extends State<Coin_Screen>
    with TickerProviderStateMixin {
  bool isGoldSelected = true;
  late TabController _tabGoldSilverController;
  List<Coins> coinRateMaster = [];
  List<Coins> coinRateMasterOld = [];
  List<Coins> coinRateGold = [];
  List<Coins> coinRateSilver = [];
  late LiveRateProvider _liverateProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabGoldSilverController = TabController(length: 2, vsync: this);
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    loadData();
    NotifySocketUpdate.controllerCoin = StreamController();

    NotifySocketUpdate.controllerCoin!.stream.asBroadcastStream().listen(
      (event) {
        loadData();
      },
    );
  }

  loadData() {
    coinRateMaster = [];
    coinRateMasterOld = [];
    coinRateGold = [];
    coinRateSilver = [];

    // Get Data From Providers..
    coinRateMaster = _liverateProvider.getCoinData();
    // seperate GoldSilverList From coinsBase();
    for (int i = 0; i < coinRateMaster.length; i++) {
      if (coinRateMaster[i].coinsBase?.toLowerCase() == 'gold') {
        coinRateGold.add(coinRateMaster[i]);
      } else {
        coinRateSilver.add(coinRateMaster[i]);
      }
    }

    coinRateMaster =
        isGoldSelected ? List.from(coinRateGold) : List.from(coinRateSilver);
    coinRateMasterOld = coinRateMaster;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    NotifySocketUpdate.controllerCoin!.close();
    super.dispose();
    _tabGoldSilverController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: size.height * .01,
                top: size.height * .01),
            child: Container(
              height: size.height * 0.045,
              decoration: BoxDecoration(
                color: AppColors.primaryLightColor,
                borderRadius: BorderRadius.circular(
                  12.0,
                ),
              ),
              child: TabBar(
                onTap: (index) {
                  if (index == 0) {
                    setState(() {
                      isGoldSelected = true;
                    });
                  } else {
                    setState(() {
                      isGoldSelected = false;
                    });
                  }
                  debugPrint(isGoldSelected.toString());
                },
                controller: _tabGoldSilverController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ),
                  color: AppColors.primaryColor,
                ),
                labelColor: AppColors.defaultColor,
                unselectedLabelColor: AppColors.primaryColor,
                tabs: const [
                  Tab(
                    child: Text(
                      'Gold',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Silver',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 35.0,
              // color: AppColors.primaryColor,
              decoration: BoxDecoration(
                border: Border.all(width: 0.8, color: AppColors.primaryColor),
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size.width * .2,
                    child: const CustomText(
                      text: 'COINS',
                      size: 14.0,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.defaultColor,
                      align: TextAlign.start,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(
                      child: CustomText(
                        text: 'PRICE',
                        size: 14.0,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.defaultColor,
                        align: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: size.height * .01,
          ),
          coinRateMaster.isEmpty
              ? const Expanded(
                  child:  Center(
                  child: CustomText(
                      text: 'Coins Not Available.',
                      textColor: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      size: 16.0),
                ))
              : Flexible(
                  child: ListView.builder(
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: coinRateMaster.length,
                    itemBuilder: (context, index) => buildCoinRateContainer(
                      size,
                      index,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  buildCoinRateContainer(Size size, int index) {
    if (coinRateMasterOld.isNotEmpty) {
      if (coinRateMasterOld.length == coinRateMaster.length) {
        var oldAskRate = coinRateMasterOld[index].ask!.isEmpty
            ? 0.0
            : double.parse(coinRateMasterOld[index].ask!);
        var newAskRate = coinRateMaster[index].ask!.isEmpty
            ? 0.0
            : double.parse(coinRateMaster[index].ask!);

        setLabelColors(oldAskRate, newAskRate, coinRateMaster[index]);
      }
    }

    if (coinRateMaster.length - 1 == index) {
      coinRateMasterOld = coinRateMaster;
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(width: 0.8, color: AppColors.primaryColor),
          color: AppColors.defaultColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0),
              child: Image.asset(
                AppImagePath.coin,
                height: 25.0,
                width: 25.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: SizedBox(
                width: size.width * .3,
                child: CustomText(
                  text: coinRateMaster[index].coinsName!,
                  size: 12.0,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.textColor,
                  align: TextAlign.start,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: coinRateMaster[index].askBGColor),
                      padding: const EdgeInsets.all(3.0),
                      child: CustomText(
                          text: coinRateMaster[index].ask!,
                          size: 12.0,
                          fontWeight: FontWeight.bold,
                          textColor: coinRateMaster[index].askTextColor),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: InkWell(
                child: Container(
                  padding: EdgeInsets.only(right: 5),
                  height: 35,
                  width: size.width / 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  alignment: Alignment.center,
                  child: CustomText(
                    text: 'Buy',
                    size: 16.0,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.defaultColor,
                    align: TextAlign.start,
                  ),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setLabelColors(double oldRate, double newRate, model) {
    if (oldRate < newRate) {
      model.askBGColor = AppColors.green;
      model.askTextColor = AppColors.defaultColor;
      // model.bidBGColor = AppColors.green;
      // model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.askBGColor = AppColors.red;
      model.askTextColor = AppColors.defaultColor;
      // model.bidBGColor = AppColors.red;
      // model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate == newRate) {
      model.askBGColor = AppColors.defaultColor;
      model.askTextColor = AppColors.textColor;
      // model.bidBGColor = AppColors.defaultColor;
      // model.bidTextColor = AppColors.textColor;
    } else {
      model.askBGColor = AppColors.defaultColor;
      model.askTextColor = AppColors.textColor;
      // model.bidBGColor = AppColors.defaultColor;
      // model.bidTextColor = AppColors.textColor;
    }
  }
}
