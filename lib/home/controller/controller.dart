import 'dart:collection';
import 'package:barcode_ricette/model/model.dart';
import 'package:flutter/material.dart';

class HomeController with ChangeNotifier {
  List<Ricetta>? _listaRicette;

  HomeController() {
    Model().addListener(notifyListeners);
  }

  UnmodifiableListView<Ricetta> get listaRicette {
    _listaRicette ??= Model().centroRicette.listaRicette;
    return UnmodifiableListView<Ricetta>(_listaRicette!);
  }

  Future<bool> save() async {
    return Model().save();
  }

  void deleteRicette(List<Ricetta> toBeDeleted) {
    Model().centroRicette.deleteRicette(toBeDeleted);
    _listaRicette!.removeWhere((element) {
      return toBeDeleted.contains(element);
    });
  }
}
