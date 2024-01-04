import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';
import '/views/items/edit_item.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ViewItem extends StatefulWidget {
  final Item item;
  const ViewItem({Key? key, required this.item}) : super(key: key);

  @override
  ViewItemState createState() => ViewItemState();
}

class ViewItemState extends State<ViewItem> {
  Item? parentItem;
  Image? _backgroundImage;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    getParentItem();
    _fetchInitialData();
    if (widget.item.imageLGPath != null) {
      _backgroundImage = Image.network(
           buildImageUrl(widget.item.imageLGPath!),
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
    DateFormat dateFormat = DateFormat('yy-MM-dd'); // Example format
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
                actions: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.edit),
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
                  )
                ],
                floating: true,
                expandedHeight: 350,
                flexibleSpace: FlexibleSpaceBar(
                  background: FittedBox(
                  fit: BoxFit.cover,
                  child: _backgroundImage ?? const Icon(Icons.camera_alt)),
                title: Text(
                  widget.item.name
                ),
              )
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 160,
                  child: Column(
                    children: [
                      Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           'Last Update: ${formatDateTime(widget.item.lastUpdate!)}',
                         ),
                         Text(
                           'Created: ${formatDateTime(widget.item.creationDate!)}',
                         ),
                       ],
                        
                      ),
                      Row(
                        children: [
                          Card(
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 80,
                                height: 50, 
                                child: 
                                  Center(
                                    child: Column(
                                      children: [
                                        DefaultTextStyle.merge(
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          child: const Text("Barcode"),
                                        ),
                                        Text(widget.item.labelId.toString()),
                                      ],
                                    ),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 50, 
                                child: 
                                  Center(
                                    child: Column(
                                      children: [
                                        DefaultTextStyle.merge(
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          child: const Text("Parent Item"),
                                        ),
                                        Text(parentItem?.name ?? "No parent"),
                                      ],
                                    ),
                                ),
                              ),
                            ),
                          )
                        ]
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                        widget.item.comment ?? "No comment"),
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
                  return DecoratedSliver(
                    decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(48),
                        bottomRight: Radius.circular(48),
                        topLeft: Radius.circular(48), topRight: Radius.circular(48),
                      ),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 3.0),
                            child: ListTile(
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
                              leading: ClipOval(
                                child: _items[index].imageLGPath != null
                                  ? Image.network(buildImageUrl(_items[index].imageLGPath!))
                                  : const Icon(Icons.storage),
                              ),
                              trailing: const Icon(Icons.more_vert),
                            ),
                          );
                        },
                        childCount: _items.length
                      ),
                    )
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





