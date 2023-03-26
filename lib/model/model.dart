import 'package:barcode_ricette/constants.dart';
import 'package:flutter/material.dart';
import 'package:barcode_ricette/helpers.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class Ricetta extends Comparable<Ricetta> with ChangeNotifier {
  final DateTime data;
  final String codiceRegione;
  final String codiceRicetta;
  final String codiceFiscale;
  bool _letto;
  bool _nuovo;
  late ArchivioRicette archivio;

  Ricetta.nuova(
      this.data, this.codiceRegione, this.codiceRicetta, this.codiceFiscale)
      : _letto = false,
        _nuovo = true;
  Ricetta(this.data, this.codiceRegione, this.codiceRicetta, this.codiceFiscale,
      this._letto, this._nuovo);

  factory Ricetta.fromJson(dynamic json) {
    return Ricetta(
        DateTime.parse(json['data']),
        json['codiceRegione'] as String,
        json['codiceRicetta'] as String,
        json['codiceFiscale'] as String,
        json['_letto'] as bool,
        json['_nuovo'] as bool);
  }

  @override
  bool operator ==(Object other) =>
      other is Ricetta && hashCode == other.hashCode;

  @override
  int get hashCode => (codiceRegione + codiceRicetta).hashCode;

  Map toJson() => {
        'data': data.toIso8601String(),
        'codiceRegione': codiceRegione,
        'codiceRicetta': codiceRicetta,
        'codiceFiscale': codiceFiscale,
        '_letto': _letto,
        '_nuovo': _nuovo,
      };

  bool get letto => _letto;
  set letto(bool value) {
    if (_letto != value) {
      _letto = value;
      notifyListeners();
    }
  }

  bool get nuovo => _nuovo;
  set nuovo(bool value) {
    if (_nuovo != value) {
      _nuovo = value;
      notifyListeners();
    }
  }

  @override
  int compareTo(Ricetta other) => data.compareTo(other.data);
}

class Model with ChangeNotifier {
  late final ArchivioUtenti archivioUtenti;
  late final CentroRicette centroRicette;

  static final Model _instance = Model._();
  Model._();
  factory Model() => _instance;

  Future<void> init() async {
    _instance.archivioUtenti =
        await FileManager().loadArchivioUtenti(); // load data from files
    archivioUtenti.addListener(notifyListeners);
    _instance.centroRicette = CentroRicette(_instance.archivioUtenti);
    _instance.centroRicette.assegnaRicette(
        await SmsHelper().fetchSmsRicette()); // look for new Ricette
  }

  Future<bool> save() async {
    return await FileManager().saveArchivioUtenti(archivioUtenti);
  }
}

class Utente extends Comparable<Utente> with ChangeNotifier {
  String _nome;
  String _codiceFiscale;
  Color _colore;
  String _immagine;
  late final ArchivioRicette archivioRicette;

  Utente(this._nome, this._codiceFiscale, this._colore, this._immagine)
      : archivioRicette = ArchivioRicette.empty();
  Utente.conRicette(this._nome, this._codiceFiscale, this._colore,
      this._immagine, ArchivioRicette archivio)
      : archivioRicette = archivio {
    archivioRicette.utente = this;
  }

  factory Utente.fromJson(dynamic json) {
    Utente u = Utente.conRicette(
        json['nome'],
        json['codiceFiscale'],
        Color(int.parse(json['colore'], radix: 16)),
        json['immagine'],
        ArchivioRicette.fromJson(json['archivioRicette']));
    u.archivioRicette.addListener(u.notifyListeners);
    return u;
  }

  Map toJson() => {
        'nome': _nome,
        'codiceFiscale': _codiceFiscale,
        'colore': _colore.toString().split('(0x')[1].split(')')[0],
        'immagine': _immagine,
        'archivioRicette': archivioRicette.toJson()
      };

  @override
  int compareTo(Utente other) => _codiceFiscale.compareTo(other._codiceFiscale);

  @override
  bool operator ==(Object other) =>
      other is Utente && other.codiceFiscale.compareTo(codiceFiscale) == 0;

  @override
  int get hashCode => _codiceFiscale.hashCode;

  String get nome => _nome;
  set nome(String value) {
    if (value != nome) {
      nome = value;
      notifyListeners();
    }
  }

  String get codiceFiscale => _codiceFiscale;
  set codiceFiscale(String value) {
    if (codiceFiscale != value) {
      codiceFiscale = value;
      notifyListeners();
    }
  }

  Color get colore => _colore;
  set colore(Color value) {
    if (colore != value) {
      colore = value;
      notifyListeners();
    }
  }

  String get immagine => _immagine;
  set immagine(String value) {
    if (immagine != value) {
      immagine = value;
      notifyListeners();
    }
  }
}

class ArchivioRicette with ChangeNotifier {
  late final List<Ricetta>
      _ricette; // si assume *sempre* ordinata per data [piu vecchia --> piu nuova]
  late final Utente utente;
  static const String _ricetteKey = 'ricette';

  ArchivioRicette.empty() : _ricette = [];
  ArchivioRicette.fromJson(dynamic json) {
    var listaRicetteJson = json[_ricetteKey] as List;
    _ricette = listaRicetteJson.map((ricettaJson) {
      Ricetta r = Ricetta.fromJson(ricettaJson);
      r.archivio = this;
      r.addListener(notifyListeners);
      return r;
    }).toList();
  }

  Map toJson() => {_ricetteKey: _ricette};

