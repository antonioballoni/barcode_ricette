import 'dart:collection';
import 'package:barcode_ricette/model/model.dart';
import 'package:flutter/material.dart';

class GestioneUtentiController with ChangeNotifier {
  int? _selectedItemIndex;
  late List<Utente> _allUtenti;

  GestioneUtentiController() {
    Model().addListener(notifyListeners);
    _allUtenti = Model().archivioUtenti.allUtenti;
  }

  @override
  void dispose() {
    super.dispose();
    Model().removeListener(notifyListeners);
  }

  UnmodifiableListView<Utente> get allUtenti {
    return UnmodifiableListView(_allUtenti);
  }

  void _removeUtenteAt(int index) {
    Model().archivioUtenti.removeUtente(_allUtenti[index]);
    _allUtenti.removeAt(index);
    _selectedItemIndex = null;
  }

  void removeSelectedUtente() {
    if (isAnythingSelected) {
      _removeUtenteAt(_selectedItemIndex!);
    }
  }

  set selectedItemIndex(int? index) {
    _selectedItemIndex = _selectedItemIndex == index ? null : index;
    notifyListeners();
  }

  int? get selectedItemIndex => _selectedItemIndex;

  bool get isAnythingSelected => _selectedItemIndex != null;

  Utente? get selectedUtente => isAnythingSelected
      ? Model().archivioUtenti.allUtenti[_selectedItemIndex!]
      : null;

  Color itemBackgroundColor(int index) {
    return index == _selectedItemIndex ? Colors.blueAccent : Colors.transparent;
  }
}
