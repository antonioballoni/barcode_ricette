import 'dart:collection';
import 'package:barcode_ricette/model/model.dart';

class GestioneUtentiController {
  GestioneUtentiController(void Function() updateUI) {
    Model().addListener(updateUI);
  }

  UnmodifiableListView<Utente> get allUtenti {
    return UnmodifiableListView(Model().archivioUtenti.allUtenti);
  }

  void removeUtenteAt(int index) {
    Model()
        .archivioUtenti
        .removeUtente(Model().archivioUtenti.allUtenti[index]);
  }
}
