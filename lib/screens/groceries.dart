import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';

import 'package:shopping_list_app/screens/new_item.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/grocery_list.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() {
    return _GroceriesScreenState();
  }
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<GroceryItem> groceryItems = [];

  var isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async{
    final url = Uri.https(
      'shopping-list-app-5a953-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    
    final response = await http.get(
      url,
    );

    final Map<String, dynamic> parsedRes = jsonDecode(response.body);

    final List<GroceryItem> loadedItems = [];

    for (final item in parsedRes.entries) {
      final category = categories.entries.firstWhere((element) =>
        element.value.name == item.value['category']
      ).value;


      loadedItems.add(GroceryItem(
        id: item.key, 
        name: item.value['name'], 
        quantity: item.value['quantity'], 
        category: category,
      ));
    }

    setState(() {
      groceryItems = loadedItems;
      isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItemScreen(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      groceryItems.add(newItem);
    });

    // _loadItems();
  }

  void removeItem(GroceryItem item) {
    setState(() {
      groceryItems.remove(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed!'),
        duration: Duration(
          milliseconds: 2000,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('You have not added any data'),
    );

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (groceryItems.isNotEmpty) {
      content = GroceryList(
        list: groceryItems,
        onDismiss: removeItem,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: content
    );
  }
}