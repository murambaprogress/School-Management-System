import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'financial_item_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _incomeItems = [];
  List<Map<String, dynamic>> _expenditureItems = [];
  final _financialBox = Hive.box('financial_box');

  @override
  void initState() {
    super.initState();
    _refreshItems(); // Load data when app starts
  }

  void _refreshItems() {
    final data = _financialBox.keys.map((key) {
      final value = _financialBox.get(key);
      return {
        "key": key,
        "heading": value["heading"],
        "subheading": value["subheading"],
        "amount": value["amount"],
      };
    }).toList();

    setState(() {
      _incomeItems = data.where((item) => item['heading'] == 'Income').toList();
      _expenditureItems = data.where((item) => item['heading'] == 'Expenditure').toList();
    });
  }

  Future<void> _deleteItem(int itemKey) async {
    await _financialBox.delete(itemKey);
    _refreshItems(); // Update the UI

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An item has been deleted')));
  }

  void _showForm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return FinancialItemForm(
          refreshItems: _refreshItems,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = _incomeItems.fold(0, (sum, item) => sum + item['amount']);
    double totalExpenditure = _expenditureItems.fold(0, (sum, item) => sum + item['amount']);
    double surplusOrDeficit = totalIncome - totalExpenditure;

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Financial Statement'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Income Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'INCOME',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._incomeItems.map((item) {
                  return ListTile(
                    title: Text(item['subheading']),
                    subtitle: Text('Amount: ${item['amount']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteItem(item['key']),
                    ),
                  );
                }).toList(),
                // Expenditure Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'EXPENDITURE',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._expenditureItems.map((item) {
                  return ListTile(
                    title: Text(item['subheading']),
                    subtitle: Text('Amount: ${item['amount']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteItem(item['key']),
                    ),
                  );
                }).toList(),
                // Surplus/Deficit Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'SURPLUS / DEFICIT',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Surplus/Deficit: ${surplusOrDeficit > 0 ? '+' : ''}$surplusOrDeficit',
                    style: TextStyle(fontSize: 18, color: surplusOrDeficit > 0 ? Colors.green : Colors.red),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showForm(context),
            child: const Text('Add Income/Expenditure'),
          ),
        ],
      ),
    );
  }
}