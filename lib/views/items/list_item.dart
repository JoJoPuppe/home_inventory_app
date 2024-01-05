import 'package:flutter/material.dart';
import '/views/items/view_item.dart';
import '/views/items/edit_item.dart';
import '/models/item_model.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.item,
    required this.apiDomain,
    required this.context,
    this.chosenModel = 'Tesla Model S',
  });

  final Item item;
  final String apiDomain;
  final String chosenModel;
  final BuildContext context;

  String buildImageUrl(String image) {
    return "$apiDomain/$image";
  }

  void _viewItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewItem(item: item),
      ),
    );
  }

  void _onSelected(String value) {
    switch (value) {
      case 'Edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditItem(item: item),
          ),
        );
        break;
      case 'Delete':
        print('Delete');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Ink(
        decoration: const BoxDecoration(
          color: Colors.transparent ,
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(25),
          ),
          onTap: _viewItem,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child:
                            item.imageLGPath != null
                            ? Image.network(buildImageUrl(item.imageLGPath!))
                            : Container(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              child: const Icon(Icons.camera_alt),
                            ),
                          ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(item.name),
                  ],
                ),
                PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  onSelected: _onSelected,
                  itemBuilder: (BuildContext context) {
                    return {'Edit', 'Delete'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                  icon: const Icon(Icons.more_vert),
                )
            ]
          ),
        )
        ),
    );
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ViewItem(
      //         item: item,
      //       )
      //     )
      //   );
      // },
      // title: Text(item.name),
      // leading: 
      // ClipOval(
      //   child: item.imageLGPath != null
      //     ? Image.network(buildImageUrl(item.imageLGPath!))
      //     : const Icon(Icons.storage),
      // ),
      // trailing: const Icon(Icons.more_vert),
  }
}
