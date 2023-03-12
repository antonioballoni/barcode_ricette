import 'package:barcode_ricette/form_utente/view/form_utente.dart';
import 'package:barcode_ricette/gestione_utenti/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:barcode_ricette/model/model.dart';
import 'package:barcode_ricette/constants.dart';

class GestioneUtenti extends StatefulWidget {
  const GestioneUtenti({super.key});
  @override
  State<GestioneUtenti> createState() => _GestioneUtentiState();
}

class _GestioneUtentiState extends State<GestioneUtenti> {
  int? _selectedItemIndex;
  late GestioneUtentiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GestioneUtentiController(
      () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(C.screenGestioneUtenti),
        actions: [
          if (_selectedItemIndex != null)
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FormUtente(
                              utente:
                                  _controller.allUtenti[_selectedItemIndex!])));
                },
                icon: const Icon(Icons.edit)),
          if (_selectedItemIndex != null)
            IconButton(
                onPressed: () {
                  _showDeleteDialog(_controller.allUtenti[_selectedItemIndex!])
                      .then(
                    (delete) {
                      if (delete!) {
                        _controller.removeUtenteAt(_selectedItemIndex!);
                        _selectedItemIndex = null; // necessary?
                      }
                    },
                  );
                },
                icon: const Icon(Icons.delete)),
        ],
      ),
      body: Center(
          child: _controller.allUtenti.isEmpty
              ? const SizedBox(
                  width: C.dimEmptyBox,
                  height: C.dimEmptyBox,
                  child: Image(image: AssetImage(C.imgNoData)))
              : ListView.separated(
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _selectedItemIndex =
                              _selectedItemIndex == index ? null : index;
                        });
                      },
                      child: Container(
                          height: 50,
                          color: _controller.allUtenti[index].colore,
                          padding: const EdgeInsets.all(4),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 3,
                                  height: 30,
                                  color: index == _selectedItemIndex
                                      ? Colors.blueAccent
                                      : Colors.transparent,
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
                                Text(_controller.allUtenti[index].nome),
                                Text(
                                    _controller.allUtenti[index].codiceFiscale),
                              ])),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 1,
                      thickness: 1,
                      color: C.colSeparator,
                    );
                  },
                  itemCount: _controller.allUtenti.length)),
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
