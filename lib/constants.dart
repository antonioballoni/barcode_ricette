import 'package:flutter/material.dart';

class C {
  // dimensioni
  static const int lunghezzaChiaveCodiceFiscale = 4;
  static const double larghezzaBarCode = 500;
  static const double altezzaBarCode = 100;
  static const double dimEmptyBox = 100;
  static const double altezzaRigaRicetta = 30;
  static const double larghezzaRettangoloColore = 15;

  // colori
  static Color colRicettaNonLetta = Colors.blue[50]!;
  static Color colRicettaSelezionata = Colors.grey[300]!;
  static Color colRicettaNonLettaSelezionata = Colors.indigo[100]!;
  static Color colNuovaRicettaStella = Colors.orange[300]!;
  static Color colNotEnabled = Colors.grey[500]!;
  static Color colSeparator = Colors.grey[300]!;
  static Color colDefaultPickerColor = Colors.yellow[100]!;

  // stringhe
  static const String snkDatiSalvati = "Dati salvati correttatmente";
  static const String snkDatiNonSalvati = "Salvataggio dati fallito";
  static const String smsPermissionNotGranted = "Permesso sms non concesso";

  // stringhe pulsanti
  static const String ok = 'Ok';
  static const String conferma = 'Conferma';
  static const String annulla = 'Annulla';

  // stringhe titoli pagine
  static const String strAppName = "BarCodeRicette";
  static const String screenGestioneUtenti = 'Utenti';
  static const String screenModificaUtente = 'Modifica Utente';
  static const String screenNuovoUtenti = 'Nuovo Utente';

  // stringhe errore
  static const String errNomeUtenteMancante = 'Immettere un nome';
  static const String errCodiceFiscale = 'Codice fiscale non valido';
  static const String errCodiceFiscaleMancante = 'Codice fiscale mancante';

  // files
  static const String fileArchivioUtenti = "archivioUtenti";

  // regexp
  static const String regexpRicette = r"(?<regione>0\w{4})(?<ricetta>\d{10})";
  static const String regexpCodiceFiscale =
      r"[A-Za-z]{6}\d{2}[A-Za-z]\d{2}[A-Za-z]\d{3}[A-za-z]";
  static const String regexpChiaveCodiceFiscale = r"[A-Za-z]{4}\*";

  // images
  static const String imgNoData = 'assets/images/empty-box.png';
  static const String imgDefaultUtenteImage = 'assets/images/default-user.png';
}
