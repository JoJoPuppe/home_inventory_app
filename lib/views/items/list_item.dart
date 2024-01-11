import 'package:flutter/material.dart';
import '/views/items/edit_item.dart';
import '/models/item_model.dart';

class ListItem extends StatelessWidget {
  final Item item;
  final String apiDomain;
  final BuildContext context;
  final Function(Item) onTap;

  const ListItem({
    super.key,
    required this.item,
    required this.apiDomain,
    required this.context,
    required this.onTap,
  });

  String buildImageUrl(String image) {
    return "$apiDomain/$image";
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
        break;
    }
  }
// item.childrenCount != null && item.childrenCount! == 0
  @override
  Widget build(BuildContext context) {
    return 
    Ink(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        )
      ),
      child: InkWell(
        onTap: () => onTap(item),
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
                          ? Image.network(
                            buildImageUrl(item.imageLGPath!),
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) {
                                return child;
                              } else {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: frame == null
                                    ? const Icon(Icons.camera_alt)
                                    : child,
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  }
                                );
                              }
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else  {
                                return const Center(
                                child: CircularProgressIndicator()
                                );
                              }
                            }
                            )
                          : Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  item.childrenCount != null && item.childrenCount! == 0 
                  ? Text(item.name,
                  style: Theme.of(context).textTheme.titleMedium)
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                      style: Theme.of(context).textTheme.titleLarge),
                      Text("Items: ${item.childrenCount.toString()}"),
                    ]
                  ),
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
