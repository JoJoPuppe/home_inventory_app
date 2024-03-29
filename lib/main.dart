import 'package:flutter/material.dart';
import 'provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '/provider/camera_manager.dart';
import '/views/home/home.dart';
import 'views/items/search_view.dart';
import '/views/code_scanner.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
      debugShowCheckedModeBanner: false,
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
      home: const InventoryHomePage(title: 'Home Inventory'),
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
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      navBarHeight: 60,
      context,
      backgroundColor: Theme.of(context).colorScheme.background,
      controller: _controller,
      popAllScreensOnTapAnyTabs: true,
      screens: const [
        HomeView(),
        ScannerWidget(goto: true),
        SearchView(),
      ],
      items: _navBarItems(),
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      navBarStyle: NavBarStyle.style2,
    );
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Theme.of(context).colorScheme.surfaceVariant,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.qr_code),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Theme.of(context).colorScheme.surfaceVariant,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Theme.of(context).colorScheme.surfaceVariant,
      ),
    ];
  }
}
