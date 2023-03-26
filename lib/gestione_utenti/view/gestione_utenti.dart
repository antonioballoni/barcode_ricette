import 'package:barcode_ricette/form_utente/view/form_utente.dart';
import 'package:barcode_ricette/gestione_utenti/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:barcode_ricette/model/model.dart';
import 'package:barcode_ricette/constants.dart';
import 'package:barcode_ricette/data_store_widgets.dart';

class GestioneUtenti extends StatefulWidget {
  const GestioneUtenti({super.key});
  @override
  State<GestioneUtenti> createState() => _GestioneUtentiState();
}

class _GestioneUtentiState extends State<GestioneUtenti> {
  GestioneUtentiController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= DataStore.of<GestioneUtentiController>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(C.screenGestioneUtenti),
        actions: [
          if (_controller!.isAnythingSelected)
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FormUtente(utente: _controller!.selectedUtente)));
                },
                icon: const Icon(Icons.edit)),
          if (_controller!.isAnythingSelected)
            IconButton(
                onPressed: () {
                  _showDeleteDialog(_controller!.selectedUtente!).then(
                    (delete) {
                      if (delete!) {
                        _controller!.removeSelectedUtente();
                      }
                    },
                  );
                },
                icon: const Icon(Icons.delete)),
        ],
      ),
      body: Center(
          child: _controller!.allUtenti.isEmpty
              ? const SizedBox(
                  width: C.dimEmptyBox,
                  height: C.dimEmptyBox,
                  child: Image(image: AssetImage(C.imgNoData)))
              : ListView.separated(
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _controller!.selectedItemIndex = index;
                      },
                      child: Container(
                          padding: const EdgeInsets.all(2),
                          color: _controller!.itemBackgroundColor(index),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  color: _controller!.allUtenti[index].colore,
                                  width: C.larghezzaRettangoloColore,
                                  height: C.altezzaRigaRicetta,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  width: 30,
                                  height: 30,
                                  child: const Image(
                                      height: 30,
                                      width: 30,
                                      image:
                                          AssetImage(C.imgDefaultUtenteImage)),
                                ),
                                Text(_controller!.allUtenti[index].nome),
                                Text(_controller!
                                    .allUtenti[index].codiceFiscale),
                              ])),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 1,
                      thickness: 0,
                      color: C.colSeparator,
                    );
                  },
                  itemCount: _controller!.allUtenti.length)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormUtente()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(Utente u) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Text("Si desidera eliminare l'utente ${u.nome}"),
          actions: [
            ElevatedButton(
              child: const Text(C.annulla),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text(C.ok),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
