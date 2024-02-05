import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'Providers/liveRate_Provider.dart';

class NotifierProvider {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider.value(
      value: LiveRateProvider(),
    ),
  ];
}
