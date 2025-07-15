import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
// import 'package:shopping_list_app/models/grocery_item.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});
  
  @override
  State<NewItemScreen> createState() {
    return _NewStateItem();
  }
}

class _NewStateItem extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  var isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSending = true;
      });

      _formKey.currentState!.save();

      final url = Uri.https(
        'shopping-list-app-5a953-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.name,
          }
        )
      );

      final Map<String, dynamic> parsedRes = jsonDecode(response.body);

      if(!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: parsedRes['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(
                  label: const Text('Name'),
                ),
                validator: (value) {
                  if (value == null 
                    || value.isEmpty 
                    || value.trim().length <= 1 
                    || value.trim().length > 50
                  ) {
                    return 'Must be between 1 and 50';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        label: const Text('Quantity'),
                      ),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null 
                          || value.isEmpty 
                          || int.tryParse(value) == null
                          || int.tryParse(value)! <= 0
                        ) {
                          return 'Must be a valid positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                        DropdownMenuItem(
                          value: category.value,
                          child: Row(children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: category.value.color,
                            ),
                            SizedBox(width: 6),
                            Text(category.value.name)
                          ])
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    )
                  ),
                ],
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      isSending ? null : _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: isSending ? null : _saveItem,
                    child: isSending ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator()) : const Text('Add Item'),
                  ),
                ]
              )
            ]
          ),
        )
      ),
    );
  }
}