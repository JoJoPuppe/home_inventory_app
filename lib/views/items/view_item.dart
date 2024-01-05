import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';
import '/views/items/edit_item.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/views/items/list_item.dart';

class ViewItem extends StatefulWidget {
  final Item item;
  const ViewItem({Key? key, required this.item}) : super(key: key);

  @override
  ViewItemState createState() => ViewItemState();
}

class ViewItemState extends State<ViewItem> {
  String? labelId;
  Item? parentItem;
  Image? _backgroundImage;
  String apiDomain = '';
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    getParentItem();
    _fetchInitialData();
    apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;

    labelId = widget.item.labelId == null ? "No barcode" : widget.item.labelId.toString();
      
    if (widget.item.imageLGPath != null) {
      _backgroundImage = Image.network(
           buildImageUrl(widget.item.imageLGPath!),
           fit: BoxFit.fitWidth
           );
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

  Future<List<Item>> getAllChildren() async {
    List<Item> insideItems = await CreateItemService.getChildren(context, widget.item.itemId);
    return insideItems;
  }

  Future<void> _fetchInitialData() async {
    final newItems = await getAllChildren();
    setState(() {
       _items = newItems;
    });
  }

  String formatDateTime(DateTime dateTime) {
    DateFormat dateFormat = DateFormat('MM.dd.yy'); // Example format
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
                pinned: true,
                floating: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false 
                      );
                    }
                  )
                ],
                backgroundColor: Theme.of(context).colorScheme.background,
                expandedHeight: (MediaQuery.of(context).size.width - kToolbarHeight) * 0.8,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                  background: Padding(
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.25,
                      MediaQuery.of(context).size.height * 0.05,
                      MediaQuery.of(context).size.width * 0.25,
                      MediaQuery.of(context).size.height * 0.05
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48.0),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: _backgroundImage ?? const Icon(Icons.camera_alt)),
                    ),
                  ),
                title: Text(
                  widget.item.name
                ),
              )
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Column(

                              children: [
                                const Icon(Icons.qr_code),
                                const SizedBox(width: 8),
                                Text(labelId ?? "No barcode")
                              ],
                          ),
                          Column(
                            children: [
                                const Icon(Icons.category),
                                const SizedBox(width: 8),
                                Text(
                                overflow: TextOverflow.ellipsis,
                                parentItem?.name ?? "No parent")
                            ]
                          ),
                          TextButton(
                          child: const Text("Details"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditItem(
                                      item: widget.item,
                                    )
                                  )
                                );
                              }
                            ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                            child: IconButton(
                              color: Theme.of(context).colorScheme.primary,
                              icon: const Icon(
                              Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditItem(
                                      item: widget.item,
                                    )
                                  )
                                );
                              }
                            ),
                          )
                        ]
                      ),
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
              future: getAllChildren(),
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
                        return ListItem(item: _items[index], apiDomain: apiDomain, context: context);
                      },
                      childCount: _items.length
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
    );
  }
}





