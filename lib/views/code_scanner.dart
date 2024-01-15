import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:permission_handler/permission_handler.dart';
import '/models/item_model.dart';
import '/services/homeinventory_api_service.dart';
import '/widgets/goto_item_dialog.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({Key? key, this.goto = false}) : super(key: key);
  final bool goto;
  @override
  ScannerState createState() => ScannerState();
}

class ScannerState extends State<ScannerWidget> {
  Code? result;
  int successScans = 0;
  int failedScans = 0;
  Future<Item>? labelItem;

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
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            ReaderWidget(
              onScan: _onScanSuccess,
              onScanFailure: _onScanFailure,
            ),
            if (labelItem != null) labelItemFutureBuilder(constraints),
          ],
        );
      }),
    );
  }

  _onScanSuccess(Code? code) async {
    if (code?.text?.isNotEmpty == true) {
      if (widget.goto) {
        labelItem = CreateItemService.getItemByLabelCode(context, code!.text!);
      } else {
        Navigator.pop(context, code!.text!);
      }
    }
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

  FutureBuilder<Item> labelItemFutureBuilder(BoxConstraints constraints) {
    return FutureBuilder<Item>(
      future: labelItem,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return gotoItemDialog(
              context, constraints, "Item found!", snapshot.data!);
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return const LinearProgressIndicator();
        }
      },
    );
  }
}
