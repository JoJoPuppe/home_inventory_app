import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';

class SelectParentModal extends StatefulWidget {
  const SelectParentModal({Key? key}) : super(key: key);
  @override

  SelectParentModalState createState() => SelectParentModalState();
}

class SelectParentModalState extends State<SelectParentModal> {
  late Future<List<Item>> itemsFuture;
  List<dynamic> parentStack = [];

  void handleItemTap(Item item) {
    // parentStack.add(itemsFuture); // Save current list to the stack
    setState(() {
      itemsFuture = CreateItemService.getChildren(context, item.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Select Parent'),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            itemsFuture = CreateItemService.getChildren(context, null);
            return SizedBox(
              height: 500,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                FutureBuilder<List<Item>>(
                  future: itemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Item> items = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(items[index].name),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Item selected: ${items[index].name}'),
                                  ),
                                );
                              },
                              trailing: GestureDetector(
                                onTap: () => handleItemTap(items[index]),
                                child: const Icon(Icons.chevron_right),
                              ),
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
                ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () => Navigator.pop(context),
                ),
                ],
              )
            );
          }
        );
      }
    );
  }
}

