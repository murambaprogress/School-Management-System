import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _financialBox = Hive.box('financial_box');

  // Color scheme
  final Color _backgroundColor = Color(0xFFE8F5E9);  // Light Green
  final Color _primaryColor = Color(0xFF4CAF50);  // Green
  final Color _secondaryColor = Color(0xFF2196F3);  // Blue
  final Color _textColor = Color(0xFF333333);  // Dark Grey
  final Color _cardColor = Colors.white;

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
    _refreshItems();
  }

  void _refreshItems() {
    final data = _financialBox.values.toList();
    setState(() {
      _items = {
        'INCOME': {},
        'EXPENDITURE': {},
      };
      for (var category in categories.keys) {
        for (var subcategory in categories[category]!) {
          _items[category]![subcategory] = [];
        }
      }
      for (var item in data) {
        String heading = item['heading'];
        String subheading = item['subheading'];
        _items[heading]![subheading]!.add({
          'key': item['key'],
          'description': item['description'],
          'amount': item['amount'],
        });
      }
    });
  }

  void _addField(String category, String subcategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String description = '';
        double amount = 0.0;
        return AlertDialog(
          title: Text('Add $category Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (description.isNotEmpty && amount > 0) {
                  _financialBox.add({
                    'heading': category,
                    'subheading': subcategory,
                    'description': description,
                    'amount': amount,
                  });
                  _refreshItems();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(int itemKey) async {
    await _financialBox.delete(itemKey);
    _refreshItems();
  }

  Widget _buildSubcategory(String category, String subcategory) {
    return Card(
      elevation: 2,
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subcategory, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
            ..._items[category]![subcategory]!.map((item) {
              return ListTile(
                title: Text(item['description'], style: TextStyle(color: _textColor)),
                subtitle: Text('Amount: ${item['amount']}', style: TextStyle(color: _secondaryColor)),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(item['key']),
                ),
              );
            }).toList(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _addField(category, subcategory),
              child: Text('Add Field'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = _items['INCOME']!.values
        .expand((items) => items)
        .fold(0, (sum, item) => sum + (item['amount'] as num));
    double totalExpenditure = _items['EXPENDITURE']!.values
        .expand((items) => items)
        .fold(0, (sum, item) => sum + (item['amount'] as num));
    double surplusOrDeficit = totalIncome - totalExpenditure;

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Financial Statement'),
        backgroundColor: _primaryColor,
      ),
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
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
                    Text(category, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryColor)),
                    SizedBox(height: 16),
                    ...subcategories.map((subcategory) => _buildSubcategory(category, subcategory)),
                    SizedBox(height: 24),
                  ],
                );
              }).toList(),
              Card(
                elevation: 2,
                color: _cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SURPLUS / DEFICIT',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryColor),
                      ),
                      Text(
                        'Total Income: $totalIncome',
                        style: TextStyle(fontSize: 18, color: _textColor),
                      ),
                      Text(
                        'Total Expenditure: $totalExpenditure',
                        style: TextStyle(fontSize: 18, color: _textColor),
                      ),
                      Text(
                        'Surplus/Deficit: ${surplusOrDeficit > 0 ? '+' : ''}$surplusOrDeficit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: surplusOrDeficit > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}