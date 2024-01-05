import 'package:flutter/material.dart';
import '/services/homeinventory_api_service.dart'; // Import the file where you define the API call
import '/models/item_model.dart';

// class SelectParentOpener extends StatelessWidget {
//   const SelectParentOpener({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return 
//     Row(
//       children: [
//         Expanded(
//           child: OutlinedButton.icon(
//             onPressed: () {
//               showModalBottomSheet<void>(
//                 context: context,
//                 builder: (context) => const _SelectParentContent());
//             },
//             icon: const Icon(Icons.arrow_drop_down),
//             label: const Text('Select Parent')
//           )
//         ),
//       ],
//     );
//   }
// }

class SelectParentContent extends StatefulWidget {
  const SelectParentContent({Key? key}) : super(key: key);
  @override

  SelectParentContentState createState() => SelectParentContentState();
}

class SelectParentContentState extends State<SelectParentContent> {
  late Future<List<Item>> itemsFuture;
  List<dynamic> parentStack = [];
  List<Item> parentNamesStack = [Item(itemId: 0, name: "Top Items")];
  String buttonText = "Select Parent";
  bool isButtonEnabled = false;
  Item? selectedItem;

  @override
  void initState() {
    super.initState();
    itemsFuture = CreateItemService.getChildren(context, null);
  }

  void handleItemTap(Item item) {
    if (item.hasChildren != null && !item.hasChildren!) {
      return;
    }
    parentStack.add(itemsFuture); // Save current list to the stack
    setState(() {
      parentNamesStack.add(item);
      itemsFuture = CreateItemService.getChildren(context, item.itemId);
    });
  }

  void handleBackTap() {
    if (parentStack.isNotEmpty) {
      setState(() {
        parentNamesStack.removeLast();
        itemsFuture = parentStack.removeLast();
      });
    }
    else {
      selectedItem = null;
    }
  }

  Widget? _buildTrailingWidget(Item item) {
    if (item.hasChildren != null) {
      return item.hasChildren!
        ? const Icon(Icons.chevron_right)
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
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => handleBackTap(),
                  ),
                  Text(parentNamesStack.last.name)
              ],
            ),
          ),
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

