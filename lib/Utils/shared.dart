import 'package:shared_preferences/shared_preferences.dart';

class Shared {
  static const String isLogin = 'IsLogin';
  static const String isRememberLoginCheckBox = 'IsRemember';
  static const String loginData = 'LoginData';
  static const String groupData = 'GroupData';
  final String isDiscovery = 'discovery';
  final String isAddBannerVisible = 'isAddBannerVisible';

  static const String isFirstTimeRegister = 'isFirstTimeRegister';

  Future<void> setIsLogin(bool flag) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(isLogin, flag);
  }

  Future<bool> getIsLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var loginStatus = pref.getBool(isLogin);
    return loginStatus ?? false;
  }
  Future<void> setisAddBannerVisible(bool flag) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(isAddBannerVisible, flag);
  }
  Future<bool> getisAddBannerVisible() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var addStatus = pref.getBool(isAddBannerVisible);
    return addStatus ?? true;
  }
  Future<void> setIsRemember(bool flag) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(isRememberLoginCheckBox, flag);
  }

  Future<bool> getIsRemember() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var rememberStatus = pref.getBool(isRememberLoginCheckBox);
    return rememberStatus ?? false;
  }

  Future<void> setIsFirstTimeRegister(bool flag) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(isFirstTimeRegister, flag);
  }

  Future<bool> getIsFirstTimeRegister() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var rememberStatus = pref.getBool(isFirstTimeRegister);
    return rememberStatus ?? false;
  }

  Future<void> setLoginData(String data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(loginData, data);
  }

  Future<String> getLoginData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? login = pref.getString(loginData);
    return login ?? '';
  }

  //groupData
  Future<void> setGroupData(String data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(groupData, data);
  }

  Future<String> getGroupData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? group = pref.getString(groupData);
    return group ?? '';
  }

  Future<void> setIsDiscoverd(bool flag) async {
    final SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setBool(isDiscovery, flag);
  }

  Future<bool> getIsDiscoverd() async {
    final SharedPreferences shared = await SharedPreferences.getInstance();
    var isDiscovered = shared.getBool(isDiscovery);
    return isDiscovered ?? false;
  }

  void clear() async {
    setIsLogin(false);
  }
}
