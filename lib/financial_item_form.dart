import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FinancialItemForm extends StatefulWidget {
  final Function refreshItems;

  const FinancialItemForm({Key? key, required this.refreshItems}) : super(key: key);

  @override
  _FinancialItemFormState createState() => _FinancialItemFormState();
}

class _FinancialItemFormState extends State<FinancialItemForm> {
  final _financialBox = Hive.box('financial_box');

  final Map<String, List<String>> categories = {
    'INCOME': [
      'Department of Education and Science',
      'School Generated Income',
      'Other Income',
    ],
    'EXPENDITURE': [
      'Education – Teachers\' / Supervisors Salaries',
      'Education – Other Expenses',
      'Repairs, Maintenance and Establishment (RME)',
      'Administration',
      'Finance',
      'Depreciation',
    ],
  };

  Map<String, Map<String, List<Map<String, dynamic>>>> _items = {
    'INCOME': {},
    'EXPENDITURE': {},
  };

  @override
  void initState() {
    super.initState();
    for (var category in categories.keys) {
      for (var subcategory in categories[category]!) {
        _items[category]![subcategory] = [];
      }
    }
  }

  void _addField(String category, String subcategory) {
    setState(() {
      _items[category]![subcategory]!.add({
        'description': '',
        'amount': 0.0,
      });
    });
  }

  void _removeField(String category, String subcategory, int index) {
    setState(() {
      _items[category]![subcategory]!.removeAt(index);
    });
  }

  void _saveItems() {
    for (var category in _items.keys) {
      for (var subcategory in _items[category]!.keys) {
        for (var item in _items[category]![subcategory]!) {
          if (item['description'].isNotEmpty && item['amount'] > 0) {
            _financialBox.add({
              'heading': category,
              'subheading': subcategory,
              'description': item['description'],
              'amount': item['amount'],
            });
          }
        }
      }
    }
    widget.refreshItems();
    Navigator.of(context).pop();
  }

  Widget _buildSubcategory(String category, String subcategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subcategory, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ..._items[category]![subcategory]!.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onChanged: (value) {
                      item['description'] = value;
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      item['amount'] = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeField(category, subcategory, index),
                ),
              ],
            ),
          );
        }).toList(),
        ElevatedButton(
          onPressed: () => _addField(category, subcategory),
          child: Text('Add Field'),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...categories.entries.map((categoryEntry) {
              String category = categoryEntry.key;
              List<String> subcategories = categoryEntry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  ...subcategories.map((subcategory) => _buildSubcategory(category, subcategory)),
                  SizedBox(height: 24),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: _saveItems,
              child: Text('Save All Items'),
            ),
          ],
        ),
      ),
    );
  }
}