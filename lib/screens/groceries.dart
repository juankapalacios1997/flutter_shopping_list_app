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
  String? _error;

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

    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode >= 400) {
        throw Exception(
          'An error ocurred!'
        );
      }

      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }

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
    } catch(error) {
      setState(() {
        _error = 'Something went wrong. Please try again later.';
      });
    }
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
  }

  void removeItem(GroceryItem item) async{
    final index = groceryItems.indexOf(item);

    setState(() {
      groceryItems.remove(item);
    });

    final url = Uri.https(
      'shopping-list-app-5a953-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to remove data. Please try again later.'),
        duration: Duration(
          milliseconds: 2000,
        ),
      )
    );
      setState(() {
        groceryItems.insert(index, item);
      });
    }
    

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

    if (_error != null) {
      content = Center(
        child: Text(_error!),
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