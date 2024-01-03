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

class ViewEditItem extends StatefulWidget {
  final Item item;
  const ViewEditItem({Key? key, required this.item}) : super(key: key);

  @override
  ViewEditItemState createState() => ViewEditItemState();
}

class ViewEditItemState extends State<ViewEditItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Item? selectedItem;
  final _formKey = GlobalKey<FormState>();
  Future<Map<String, bool>>? _sendResopnse;
  Image? _backgroundImage;

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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _commentController.text = widget.item.comment ?? "";
    _codeController.text = widget.item.labelId.toString();
    if (widget.item.imageLGPath != null) {
      _backgroundImage = Image.network(buildImageUrl(widget.item.imageLGPath!));
    }
    selectedItem = widget.item;
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
        selectedItem = newItem;
      });
    }
  }

  String buildImageUrl(String image) {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
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
              Center(
                child: CircleAvatar(
                  radius: 80,
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: GestureDetector(
                      child: ClipOval(
                        child: _backgroundImage ?? const Icon(Icons.camera_alt)
                      ),
                      onTap: () async {
                        final Uint8List? squareImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TakePictureScreen(),
                          )
                        );
                        if (squareImage != null) {
                          setState(() {
                            _backgroundImage = Image.memory(squareImage);
                          });
                        }
                    },
                  ),
                ),
              ),
              ),
              const Text('Name'),
              Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Text(_nameController.text),
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                        splashColor: Colors.blue,
                        borderRadius: BorderRadius.circular(32.0),
                        onTap: () => _showEditDialog(_nameController),
                        child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 32,
                        ),
                    ),
                  ),
                ]
              ),
              const Text('Comment'),
              Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      child: Text(_commentController.text),
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                        splashColor: Colors.blue,
                        borderRadius: BorderRadius.circular(32.0),
                        onTap: () => _showEditDialog(_commentController),
                        child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 32,
                        ),
                    ),
                  ),
                ]
              ),
              const Text('Comment'),
              Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      child: Text(_codeController.text),
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                        child: const Text('New Scan'),
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
                  ),
                ]
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
                child: const Text('Update'),
              ),
            ),
            // if (_message.isNotEmpty)
            //   Text(_message),
           if (_sendResopnse != null)
             buildFutureBuilder(),
          Expanded(
            child: ItemChildList(item: widget.item),
            ),
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





