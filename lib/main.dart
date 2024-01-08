import 'package:flutter/material.dart';
import 'package:home_inventory_app/views/items/view_item.dart';
import 'views/settings/settings_screen.dart';
import 'views/items/add_item.dart';
import 'provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '/models/item_model.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/provider/camera_manager.dart';
import '/views/items/list_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SettingsProvider settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();
  await CameraManager.instance.init();
  runApp(
    ChangeNotifierProvider.value(
      value: settingsProvider,
      child: const HomeInventoryApp(),
    ),
  );
}

class HomeInventoryApp extends StatelessWidget {
  const HomeInventoryApp({Key? key}) : super(key: key); // Receive prefs
  // const HomeInventoryApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Inventory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue[900]!,
          brightness: Brightness.dark,


          // background: Colors.blueGrey[900]!,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      home: const InventoryHomePage(title: 'Home Inventory Overview'),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key, required this.title});

  final String title;

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  List<Item> _items = [];

  String apiDomain = '';


  Future<List<Item>> getAllItems() async {
    List<Item> insideItems = await CreateItemService.getChildren(context, null);
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
  void _onItemTap(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewItem(item: item),
      )
    );
  }
  //ignore: must_call_super
  // Future<List<Item>>? _itemList;
  void _searchModalOpen() async {
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
        title: Text(widget.title),
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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 0,
            child: FloatingActionButton(
              onPressed: _searchModalOpen,
              tooltip: 'Add Item',
              child: const Icon(Icons.add),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItem(),
                    settings: const RouteSettings(name: "/add_item")
                  ),
                );
                
              },
              tooltip: 'Add Item',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),

    );
  }

  Widget newItemListWidget() {
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
            return ListItem(item: _items[index], onTap: _onItemTap, apiDomain: apiDomain, context: context);
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
