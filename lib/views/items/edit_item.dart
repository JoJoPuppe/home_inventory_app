import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/code_scanner.dart';
import '/models/item_model.dart';
import '/views/items/select_parent.dart';
import 'dart:typed_data';
import '/views/camera/camera_view.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class EditItem extends StatefulWidget {
  final Item item;
  const EditItem({Key? key, required this.item}) : super(key: key);

  @override
  EditItemState createState() => EditItemState();
}

class EditItemState extends State<EditItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Item? parentItem;
  Item? initParentItem;
  final _formKey = GlobalKey<FormState>();
  Future<String>? _sendResopnse;
  Image? _backgroundImage;
  Uint8List? _updatedImage;
  bool nameUpdated = false;
  bool commentUpdated = false;
  bool codeUpdated = false;
  bool imageUpdated = false;
  bool parentUpdated = false;

  Map<String, dynamic> getUpdatedData() {
    Map<String, dynamic> updatedData = {};
    if (nameUpdated) {
      updatedData['name'] = _nameController.text;
    }
    if (commentUpdated) {
      updatedData['comment'] = _commentController.text;
    }
    if (codeUpdated) {
      updatedData['label_id'] = _codeController.text;
    }
    if (imageUpdated) {
      updatedData['image'] = _updatedImage;
    }
    if (parentUpdated) {
      updatedData['parent_item_id'] = parentItem?.itemId.toString();
    }
    return updatedData;
  }

  void _submitForm() async {
    final updatedData = getUpdatedData();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _sendResopnse = CreateItemService.updateItem(context, updatedData, widget.item.itemId);
        //   _isLoading = false;
        //   _message = response.success ? 'Request successful!' : 'Request failed.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getParentItem();
    _nameController.text = widget.item.name;
    _commentController.text = widget.item.comment ?? "";
    _codeController.text = widget.item.labelId == null ? "No barcode" : widget.item.labelId.toString();
    if (widget.item.imageLGPath != null) {
      _backgroundImage = Image.network(buildImageUrl(widget.item.imageLGPath!));
    }
    _nameController.addListener(() {
      if (_nameController.text != widget.item.name) {
        nameUpdated = true;
      }
    });
    _codeController.addListener(() {
      if (_codeController.text != widget.item.labelId.toString() && "No barcode" != widget.item.labelId.toString()) {
        codeUpdated = true;
      }
    });
    _commentController.addListener(() {
      if (_commentController.text != widget.item.comment) {
        commentUpdated = true;
      }
    });
  }

  void getParentItem() async{
    if (widget.item.parentItemId != null ) {
      Item newParentItem = await CreateItemService.getItem(context, widget.item.parentItemId!);
      setState(() {
        parentItem = newParentItem;
        initParentItem = newParentItem;
      });
    }
  }

  void _updateText(controller) {
    setState(() {
      controller.text;
    });
  }

  Future<void> _showEditDialog(TextEditingController controller) async {
    final startText = controller.text;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Text'),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                controller.text = startText;
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                _updateText(controller);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void openSelectParentModal() async {
    final Item? newItem = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return const SelectParentContent();
        });
    if (newItem != null) {
      setState(() {
        parentItem = newItem;
        if (parentItem?.itemId != initParentItem?.itemId) {
          parentUpdated = true;
        }
      });
    }
  }

  String buildImageUrl(String image) {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false)
        .currentSettings
        .serverURL;
    return "$apiDomain/$image";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Item"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48.0),
                  child: SizedBox(
                  height: 100,
                  width: 100,
                  child: _backgroundImage ?? const Icon(Icons.camera_alt)),
                ),
              ),
              ListTile(
                  leading: nameUpdated ? const Icon(Icons.check) : null,
                  title: const Text(
                        style: TextStyle(fontWeight: FontWeight.bold),'Name'),
                  subtitle: Text(_nameController.text),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditDialog(_nameController),
                ),
              ListTile(
                  leading: imageUpdated ? const Icon(Icons.check) : null,
                  title: const Text('Photo'),
                  subtitle: const Text('Retake photo'),
                  trailing: const Icon(Icons.camera_alt),
                  onTap: () async {
                    final Uint8List? squareImage = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TakePictureScreen(),
                        ));
                    if (squareImage != null) {
                      setState(() {
                        imageUpdated = true;
                        _backgroundImage = Image.memory(squareImage);
                        _updatedImage = squareImage;
                      });
                    }
                  },
                ),
              ListTile(
                  leading: commentUpdated ? const Icon(Icons.check) : null,
                  title: const Text('Comment'),
                  subtitle: Text(_commentController.text == '' ? 'No comment' : _commentController.text),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditDialog(_commentController),
                ),
              ListTile(
                  leading: codeUpdated ? const Icon(Icons.check) : null,
                  title: const Text('Barcode'),
                  subtitle: Text(_codeController.text),
                  trailing: const Icon(Icons.qr_code),
                  onTap: () async {
                    final code = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScannerWidget(),
                        ));
                    _codeController.text = code;
                  }
                ),
              ListTile(
                  leading: parentUpdated ? const Icon(Icons.check) : null,
                  title: const Text('Parent Item'),
                  subtitle: 
                    parentItem == null
                        ? const Text('No item selected')
                        : Text(parentItem!.name),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    openSelectParentModal();
                  },
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Center(child: Text('Update')),
                ),
              ),
              // if (_message.isNotEmpty)
              //   Text(_message),
              if (_sendResopnse != null) buildFutureBuilder(),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<String> buildFutureBuilder() {
    return FutureBuilder<String>(
      future: _sendResopnse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!);
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
