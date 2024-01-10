import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';
import '/views/items/edit_item.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/views/items/list_item.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '/views/items/add_item.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class ViewItem extends StatefulWidget {
  final Item item;
  const ViewItem({Key? key, required this.item }) : super(key: key);

  @override
  ViewItemState createState() => ViewItemState();
}

class ViewItemState extends State<ViewItem> {
  List<dynamic> parentStack = [];
  final List<Item> itemStack = [];
  String? labelId;
  Image? _backgroundImage;
  Item? parentItem;
  String apiDomain = '';
  String name = '';
  late Item currentItem;
  List<Map<String, dynamic>> history = [];
  late Future<List<Item>> newItems;
  bool addItem = false;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    getParentItem(widget.item);
    _fetchInitialData();
    currentItem = widget.item;
    apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
    name = widget.item.name;
    labelId = widget.item.labelId == null ? "No barcode" : widget.item.labelId.toString();
    _backgroundImage = getBackgroundImage(widget.item);
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (parentStack.isNotEmpty && !addItem) {
      Map<String, dynamic> prevHistory = history.removeLast();
      currentItem = prevHistory["item"];
      setState(() {
        itemStack.removeLast();
        newItems = parentStack.removeLast();
        _backgroundImage = prevHistory["background_image"];
        labelId = prevHistory["label_id"];
        parentItem = prevHistory["parent_item"];
        newItems = CreateItemService.getChildren(context, currentItem.itemId);();
      });
      return true;
    } else {
      return false;
    }
  }

  Image? getBackgroundImage(Item item) {
    if (item.imageLGPath != null) {
      return Image.network(
           buildImageUrl(item.imageLGPath!),
           fit: BoxFit.fitWidth
           );
    }
    return null;
  }

  void getParentItem(Item item) async{
    if (item.parentItemId != null ) {
      Item newParentItem = await CreateItemService.getItem(context, item.parentItemId!);
      setState(() {
        parentItem = newParentItem;
      });
    }
  }

  void _onTapBreadCrumb(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewItem(item: item),
      )
    );
  }

  String buildImageUrl(String image) {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
    return "$apiDomain/$image";
  }

  Future<void> _fetchInitialData() async {
    newItems = CreateItemService.getChildren(context, widget.item.itemId);
  }

  String formatDateTime(DateTime dateTime) {
    DateFormat dateFormat = DateFormat('MM.dd.yy'); // Example format
    return dateFormat.format(dateTime);
  }

  void _onItemTap(Item item) {
    parentStack.add(newItems);
    history.add(
      {
        "parent_item": parentItem,
        "item": currentItem,
        "label_id": labelId,
        "background_image": _backgroundImage,
      }
    );
    final newBackgroundImage = getBackgroundImage(item);
    final newLabelId = item.labelId == null ? "No barcode" : item.labelId.toString();
    setState(() {
      _backgroundImage = newBackgroundImage;
      labelId = newLabelId;
      itemStack.add(currentItem);
      parentItem = currentItem;
      name = item.name;
      newItems = CreateItemService.getChildren(context, item.itemId);();
      currentItem = item;
    });
  }

  void _handleBack() {
    if (parentStack.isNotEmpty) {
      Map<String, dynamic> prevHistory = history.removeLast();
      currentItem = prevHistory["item"];
      setState(() {
        itemStack.removeLast();
        newItems = parentStack.removeLast();
        _backgroundImage = prevHistory["background_image"];
        labelId = prevHistory["label_id"];
        parentItem = prevHistory["parent_item"];
        newItems = CreateItemService.getChildren(context, currentItem.itemId);();
      });
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context, '/', (route) => false 
      );
    }
  }

  Future<void> _addNewItem(BuildContext context) async {
    addItem = true;
    // final addItemResult = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AddItem(parentItem: currentItem)
    //   ),
    // );
    final addItemResult = await PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AddItem(parentItem: currentItem),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.fade,
    );
    addItem = false;
    if (!mounted) return;
    if (addItemResult != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Added item: $addItemResult')));
        setState(() {
          newItems = CreateItemService.getChildren(context, currentItem.itemId);();
        });
    }
  }
  void _onSelected(String value) {
    switch (value) {
      case 'Edit':
        break;
      case 'Delete':
        break;
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
                leading: IconButton(
                  onPressed: () => _handleBack(),
                  icon: const Icon(Icons.arrow_back),),
                actions: [
                  PopupMenuButton<String>(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    onSelected: _onSelected,
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Details', 'Delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                    icon: const Icon(Icons.more_vert),
                  )
                ],
                pinned: true,
                floating: true,
                backgroundColor: Theme.of(context).colorScheme.background,
                expandedHeight: (MediaQuery.of(context).size.width - kToolbarHeight) * 0.8,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  background: Padding(
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.25,
                      MediaQuery.of(context).size.height * 0.05,
                      MediaQuery.of(context).size.width * 0.25,
                      MediaQuery.of(context).size.height * 0.08
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48.0),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: _backgroundImage ?? const Icon(Icons.camera_alt)),
                    ),
                  ),
                title: Text(
                  currentItem.name,
                ),
              )
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Column(
                    children: [
                      currentItem.parentItemId != null
                      ? Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8.0,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                             children: [ 
                               IconButton(
                                 icon: const Icon(Icons.home),
                                 onPressed: () {
                                   Navigator.of(context).pop();
                                 }
                               ),
                               ...itemStack.map((item) => 
                                 Row(
                                   children: [
                                     Icon(
                                           color: Theme.of(context).colorScheme.onSurfaceVariant,
                                     Icons.chevron_right),
                                     GestureDetector(
                                       onTap: () => _onTapBreadCrumb(item),
                                       child: Padding(
                                         padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                         child: Text(
                                           style: TextStyle(
                                               color: Theme.of(context).colorScheme.tertiary,
                                               fontSize: 20.0,
                                            ),
                                            item.name
                                          ),
                                       ),
                                     ),
                                     ],
                                )
                                ).toList(),
                              ],
                            ),
                          ),
                        ),
                      )
                      : const SizedBox(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                            widget.item.comment ?? "No comment"),
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: newItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    )
                  );
                }
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('No Child Items'),
                    )
                  );
                }
                if (snapshot.hasData) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        List<Item> items = snapshot.data!;
                        return ListItem(
                          item: items[index],
                          onTap: _onItemTap,
                          apiDomain: apiDomain,
                          context: context
                        );
                      },
                      childCount: snapshot.data!.length
                    ),
                  );
                } else {
                    return const SliverToBoxAdapter(
                      child: Text('No data'),
                  );
                }
              }
            )
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewItem(context);
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}





