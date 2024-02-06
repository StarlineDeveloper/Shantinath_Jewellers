// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/notify_socket_update.dart';
import '../Functions.dart';
import '../Models/CommonRequestModel.dart';
import '../Models/client_header.dart';
import '../Models/comex_data_model.dart';
import '../Models/liverate.dart';
import '../Models/loginData.dart';
import '../Models/reference_data.dart';
import '../Models/reference_data_rate.dart';
import '../Popup/alert_confirm_popup.dart';
import '../Providers/liveRate_Provider.dart';
import '../Services/insertopenorder_service.dart';
import '../Utils/shared.dart';
import '../Widgets/custom_text.dart';
import 'login_screen.dart';

class LiveRateScreen extends StatefulWidget {
  static const String routeName = '/live-rate';

  const LiveRateScreen({super.key});

  @override
  State<LiveRateScreen> createState() => _LiveRateScreenState();
}

class _LiveRateScreenState extends State<LiveRateScreen> with TickerProviderStateMixin {
  late LiveRateProvider _liverateProvider;
  late TabController _tabController;
  late TabController _tabGoldSilverController;

  // Boolean flags
  bool isHighVisible = false;
  bool isLowVisible = false;
  bool isBuyVisible = true;
  bool isSellVisible = true;
  bool isRateVisible = true;
  bool isDiffVisible = true;
  bool isSellLoading = false;
  bool isBuyLoading = false;
  bool isSellPremiumRateDiffVisible = false;
  bool isReferenceContainerVisible = false;
  bool isMarketSelected = true;
  bool isGoldSelected = true;
  bool afterLoginView = true;
  late bool isBuySellSelected;
  bool isLogin = false;

  // Text controller
  final TextEditingController _priceController = TextEditingController();

  // Lists and other variables
  List<Liverate> liveRatesDetailMaster = [];
  List<Liverate> liveRatesDetailGold = [];
  List<Liverate> liveRatesDetailSilver = [];
  List<ReferenceDataRate> liveRateReferenceDetail = [];
  List<ReferenceData> referenceData = [];
  List<ReferenceDataRate> rateReferenceData = [];
  List<ComexDataModel> referenceComexData = [];
  List<ComexDataModel> referenceNextData = [];
  List<ComexDataModel> referenceNextDataOld = [];
  List<ComexDataModel> referenceNextDataOldChange = [];
  List<ComexDataModel> referenceComexDataGold = [];
  List<ComexDataModel> referenceComexDataSilver = [];
  List<ComexDataModel> referenceFutureData = [];
  List<ComexDataModel> referenceInrData = [];
  List<Liverate> liveRatesDetailOldMaster = [];
  List<ReferenceDataRate> liveRateReferenceDetailOld = [];
  List<ComexDataModel> referenceComexDataOld = [];
  List<ComexDataModel> referenceFutureDataOld = [];
  List<ComexDataModel> referenceComexDataOldChange = [];
  List<ComexDataModel> referenceFutureDataOldChange = [];
  List<Liverate> liveRatesDetailOldChange = [];
  List<ReferenceDataRate> liveRateReferenceDetailOldChange = [];

  String bid = '';
  String ask = '';
  String high = '';
  String low = '';
  String quantity = '';
  List<String> items = [];
  ClientHeaderData clientHeadersDetail = ClientHeaderData();
  Shared shared = Shared();
  var streamController;
  List<GroupDetailsDropDown> dropDown = [];
  var oneClick, inTotal, step;
  String gmkg = '';
  InsertOpenOrderService insertOpenOrderService = InsertOpenOrderService();
  late LoginData userData;

  clearFields() {
    _priceController.clear();
  }

  @override
  void initState() {
    super.initState();

    _initializeControllers();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    checkIsLogin();
    loadData();
    dropDown = _liverateProvider.getDropDownData();

    _initializeListeners();
    if (!mounted) {
      return;
    }
  }

  void _initializeControllers() {
    _tabController = TabController(length: 2, vsync: this);
    _tabGoldSilverController = TabController(length: 2, vsync: this);
    NotifySocketUpdate.controllerMainData = StreamController();
    // NotifySocketUpdate.controllerMainData = StreamController();
    NotifySocketUpdate.dropDown = StreamController();
    streamController = StreamController<List<Liverate>>.broadcast();
    if (!mounted) {
      return;
    }
  }

