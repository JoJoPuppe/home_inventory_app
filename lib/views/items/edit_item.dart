import 'dart:math';

import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/code_scanner.dart';
import '/models/item_model.dart';
import '/views/items/select_parent.dart';
import 'dart:typed_data';
import '/views/camera/camera_view.dart';
import '/views/items/child_list.dart';
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
  final _formKey = GlobalKey<FormState>();
  Future<Map<String, bool>>? _sendResopnse;
  Image? _backgroundImage;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _sendResopnse = CreateItemService.addItem(context, {
          'name': _nameController.text,
          'label_id': _codeController.text,
          'comment': _commentController.text,
          'image': _backgroundImage,
          'parent_item_id': parentItem?.itemId.toString(),
        });
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
    _codeController.text = widget.item.labelId.toString();
    if (widget.item.imageLGPath != null) {
      _backgroundImage = Image.network(buildImageUrl(widget.item.imageLGPath!));
    }
  }

  void getParentItem() async{
    if (widget.item.parentItemId != null ) {
      Item newParentItem = await CreateItemService.getItem(context, widget.item.parentItemId!);
      setState(() {
        parentItem = newParentItem;
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
        title: Text(widget.item.name),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: ListTile(
                  title: const Text('Name'),
                  subtitle: Text(_nameController.text),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditDialog(_nameController),
                ),
            ),
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: ListTile(
                  title: const Text('Foto'),
                  subtitle: const Text('Retake photo'),
                  trailing: 
                  SizedBox(
                    width: 40,
                    child: ClipOval(
                      child: _backgroundImage ?? const Icon(Icons.camera_alt),
                    ),
                  ),
                  onTap: () async {
                    final Uint8List? squareImage = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TakePictureScreen(),
                        ));
                    if (squareImage != null) {
                      setState(() {
                        _backgroundImage = Image.memory(squareImage);
                      });
                    }
                  },
                ),
            ),
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: ListTile(
                  title: const Text('Comment'),
                  subtitle: Text(_commentController.text),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditDialog(_commentController),
                ),
            ),
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: ListTile(
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
            ),
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: ListTile(
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
