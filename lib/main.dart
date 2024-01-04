import 'package:flutter/material.dart';
import 'views/settings/settings_screen.dart';
import 'views/items/add_item.dart';
import 'provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '/models/item_model.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/provider/camera_manager.dart';
import '/views/items/view_item.dart';

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
          seedColor: Colors.grey[100]!,
          brightness: Brightness.dark,
          surface: Colors.grey[100]!),
        useMaterial3: true,
      ),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: newItemListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyCustomForm(),
              settings: const RouteSettings(name: "/add_item")
            ),
          );
          
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewItem(
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
