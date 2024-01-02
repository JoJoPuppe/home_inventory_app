import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';

class SelectParentModal extends StatefulWidget {
  const SelectParentModal({Key? key}) : super(key: key);
  @override

  SelectParentModalState createState() => SelectParentModalState();
}

class SelectParentModalState extends State<SelectParentModal> {
  late Future<List<Item>> items;
  List<dynamic> parentStack = [];

  @override
  void initState() {
    super.initState();
    items = CreateItemService.getChildren(context, null);
  }

  void handleItemTap(Item item) {
    parentStack.add(items); // Save current list to the stack
    items = CreateItemService.getChildren(context, item.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Select Parent'),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 500,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                FutureBuilder<List<Item>>(
                  future: items,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Item> items = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(items[index].name),
                              onTap: () => handleItemTap(items[index]),
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

