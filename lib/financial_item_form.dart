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

  List<Map<String, dynamic>> _incomeItems = [];
  List<Map<String, dynamic>> _expenditureItems = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one empty field for income and expenditure
    _incomeItems.add({'subheading': '', 'amount': 0.0});
    _expenditureItems.add({'subheading': '', 'amount': 0.0});
  }

  void _addIncomeField() {
    setState(() {
      _incomeItems.add({'subheading': '', 'amount': 0.0});
    });
  }

  void _addExpenditureField() {
    setState(() {
      _expenditureItems.add({'subheading': '', 'amount': 0.0});
    });
  }

  void _saveItems() {
    // Save income items
    for (var item in _incomeItems) {
      if (item['subheading']!.isNotEmpty && item['amount'] > 0) {
        _financialBox.add({
          'heading': 'Income',
          'subheading': item['subheading'],
          'amount': item['amount'],
        });
      }
    }

    // Save expenditure items
    for (var item in _expenditureItems) {
      if (item['subheading']!.isNotEmpty && item['amount'] > 0) {
        _financialBox.add({
          'heading': 'Expenditure',
          'subheading': item['subheading'],
          'amount': item['amount'],
        });
      }
    }

    widget.refreshItems(); // Refresh the items in the home page
    Navigator.of(context).pop(); // Close the form
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INCOME',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ..._incomeItems.map((item) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Subheading'),
                    onChanged: (value) {
                      item['subheading'] = value;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      item['amount'] = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
              ],
            );
          }).toList(),
          ElevatedButton(
            onPressed: _addIncomeField,
            child: Text('Add Income Item'),
          ),
          SizedBox(height: 20),
          Text(
            'EXPENDITURE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ..._expenditureItems.map((item) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Subheading'),
                    onChanged: (value) {
                      item['subheading'] = value;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      item['amount'] = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
              ],
            );
          }).toList(),
          ElevatedButton(
            onPressed: _addExpenditureField,
            child: Text('Add Expenditure Item'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveItems,
            child: Text('Save Items'),
          ),
        ],
      ),
    );
  }
}