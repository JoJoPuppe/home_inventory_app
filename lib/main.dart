import 'package:flutter/material.dart';
import 'package:home_inventory_app/views/code_scanner.dart';
import 'views/settings/settings_screen.dart';
import 'views/items/add_item.dart';
import 'provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '/models/item_model.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/provider/camera_manager.dart';
import '/views/items/list_item.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

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
          seedColor: Colors.blue[100]!,
          brightness: Brightness.dark,
          background: Colors.blueGrey[900]!,
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

  String apiDomain = '';

  int selectedIndex = 0;
  int badge = 0;
  final padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12);
  double gap = 10;

  PageController controller = PageController();

  List<Color> colors = [
    Colors.purple,
    Colors.pink,
    Colors.amber[600]!,
    Colors.teal
  ];


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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  //ignore: must_call_super
  // Future<List<Item>>? _itemList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: PageView(
          onPageChanged: (page) {
            setState(() {
              selectedIndex = page;
            });
          },
          controller: controller,
          children: [
             newItemListWidget(),
             const AddItem(),
             const ScannerWidget(),
             const SettingsScreen(),
          ]
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              boxShadow: [
                BoxShadow(
                  spreadRadius: -10,
                  blurRadius: 60,
                  color: Colors.black.withOpacity(.4),
                  offset: const Offset(0, 25),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
              child: GNav(
                tabs: [
                  GButton(
                    gap: gap,
                    iconActiveColor: Colors.purple,
                    iconColor: Colors.black,
                    textColor: Colors.purple,
                    backgroundColor: Colors.purple.withOpacity(.2),
                    iconSize: 24,
                    padding: padding,
                    icon: LineIcons.home,
                    text: 'Home',
                  ),
                  GButton(
                    gap: gap,
                    iconActiveColor: Colors.pink,
                    iconColor: Colors.black,
                    textColor: Colors.pink,
                    backgroundColor: Colors.pink.withOpacity(.2),
                    iconSize: 24,
                    padding: padding,
                    icon: LineIcons.plusCircle,
                    leading: Icon(
                              LineIcons.heart,
                              color: selectedIndex == 1
                                  ? Colors.pink
                                  : Colors.black,
                            ),
                  ),
                  GButton(
                    gap: gap,
                    iconActiveColor: Colors.amber[600],
                    iconColor: Colors.black,
                    textColor: Colors.amber[600],
                    backgroundColor: Colors.amber[600]!.withOpacity(.2),
                    iconSize: 24,
                    padding: padding,
                    icon: LineIcons.search,
                    text: 'Search',
                  ),
                  GButton(
                    gap: gap,
                    iconActiveColor: Colors.teal,
                    iconColor: Colors.black,
                    textColor: Colors.teal,
                    backgroundColor: Colors.teal.withOpacity(.2),
                    iconSize: 24,
                    padding: padding,
                    icon: LineIcons.user,
                    leading: const CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                        'https://sooxt98.space/content/images/size/w100/2019/01/profile.png',
                      ),
                    ),
                    text: 'Sheldon',
                  )
                ],
                selectedIndex: selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                  controller.jumpToPage(index);
                },
              ),
            ),
          ),
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
            return ListItem(item: _items[index], apiDomain: apiDomain, context: context);
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


      // newItemListWidget(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const MyCustomForm(),
      //         settings: const RouteSettings(name: "/add_item")
      //       ),
      //     );
      //     
      //   },
      //   tooltip: 'Add Item',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
