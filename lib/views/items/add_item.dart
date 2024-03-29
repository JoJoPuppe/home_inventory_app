import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/code_scanner.dart';
import '/views/camera/camera_view.dart';
import '/views/items/select_parent.dart';
import 'dart:typed_data';
import '/models/item_model.dart';
import '/widgets/home_dialog.dart';

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
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _sendResopnse = CreateItemService.addItem(context, {
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
      appBar: AppBar(title: const Text('Add Item'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: FilledButton(
            onPressed: _submitForm,
            child: const Row(
              children: [
                Icon(Icons.check),
                SizedBox(width: 5),
                Text('Save'),
              ],
            ),
          ),
        )
      ]),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: SizedBox(
                                height: 110,
                                width: 210,
                                child: IconButton(
                                  iconSize: 60,
                                  icon: _backgroundImage != null
                                      ? Image.memory(_backgroundImage!)
                                      : const Column(
                                          children: [
                                            Icon(Icons.camera_alt),
                                            Text('Take a Picture'),
                                          ],
                                        ),
                                  onPressed: () async {
                                    final Uint8List? squareImage =
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TakePictureScreen(),
                                            ));
                                    if (squareImage != null) {
                                      setState(() {
                                        _backgroundImage = squareImage;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  hintText: 'Enter the name of the item',
                                  contentPadding: EdgeInsets.all(15),
                                  border: InputBorder.none),
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 1),
                              // color: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  hintText: 'Write a comment',
                                  contentPadding: EdgeInsets.all(15),
                                  border: InputBorder.none),
                              controller: _commentController,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: OutlinedButton.icon(
                                onPressed: () async {
                                  final code = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ScannerWidget(),
                                      ));
                                  setState(() {
                                    _labelId = code;
                                  });
                                },
                                icon: const Icon(Icons.qr_code),
                                label: _labelId == null
                                    ? const Text('Scan Barcode')
                                    : Text(_labelId!),
                              )),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: OutlinedButton.icon(
                                onPressed: openSelectParentModal,
                                icon: const Icon(Icons.category),
                                label: selectedParentItem == null
                                    ? const Text('Select Parent')
                                    : Text(
                                        "Parent: ${selectedParentItem!.name}"),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_sendResopnse != null) buildFutureBuilder(constraints),
            ],
          );
        }),
      ),
    );
  }

  FutureBuilder<String> buildFutureBuilder(BoxConstraints constraints) {
    return FutureBuilder<String>(
      future: _sendResopnse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return homeDialog(context, constraints, "Item added successfully");
        } else if (snapshot.hasError) { 
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return const LinearProgressIndicator();
        }
      },
    );
  }

  Widget buildResulPopUp() {
    return AlertDialog(
        title: const Text('Result'),
        content: const Text("Item added successfully"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          )
        ]);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