  List<Ricetta> get listaRicette => List.from(_ricette,
      growable: false); //should be read only, it'as a copy anyway

  void addRicetta(Ricetta r) {
    if (_addRicetta(r)) notifyListeners();
  }

  bool _addRicetta(Ricetta r) {
    if (_ricette.contains(r)) {
      return false;
    } else {
      r.archivio = this;
      _ricette.add(r);
      _ricette.sort();
      r.addListener(() {
        notifyListeners();
      });
      return true;
    }
  }

  void addListRicette(List<Ricetta> lista) {
    bool added = false;
    for (Ricetta r in lista) {
      if (_addRicetta(r)) {
        added = true;
      }
    }
    if (added) notifyListeners();
  }

  void removeRicetta(Ricetta r) {
    if (_removeRicetta(r)) {
      notifyListeners();
    }
  }

  void removeListaRicette(List<Ricetta> lista) {
    bool removed = false;
    for (Ricetta r in lista) {
      if (_removeRicetta(r)) removed = true;
    }
    if (removed) notifyListeners();
  }

  bool _removeRicetta(Ricetta r) => _ricette.remove(r);
}

class ArchivioUtenti with ChangeNotifier {
  static const String _keyUtenti = 'utenti';
  late final List<Utente> _utenti;

  ArchivioUtenti.empty() : _utenti = [];
  ArchivioUtenti._(this._utenti) {
    for (Utente u in _utenti) {
      u.addListener(notifyListeners);
    }
    _utenti.sort();
  }
  factory ArchivioUtenti.fromJson(dynamic json) {
    var jsonListaUtenti = json[_keyUtenti] as List;
    return ArchivioUtenti._(
        jsonListaUtenti.map((e) => Utente.fromJson(e)).toList());
  }

  Map toJson() => {_keyUtenti: _utenti};

  bool addUtente(Utente u) {
    if (_utenti.contains(u)) {
      return false;
    }
    _utenti.add(u);
    _utenti.sort();
    u.addListener(() => notifyListeners());
    notifyListeners();
    return true;
  }

  Utente? removeUtente(Utente u) {
    if (_utenti.contains(u)) {
      Utente removed = _utenti.removeAt(_utenti.indexOf(u));
      notifyListeners();
      return removed;
    }
    return null;
  }

  Utente? removeUtenteWithCodiceFiscale(String codiceFiscale) {
    int index = _utenti.indexWhere(
        (element) => element._codiceFiscale.compareTo(codiceFiscale) == 0);
    if (index > -1) {
      Utente removed = _utenti.removeAt(index);
      notifyListeners();
      return removed;
    } else {
      return null;
    }
  }

  List<Utente> get allUtenti => _utenti.toList();
}

class CentroRicette {
  final ArchivioUtenti _archivioUtenti;
  final Map<String, Utente> _mapChiaveUtente = {};

  CentroRicette(this._archivioUtenti) {
    _archivioUtenti.addListener(_updateMappaChiaviCodiciFiscaliUtenti);
    _updateMappaChiaviCodiciFiscaliUtenti();
  }

  List<Ricetta> get listaRicette {
    List<Ricetta> ricette = [];
    for (Utente u in _archivioUtenti._utenti) {
      ricette.addAll(u.archivioRicette._ricette);
    }
    return ricette;
  }

  /*
    Se non trova una chiaveCodiceFiscaleUtente ignora il messaggio 
  */
  void assegnaRicette(List<SmsMessage> smsList) {
    for (SmsMessage sms in smsList) {
      var cfMatch = RegExp(C.regexpChiaveCodiceFiscale).firstMatch(sms.body!);
      if (cfMatch != null) {
        String chiaveCF = cfMatch[0]!.split('*')[0]; // levo il * dalla stringa
        Utente? utente = _mapChiaveUtente[chiaveCF.toUpperCase()];
        if (utente != null) {
          Ricetta r = _smsToRicetta(sms, utente.codiceFiscale);
          utente.archivioRicette.addRicetta(r);
        }
        // else ignoro il messaggio, ma andrebbe assegnato a un utente generico
      }
      // else ignora il messaggio
    }
  }

  void deleteRicette(List<Ricetta> ricette) {
    for (Ricetta r in ricette) {
      Utente? u = _findUtenteFromCodiceFiscale(r.codiceFiscale);
      if (u != null) {
        u.archivioRicette.removeRicetta(r);
      }
    }
  }

  void _updateMappaChiaviCodiciFiscaliUtenti() {
    if (_mapChiaveUtente.isNotEmpty) {
      _mapChiaveUtente.clear();
    }
    for (Utente u in _archivioUtenti.allUtenti) {
      _mapChiaveUtente.putIfAbsent(
          _chiaveCodiceFiscale(u.codiceFiscale), () => u);
    }
  }

  Ricetta _smsToRicetta(SmsMessage sms, String cf) {
    var codiceRicettaMatch = RegExp(C.regexpRicette).firstMatch(sms.body!)!;
    return Ricetta.nuova(
        sms.dateSent!,
        codiceRicettaMatch.namedGroup('regione')!.toUpperCase(),
        codiceRicettaMatch.namedGroup('ricetta')!,
        cf);
  }

  String _chiaveCodiceFiscale(String codiceFiscale) =>
      codiceFiscale.substring(0, C.lunghezzaChiaveCodiceFiscale);

  Utente? _findUtenteFromCodiceFiscale(String codiceFiscale) {
    return _mapChiaveUtente[_chiaveCodiceFiscale(codiceFiscale)];
  }
}
