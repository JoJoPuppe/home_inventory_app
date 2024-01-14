import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '/views/items/view_item.dart';
import 'dart:async';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);
  @override

  SearchViewState createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  Timer? searchDebounce;
  final TextEditingController _queryController = TextEditingController();
  Future<List<Item>>? searchItemsFuture;
  Item? selectedItem;
  bool firstLoad = true;

  @override
  void initState() {
    super.initState();
    // searchItemsFuture = CreateItemService.searchItems(context, null);
  }

  void _handleTap(Item item) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewItem(item: item)));
  }

  Future<List<Item>> onSearchChanged(String query) {
    Completer<List<Item>> completer = Completer();
    firstLoad = false;
    if (searchDebounce?.isActive ?? false) searchDebounce!.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 500), () {
      CreateItemService.searchItems(context, query).then((result) {
        completer.complete(result);
      }).catchError((error) {
        completer.completeError(error);
      });
    });

    return completer.future;
  }

  String buildImageUrl(String image) {
    String apiDomain = Provider.of<SettingsProvider>(context, listen: false).currentSettings.serverURL;
    return "$apiDomain/$image";
  }

  Widget? _buildLeadingWidget(Item item) {
    if (item.imageSMPath != null) {
      return CircleAvatar(
        radius: 25,
        child: Image.network(buildImageUrl(item.imageSMPath!)));
    } else {
      return const Icon(Icons.circle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                       floatingLabelBehavior: FloatingLabelBehavior.never,
                       hintText: 'Search Item',
                       contentPadding: EdgeInsets.all(15),
                       border: InputBorder.none
                     ),
                    controller: _queryController,
                    onChanged: (value) {
                      setState(() {
                        searchItemsFuture = onSearchChanged(value);
                      });
                    },
                  ),
                ),
              !firstLoad
              ? FutureBuilder<List<Item>>(
                future: searchItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Item> items = snapshot.data!;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: _buildLeadingWidget(items[index]),
                            title: Text(items[index].name),
                            subtitle: Text(items[index].comment ?? ''),
                            onTap: () => _handleTap(items[index]),
                          );
                        },
                      )
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                },
              )
              : const Center(child: 
                  Column(
                    children: [
                      SizedBox(height: 50),
                      Icon(Icons.search, size: 100),
                      Text("Search for Items"),
                    ],
                  )
              ),
              ],
            ),
          ),
        ),
      );
  }
  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}

