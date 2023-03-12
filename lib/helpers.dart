import 'dart:convert';
import 'package:barcode_ricette/constants.dart';
import 'package:barcode_ricette/model/model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class DateFormatter {
  static String formatDate(DateTime d) {
    return "${d.day}-${d.month.toString().padLeft(2, '0')}-${d.year.toString().padLeft(2, '0')}";
  }
}

class FileManager {
  static final FileManager _fm = FileManager._private();

  FileManager._private();

  factory FileManager() => _fm;

  Future<bool> saveArchivioUtenti(ArchivioUtenti archivio) async {
    String archivioString = jsonEncode(archivio);
    try {
      final File archivioFile = await _archivioFile;
      await archivioFile.writeAsString(archivioString);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<ArchivioUtenti> loadArchivioUtenti() async {
    late ArchivioUtenti archivio;
    String? archivioString = await _readArchivioUtenti();
    if (archivioString != null) {
      archivio = ArchivioUtenti.fromJson(jsonDecode(archivioString));
    } else {
      archivio = ArchivioUtenti.empty();
    }
    return archivio;
  }

  Future<String> get _docPath async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  Future<File> get _archivioFile async {
    final path = await _docPath;
    return File('$path/${C.fileArchivioUtenti}');
  }

  Future<String?> _readArchivioUtenti() async {
    try {
      final File archivioFile = await _archivioFile;
      final String content = await archivioFile.readAsString();
      return content;
    } catch (e) {
      return null;
    }
  }
}

class SmsHelper {
  static final SmsHelper _instance = SmsHelper._private();
  final SmsQuery smsQuery = SmsQuery();

  SmsHelper._private();
  factory SmsHelper() => _instance;

  Future<bool> isSmsPermissionGranted() async {
    return await Permission.sms.request().isGranted;
  }

  Future<List<SmsMessage>> fetchSmsRicette() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      List<SmsMessage> messages =
          await smsQuery.querySms(kinds: [SmsQueryKind.inbox]);
      return _filterSmsRicette(messages);
    }
    throw Exception(C.smsPermissionNotGranted);
  }

  List<SmsMessage> _filterSmsRicette(List<SmsMessage> lsms) {
    final RegExp r = RegExp(C.regexpRicette);
    return lsms
        .where((sms) => sms.body != null && r.hasMatch(sms.body!))
        .toList();
  }
}
