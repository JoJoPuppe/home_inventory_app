import 'package:flutter/material.dart';
import '/views/items/list_item.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/views/items/view_item.dart';
import '/models/item_model.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '/views/settings/settings_screen.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
  void _onItemTap2(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewItem(item: item),
      )
    );
  }
  // void _onItemTap(Item item) {
  //   PersistentNavBarNavigator.pushNewScreen(
  //     widget.tabContext ?? context,
  //     screen: ViewItem(item: item),
  //     withNavBar: true,
  //     pageTransitionAnimation: PageTransitionAnimation.fade,
  //   );
  // }
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
            return ListItem(item: _items[index], onTap: _onItemTap2, apiDomain: apiDomain, context: context);
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

