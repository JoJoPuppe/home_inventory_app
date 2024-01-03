import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';
import '/views/items/child_list.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class ViewItem extends StatefulWidget {
  final Item item;
  const ViewItem({Key? key, required this.item}) : super(key: key);

  @override
  ViewItemState createState() => ViewItemState();
}

class ViewItemState extends State<ViewItem> {
  Item? parentItem;
  Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    getParentItem();
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
      body: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Center(
                child: CircleAvatar(
                  radius: 80,
                  child: SizedBox(
                    height: 300,
                    width: 300,
                      child: ClipOval(
                        child: _backgroundImage ?? const Icon(Icons.camera_alt)
                      ),
                  ),
                ),
              ),
              const Text('Name'),
              Expanded(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Text(widget.item.name),
                  ),
              ),
              const Text('Comment'),
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      child: Text(widget.item.comment ?? ''),
                  ),
              ),
              const Text('Barcode'),
              Expanded(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      child: Text(widget.item.labelId.toString()),
                  ),
                  ),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              child: Center(
                child: parentItem == null ? const Text('No item selected') : Text(parentItem!.name),
              ),
            ),
            // if (_message.isNotEmpty)
            //   Text(_message),
          Expanded(
            child: ItemChildList(item: widget.item),
            ),
          ],
        ),
    );
  }
}





