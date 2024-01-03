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
  String buttonText = "Select Parent";
  bool isButtonEnabled = false;
  Item? selectedItem;

  @override
  void initState() {
    super.initState();
    itemsFuture = CreateItemService.getChildren(context, null);
  }

  void handleItemTap(Item item) {
    parentStack.add(itemsFuture); // Save current list to the stack
    setState(() {
      itemsFuture = CreateItemService.getChildren(context, item.itemId);
    });
  }

  void handleBackTap() {
    if (parentStack.isNotEmpty) {
      setState(() {
        itemsFuture = parentStack.removeLast();
      });
    }
  }

  void updateButton(Item item) {
    setState(() {
      selectedItem = item;
      buttonText = item.name;
      isButtonEnabled = true;
    });
  }

  Widget _buildTrailingWidget(Item item) {
    if (item.hasChildren != null) {
      return item.hasChildren!
        ? GestureDetector(
            onTap: () => handleItemTap(item),
            child: const Icon(Icons.chevron_right),
          )
        : const Icon(Icons.circle);
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
                        onTap: () => updateButton(items[index]),
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
          ElevatedButton(
            onPressed: isButtonEnabled ? () => Navigator.pop(context, selectedItem) : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.grey;
                  }
                  return Colors.green; // Use the component's default.
                },
              ),
            ),
            child: Text(buttonText),
          ),
          ElevatedButton(
              child: const Text('Close BottomSheet'),
              onPressed: () => Navigator.pop(context),
            ),
          ElevatedButton(
              child: const Text('Back'),
              onPressed: () => handleBackTap(),
            ),
          ],
        )
      );
  }
}

