import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:permission_handler/permission_handler.dart';



class ScannerWidget extends StatefulWidget {
  const ScannerWidget({Key? key}) : super(key: key);
  @override

  ScannerState createState() => ScannerState();
}


class ScannerState extends State<ScannerWidget> {
  Code? result;
  int successScans = 0;
  int failedScans = 0;

  void _checkPermissions() async {
    const permission = Permission.camera;
    if (await permission.isDenied) {
      await permission.request();
    }
  }


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

