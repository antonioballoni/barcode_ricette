import 'package:barcode_ricette/model/model.dart';

class FormUtenteController {
  FormUtenteController();

  void addUtente(Utente u) {
    Model().archivioUtenti.addUtente(u);
  }
}
