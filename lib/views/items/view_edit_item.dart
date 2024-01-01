import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/code_scanner.dart';

class ViewEditItem extends StatefulWidget {
  const ViewEditItem({Key? key}) : super(key: key);
  @override

  ViewEditItemState createState() => ViewEditItemState();
}

class ViewEditItemState extends State<ViewEditItem> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Future<Map<String, bool>>? _sendResponse;
  String _dropdownValue = 'Option 1';
  // bool _isLoading = false;
  // String _message = '';

  void _submitForm() async {
      setState(() {
        _sendResponse = CreateItemService.createItem(
          context,
          {
            'comment': _dropdownValue,
            'name': _controller.text,
        });


      //   _isLoading = false;
      //   _message = response.success ? 'Request successful!' : 'Request failed.';
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: 
        Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ),
            // if (_message.isNotEmpty)
            //   Text(_message),
           if (_sendResponse != null)
             buildFutureBuilder(),

          ],
        ),
    );
  }
  FutureBuilder<Map<String, bool>> buildFutureBuilder() {
    return FutureBuilder<Map<String, bool>>(
      future: _sendResponse,
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



