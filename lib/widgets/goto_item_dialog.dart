import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '/views/items/view_item.dart';
import '/models/item_model.dart';

Widget gotoItemDialog(BuildContext context, BoxConstraints constraints,
    String message, Item item) {
  return Container(
    color: Colors.black.withOpacity(0.7),
    height: constraints.maxHeight,
    width: constraints.maxWidth,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Theme.of(context).colorScheme.surface,
            ),
            width: double.infinity,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 30,
                      child: Icon(Icons.check_circle_outlined,
                          size: 36, color: Colors.white)),
                  Text(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.green,
                      ),
                      message),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      minimumSize: MaterialStateProperty.all(
                        const Size.fromHeight(40),
                      ),
                    ),
                    onPressed: () => PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ViewItem(item: item),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
                    child: const Text(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      "Show Item",
                    ),
                  ),
                ],
              ),
            )),
      ),
    ),
  );
}
