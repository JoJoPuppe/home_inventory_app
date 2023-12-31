import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';


class ScannerWidget extends StatefulWidget {
  const ScannerWidget({Key? key}) : super(key: key);
  @override

  ScannerState createState() => ScannerState();
}


class ScannerState extends State<ScannerWidget> {
  Code? result;
  int successScans = 0;
  int failedScans = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
      ),
      body: ReaderWidget(
        onScan: _onScanSuccess,
        onScanFailure: _onScanFailure,
          
      ),
    );
  }

  _onScanSuccess(Code? code) {
    setState(() {
      successScans++;
      if (code?.text?.isNotEmpty == true) {
        Navigator.pop(context, code?.text);
      }
    });
  }

  _onScanFailure(Code? code) {
    setState(() {
      failedScans++;
      result = code;
    });
    if (code?.error?.isNotEmpty == true) {
      _showMessage(context, 'Error: ${code?.error}');
    }
  }
  _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

}

