import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class StatementOfFinancialPosition extends StatefulWidget {
  @override
  _StatementOfFinancialPositionState createState() => _StatementOfFinancialPositionState();
}

class _StatementOfFinancialPositionState extends State<StatementOfFinancialPosition> {
  final _formKey = GlobalKey<FormState>();
  final _financialPositionBox = Hive.box('financial_position_box');

  String schoolName = '';
  DateTime asOfDate = DateTime.now();
  bool isEditing = false; // Track if we are editing or creating a new statement

  Map<String, List<Map<String, dynamic>>> financialData = {
    'Current Assets': [
      {'name': 'Cash and Cash Equivalents', 'value': 0.0},
      {'name': 'Accounts Receivable', 'value': 0.0},
      {'name': 'Inventory', 'value': 0.0},
      {'name': 'Prepaid Expenses', 'value': 0.0},
    ],
    'Non-Current Assets': [
      {'name': 'Property, Plant, and Equipment (Net)', 'value': 0.0},
      {'name': 'Investments', 'value': 0.0},
    ],
    'Current Liabilities': [
      {'name': 'Accounts Payable', 'value': 0.0},
      {'name': 'Short-Term Debt', 'value': 0.0},
      {'name': 'Accrued Expenses', 'value': 0.0},
    ],
    'Non-Current Liabilities': [
      {'name': 'Long-Term Debt', 'value': 0.0},
    ],
  };

  List<Map<String, dynamic>> savedStatements = [];

  @override
  void initState() {
    super.initState();
    _loadSavedStatements();
    _resetForm(); // Initialize the form with default values
  }

