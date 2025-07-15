import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({
    super.key,
    required this.list,
    required this.onDismiss,
  });

  final List<GroceryItem> list;

  final void Function(GroceryItem) onDismiss;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(list[index].id),
        onDismissed: (direction) {
          onDismiss(list[index]);
        },
        child: ListTile(
          title: Text(list[index].name),
          leading: Container(
            width: 24,
            height: 24,
            color: list[index].category.color,
          ),
          trailing: Text(list[index].quantity.toString()),
        ),
      )
    );
  }
}