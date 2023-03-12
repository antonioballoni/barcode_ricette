import 'dart:collection';
import 'package:barcode_ricette/model/model.dart';

class HomeController {
  List<Ricetta>? _listaRicette;
  void Function() updateUI;

  HomeController(this.updateUI);

  UnmodifiableListView<Ricetta> get listaRicette {
    _listaRicette ??= Model().centroRicette.listaRicette;
    return UnmodifiableListView<Ricetta>(_listaRicette!);
  }

  Future<bool> save() async {
    return Model().save();
  }

  void deleteRicette(List<Ricetta> toBeDeleted) {
    Model().centroRicette.deleteRicette(toBeDeleted);
    updateUI();
  }
}