  void _loadSavedStatements() {
    savedStatements = _financialPositionBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _addField(String category) {
    setState(() {
      financialData[category]!.add({'name': '', 'value': 0.0});
    });
  }

  void _removeField(String category, int index) {
    setState(() {
      financialData[category]!.removeAt(index);
    });
  }

  double _calculateTotal(String category) {
    return financialData[category]!.fold(0.0, (sum, item) => sum + (item['value'] as double));
  }

  double _calculateNetAssets() {
    double totalAssets = _calculateTotal('Current Assets') + _calculateTotal('Non-Current Assets');
    double totalLiabilities = _calculateTotal('Current Liabilities') + _calculateTotal('Non-Current Liabilities');

    return totalAssets - totalLiabilities;
  }

  void _saveStatement() {
    if (_formKey.currentState!.validate()) {
      final statement = {
        'schoolName': schoolName,
        'asOfDate': asOfDate.toIso8601String(),
        'financialData': financialData,
      };
      _financialPositionBox.add(statement);
      _loadSavedStatements(); // Load updated statements
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Statement saved')));
      
      // Clear the form after saving
      _resetForm();
    }
  }

  Future<void> _printStatement() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Statement of Financial Position', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('School Name: $schoolName', style: pw.TextStyle(fontSize: 18)),
              pw.Text('As of Date: ${DateFormat('yyyy-MM-dd').format(asOfDate)}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Text('Assets', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('Current Assets:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...financialData['Current Assets']!.map((item) {
                return pw.Text('${item['name']}: ${item['value']}', style: pw.TextStyle(fontSize: 16));
              }).toList(),
              pw.Text('Non-Current Assets:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...financialData['Non-Current Assets']!.map((item) {
                return pw.Text('${item['name']}: ${item['value']}', style: pw.TextStyle(fontSize: 16));
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Text('Liabilities', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('Current Liabilities:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...financialData['Current Liabilities']!.map((item) {
                return pw.Text('${item['name']}: ${item['value']}', style: pw.TextStyle(fontSize: 16));
              }).toList(),
              pw.Text('Non-Current Liabilities:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...financialData['Non-Current Liabilities']!.map((item) {
                return pw.Text('${item['name']}: ${item['value']}', style: pw.TextStyle(fontSize: 16));
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Net Assets', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text('Net Assets (Assets - Liabilities): ${_calculateNetAssets()}', style: pw.TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  void _editStatement(Map<String, dynamic> statement) {
    setState(() {
      schoolName = statement['schoolName'];
      asOfDate = DateTime.parse(statement['asOfDate']);
      financialData = Map<String, List<Map<String, dynamic>>>.from(statement['financialData']);
      isEditing = true; // Set editing state
    });
  }

  void _createNewStatement() {
    _resetForm(); // Reset to default values
  }

  void _resetForm() {
    setState(() {
      schoolName = '';
      asOfDate = DateTime.now();
      financialData = {
        'Current Assets': [
          {'name': 'Cash and Cash Equivalents', 'value': 0.0},
          {'name': 'Accounts Receivable', 'value': 0.0},
          {'name': 'Inventory', 'value': 0.0},
          {'name': 'Prepaid Expenses', 'value': 0.0},
        ],
        'Non-Current Assets': [
          {'name': 'Property, Plant, and Equipment (Net)', 'value': 0.0},
          {'name': 'Investments', 'value': 0.0},
        ],
        'Current Liabilities': [
          {'name': 'Accounts Payable', 'value': 0.0},
          {'name': 'Short-Term Debt', 'value': 0.0},
          {'name': 'Accrued Expenses', 'value': 0.0},
        ],
        'Non-Current Liabilities': [
          {'name': 'Long-Term Debt', 'value': 0.0},
        ],
      };
      isEditing = false; // Reset editing state
    });
  }

  Widget buildHistoryTable() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: savedStatements.length,
      itemBuilder: (context, index) {
        final statement = savedStatements[index];
        return Card(
          child: ListTile(
            title: Text(statement['schoolName']),
            subtitle: Text('As of: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(statement['asOfDate']))}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editStatement(statement),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _financialPositionBox.deleteAt(index);
                    _loadSavedStatements(); // Refresh the list after deletion
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content
                    : Text('Statement deleted')));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statement of Financial Position'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: _printStatement,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('School Name:', style: TextStyle(fontSize: 18)),
                      TextFormField(
                        decoration: InputDecoration(labelText: ''),
                        initialValue: schoolName,
                        onChanged: (value) => setState(() => schoolName = value),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: asOfDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != asOfDate) setState(() => asOfDate = picked);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'As of Date'),
                          child: Text(DateFormat('yyyy-MM-dd').format(asOfDate)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Assets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Current Assets:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...financialData['Current Assets']!.map((item) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item['name'],
                                decoration: InputDecoration(labelText: 'Asset Name'),
                                onChanged: (value) {
                                  setState(() {
                                    item['name'] = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                initialValue: item['value'].toString(),
                                decoration: InputDecoration(labelText: 'Value'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    item['value'] = double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeField('Current Assets', financialData['Current Assets']!.indexOf(item)),
                            ),
                          ],
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () => _addField('Current Assets'),
                        child: Text('Add Current Asset'),
                      ),
                      Text('Non-Current Assets:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...financialData['Non-Current Assets']!.map((item) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item['name'],
                                decoration: InputDecoration(labelText: 'Asset Name'),
                                onChanged: (value) {
                                  setState(() {
                                    item['name'] = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                initialValue: item['value'].toString(),
                                decoration: InputDecoration(labelText: 'Value'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    item['value'] = double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeField('Non-Current Assets', financialData['Non-Current Assets']!.indexOf(item)),
                            ),
                          ],
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () => _addField('Non-Current Assets'),
                        child: Text('Add Non-Current Asset'),
                      ),
                      SizedBox(height: 20),
                      Text('Liabilities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Current Liabilities:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...financialData['Current Liabilities']!.map((item) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                              
                                initialValue: item['name'],
                                decoration: InputDecoration(labelText: 'Liability Name'),
                                onChanged: (value) {
                                  setState(() {
                                    item['name'] = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                initialValue: item['value'].toString(),
                                decoration: InputDecoration(labelText: 'Value'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    item['value'] = double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeField('Current Liabilities', financialData['Current Liabilities']!.indexOf(item)),
                            ),
                          ],
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () => _addField('Current Liabilities'),
                        child: Text('Add Current Liability'),
                      ),
                      Text('Non-Current Liabilities:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...financialData['Non-Current Liabilities']!.map((item) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item['name'],
                                decoration: InputDecoration(labelText: 'Liability Name'),
                                onChanged: (value) {
                                  setState(() {
                                    item['name'] = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                initialValue: item['value'].toString(),
                                decoration: InputDecoration(labelText: 'Value'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    item['value'] = double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeField('Non-Current Liabilities', financialData['Non-Current Liabilities']!.indexOf(item)),
                            ),
                          ],
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () => _addField('Non-Current Liabilities'),
                        child: Text('Add Non-Current Liability'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveStatement,
                        child: Text('Save Statement'),
                      ),
                      SizedBox(height: 20),
                      if (!isEditing) // Show this button only when not editing
                        ElevatedButton(
                          onPressed: _createNewStatement,
                          child: Text('Create New Statement'),
                        ),
                      SizedBox(height: 20),
                      Divider(thickness: 2),
                      SizedBox(height: 10),
                      Center(
                        child: Text("Net Assets", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text("Net Assets (Assets - Liabilities): ${_calculateNetAssets()}", style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(width: 2),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Saved Statements", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    buildHistoryTable(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}