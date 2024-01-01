import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/code_scanner.dart';
import '/views/camera/camera_view.dart';
import 'dart:typed_data';

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);
  @override

  MyCustomFormState createState() => MyCustomFormState();
}

class MyCustomFormState extends State<MyCustomForm> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<Map<String, bool>>? _sendResopnse;
  String _dropdownValue = 'Option 1';
  Uint8List? _backgroundImage;
  // bool _isLoading = false;
  // String _message = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // setState(() {
      //   _isLoading = true;
      // }); 
      // Perform the POST request
      setState(() {
        _sendResopnse = CreateItemService.addItem(
          context,
          {
            'comment': _dropdownValue,
            'name': _controller.text,
            'image': _backgroundImage,
        });
      //   _isLoading = false;
      //   _message = response.success ? 'Request successful!' : 'Request failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  _dropdownValue = newValue!;
                });
              },
              items: <String>['Option 1', 'Option 2', 'Option 3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Enter your text'),
              controller: _controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Enter your text'),
                    controller: _codeController,
                  ),
                ),
                ElevatedButton(
                  child: const Text('Scan'),
                  onPressed: () async {
                    final code = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScannerWidget(),
                      )
                    );
                    _codeController.text = code;
                  }
                )
              ]
            ),
            SizedBox(
              height: 80,
              width: 80,
              child: 
              IconButton(
                iconSize: 80,
                icon: _backgroundImage != null
                  ? Image.memory(_backgroundImage!)
                  : const Icon(Icons.camera_alt),
                onPressed: () async {
                  final Uint8List? squareImage = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TakePictureScreen(),
                    )
                  );
                  if (squareImage != null) {
                    setState(() {
                      _backgroundImage = squareImage;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ),
            // if (_message.isNotEmpty)
            //   Text(_message),
           if (_sendResopnse != null)
             buildFutureBuilder(),

          ],
        ),
      ),
    );
  }
  FutureBuilder<Map<String, bool>> buildFutureBuilder() {
    return FutureBuilder<Map<String, bool>>(
      future: _sendResopnse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.toString());
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}



