import 'package:flutter/material.dart';
import 'package:barcode_ricette/constants.dart';
import 'package:barcode_ricette/model/model.dart';
import 'package:barcode_ricette/helpers.dart';
import 'package:barcode_ricette/home/view/home.dart';
import 'package:barcode_ricette/home/controller/controller.dart';
import 'data_store_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInit());
}

class AppInit extends StatelessWidget {
  const AppInit({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _runFirst(),
        builder: (_, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // DataStore
            return DataStore<HomeController>(
                data: HomeController(), child: const MaterialApp(home: Home()));
          } else if (snapshot.hasError) {
            // messaggio errore
            return _materialApp(_buildErrorWidget(snapshot.error.toString()));
          } else {
            // gitandola
            return _materialApp(_buildWaitingWidget());
          }
        });
  }

  Future<void> _runFirst() async {
    if (await haveAllAppRequirements()) {
      return Model().init();
    } else {
      return Future.error(C.smsPermissionNotGranted);
    }
  }

  Future<bool> haveAllAppRequirements() async {
    return SmsHelper().isSmsPermissionGranted();
  }

  Widget _materialApp(Widget content) {
    return MaterialApp(home: Scaffold(body: content));
  }

  Widget _buildWaitingWidget() {
    return const Center(
      child: SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
        child: Container(width: 400, color: Colors.red, child: Text(message)));
  }
}

/*
class MyAppTree extends StatefulWidget {
  const MyAppTree({super.key});

  @override
  State<MyAppTree> createState() => _MyAppTreeState();
}

class _MyAppTreeState extends State<MyAppTree> {
  bool _selectMode = false;
  late List<bool> _selected;
  late final List<Ricetta> _listaRicette;

  @override
  void didChangeDependencies() {
    _listaRicette =
        DataStore.of<MyDataRepo>(context).centroRicette.listaRicette;
    _selected = List.filled(_listaRicette.length, false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text(C.strAppName),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: _selectMode
                  ? IconButton(
                      onPressed: _backButtonPressed,
                      icon: const Icon(Icons.arrow_back))
                  : null,
              actions: [
                if (_selectMode)
                  IconButton(
                      onPressed: _onDeleteRicetteButtonPressed,
                      icon: const Icon(Icons.delete)),
                IconButton(
                    onPressed: _onCheckNewSmsButtonPressed,
                    icon: const Icon(Icons.download)),
                Builder(builder: (context) {
                  return IconButton(
                      onPressed: () {
                        MyDataRepo.save(DataStore.of<MyDataRepo>(context))
                            .then((salvati) {
                          final String msg =
                              salvati ? C.snkDatiSalvati : C.snkDatiNonSalvati;
                          _displaySnackBar(context, msg);
                        });
                      },
                      icon: const Icon(Icons.save));
                }),
                Builder(
                  builder: (context) {
                    return IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GestioneUtenti()),
                          );
                        },
                        icon: const Icon(Icons.people_alt_rounded));
                  },
                )
              ],
            ),
            body: Center(
                child: _listaRicette.isEmpty
                    ? _buildNoRicetteView()
                    : _buildListView())));
  }

  void _backButtonPressed() {
    setState(() {
      _selectMode = false;
      _selected = List.filled(_listaRicette.length, false);
    });
  }

  void _onCheckNewSmsButtonPressed() {
    // do stuff
  }

  void _onDeleteRicetteButtonPressed() {
    List<Ricetta> toBeDeleted = []; // ricette da eliminare
    for (int i = 0; i < _listaRicette.length; i++) {
      if (_selected[i]) {
        toBeDeleted.add(_listaRicette[i]);
      }
    }
    DataStore.of<MyDataRepo>(context).centroRicette.deleteRicette(toBeDeleted);
    DataStore.updatedOf<MyDataRepo>(
        context); // controllare se riconstruisce tutto il widget (liste ripartono da zero)
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(5),
      itemCount: _listaRicette.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            if (!_selectMode) {
              setState(() {
                _selectMode = true;
                _selected[index] = !_selected[index];
              });
            }
          },
          onTap: () {
            if (_selectMode) {
              setState(() {
                _selected[index] = !_selected[index];
              });
            } else {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) =>
                    BarCodeRicettaDialog(ricetta: _listaRicette[index]),
              ).then((_) {
                _listaRicette[index].letto = true;
                DataStore.updatedOf<MyDataRepo>(context);
              });
            }
          },
          child: Container(
              color: _listaRicette[index].letto
                  ? _selected[index]
                      ? C.colRicettaSelezionata
                      : Colors.transparent
                  : _selected[index]
                      ? C.colRicettaNonLettaSelezionata
                      : C.colRicettaNonLetta,
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                  ), // todo color (devo avere riferimento all'utente)
                  Container(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                        DateFormatter.formatDate(_listaRicette[index].data)),
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(_listaRicette[index].codiceFiscale)),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(_listaRicette[index].codiceRegione)),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(_listaRicette[index].codiceRicetta)),
                  Container(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.star,
                        color: _listaRicette[index].nuovo
                            ? C.colNuovaRicettaStella
                            : C.colNotEnabled),
                  )
                ],
              )),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(height: 1, thickness: 1, color: C.colSeparator);
      },
    );
  }

  Widget _buildNoRicetteView() {
    return const SizedBox(
        width: C.dimEmptyBox,
        height: C.dimEmptyBox,
        child: Image(image: AssetImage(C.imgNoData)));
  }

  void _displaySnackBar(BuildContext context, String message) {
    var snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class BarCodeRicettaDialog extends StatelessWidget {
  const BarCodeRicettaDialog({super.key, required this.ricetta});
  final Ricetta ricetta;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BarcodeWidget(
            data: ricetta.codiceRegione,
            barcode: Barcode.code39(),
            width: C.larghezzaBarCode,
            height: C.altezzaBarCode,
            padding: const EdgeInsets.only(bottom: 30),
          ),
          BarcodeWidget(
              data: ricetta.codiceRicetta,
              barcode: Barcode.code39(),
              width: C.larghezzaBarCode,
              height: C.altezzaBarCode,
              padding: const EdgeInsets.only(bottom: 30)),
          BarcodeWidget(
              data: ricetta.codiceFiscale,
              barcode: Barcode.code39(),
              width: C.larghezzaBarCode,
              height: C.altezzaBarCode,
              padding: const EdgeInsets.only(bottom: 30)),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue),
            child: const Text("Chuidi"))
      ],
    );
  }
}

*/