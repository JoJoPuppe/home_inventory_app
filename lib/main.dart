import 'package:flutter/material.dart';
import 'views/settings/settings_screen.dart';
import 'views/items/add_item.dart';
import 'provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '/models/item_model.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/provider/camera_manager.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const InventoryHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {

  Future<List<Item>> getAllItems() async {
    return CreateItemService.getItems(context);
  }

  String buildImageUrl(String image) {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
    return "$apiDomain/$image";
  }

  @override
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
      body: itemListWidget(),
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

  Widget itemListWidget() {
  return FutureBuilder(
    builder: (context, snapshot) {
      if (snapshot.data == null) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        return ListView.builder(
          padding: const EdgeInsets.all(2),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Item item = snapshot.data![index];
            return ListTile(
                title: Text(item.name),
                subtitle: Text(item.comment ?? ''),
                leading: item.imageSMPath != null
                    ? Image.network(buildImageUrl(item.imageSMPath!))
                    : const Icon(Icons.storage),
                isThreeLine: true,
                trailing: const Icon(Icons.more_vert),
              );
          },
        );
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      } else {
        return const Text('No data');
      }
    },
    future: CreateItemService.getItems(context),
  );
  }
}
