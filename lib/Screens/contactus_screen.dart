// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:terminal_demo/Functions.dart';
import 'package:terminal_demo/Models/CommonRequestModel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/notify_socket_update.dart';
import '../Models/client_header.dart';
import '../Providers/liveRate_Provider.dart';
import '../Services/feedback_service.dart';
import '../Widgets/contact_detail_container.dart';
import '../Widgets/custom_text.dart';

class ContactUs_Screen extends StatefulWidget {
  const ContactUs_Screen({super.key});

  @override
  State<ContactUs_Screen> createState() => ContactUs_ScreenState();
}

class ContactUs_ScreenState extends State<ContactUs_Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final FeedbackService feedbackService = FeedbackService();
  bool isLoading = false;
  FocusNode emailFocusNode = new FocusNode();
  FocusNode phoneFocusNode = new FocusNode();
  FocusNode subjectFocusNode = new FocusNode();
  FocusNode messageFocusNode = new FocusNode();

  ClientHeaderData liveData = ClientHeaderData();
  late LiveRateProvider _liverateProvider;
  bool isAddressContainerVisible = false;
  bool isEmailContainerVisible = false;
  bool isBookingContainerVisible = false;

  bool isAddress1Visible = false;
  bool isAddress2Visible = false;
  bool isAddress3Visible = false;

  bool isEmail1Visible = false;
  bool isEmail2Visible = false;

  bool isBooking1Visible = false;
  bool isBooking2Visible = false;
  bool isBooking3Visible = false;
  bool isBooking4Visible = false;
  bool isBooking5Visible = false;
  bool isBooking6Visible = false;
  bool isBooking7Visible = false;

  clearFields() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    subjectController.clear();
    messageController.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);
    getLiveData();
    NotifySocketUpdate.controllerClientData = StreamController.broadcast();
    NotifySocketUpdate.controllerClientData!.stream.listen((event) {
      getLiveData();
    });
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerClientData!.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: Column(
            children: [
              Visibility(
                visible: isAddressContainerVisible,
                child: Container(
                  margin: EdgeInsets.only(top: 4),
                  width: size.width,
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    //  shadows: const [AppColors.boxShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.defaultColor,
                          size: 30.0,
                        ),
                      ),
                      AddressContainer(
                        isVisible: isAddress1Visible,
                        titleText: 'ADDRESS',
                        titleSize: 16.0,
                        descriptionText: liveData.addressClient ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        titleFontWeight: FontWeight.bold,
                        descriptionFontWeight: FontWeight.w400,
                      ),
                      AddressContainer(
                        isVisible: isAddress2Visible,
                        titleText: 'ADDRESS',
                        titleSize: 16.0,
                        descriptionText: liveData.addressClient2 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        titleFontWeight: FontWeight.bold,
                        descriptionFontWeight: FontWeight.w400,
                      ),
                      AddressContainer(
                        isVisible: isAddress3Visible,
                        titleText: 'ADDRESS',
                        titleSize: 16.0,
                        descriptionText: liveData.addressClient3 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        titleFontWeight: FontWeight.bold,
                        descriptionFontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 3.0,
              ),
              Visibility(
                visible: isEmailContainerVisible,
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    //  shadows: const [AppColors.boxShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.email_outlined,
                          color: AppColors.defaultColor,
                          size: 30.0,
                        ),
                      ),
                      Visibility(
                        visible: isEmailContainerVisible,
                        child: const CustomText(
                          text: 'EMAIL',
                          size: 16.0,
                          textColor: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ContactDetailContainer(
                        isVisible: isEmail1Visible,
                        descriptionText: liveData.email1 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(scheme: 'mailto', path: liveData.email1),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isEmail2Visible,
                        descriptionText: liveData.email2 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(scheme: 'mailto', path: liveData.email2),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 3.0,
              ),
              Visibility(
                visible: isBookingContainerVisible,
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // shadows: const [AppColors.boxShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.call,
                          color: AppColors.defaultColor,
                          size: 30.0,
                        ),
                      ),
                      Visibility(
                        visible: isBookingContainerVisible,
                        child: const CustomText(
                          text: 'BOOKING NUMBER',
                          size: 16.0,
                          textColor: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking1Visible,
                        descriptionText: liveData.bookingNo1 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.bookingNo1!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking2Visible,
                        descriptionText: liveData.bookingNo2 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.bookingNo2!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking3Visible,
                        descriptionText: liveData.bookingNo3 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.bookingNo3!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking4Visible,
                        descriptionText: liveData.bookingNo4 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.bookingNo4!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking5Visible,
                        descriptionText: liveData.bookingNo5 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.bookingNo5!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking6Visible,
                        descriptionText: liveData.bookingNo6 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.bookingNo6!)),
                          );
                        },
                      ),
                      ContactDetailContainer(
                        isVisible: isBooking7Visible,
                        descriptionText: liveData.bookingNo7 ?? '',
                        descriptionSize: 14.0,
                        color: AppColors.textColor,
                        descriptionFontWeight: FontWeight.w400,
                        onTap: () {
                          launchUrl(
                            Uri(
                                scheme: 'tel',
                                path: Functions.alphaNum(liveData.bookingNo7!)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 3.0,
              ),
              Container(
                width: size.width,
                // margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // shadows: const [AppColors.boxShadow],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          // color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Align(
                            alignment: Alignment.center,
                            child: CustomText(
                                text: 'FEEDBACK FROM',
                                fontWeight: FontWeight.bold,
                                textColor: AppColors.primaryColor,
                                size: 18.0)

                            // const Text(
                            //   textScaleFactor: 1.0,
                            //   'FEEDBACK FROM',
                            //   style: TextStyle(
                            //       color: AppColors.defaultColor,
                            //       fontSize: 20.0,
                            //       fontWeight: FontWeight.bold),
                            // ),
                            ),
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Name*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.textColor,
                          size: 14.0),

                      // Text(
                      //   textScaleFactor: 1.0,
                      //   'Name*',
                      //   style: TextStyle(
                      //       color: AppColors.textColor,
                      //       fontSize: 14.0,
                      //       fontWeight: FontWeight.normal),
                      // ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: nameController,
                        decoration:
                            getInputBoxDecoration('Please Enter Your Name'),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: AppColors.primaryColor,
                        onFieldSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(emailFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Email*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.textColor,
                          size: 14.0),

                      // Text(
                      //   textScaleFactor: 1.0,
                      //   'Email*',
                      //   style: TextStyle(
                      //       color: AppColors.textColor,
                      //       fontSize: 14.0,
                      //       fontWeight: FontWeight.normal),
                      // ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration:
                            getInputBoxDecoration('Please Enter Your Email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        cursorColor: AppColors.primaryColor,
                        focusNode: emailFocusNode,
                        onFieldSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(phoneFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Phone*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.textColor,
                          size: 14.0),

                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration:
                            getInputBoxDecoration('Please Enter Your Phone'),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        cursorColor: AppColors.primaryColor,
                        focusNode: phoneFocusNode,
                        onFieldSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(subjectFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Subject*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.textColor,
                          size: 14.0),

                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: subjectController,
                        decoration: getInputBoxDecoration(
                            'Please Enter Your Subject(Optional)'),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: AppColors.primaryColor,
                        focusNode: subjectFocusNode,
                        onFieldSubmitted: (String value) {
                          FocusScope.of(context).requestFocus(messageFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      CustomText(
                          text: 'Message*',
                          fontWeight: FontWeight.normal,
                          textColor: AppColors.textColor,
                          size: 14.0),

                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: messageController,
                        decoration: getInputBoxDecoration('Message For Me'),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        cursorColor: AppColors.primaryColor,
                        focusNode: messageFocusNode,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (nameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              // subjectController.text.isEmpty ||
                              messageController.text.isEmpty) {
                            Platform.isIOS
                                ? Functions.showSnackBar(
                                    context, 'Please fill all fields.')
                                : Functions.showToast(
                                    'Please fill all fields.');
                          } else {
                            FeedbackRequest feedback = FeedbackRequest(
                              name: nameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              sub: subjectController.text,
                              message: messageController.text,
                              client: int.parse(Constants.clientId),
                            );

                            sendFeedback(feedback);
                          }
                        },
                        child: Container(
                          width: size.width * .9,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            // color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          alignment: Alignment.center,
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Stack(
                            children: [
                              Visibility(
                                visible: !isLoading,
                                child: CustomText(
                                    text: 'SEND MESSAGE',
                                    fontWeight: FontWeight.bold,
                                    textColor: AppColors.primaryColor,
                                    size: 16.0),

                                // const Text(
                                //   textScaleFactor: 1.0,
                                //   'SEND MESSAGE',
                                //   style: TextStyle(
                                //     color: AppColors.defaultColor,
                                //     fontSize: 16.0,
                                //     fontWeight: FontWeight.normal,
                                //   ),
                                // ),
                              ),
                              Visibility(
                                visible: isLoading,
                                child: SizedBox(
                                  height: 20.0,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.defaultColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getInputBoxDecoration(String text) {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
      hintText: text,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  sendFeedback(FeedbackRequest feedback) {
    setState(() {
      isLoading = true;
    });
    Functions.checkConnectivity().then((isConnected) {
      if (isConnected) {
        feedbackService.feedbackService(feedback).then((response) {
          if (response.data != null) {
            setState(() {
              isLoading = false;
            });
            Platform.isIOS
                ? Functions.showSnackBar(context,
                    'Feedback Sended.\nThank You For Valuable Feedback.')
                : Functions.showToast(
                    'Feedback Sended.\nThank You For Valuable Feedback.');

            clearFields();
          } else {
            Functions.showToast(response.errorMessage!);
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Functions.showToast(Constants.noInternet);
      }
    });
  }

  getLiveData() {
    setState(() {
      liveData = _liverateProvider.getClientHeaderData();
    });

    // Check for visiblity of Address Area
    if (liveData.addressClient!.isEmpty &&
        liveData.addressClient2!.isEmpty &&
        liveData.addressClient3!.isEmpty) {
      isAddressContainerVisible = false;
    } else {
      isAddressContainerVisible = true;
      liveData.addressClient!.isEmpty
          ? isAddress1Visible = false
          : isAddress1Visible = true;
      liveData.addressClient2!.isEmpty
          ? isAddress2Visible = false
          : isAddress2Visible = true;
      liveData.addressClient3!.isEmpty
          ? isAddress3Visible = false
          : isAddress3Visible = true;
    }

    // Check for visiblity of Email Area and Booking Area
    if (liveData.email1!.isEmpty && liveData.email2!.isEmpty) {
      isEmailContainerVisible = false;
    } else {
      isEmailContainerVisible = true;
      liveData.email1!.isEmpty
          ? isEmail1Visible = false
          : isEmail1Visible = true;
      liveData.email2!.isEmpty
          ? isEmail2Visible = false
          : isEmail2Visible = true;
    }

    // Check for visiblity of Booking Area
    if (liveData.bookingNo1!.isEmpty &&
        liveData.bookingNo2!.isEmpty &&
        liveData.bookingNo3!.isEmpty &&
        liveData.bookingNo4!.isEmpty &&
        liveData.bookingNo5!.isEmpty &&
        liveData.bookingNo6!.isEmpty &&
        liveData.bookingNo7!.isEmpty) {
      isBookingContainerVisible = false;
    } else {
      isBookingContainerVisible = true;
      liveData.bookingNo1!.isEmpty
          ? isBooking1Visible = false
          : isBooking1Visible = true;
      liveData.bookingNo2!.isEmpty
          ? isBooking2Visible = false
          : isBooking2Visible = true;
      liveData.bookingNo3!.isEmpty
          ? isBooking3Visible = false
          : isBooking3Visible = true;
      liveData.bookingNo4!.isEmpty
          ? isBooking4Visible = false
          : isBooking4Visible = true;
      liveData.bookingNo5!.isEmpty
          ? isBooking5Visible = false
          : isBooking5Visible = true;
      liveData.bookingNo6!.isEmpty
          ? isBooking6Visible = false
          : isBooking6Visible = true;
      liveData.bookingNo7!.isEmpty
          ? isBooking7Visible = false
          : isBooking7Visible = true;
    }

    debugPrint(liveData.personName1);
  }
}

class AddressContainer extends StatelessWidget {
  const AddressContainer({
    required this.descriptionText,
    required this.descriptionSize,
    required this.color,
    required this.descriptionFontWeight,
    required this.titleText,
    required this.titleSize,
    required this.titleFontWeight,
    this.isVisible = false,
    super.key,
  });

  final bool isVisible;
  final String titleText;
  final double titleSize;
  final String descriptionText;
  final double descriptionSize;
  final Color color;
  final FontWeight titleFontWeight;
  final FontWeight descriptionFontWeight;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: const EdgeInsets.only(
          top: 10,
        ),
        // color: AppColors.defaultColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: titleText,
              size: titleSize,
              textColor: color,
              fontWeight: titleFontWeight,
            ),
            CustomText(
              text: descriptionText,
              fontWeight: descriptionFontWeight,
              textColor: color,
              size: descriptionSize,
              align: TextAlign.center,
            ),

            // Text(
            //   textScaleFactor: 1.0,
            //   descriptionText,
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //       fontSize: descriptionSize,
            //       color: color,
            //       fontWeight: descriptionFontWeight),
            // ),
          ],
        ),
      ),
    );
  }
}
