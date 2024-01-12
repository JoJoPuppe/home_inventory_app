import 'package:flutter/material.dart';
import '/views/items/list_item.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/items/add_item.dart';
import '/views/items/view_item.dart';
import '/models/item_model.dart';
import '/views/items/edit_item.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '/views/settings/settings_screen.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<Item> _items = [];
  String apiDomain = '';

  Future<List<Item>> getAllItems() async {
    Future<List<Item>> insideItems = CreateItemService.getChildren(context, null);
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
    apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
  }

  Future<void> _fetchInitialData() async {
    final newItems = await getAllItems();
    setState(() {
       _items = newItems;
    });
  }
  void _onItemTap2(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewItem(item: item),
      )
    );
  }
  void _onEdit(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditItem(item: item)),
    );
  }
  void _notify(String message) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text(message)));
  }

  void _onDelete(Item item) async {
    Item deletedItem = await CreateItemService.deleteItem(context, item.itemId);
    _notify("Item ${deletedItem.name} deleted.");
    _fetchInitialData();
  }

  Future<void> _addNewItem(BuildContext context) async {
    final addItemResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItem()
      ),
    );
    if (!mounted) return;
    if (addItemResult != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Added item: $addItemResult')));
    }
    _refreshIndicatorKey.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Inventory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                )
              );
            }
          )
        ]
      ),
      body: newItemListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewItem(context);
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),

    );
  }
  Widget newItemListWidget() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
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
            return ListItem(item: _items[index],
              onEdit: _onEdit, onDelete: _onDelete, onTap: _onItemTap2, apiDomain: apiDomain, context: context);
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

