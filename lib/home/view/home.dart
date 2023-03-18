import 'package:barcode_ricette/home/controller/controller.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:barcode_ricette/constants.dart';
import 'package:barcode_ricette/model/model.dart';
import 'package:barcode_ricette/helpers.dart';
import 'package:barcode_ricette/gestione_utenti/view/gestione_utenti.dart';
import 'package:barcode_ricette/data_store_widgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _selectMode = false;
  final List<int> _selected = [];

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
                  Builder(builder: (context) {
                    HomeController controller =
                        DataStore.of<HomeController>(context);
                    return IconButton(
                        onPressed: () =>
                            _onDeleteRicetteButtonPressed(controller),
                        icon: const Icon(Icons.delete));
                  }),
                Builder(
                  builder: (context) {
                    HomeController controller =
                        DataStore.of<HomeController>(context);
                    return IconButton(
                        onPressed: _onCheckNewSmsButtonPressed,
                        icon: const Icon(Icons.download));
                  },
                ),
                Builder(builder: (context) {
                  HomeController controller =
                      DataStore.of<HomeController>(context);
                  return IconButton(
                      onPressed: () {
                        controller.save().then((salvati) {
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
            body: Center(child: Builder(
              builder: (context) {
                HomeController controller =
                    DataStore.of<HomeController>(context);
                return controller.listaRicette.isEmpty
                    ? _buildNoRicetteView()
                    : _buildListView(controller);
              },
            ))));
  }

  void _backButtonPressed() {
    setState(() {
      _selectMode = false;
      _selected.clear();
    });
  }

  void _onCheckNewSmsButtonPressed() {
    // do stuff
  }

  void _onDeleteRicetteButtonPressed(HomeController controller) {
    List<Ricetta> toBeDeleted = _selected
        .map((index) => controller.listaRicette[index])
        .toList(); // ricette da eliminare
    controller.deleteRicette(toBeDeleted);
    setState(() {
      _selectMode = false;
      _selected.clear();
    });
  }

  Widget _buildListView(HomeController controller) {
    return ListView.separated(
      padding: const EdgeInsets.all(5),
      itemCount: controller.listaRicette.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            if (!_selectMode) {
              setState(() {
                _selectMode = true;
                _selected.contains(index)
                    ? _selected.remove(index)
                    : _selected.add(index);
              });
            }
          },
          onTap: () {
            if (_selectMode) {
              setState(() {
                _selected.contains(index)
                    ? _selected.remove(index)
                    : _selected.add(index);
              });
            } else {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => BarCodeRicettaDialog(
                    ricetta: controller.listaRicette[index]),
              ).then((_) {
                controller.listaRicette[index].letto = true;
              });
            }
          },
          child: Container(
              color: controller.listaRicette[index].letto
                  ? _selected.contains(index)
                      ? C.colRicettaSelezionata
                      : Colors.transparent
                  : _selected.contains(index)
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
                    child: Text(DateFormatter.formatDate(
                        controller.listaRicette[index].data)),
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child:
                          Text(controller.listaRicette[index].codiceFiscale)),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child:
                          Text(controller.listaRicette[index].codiceRegione)),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child:
                          Text(controller.listaRicette[index].codiceRicetta)),
                  Container(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.star,
                        color: controller.listaRicette[index].nuovo
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
