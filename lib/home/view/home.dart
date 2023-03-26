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
  HomeController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= DataStore.of<HomeController>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text(C.strAppName),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: _controller!.selectMode
                  ? IconButton(
                      onPressed: _backButtonPressed,
                      icon: const Icon(Icons.arrow_back))
                  : null,
              actions: [
                if (_controller!.selectMode)
                  IconButton(
                      onPressed: () => _onDeleteRicetteButtonPressed(),
                      icon: const Icon(Icons.delete)),
                IconButton(
                    onPressed: _onCheckNewSmsButtonPressed,
                    icon: const Icon(Icons.download)),
                IconButton(
                    onPressed: () {
                      _controller!.save().then((salvati) {
                        final String msg =
                            salvati ? C.snkDatiSalvati : C.snkDatiNonSalvati;
                        _displaySnackBar(context, msg);
                      });
                    },
                    icon: const Icon(Icons.save)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GestioneUtenti()),
                      );
                    },
                    icon: const Icon(Icons.people_alt_rounded))
              ],
            ),
            body: Center(
              child: _controller!.listaRicette.isEmpty
                  ? _buildNoRicetteView()
                  : _buildListView(),
            )));
  }

  void _backButtonPressed() {
    _controller!.exitSelectMode();
  }

  void _onCheckNewSmsButtonPressed() {
    // do stuff
  }

  void _onDeleteRicetteButtonPressed() {
    _controller!.deleteRicette();
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(5),
      itemCount: _controller!.listaRicette.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            _controller!.selectModeOn(index);
          },
          onTap: () {
            if (_controller!.selectMode) {
              _controller!.toggleSelectedElement(index);
            } else {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => BarCodeRicettaDialog(
                    ricetta: _controller!.listaRicette[index]),
              ).then((_) {
                _controller!.markAsRead(index);
              });
            }
          },
          child: Container(
              color: _controller!.itemColor(index),
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
                        _controller!.listaRicette[index].data)),
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child:
                          Text(_controller!.listaRicette[index].codiceFiscale)),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child:
                          Text(_controller!.listaRicette[index].codiceRegione)),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child:
                          Text(_controller!.listaRicette[index].codiceRicetta)),
                  Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.star,
                          color: _controller!.starColor(index)))
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
