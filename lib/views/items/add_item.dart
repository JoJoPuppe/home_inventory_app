import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/code_scanner.dart';
import '/views/camera/camera_view.dart';
import '/views/items/select_parent.dart';
import 'dart:typed_data';
import '/models/item_model.dart';

class AddItem extends StatefulWidget {
  final Item? parentItem;
  const AddItem({Key? key, this.parentItem}) : super(key: key);
  @override

  AddItemState createState() => AddItemState();
}

class AddItemState extends State<AddItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Item? selectedParentItem;
  String? _labelId;
  final _formKey = GlobalKey<FormState>();
  Future<String>? _sendResopnse;
  Uint8List? _backgroundImage;
  // bool _isLoading = false;
  // String _message = '';

  @override
  initState() {
    super.initState();
    setState(() {
      selectedParentItem = widget.parentItem;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _sendResopnse = CreateItemService.addItem(
          context,
          {
            'name': _nameController.text,
            'label_id': _labelId, 
            'comment': _commentController.text,
            'image': _backgroundImage,
            'parent_item_id': selectedParentItem?.itemId.toString(),
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
        selectedParentItem = newItem;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body:
      Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: 
                  IconButton(
                    iconSize: 80,
                    icon: _backgroundImage != null
                      ? Image.memory(_backgroundImage!)
                      : const Column(
                        children: [
                          Icon(Icons.camera_alt),
                          Text('Take a Picture'),
                        ],
                      ),
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
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  ),
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
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1),

                  // color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                     floatingLabelBehavior: FloatingLabelBehavior.never,
                     hintText: 'Write a comment',
                     contentPadding: EdgeInsets.all(15),
                     border: InputBorder.none
                   ),
                  controller: _commentController,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final code = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScannerWidget(),
                          )
                        );
                        setState(() {
                          _labelId = code;
                        });
                      },
                      icon: const Icon(Icons.qr_code),
                      label: _labelId == null ? const Text('Scan Barcode') : Text(_labelId!),
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: openSelectParentModal,
                      icon: const Icon(Icons.category),
                      label: selectedParentItem == null ? const Text('Select Parent') : Text(selectedParentItem!.name),
                    )
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryContainer)),
                            onPressed: _submitForm,
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // if (_message.isNotEmpty)
              //   Text(_message),
             if (_sendResopnse != null)
               buildFutureBuilder(),
          
            ],
          ),
        ),
      )
    );
  }
  FutureBuilder<String> buildFutureBuilder() {
    return FutureBuilder<String>(
      future: _sendResopnse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Navigator.pop(context, snapshot.data);
        } else if (snapshot.hasError) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('${snapshot.error}')));
          // return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}



