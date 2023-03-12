import 'package:barcode_ricette/constants.dart';

extension ExtString on String {
  bool get isValidCodiceFiscale {
    final cfRegExp = RegExp(C.regexpCodiceFiscale);
    return cfRegExp.hasMatch(this);
  }
}
