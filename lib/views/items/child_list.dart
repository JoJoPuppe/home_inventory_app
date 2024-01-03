import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/items/view_edit_item.dart';
import '/models/item_model.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class ItemChildList extends StatefulWidget {
  const ItemChildList({super.key, required this.item});

  final Item item;

  @override
  State<ItemChildList> createState() => _ItemChildListState();
}

class _ItemChildListState extends State<ItemChildList> {
  List<Item> _items = [];

  Future<List<Item>> getAllItems() async {
    List<Item> insideItems = await CreateItemService.getChildren(context, widget.item.itemId);
    return insideItems;
  }

  String buildImageUrl(String image) {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
    return "$apiDomain/$image";
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final newItems = await getAllItems();
    setState(() {
       _items = newItems;
    });
  }
  //ignore: must_call_super
  // Future<List<Item>>? _itemList;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final newItems = await getAllItems();
        setState(() {
          _items = newItems;
        });
      },
      child: _items.isNotEmpty
      ? ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewEditItem(
                      item: _items[index],
                    )
                  )
                );
              },
              title: Text(_items[index].name),
              subtitle: Text(_items[index].comment ?? ''),
              leading: _items[index].imageSMPath != null
                  ? Image.network(buildImageUrl(_items[index].imageSMPath!))
                  : const Icon(Icons.storage),
              trailing: const Icon(Icons.more_vert),
            );
          },
        )
      : LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('There is not data.'),
                      Text('Pull to refresh.'),
                    ],
                  ),
                ),
              ),
            );
          },
        )
    );
  }
}