  void _initializeListeners() {
    liveRatesDetailMaster = _liverateProvider.getLiveRateData();
    referenceFutureData = _liverateProvider.getFutureData();
    referenceComexData = _liverateProvider.getComexData();
    referenceNextData = _liverateProvider.getNextData();
    NotifySocketUpdate.controllerMainData!.stream.asBroadcastStream().listen(
      (event) {
        loadData();
      },
    );
    // NotifySocketUpdate.controllerMainData!.stream.asBroadcastStream().listen(
    //   (event) {
    //     Future.delayed(const Duration(seconds: 1), () {
    //       liveRatesDetailMaster = _liverateProvider.getLiveRateData();
    //
    //       liveRatesDetailOldMaster = liveRatesDetailMaster;
    //
    //       if (!streamController.isClosed) {
    //         streamController.sink.add(liveRatesDetailMaster);
    //       }
    //     });
    //   },
    // );
    NotifySocketUpdate.dropDown!.stream.asBroadcastStream().listen(
      (event) {
        setState(() {
          dropDown = _liverateProvider.getDropDownData();
        });
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabGoldSilverController.dispose();
    streamController.close();
    NotifySocketUpdate.controllerMainData!.close();
    // NotifySocketUpdate.controllerMainData!.close();
    NotifySocketUpdate.dropDown!.close();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  loadData() {
    liveRateReferenceDetail = [];
    referenceData = _liverateProvider.getReferenceData();
    liveRateReferenceDetail = _liverateProvider.getReferenceDataRate();
    clientHeadersDetail = _liverateProvider.getClientHeaderData();

    // liveRateReferenceDetailOld = liveRateReferenceDetail;

    Functions.checkConnectivity().then((isConnected) {
      List<ComexDataModel> comexData = [];
      List<ComexDataModel> futureData = [];
      List<ComexDataModel> nextData = [];
      if (isConnected) {
        setState(() {
          referenceFutureData = _liverateProvider.getFutureData();
          referenceComexData = _liverateProvider.getComexData();
          referenceNextData = _liverateProvider.getNextData();
        });
        // Set Future and Next list based on Liverates and Reference
        for (var data in referenceData) {
          for (var rate in liveRateReferenceDetail) {
            if (rate.symbol.toLowerCase() == data.source!.toLowerCase()) {
              bid = rate.bid.toString();
              ask = rate.ask.toString();
              high = rate.high.toString();
              low = rate.low.toString();
            } // Set bid, ask, high and low which matches the symbol of rate and source of data.
          }
          if (data.isDisplay! &&
              (data.source == 'gold' || data.source == 'silver')) {
            futureData.add(
              ComexDataModel(
                symbolName: data.symbolName,
                bid: bid.toString(),
                ask: ask.toString(),
                high: high.toString(),
                low: low.toString(),
                isDisplay: data.isDisplay,
              ),
            );
          } else if (data.isDisplay! &&
              (data.source == 'XAGUSD' ||
                  data.source == 'XAUUSD' ||
                  data.source == 'INRSpot')) {
            comexData.add(
              ComexDataModel(
                symbolName: data.symbolName,
                bid: bid.toString(),
                ask: ask.toString(),
                high: high.toString(),
                low: low.toString(),
                isDisplay: data.isDisplay,
              ),
            );
          } else if (data.isDisplay! &&
              (data.source == 'goldnext' || data.source == 'silvernext')) {
            nextData.add(
              ComexDataModel(
                symbolName: data.symbolName,
                bid: bid.toString(),
                ask: ask.toString(),
                high: high.toString(),
                low: low.toString(),
                isDisplay: data.isDisplay,
              ),
            );
          }
        }
        _liverateProvider.addFutureData(futureData);
        _liverateProvider.addComexData(comexData);
        _liverateProvider.addNextData(nextData);
      } else {
        setState(() {
          referenceFutureData = _liverateProvider.getFutureData();
          referenceComexData = _liverateProvider.getComexData();
          referenceNextData = _liverateProvider.getNextData();
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      // liveRatesDetailMaster=[];

      liveRatesDetailMaster = _liverateProvider.getLiveRateData();

      liveRatesDetailOldMaster = liveRatesDetailMaster;

      if (!streamController.isClosed) {
        streamController.sink.add(liveRatesDetailMaster);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child:

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: referenceComexData.isEmpty ||
                            referenceComexData.length > 3
                        ? 3
                        : referenceComexData.length,
                    crossAxisSpacing: size.width * .01,
                    mainAxisExtent: size.height * 0.13,
                  ),
                  itemBuilder: (builder, index) {
                    return buildComexContainers(size, index);
                  },
                  itemCount: referenceComexData.length,
                ),
              ),
              SizedBox(
                height: size.height * .01,
              ),
              /*Constants.isLogin
                  ? buildLoginProductInfo(size)
                  : */buildNonLoginProductInfo(size),
              Visibility(
                visible: Constants.isLogin
                    ? true
                    : clientHeadersDetail.rateDisplay != null &&
                        clientHeadersDetail.rateDisplay!,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: liveRatesDetailMaster.length,
                  itemBuilder: (context, index) => buildProductContainer(
                    size,
                    index,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * .001,
              ),
              Flexible(
                child:


                GridView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: referenceFutureData.isEmpty ||
                            referenceFutureData.length > 3
                        ? 3
                        : referenceFutureData.length,
                    crossAxisSpacing: size.width * .01,
                      // mainAxisExtent: size.height * .17,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (builder, index) {
                    return buildFutureContainers(size, index);
                  },
                  itemCount: referenceFutureData.length,
                ),
              ),
              SizedBox(
                height: size.height * .001,
              ),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: referenceNextData.isEmpty ||
                            referenceNextData.length > 3
                        ? 3
                        : referenceNextData.length,
                    crossAxisSpacing: size.width * .01,
                    childAspectRatio: 1.5,
                    // mainAxisExtent: size.height * .17,
                  ),
                  itemBuilder: (builder, index) {
                    return buildNextContainers(size, index);
                  },
                  itemCount: referenceNextData.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNonLoginProductInfo(Size size) {
    return Column(
      children: [
        clientHeadersDetail.rateDisplay != null && clientHeadersDetail.rateDisplay!&&liveRatesDetailMaster.isNotEmpty
            ? Container(
                height: 35.0,
                decoration: BoxDecoration(
                  // border:
                  //     Border.all(width: 0.8, color: AppColors.secondaryColor),
                    gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.only(left: 12.0, right: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: size.width * .3,
                      child: const CustomText(
                        text: 'PRODUCT',
                        size: 15.0,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.primaryColor,
                        align: TextAlign.start,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: size.width / 5,
                            child: Visibility(
                              visible: clientHeadersDetail.buyRate != null &&
                                  clientHeadersDetail.buyRate!,
                              child: const CustomText(
                                text: 'BUY',
                                size: 15.0,
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.primaryColor,
                                align: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width / 5,
                            child: Visibility(
                              visible: clientHeadersDetail.sellRate != null &&
                                  clientHeadersDetail.sellRate!,
                              child: const CustomText(
                                text: 'SELL',
                                size: 15.0,
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.primaryColor,
                                align: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            : const CustomText(
                text: 'Liverate Currently Not Available',
                size: 16.0,
                fontWeight: FontWeight.bold,
                textColor: AppColors.defaultColor,
                align: TextAlign.center,
              ),
      ],
    );
  }

  Widget buildLoginProductInfo(Size size) {
    return Container(
      height: 35.0,
      // color: AppColors.secondaryColor,
      decoration: BoxDecoration(
        // border: Border.all(width: 0.8, color: AppColors.secondaryLightColor),
          gradient: AppColors.primaryGradient,

        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.only(left: 12.0, right: 0.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: size.width * .3,
            child: const CustomText(
              text: 'PRODUCT',
              size: 15.0,
              fontWeight: FontWeight.bold,
              textColor: AppColors.primaryColor,
              align: TextAlign.start,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: size.width / 5,
                  child: const CustomText(
                    text: 'BUY',
                    size: 15.0,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primaryColor,
                    align: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: size.width / 5,
                  child: const CustomText(
                    text: 'SELL',
                    size: 15.0,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primaryColor,
                    align: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildFutureContainers(Size size, int index) {
    if (referenceFutureDataOldChange.isNotEmpty) {
      if (referenceFutureDataOldChange.length == referenceFutureData.length) {
        var oldAskRate = referenceFutureDataOldChange[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceFutureDataOldChange[index].ask!);
        var newAskRate = referenceFutureData[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceFutureData[index].ask!);

        setFutureAskLableColor(
            oldAskRate, newAskRate, referenceFutureData[index]);

        var oldBidRate = referenceFutureDataOldChange[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceFutureDataOldChange[index].bid!);
        var newBidRate = referenceFutureData[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceFutureData[index].bid!);

        setFutureBidLableColor(
            oldBidRate, newBidRate, referenceFutureData[index]);
      }
    }
    if (referenceFutureData.length - 1 == index) {
      referenceFutureDataOldChange = referenceFutureData;
    }

    return referenceFutureData.isEmpty
        ? Container()
        : Card(
            // color: AppColors.primaryLightColor,
            elevation: 10,
            // shadowColor: AppColors.hintColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,

                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CustomText(
                      text: referenceFutureData[index]
                              .symbolName
                              ?.toUpperCase() ??
                          '',
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.primaryColor,
                      size: 15.0,
                      align: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                  
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: CustomText(
                                  text: 'Buy',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.primaryColor,
                                  size: 16.0,
                                )),
                            Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: CustomText(
                                  text: 'Sell',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.primaryColor,
                                  size: 16.0,
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                height: 30.0,
                                width: size.width / 4.5,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: referenceFutureData[index].bidBGColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(7),
                                  ),
                                ),
                                child: CustomText(
                                  text: referenceFutureData[index].bid ?? '',
                                  fontWeight: FontWeight.bold,
                                  textColor:
                                      referenceFutureData[index].bidTextColor,
                                  size: 16.0,
                                )),
                            Container(
                                height: 30.0,
                                width: size.width / 4.5,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: referenceFutureData[index].askBGColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(7),
                                  ),
                                ),
                                child: CustomText(
                                  text: referenceFutureData[index].ask ?? '',
                                  fontWeight: FontWeight.bold,
                                  textColor:
                                      referenceFutureData[index].askTextColor,
                                  size: 16.0,
                                )),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text:
                                'L: ${referenceFutureData[index].low!.isEmpty ? '' : referenceFutureData[index].low!}',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.secondaryTextColor,
                            size: 12.0,
                          ),
                          CustomText(
                            text:
                                ' / H: ${referenceFutureData[index].high!.isEmpty ? '' : referenceFutureData[index].high!} ',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.secondaryTextColor,
                            size: 12.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget buildNextContainers(Size size, int index) {
    if (referenceNextDataOldChange.isNotEmpty) {
      if (referenceNextDataOldChange.length == referenceNextData.length) {
        var oldAskRate = referenceNextDataOldChange[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceNextDataOldChange[index].ask!);
        var newAskRate = referenceNextData[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceNextData[index].ask!);

        setFutureAskLableColor(
            oldAskRate, newAskRate, referenceNextData[index]);

        var oldBidRate = referenceNextDataOldChange[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceNextDataOldChange[index].bid!);
        var newBidRate = referenceNextData[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceNextData[index].bid!);

        setFutureBidLableColor(
            oldBidRate, newBidRate, referenceNextData[index]);
      }
    }

    if (referenceNextData.length - 1 == index) {
      referenceNextDataOldChange = referenceNextData;
    }

    return referenceNextData.isEmpty
        ? Container()
        : Card(
            // color: AppColor.defaultColor,
            elevation: 10,
            // shadowColor: AppColors.hintColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CustomText(
                      text:
                          referenceNextData[index].symbolName?.toUpperCase() ??
                              '',
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.primaryColor,
                      size: 15.0,
                      align: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: CustomText(
                                  text: 'Buy',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.primaryColor,
                                  size: 16.0,
                                )),
                            Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: CustomText(
                                  text: 'Sell',
                                  fontWeight: FontWeight.bold,
                                  textColor: AppColors.primaryColor,
                                  size: 16.0,
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                height: 30.0,
                                width: size.width / 4.5,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: referenceNextData[index].bidBGColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(7),
                                  ),
                                ),
                                child: CustomText(
                                  text: referenceNextData[index].bid ?? '',
                                  fontWeight: FontWeight.bold,
                                  textColor:
                                      referenceNextData[index].bidTextColor,
                                  size: 16.0,
                                )),
                            Container(
                                height: 30.0,
                                width: size.width / 4.5,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: referenceNextData[index].askBGColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(7),
                                  ),
                                ),
                                child: CustomText(
                                  text: referenceNextData[index].ask ?? '',
                                  fontWeight: FontWeight.bold,
                                  textColor:
                                      referenceNextData[index].askTextColor,
                                  size: 16.0,
                                )),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text:
                                'L: ${referenceNextData[index].low!.isEmpty ? '' : referenceNextData[index].low!}',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.secondaryTextColor,
                            size: 12.0,
                          ),
                          CustomText(
                            text:
                                ' / H: ${referenceNextData[index].high!.isEmpty ? '' : referenceNextData[index].high!} ',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.secondaryTextColor,
                            size: 12.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget buildComexContainers(Size size, int index) {
    if (referenceComexDataOldChange.isNotEmpty) {
      if (referenceComexDataOldChange.length == referenceComexData.length) {
        var oldAskRate = referenceComexDataOldChange[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceComexDataOldChange[index].ask!);
        var newAskRate = referenceComexData[index].ask!.isEmpty
            ? 0.0
            : double.parse(referenceComexData[index].ask!);

        setAskLableColor(oldAskRate, newAskRate, referenceComexData[index]);

        var oldBidRate = referenceComexDataOldChange[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceComexDataOldChange[index].bid!);
        var newBidRate = referenceComexData[index].bid!.isEmpty
            ? 0.0
            : double.parse(referenceComexData[index].bid!);

        setBidLableColor(oldBidRate, newBidRate, referenceComexData[index]);
      }
    }
    if (referenceComexData.length - 1 == index) {
      referenceComexDataOldChange = referenceComexData;
    }

    return referenceComexData.isEmpty
        ? Container()
        : Card(
            // color: AppColor.secondaryColor,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,

                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CustomText(
                      text: referenceComexData[index].symbolName ?? '',
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.primaryColor,
                      size: 14.0,
                      align: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 30.0,
                        width: size.width / 4.5,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: referenceComexData[index].askBGColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(7),
                          ),
                        ),
                        child:
                        CustomText(
                          text:
                          referenceComexData[index].ask ?? '',
                          fontWeight: FontWeight.bold,
                          textColor: referenceComexData[index].askTextColor,
                          size: 16.0,
                          align: TextAlign.start,
                        ),

                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text:
                                'L-${referenceComexData[index].low!.isEmpty ? '' : referenceComexData[index].low!}',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.secondaryTextColor,
                            size: 10.0,
                            align: TextAlign.start,
                          ),
                          CustomText(
                            text:
                                '/H-${referenceComexData[index].high!.isEmpty ? '' : referenceComexData[index].high!}',
                            fontWeight: FontWeight.bold,
                            textColor: AppColors.secondaryTextColor,
                            size: 10.0,
                            align: TextAlign.start,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget buildProductContainer(Size size, int index) {
    try {
      if (liveRatesDetailOldChange.isNotEmpty) {
        if (liveRatesDetailOldChange.length == liveRatesDetailMaster.length) {
          if (liveRatesDetailOldChange[index].ask == '-' ||
              liveRatesDetailOldChange[index].ask == '--') {
            liveRatesDetailOldChange[index].askBGColor = AppColors.defaultColor;
            liveRatesDetailOldChange[index].askTextColor =AppColors.textColor;
          } else {
            dynamic oldAskRate = liveRatesDetailOldChange[index].ask!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailOldChange[index].ask!);
            dynamic newAskRate = liveRatesDetailMaster[index].ask!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailMaster[index].ask!);

            setLabelColorsAskMainProduct(
                oldAskRate, newAskRate, liveRatesDetailMaster[index]);
          }

          if (liveRatesDetailOldChange[index].bid == '-' ||
              liveRatesDetailOldChange[index].bid == '--') {
            liveRatesDetailOldChange[index].bidBGColor = AppColors.defaultColor;
            liveRatesDetailOldChange[index].bidTextColor =AppColors.textColor;
            // setLabelColorsMainProduct('--', '--', liveRatesDetailMaster[index]);
          } else {
            dynamic oldBidRate = liveRatesDetailOldChange[index].bid!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailOldChange[index].bid!);
            dynamic newBidRate = liveRatesDetailMaster[index].bid!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailMaster[index].bid!);

            setLabelColorsBidMainProduct(
                oldBidRate, newBidRate, liveRatesDetailMaster[index]);
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (liveRatesDetailMaster.length - 1 == index) {
      liveRatesDetailOldChange = liveRatesDetailMaster;
    }

    return liveRatesDetailMaster.isEmpty
        ? Container()
        : Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 0.0, right: 0.0),
            child: GestureDetector(
              onTap: () {
                if (Constants.isLogin) {
                  generateDropDownList(liveRatesDetailMaster[index].id,
                      liveRatesDetailMaster[index].src);
                  showNewTradePopup(size, index);
                } else {
                  Navigator.of(context)
                      .pushNamed(
                    Login_Screen.routeName,
                    arguments: const Login_Screen(
                      isFromSplash: false,
                    ),
                  )
                      .then((_) {
                    // liveRatesDetailMaster.clear();
                    checkIsLogin();
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 2.0),
                child: Container(
                  height: 50.0,
                  decoration: ShapeDecoration(
                    color: AppColors.defaultColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // shadows: const [AppColors.boxShadow],
                  ),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.all(
                      //        5.0),
                      //   child: Image.asset(
                      //     AppImagePath.greencolum,
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: size.width * .3,
                              child: CustomText(
                                text: '${liveRatesDetailMaster[index].name!.toUpperCase()} ',
                                size: 14,
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.primaryColor,
                                align: TextAlign.start,
                              ),
                            ),
                            SizedBox(
                              width: size.width * .3,
                              child: CustomText(
                                text:
                                    'Time-${liveRatesDetailMaster[index].time}',
                                size: 10.5,
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.secondaryTextColor,
                                align: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: size.width / 5,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Visibility(
                                      visible: clientHeadersDetail.buyRate != null &&
                                          clientHeadersDetail.buyRate!,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            color:  liveRatesDetailMaster[index]
                                                .bidBGColor),
                                        padding: const EdgeInsets.all(3.0),
                                        child: CustomText(
                                            text:
                                                '${liveRatesDetailMaster[index].bid}',
                                            size: 14.5,
                                            fontWeight: FontWeight.bold,
                                            textColor:
                                                liveRatesDetailMaster[index]
                                                    .bidTextColor),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible:clientHeadersDetail.lowRate != null &&
                                        clientHeadersDetail.lowRate!,
                                    child: CustomText(
                                      text:
                                          'L-${liveRatesDetailMaster[index].low}',
                                      size: 13.0,
                                      fontWeight: FontWeight.normal,
                                      textColor: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: size.width / 5,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Visibility(
                                      visible:clientHeadersDetail.sellRate != null &&
                                          clientHeadersDetail.sellRate!,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          color: liveRatesDetailMaster[index]
                                              .askBGColor,
                                        ),
                                        padding: const EdgeInsets.all(3.0),
                                        child: CustomText(
                                          text:
                                              '${liveRatesDetailMaster[index].ask}',
                                          size: 14.5,
                                          fontWeight: FontWeight.bold,
                                          textColor: liveRatesDetailMaster[index]
                                              .askTextColor,
                                          align: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible:clientHeadersDetail.highRate != null &&
                                        clientHeadersDetail.highRate!,
                                    child: CustomText(
                                      text:
                                          'H-${liveRatesDetailMaster[index].high}',
                                      size: 13.0,
                                      textColor: AppColors.green,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget buildSellTradeContainer(Size size, int index, AsyncSnapshot<List<Liverate>> snapshot) {
    try {
      if (liveRatesDetailOldChange.isNotEmpty) {
        if (liveRatesDetailOldChange.length == liveRatesDetailMaster.length) {
          if (liveRatesDetailOldChange[index].bid == '-' ||
              liveRatesDetailOldChange[index].bid == '--') {

            // var oldAskRate = liveRatesDetailOldChange[index].ask!.isEmpty
            //     ? 0.0
            //     : double.parse(liveRatesDetailOldChange[index].ask!);
            // var newAskRate = liveRatesDetailMaster[index].ask!.isEmpty
            //     ? 0.0
            //     : double.parse(liveRatesDetailMaster[index].ask!);
            //
            // setLabelColors(oldAskRate, newAskRate, liveRatesDetailMaster[index]);
          } else {
            var oldBidRate = liveRatesDetailOldChange[index].bid!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailOldChange[index].bid!);
            var newBidRate = liveRatesDetailMaster[index].bid!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailMaster[index].bid!);

            setLabelTradeColors(
                oldBidRate, newBidRate, liveRatesDetailMaster[index]);
          }

          // var oldBidRate = liveRatesDetailOldChange[index].bid!.isEmpty
          //     ? 0.0
          //     : double.parse(liveRatesDetailOldChange[index].bid!);
          // var newBidRate = liveRatesDetail[index].bid!.isEmpty
          //     ? 0.0
          //     : double.parse(liveRatesDetail[index].bid!);
          //
          // setMainBidTradeLableColor(oldBidRate, newBidRate, liveRatesDetail[index]);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    liveRatesDetailOldChange = liveRatesDetailMaster;
    //  if (liveRatesDetail.length - 1 == index) {
    //   liveRatesDetailOldChange = liveRatesDetail;
    // }

    return SizedBox(
      width: size.width,
      child: Card(
        // color: AppColor.defaultColor,
        elevation: 5,
        shadowColor: liveRatesDetailMaster[index].bidTradeBGColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomText(
                  text: 'SELL',
                  size: 16.0,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.primaryColor),
              CustomText(
                text: '${liveRatesDetailMaster[index].bid} ',
                size: 16.0,
                fontWeight: FontWeight.bold,
                textColor: liveRatesDetailMaster[index].bid == '-' ||
                        liveRatesDetailMaster[index].bid == '--'
                    ? AppColors.primaryColor
                    : liveRatesDetailMaster[index].bidTradeBGColor,

                // textColor: liveRatesDetailMaster[index].bidTradeBGColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBuyTradeContainer(Size size, int index, AsyncSnapshot<List<Liverate>> snapshot) {
    try {
      if (liveRatesDetailOldChange.isNotEmpty) {
        if (liveRatesDetailOldChange.length == liveRatesDetailMaster.length) {
          if (liveRatesDetailOldChange[index].ask == '-' ||
              liveRatesDetailOldChange[index].ask == '--') {
            // var oldAskRate = liveRatesDetailOldChange[index].ask!.isEmpty
            //     ? 0.0
            //     : double.parse(liveRatesDetailOldChange[index].ask!);
            // var newAskRate = liveRatesDetailMaster[index].ask!.isEmpty
            //     ? 0.0
            //     : double.parse(liveRatesDetailMaster[index].ask!);
            //
            // setLabelColors(oldAskRate, newAskRate, liveRatesDetailMaster[index]);
          } else {
            var oldAskRate = liveRatesDetailOldChange[index].ask!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailOldChange[index].ask!);
            var newAskRate = liveRatesDetailMaster[index].ask!.isEmpty
                ? 0.0
                : double.parse(liveRatesDetailMaster[index].ask!);

            setLabelTradeColors(
                oldAskRate, newAskRate, liveRatesDetailMaster[index]);
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    liveRatesDetailOldChange = liveRatesDetailMaster;
    //  if (liveRatesDetail.length - 1 == index) {
    //   liveRatesDetailOldChange = liveRatesDetail;
    // }

    return SizedBox(
      width: size.width,
      child: Card(
        // color: AppColor.defaultColor,
        elevation: 5,
        shadowColor: liveRatesDetailMaster[index].askTradeBGColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomText(
                  text: 'BUY',
                  size: 16.0,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.primaryColor),
              CustomText(
                text: '${liveRatesDetailMaster[index].ask} ',
                size: 16.0,
                fontWeight: FontWeight.bold,
                textColor: liveRatesDetailMaster[index].ask == '-' ||
                        liveRatesDetailMaster[index].ask == '--'
                    ? AppColors.primaryColor
                    : liveRatesDetailMaster[index].askTradeBGColor,

                // textColor: liveRatesDetailMaster[index].bidTradeBGColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showNewTradePopup(Size size, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent.withOpacity(0.6),
      // backgroundColor: AppColor.defaultColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return StreamBuilder<List<Liverate>>(
              stream: getLiveRatesStream(),
              builder: (BuildContext context,AsyncSnapshot<List<Liverate>> snapshot) {
                return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      children: [
                        Container(
                          height: size.height * 0.05,
                          width: size.width,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12)),
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(
                              text: liveRatesDetailMaster[index].name!.toUpperCase(),
                              textColor: AppColors.defaultColor,
                              size: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2, color: AppColors.primaryColor),
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0, top: 10.0),
                                  child: Container(
                                    height: size.height * 0.05,
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
                                            // getOrdersStatusFromIndex(index);
                                            isMarketSelected = true;
                                            // isLimitSelected = false;
                                          });
                                        } else {
                                          setState(() {
                                            // getOrdersStatusFromIndex(index);
                                            isMarketSelected = false;
                                            // isLimitSelected = true;
                                          });
                                        }
                                        debugPrint(isMarketSelected.toString());
                                      },
                                      controller: _tabController,
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        color: AppColors.primaryColor,
                                      ),
                                      labelColor: AppColors.defaultColor,
                                      unselectedLabelColor:
                                          AppColors.primaryColor,
                                      tabs: const [
                                        Tab(
                                          child: Text(
                                            textScaler:  TextScaler.linear(1.0),
                                            'Market',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            textScaler:  TextScaler.linear(1.0),
                                            'Limit',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Flexible(
                                          flex: 1,
                                          child: buildSellTradeContainer(
                                              size, index, snapshot)),
                                      Flexible(
                                          flex: 1,
                                          child: buildBuyTradeContainer(size, index, snapshot)),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: items.isNotEmpty,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: 10.0, top: size.height * 0.02),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CustomText(
                                          text: 'Quantity :',
                                          size: 14.0,
                                          fontWeight: FontWeight.bold,
                                          textColor: AppColors.textColor,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton2<String>(
                                            isExpanded: false,
                                            items:
                                                _addDividersAfterItems(items),
                                            value: quantity,
                                            onChanged: (String? value) {
                                              setState(() {
                                                quantity = value!;
                                              });
                                            },
                                            buttonStyleData: ButtonStyleData(
                                              height: 40,
                                              width: 120,
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColors.primaryColor,
                                                ),
                                                color: AppColors.defaultColor,
                                              ),
                                              elevation: 2,
                                            ),
                                            iconStyleData: const IconStyleData(
                                              icon: Icon(
                                                Icons.arrow_drop_down_sharp,
                                                color: AppColors.primaryColor,
                                              ),
                                              iconSize: 20,
                                              iconEnabledColor:
                                                  AppColors.textColor,
                                              iconDisabledColor: Colors.grey,
                                            ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              maxHeight: 200,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: AppColors.defaultColor,
                                              ),
                                              offset: const Offset(-0, 0),
                                              scrollbarTheme:
                                                  ScrollbarThemeData(
                                                thumbColor:
                                                    MaterialStateProperty.all(
                                                        AppColors.primaryColor
                                                            .withOpacity(0.3)),
                                                radius:
                                                    const Radius.circular(8),
                                                thickness:
                                                    MaterialStateProperty.all(
                                                        3),
                                                thumbVisibility:
                                                    MaterialStateProperty.all(
                                                        true),
                                              ),
                                            ),
                                            menuItemStyleData:
                                                MenuItemStyleData(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              customHeights:
                                                  _getCustomItemsHeights(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 10.0, top: size.height * 0.02),
                                  child: Visibility(
                                    visible: !isMarketSelected,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CustomText(
                                          text: 'Price :',
                                          size: 14.0,
                                          fontWeight: FontWeight.bold,
                                          textColor: AppColors.textColor,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: TextFormField(
                                            cursorColor: AppColors.primaryColor,
                                            controller: _priceController,
                                            decoration:
                                                getInputBoxDecoration('Price'),
                                            keyboardType: TextInputType
                                                .numberWithOptions(),
                                            textInputAction:
                                                TextInputAction.done,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0, top: size.height * 0.02),
                                  child: Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          child: Container(
                                            margin: EdgeInsets.only(right: 5),
                                            height: 50,
                                            decoration: ShapeDecoration(
                                              color: AppColors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              shadows: const [
                                                AppColors.boxShadow
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                Visibility(
                                                  visible: !isSellLoading,
                                                  child: CustomText(
                                                    text: 'Sell',
                                                    size: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    textColor:
                                                        AppColors.defaultColor,
                                                    align: TextAlign.center,
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: isSellLoading,
                                                  child: SizedBox(
                                                    height: 20.0,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color:
                                                          AppColors.defaultColor,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            if (!isMarketSelected &&
                                                _priceController.text.isEmpty) {
                                              setState(() {
                                                isBuySellSelected = false;
                                              });
                                              validateTrade(
                                                  liveRatesDetailMaster[index]
                                                      .id!);
                                            } else if (quantity.isEmpty ||
                                                items.isEmpty) {
                                              return DialogUtil.showAlertDialog(
                                                context,
                                                title:
                                                    Constants.alertAndCnfTitle,
                                                content:
                                                    'This symbol quantity is not available',
                                                okBtnText: 'Ok',
                                                cancelBtnText: 'Cancel',
                                              );
                                            } else {
                                              setState(() {
                                                isBuySellSelected = false;
                                                isSellLoading = true;
                                              });
                                              validateTrade(
                                                  liveRatesDetailMaster[index]
                                                      .id!);
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 5),
                                            height: 50,
                                            decoration: ShapeDecoration(
                                              color: AppColors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              shadows: const [
                                                AppColors.boxShadow
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                Visibility(
                                                  visible: !isBuyLoading,
                                                  child: CustomText(
                                                    text: 'BUY',
                                                    size: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    textColor:
                                                        AppColors.defaultColor,
                                                    align: TextAlign.center,
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: isBuyLoading,
                                                  child: SizedBox(
                                                    height: 20.0,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color:
                                                          AppColors.defaultColor,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            if (!isMarketSelected &&
                                                _priceController.text.isEmpty) {
                                              setState(() {
                                                isBuySellSelected = true;
                                              });
                                              validateTrade(
                                                  liveRatesDetailMaster[index]
                                                      .id!);
                                            } else if (quantity.isEmpty ||
                                                items.isEmpty) {
                                              return DialogUtil.showAlertDialog(
                                                context,
                                                title:
                                                    Constants.alertAndCnfTitle,
                                                content:
                                                    'This symbol quantity is not available',
                                                okBtnText: 'Ok',
                                                cancelBtnText: 'Cancel',
                                              );
                                            } else {
                                              setState(() {
                                                isBuySellSelected = true;
                                                isBuyLoading = true;
                                              });
                                              validateTrade(
                                                  liveRatesDetailMaster[index]
                                                      .id!);
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _tabController.animateTo(0,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      setState(() {
        isMarketSelected = true;
        _priceController.clear();
      });
    });
  }

  Stream<List<Liverate>> getLiveRatesStream() {
    return streamController.stream;
  }

  setAskLableColor(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.askBGColor = AppColors.green;
      model.askTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.askBGColor = AppColors.red;
      model.askTextColor = AppColors.defaultColor;
    } else {
      model.askBGColor = AppColors.defaultColor;
      model.askTextColor = AppColors.textColor;
    }
  }

  setFutureAskLableColor(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.askBGColor = AppColors.green;
      model.askTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.askBGColor = AppColors.red;
      model.askTextColor = AppColors.defaultColor;
    } else {
      model.askBGColor = AppColors.defaultColor;
      model.askTextColor = AppColors.textColor;
    }
  }

  setBidLableColor(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.bidBGColor = AppColors.green;
      model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.bidBGColor = AppColors.red;
      model.bidTextColor = AppColors.defaultColor;
    } else {
      model.bidBGColor = AppColors.defaultColor;
      model.bidTextColor = AppColors.textColor;
    }
  }

  setFutureBidLableColor(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.bidBGColor = AppColors.green;
      model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      model.bidBGColor = AppColors.red;
      model.bidTextColor = AppColors.defaultColor;
    } else {
      model.bidBGColor = AppColors.defaultColor;
      model.bidTextColor = AppColors.textColor;
    }
  }

  // void setLabelColors(double oldRate, double newRate, model) {
  //   if (oldRate < newRate) {
  //     model.askBGColor = AppColors.green;
  //     model.askTextColor = AppColors.defaultColor;
  //     model.bidBGColor = AppColors.green;
  //     model.bidTextColor = AppColors.defaultColor;
  //   } else if (oldRate > newRate) {
  //     model.askBGColor = AppColors.red;
  //     model.askTextColor = AppColors.defaultColor;
  //     model.bidBGColor = AppColors.red;
  //     model.bidTextColor = AppColors.defaultColor;
  //   }
  //   /*else if (oldRate == newRate) {
  //     model.askBGColor = AppColors.primaryColor;
  //     model.askTextColor = AppColors.defaultColor;
  //     model.bidBGColor = AppColors.primaryColor;
  //     model.bidTextColor = AppColors.defaultColor;
  //   } */
  //   else {
  //     model.askBGColor = AppColors.primaryColor;
  //     model.askTextColor = AppColors.defaultColor;
  //     model.bidBGColor = AppColors.primaryColor;
  //     model.bidTextColor = AppColors.defaultColor;
  //   }
  // }
  //
  // void setLabelFutureColors(dynamic oldRate, dynamic newRate, model) {
  //   if (oldRate < newRate) {
  //     model.askBGColor = AppColors.green;
  //     model.askTextColor = AppColors.defaultColor;
  //     model.bidBGColor = AppColors.green;
  //     model.bidTextColor = AppColors.defaultColor;
  //   } else if (oldRate > newRate) {
  //     model.askBGColor = AppColors.red;
  //     model.askTextColor = AppColors.defaultColor;
  //     model.bidBGColor = AppColors.red;
  //     model.bidTextColor = AppColors.defaultColor;
  //   }
  //   /*else if (oldRate == newRate) {
  //     model.askBGColor = AppColors.primaryColor;
  //     model.askTextColor = AppColors.defaultColor;
  //     model.bidBGColor = AppColors.primaryColor;
  //     model.bidTextColor = AppColors.defaultColor;
  //   } */
  //   else {
  //     model.askBGColor = AppColors.primaryColor;
  //     model.askTextColor = AppColors.defaultColor;
  //     model.bidBGColor = AppColors.primaryColor;
  //     model.bidTextColor = AppColors.defaultColor;
  //   }
  // }

  void setLabelColorsBidMainProduct(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      // model.askBGColor = AppColors.green;
      // model.askTextColor = AppColors.defaultColor;
      model.bidBGColor = AppColors.green;
      model.bidTextColor = AppColors.defaultColor;
    } else if (oldRate > newRate) {
      // model.askBGColor = AppColors.red;
      // model.askTextColor = AppColors.defaultColor;
      model.bidBGColor = AppColors.red;
      model.bidTextColor = AppColors.defaultColor;
    } else {
      // model.askBGColor = AppColors.primaryColor;
      // model.askTextColor = AppColors.secondaryTextColor;
      model.bidBGColor = AppColors.defaultColor;
      model.bidTextColor = AppColors.textColor;
    }
  }

  void setLabelColorsAskMainProduct(dynamic oldRate, dynamic newRate, model) {
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
    } else {
      model.askBGColor = AppColors.defaultColor;
      model.askTextColor = AppColors.textColor;
      // model.bidBGColor = AppColors.primaryColor;
      // model.bidTextColor = AppColors.secondaryTextColor;
    }
  }

  void setLabelTradeColors(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.bidTradeBGColor = AppColors.red;
    } else if (oldRate > newRate) {
      model.bidTradeBGColor = AppColors.green;
    } else {
      model.bidTradeBGColor = AppColors.primaryColor;
    }
  }

  void setLabelTradeAskColors(dynamic oldRate, dynamic newRate, model) {
    if (oldRate < newRate) {
      model.askTradeBGColor = AppColors.red;
    } else if (oldRate > newRate) {
      model.askTradeBGColor = AppColors.green;
    } else {
      model.askTradeBGColor = AppColors.primaryColor;
    }
  }

  getInputBoxDecoration(String text) {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
      hintText: text,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  List<double> _getCustomItemsHeights() {
    final List<double> itemsHeights = [];
    for (int i = 0; i < (items.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    final List<DropdownMenuItem<String>> menuItems = [];
    for (final String item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CustomText(
                text: item,
                size: 14.0,
                fontWeight: FontWeight.bold,
                textColor: item == quantity
                    ? AppColors.primaryColor
                    : AppColors.textColor,
              ),
            ),
          ),
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(color: AppColors.hintColor),
            ),
        ],
      );
    }
    return menuItems;
  }

  Future<void> checkIsLogin() async {
    final bool loginStatus = await shared.getIsLogin();
    if (loginStatus) {
      setState(() {
        Constants.isLogin = true;
      });
      final loginData = await shared.getLoginData();
      if (loginData.isNotEmpty) {
        userData = LoginData.getJson(json.decode(loginData));
      }
    }
  }

  void callInsertOpenOrderDetailAPi(String quantity, bool isMarketSelected,bool isBuySellSelected, String price, String symbolId) {
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        var objVariable = insertOpenOrderDetailRequestToJson(
            InsertOpenOrderDetailRequest(
                symbolId: symbolId,
                token: Constants.token,
                quantity: Functions.extractNumber(quantity),
                tradeFrom: Platform.isIOS ? 'Ios' : 'Android',
                tradeType: isMarketSelected && isBuySellSelected
                    ? '1'
                    : isMarketSelected && !isBuySellSelected
                        ? '2'
                        : !isMarketSelected && isBuySellSelected
                            ? '3'
                            : !isMarketSelected && !isBuySellSelected
                                ? '4'
                                : '',
                deviceToken: Constants.fcmToken,
                buyLimitPrice:
                    !isMarketSelected && isBuySellSelected ? price : '',
                sellLimitPrice:
                    !isMarketSelected && !isBuySellSelected ? price : ''));

        insertOpenOrderService.insertOpenOrderObj(objVariable).then((response) {
          if (response.data == '200') {
            Navigator.of(context).pop();
            setState(() {
              isBuyLoading = false;
              isSellLoading = false;
              Constants.tradeType = isMarketSelected && isBuySellSelected
                  ? '1'
                  : isMarketSelected && !isBuySellSelected
                      ? '2'
                      : !isMarketSelected && isBuySellSelected
                          ? '3'
                          : !isMarketSelected && !isBuySellSelected
                              ? '4'
                              : '';
            });
          } else {
            setState(() {
              isBuyLoading = false;
              isSellLoading = false;
            });
            // Functions.showToast('Login Fail');
          }
        });

        debugPrint(
            'insertOpen----------------------------------------$objVariable');
      } else {
        setState(() {
          isBuyLoading = false;
          isSellLoading = false;
        });
        Functions.showToast(Constants.noInternet);
      }
    });
  }

  generateDropDownList(String? symbolId, String? source) {
    if (int.tryParse(symbolId ?? "") != 0) {
      int selectedSymbolId = int.parse(symbolId!);
      var selectedItems =
          dropDown.where((item) => selectedSymbolId == item.symbolId);

      if (selectedItems.isNotEmpty) {
        final selectedItem = selectedItems.first;
        oneClick = selectedItem.oneClick;
        inTotal = selectedItem.inTotal;
        step = selectedItem.step;

        if (step == null || step <= 0) {
          step = oneClick;
        }

        if (oneClick != 0 && inTotal != 0 && step != 0) {
          setState(() {
            gmkg = (source?.toLowerCase() == 'gold' ||
                    source?.toLowerCase() == 'goldnext')
                ? 'gm'
                : 'Kg';
            items = List.generate(
                ((inTotal - oneClick) ~/ step) + 1,
                (index) =>
                    '${(oneClick + index * step).toStringAsFixed(1)} $gmkg');
            quantity = (items.isNotEmpty ? items[0] : null)!;
          });
        } else {
          setState(() {
            items.clear();
            quantity = '';
          });
        }
      } else {
        setState(() {
          items.clear();
          quantity = '';
        });
      }
    } else {
      setState(() {
        items.clear();
        quantity = '';
      });
    }
  }

  void validateTrade(String symbolId) {
    if (isMarketSelected && isBuySellSelected) {
      callInsertOpenOrderDetailAPi(quantity, isMarketSelected,
          isBuySellSelected, _priceController.text, symbolId);
    } else if (isMarketSelected && !isBuySellSelected) {
      callInsertOpenOrderDetailAPi(quantity, isMarketSelected,
          isBuySellSelected, _priceController.text, symbolId);
    } else if (!isMarketSelected && isBuySellSelected) {
      if (_priceController.text.isNotEmpty) {
        callInsertOpenOrderDetailAPi(quantity, isMarketSelected,
            isBuySellSelected, _priceController.text, symbolId);
      } else {
        return DialogUtil.showAlertDialog(
          context,
          title: Constants.alertAndCnfTitle,
          content: 'Please enter price',
          okBtnText: 'Ok',
          cancelBtnText: 'Cancel',
        );
      }
    } else if (!isMarketSelected && !isBuySellSelected) {
      if (_priceController.text.isNotEmpty) {
        callInsertOpenOrderDetailAPi(quantity, isMarketSelected,
            isBuySellSelected, _priceController.text, symbolId);
      } else {
        return DialogUtil.showAlertDialog(
          context,
          title: Constants.alertAndCnfTitle,
          content: 'Please enter price',
          okBtnText: 'Ok',
          cancelBtnText: 'Cancel',
        );
      }
    }
  }

}
