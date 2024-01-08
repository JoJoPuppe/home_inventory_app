import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';
import '/models/search_result.dart';

class SearchModalContent extends StatefulWidget {
  const SearchModalContent({Key? key}) : super(key: key);
  @override

  SearchModalContentState createState() => SearchModalContentState();
}

class SearchModalContentState extends State<SearchModalContent> {
  late Future<List<SearchResult>> itemsFuture;
  Item? selectedItem;

  @override
  void initState() {
    super.initState();
    itemsFuture = CreateItemService.searchItems(context, null);
  }

  void handleItemTap(Item item) {
    if (item.childrenCount != null && item.childrenCount! == 0) {
      return;
    }
  }

  Widget? _buildTrailingWidget(Item item) {
    if (item.childrenCount != null) {
      return item.childrenCount! > 0
        ? SizedBox(
          width: 100,
          child: Row(
            children: [
              Text(item.childrenCount.toString()),
              const Icon(Icons.chevron_right),
            ],
          ),
        )
        : null;
    } else {
      return const Icon(Icons.arrow_drop_up);
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
      SizedBox(
        height: 500,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
          FutureBuilder<List<SearchResult>>(
            future: itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<SearchResult> items = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index].name),
                        onTap: () => handleItemTap(items[index]),
                        onLongPress: () => Navigator.pop(context,items[index]),
                        trailing: _buildTrailingWidget(items[index]),
                      );
                    },
                  )
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text('Hold long to select parent.')
            ),
          )
          ],
        )
      );
  }
}

