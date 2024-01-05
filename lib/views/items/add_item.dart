import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/code_scanner.dart';
import '/views/camera/camera_view.dart';
import '/views/items/select_parent.dart';
import 'dart:typed_data';
import '/models/item_model.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);
  @override

  AddItemState createState() => AddItemState();
}

class AddItemState extends State<AddItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Item? selectedItem;
  final _formKey = GlobalKey<FormState>();
  Future<Map<String, bool>>? _sendResopnse;
  Uint8List? _backgroundImage;
  // bool _isLoading = false;
  // String _message = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _sendResopnse = CreateItemService.addItem(
          context,
          {
            'name': _nameController.text,
            'label_id': _codeController.text,
            'comment': _commentController.text,
            'image': _backgroundImage,
            'parent_item_id': selectedItem?.itemId.toString(),
        });
      //   _isLoading = false;
      //   _message = response.success ? 'Request successful!' : 'Request failed.';
      });
    }
  }

  void openSelectParentModal() async {
    final Item? newItem = await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return const SelectParentContent();
    });
    if (newItem != null) {
      setState(() {
        selectedItem = newItem;
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Colors.blueGrey[800]!,
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                     floatingLabelBehavior: FloatingLabelBehavior.never,
                     hintText: 'Enter the name of the item',
                     contentPadding: EdgeInsets.all(15),
                     border: InputBorder.none
                   ),
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Comment'),
                controller: _commentController,
                validator: (value) {
                  return null;
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Barcode'),
                      controller: _codeController,
                      validator: (value) {
                        //validate only numbers
                        if (value != null && value.isNotEmpty) {
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                        }
                      }
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: openSelectParentModal,
                      icon: const Icon(Icons.arrow_drop_down),
                      label: const Text('Select Parent')
                    )
                  ),
                ],
              ),
              DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                child: Center(
                  child: selectedItem == null ? const Text('No item selected') : Text(selectedItem!.name),
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



