import 'dart:collection';
import 'package:barcode_ricette/model/model.dart';
import 'package:flutter/material.dart';
import 'package:barcode_ricette/constants.dart';

class HomeController with ChangeNotifier {
  List<Ricetta>? _listaRicette; // lista delle ricette ottenuta dal Model
  bool _selectMode = false; // se siamo in modalita' di selezione
  final List<int> _selected = []; // ricette selezionate dell'utente

  HomeController() {
    Model().addListener(notifyListeners);
  }

  @override
  void dispose() {
    Model().removeListener(notifyListeners);
    super.dispose();
  }

  UnmodifiableListView<Ricetta> get listaRicette {
    _listaRicette ??= Model().centroRicette.listaRicette;
    return UnmodifiableListView<Ricetta>(_listaRicette!);
  }

  bool get selectMode => _selectMode;

  Future<bool> save() async {
    return Model().save();
  }

  void deleteRicette() {
    List<Ricetta> toBeDeleted = _selected
        .map((index) => _listaRicette![index])
        .toList(); // raccolgo ricette da eliminare

    Model().centroRicette.deleteRicette(toBeDeleted); // aggiorno il model

    _listaRicette!.removeWhere((element) {
      return toBeDeleted.contains(element);
    }); // allineo la lista locale

    exitSelectMode();
  }

  void exitSelectMode() {
    _selectMode = false;
    _selected.clear();
    notifyListeners();
  }

  void selectModeOn(int index) {
    if (!_selectMode) {
      _selectMode = true;
      _selected.add(index);
      notifyListeners();
    }
  }

  void toggleSelectedElement(int index) {
    _selected.contains(index) ? _selected.remove(index) : _selected.add(index);
    if (_selected.isEmpty) {
      exitSelectMode();
      return;
    }
    notifyListeners();
  }

  void markAsRead(int index) {
    Model().centroRicette.listaRicette[index].letto = true;
  }

  Color itemColor(int index) {
    return listaRicette[index].letto
        ? _selected.contains(index)
            ? C.colRicettaSelezionata
            : Colors.transparent
        : _selected.contains(index)
            ? C.colRicettaNonLettaSelezionata
            : C.colRicettaNonLetta;
  }

  Color starColor(int index) {
    return listaRicette[index].nuovo
        ? C.colNuovaRicettaStella
        : C.colNotEnabled;
  }
}
