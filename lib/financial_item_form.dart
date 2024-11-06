import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    for (var category in categories.keys) {
      for (var subcategory in categories[category]!) {
        _items[category]![subcategory] = [];
      }
    }
    _loadHistory();
  }

  void _loadHistory() {
    // Load history from Hive or any persistent storage
    // This is a placeholder; implement as needed
     _history = _financialBox.get('history') ?? [];
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
    double totalIncome = 0.0;
    double totalExpenditure = 0.0;

    for (var category in _items.keys) {
      for (var subcategory in _items[category]!.keys) {
        for (var item in _items[category]![subcategory]!) {
          if (item['description'].isNotEmpty && item['amount'] > 0) {
            if (category == 'INCOME') {
              totalIncome += item['amount'];
            } else if (category == 'EXPENDITURE') {
              totalExpenditure += item['amount'];
            }
            // Save to Hive
            _financialBox.add({
              'heading': category,
              'subheading': subcategory,
              'description': item['description'],
              'amount': item['amount'],
              'timestamp': DateTime.now().toIso8601String(),
            });
          }
        }
      }
    }

    if (totalIncome > 0 || totalExpenditure > 0) {
      setState(() {
        _history.add({
          'totalIncome': totalIncome,
          'totalExpenditure': totalExpenditure,
          'timestamp': DateTime.now(),
        });
      });
    }

    widget.refreshItems();
    Navigator.of(context).pop();
  }

  double getSurplusOrDeficit() {
    double totalIncome = _history.fold(0, (sum, entry) => sum + entry['totalIncome']);
    double totalExpenditure = _history.fold(0, (sum, entry) => sum + entry['totalExpenditure']);
    return totalIncome - totalExpenditure;
  }

  Widget _buildSubcategory(String category, String subcategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subcategory, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DataTable(
          columns: [
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Actions')),
          ],
          rows : _items[category]![subcategory]!.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;
            return DataRow(cells: [
              DataCell(TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  item['description'] = value;
                },
              )),
              DataCell(TextField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  item['amount'] = double.tryParse(value) ?? 0.0;
                },
              )),
              DataCell(IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeField(category, subcategory, index),
              )),
            ]);
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () => _addField(category, subcategory),
          child: Text('Add Field'),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildHistoryTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Total Income')),
        DataColumn(label: Text('Total Expenditure')),
        DataColumn(label: Text('Surplus/Deficit')),
        DataColumn(label: Text('Actions')),
      ],
      rows: _history.map((entry) {
        return DataRow(cells: [
          DataCell(Text(DateFormat.yMMMd().format(entry['timestamp']))),
          DataCell(Text(entry['totalIncome'].toString())),
          DataCell(Text(entry['totalExpenditure'].toString())),
          DataCell(Text(getSurplusOrDeficit().toString())),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Implement repopulate logic here
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Implement delete logic here
                },
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }

  Future<void> printSelectedHistory() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Financial History', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              ..._history.map((entry) {
                return pw.Column(
                  children: [
                    pw.Text('Date: ${DateFormat.yMMMd().format(entry['timestamp'])}'),
                    pw.Text('Total Income: ${entry['totalIncome']}'),
                    pw.Text('Total Expenditure: ${entry['totalExpenditure']}'),
                    pw.Text('Surplus/Deficit: ${getSurplusOrDeficit()}'),
                    pw.Divider(),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void shareSelectedHistory() {
    StringBuffer shareContent = StringBuffer();
    
    shareContent.writeln('Financial History\n');
    
    for (var entry in _history) {
      shareContent.writeln('Date: ${DateFormat.yMMMd().format(entry['timestamp'])}');
      shareContent.writeln('Total Income: ${entry['totalIncome']}');
      shareContent.writeln('Total Expenditure: ${entry['totalExpenditure']}');
      shareContent.writeln('Surplus/Deficit: ${getSurplusOrDeficit()}');
      shareContent.writeln('\n');
    }
    
    Share.share(shareContent.toString());
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
              onPressed: () => _saveItems(),
              child: Text('Save All Items'),
            ),
            SizedBox(height: 24),
            Text('History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            buildHistoryTable(),
            ElevatedButton(
              onPressed: printSelectedHistory,
              child: Text('Print Selected'),
            ),
            ElevatedButton(
              onPressed: shareSelectedHistory,
              child: Text('Share Selected'),
            ),
          ],
        ),
      ),
    );
  }
}