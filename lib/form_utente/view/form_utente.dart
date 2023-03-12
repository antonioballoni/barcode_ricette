import 'package:barcode_ricette/form_utente/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:barcode_ricette/model/model.dart';
import 'package:barcode_ricette/constants.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../extensions.dart';
import 'my_form_widgets.dart';

class FormUtente extends StatefulWidget {
  const FormUtente({super.key, this.utente});

  final Utente? utente;

  @override
  State<FormUtente> createState() => _FormUtenteState();
}

class _FormUtenteState extends State<FormUtente> {
  late final Utente? _utente;
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final codiceFiscaleController = TextEditingController();
  late Color _pickerColor;
  late FormUtenteController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FormUtenteController();
    _utente = widget.utente;
    if (_utente != null) {
      // edit mode
      nomeController.text = _utente!.nome;
      codiceFiscaleController.text = _utente!.codiceFiscale;
      _pickerColor = _utente!.colore;
    } else {
      _pickerColor = C.colDefaultPickerColor;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    codiceFiscaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _utente == null
            ? const Text(C.screenNuovoUtenti)
            : const Text(C.screenModificaUtente),
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextFormField(
                controller: nomeController,
                hintText: 'Nome',
                padding: const EdgeInsets.all(2),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return C.errNomeUtenteMancante;
                  }
                  return null;
                },
              ),
              MyTextFormField(
                controller: codiceFiscaleController,
                hintText: 'codice fiscale',
                padding: const EdgeInsets.all(2),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return C.errCodiceFiscaleMancante;
                  } else if (!value.isValidCodiceFiscale) {
                    return C.errCodiceFiscale;
                  }
                  return null;
                },
                formatters: [MyUpperCaseTextFormatter()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Colore personale'),
                  GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Scelta colore'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: _pickerColor,
                                  onColorChanged: (value) {
                                    _pickerColor = value;
                                  },
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: const Text(C.conferma))
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 26.0,
                        height: 26.0,
                        decoration: BoxDecoration(
                          color: _pickerColor,
                          shape: BoxShape.circle,
                        ),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_utente == null) {
                            var nuovoUtente = Utente(
                                nomeController.text,
                                codiceFiscaleController.text,
                                _pickerColor,
                                C.imgDefaultUtenteImage);
                            _controller.addUtente(nuovoUtente);
                          } else {
                            _utente!.nome = nomeController.text;
                            _utente!.codiceFiscale =
                                codiceFiscaleController.text;
                            _utente!.colore = _pickerColor;
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(C.conferma)),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(C.annulla))
                ],
              )
            ],
          )),
    );
  }
}
