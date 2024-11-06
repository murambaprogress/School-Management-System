import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class CashFlowStatement extends StatefulWidget {
  @override
  _CashFlowStatementState createState() => _CashFlowStatementState();
}

class _CashFlowStatementState extends State<CashFlowStatement> {
  // Lists to hold the cash inflows and outflows
  List<Map<String, dynamic>> operatingInflows = [];
  List<Map<String, dynamic>> operatingOutflows = [];
  List<Map<String, dynamic>> investingInflows = [];
  List<Map<String, dynamic>> investingOutflows = [];
  List<Map<String, dynamic>> financingInflows = [];
  List<Map<String, dynamic>> financingOutflows = [];
  
  // List to hold saved statements
  List<Map<String, dynamic>> savedStatements = [];

  // Methods to add new fields
  void _addOperatingInflows() {
    setState(() {
      operatingInflows.add({'description': '', 'amount': 0.0});
    });
  }

  void _addOperatingOutflows() {
    setState(() {
      operatingOutflows.add({'description': '', 'amount': 0.0});
    });
  }

  void _addInvestingInflows() {
    setState(() {
      investingInflows.add({'description': '', 'amount': 0.0});
    });
  }

  void _addInvestingOutflows() {
    setState(() {
      investingOutflows.add({'description': '', 'amount': 0.0});
    });
  }

  void _addFinancingInflows() {
    setState(() {
      financingInflows.add({'description': '', 'amount': 0.0});
    });
  }

  void _addFinancingOutflows() {
    setState(() {
      financingOutflows.add({'description': '', 'amount': 0.0});
    });
  }

  // Method to calculate totals
  double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (total, item) => total + item['amount']);
  }

  // Method to save the current statement
  void _saveStatement() {
    final statement = {
      'operatingInflows': operatingInflows,
      'operatingOutflows': operatingOutflows,
      'investingInflows': investingInflows,
      'investingOutflows': investingOutflows,
      'financingInflows': financingInflows,
      'financingOutflows': financingOutflows,
    };

    setState(() {
      savedStatements.add(statement);
    });

    _clearFields();
  }

  // Method to clear the input fields
  void _clearFields() {
    operatingInflows.clear();
    operatingOutflows.clear();
    investingInflows.clear();
    investingOutflows.clear();
    financingInflows.clear();
    financingOutflows.clear();
  }

  // Method to load a saved statement
  void _editStatement(Map<String, dynamic> statement) {
    setState(() {
      operatingInflows = List.from(statement['operatingInflows']);
      operatingOutflows = List.from(statement['operatingOutflows']);
      investingInflows = List.from(statement['investingInflows']);
      investingOutflows = List.from(statement['investingOutflows']);
      financingInflows = List.from(statement['financingInflows']);
      financingOutflows = List.from(statement['financingOutflows']);
    });
  }

  // Method to share the statement
  void _shareStatement() {
    final StringBuffer statementBuffer = StringBuffer();
    statementBuffer.writeln('Statement of Cash Flows\n');
    statementBuffer.writeln('Operating Activities:');
    statementBuffer.writeln('Inflows:');
    for (var inflow in operatingInflows) {
      statementBuffer.writeln('${inflow['description']}: \$${inflow['amount']}');
    }
    statementBuffer.writeln('Outflows:');
    for (var outflow in operatingOutflows) {
      statementBuffer.writeln('${outflow['description']}: \$${outflow['amount']}');
    }
    statementBuffer.writeln('Investing Activities:');
    statementBuffer.writeln('Inflows:');
    for (var inflow in investingInflows) {
      statementBuffer.writeln('${inflow['description']}: \$${inflow['amount']}');
    }
    statementBuffer.writeln('Outflows:');
    for (var outflow in investingOutflows) {
      statementBuffer.writeln('${outflow['description']}: \$${outflow['amount']}');
    }
    statementBuffer.writeln('Financing Activities:');
    statementBuffer.writeln('Inflows:');
    for (var inflow in financingInflows) {
      statementBuffer.writeln('${inflow['description']}: \$${inflow['amount']}');
    }
    statementBuffer.writeln('Outflows:');
    for (var outflow in financingOutflows) {
      statementBuffer.writeln('${outflow['description']}: \$${outflow['amount']}');
    }
    statementBuffer.writeln('Net Increase in Cash: \$${(_calculateTotal(operatingInflows) - _calculateTotal(operatingOutflows)) + (_calculateTotal(investingInflows) - _calculateTotal(investingOutflows)) + (_calculateTotal(financingInflows) - _calculateTotal(financingOutflows))}');

    Share.share(statementBuffer.toString());
  }

  // Method to print the statement
  void _printStatement() {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(child: pw.Text('Statement of Cash Flows'));
      }));
      return pdf.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statement of Cash Flows'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveStatement,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareStatement,
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: _printStatement,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statement of Cash Flows',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'For the Year Ended [Insert Date]',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Cash Flows from Operating Activities
              Text(
                'Cash Flows from Operating Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Cash Inflows:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...operatingInflows.map((item) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) => item['description'] = value,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => item['amount'] = double.tryParse(value) ?? 0.0,
                      ),
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addOperatingInflows,
                child: Text('Add Inflow'),
              ),
              SizedBox(height: 10),
              Text('Cash Outflows:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...operatingOutflows.map((item) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) => item['description'] = value,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => item['amount'] = double.tryParse(value) ?? 0.0,
                      ),
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addOperatingOutflows,
                child: Text('Add Outflow'),
              ),
              SizedBox(height: 20),

              // Cash Flows from Investing Activities
              Text(
                'Cash Flows from Investing Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Cash Inflows:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...investingInflows.map((item) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) => item['description'] = value,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => item['amount'] = double.tryParse(value) ?? 0.0,
                      ),
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addInvestingInflows,
                child: Text('Add Inflow'),
              ),
              SizedBox(height: 10),
              Text('Cash Outflows:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...investingOutflows.map((item) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) => item['description'] = value,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => item['amount'] = double.tryParse(value) ?? 0.0,
                      ),
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addInvestingOutflows,
                child: Text('Add Outflow'),
              ),
              SizedBox(height: 20),

              // Cash Flows from Financing Activities
              Text(
                'Cash Flows from Financing Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Cash Inflows:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...financingInflows.map((item) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) => item['description'] = value,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => item['amount'] = double.tryParse(value) ?? 0.0,
                      ),
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addFinancingInflows,
                child: Text('Add Inflow'),
              ),
              SizedBox(height: 10),
              Text('Cash Outflows:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...financingOutflows.map((item) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) => item['description'] = value,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => item['amount'] = double.tryParse(value) ?? 0.0,
                      ),
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addFinancingOutflows,
                child: Text('Add Outflow'),
              ),
              SizedBox(height: 20),

              // Display Totals
              Text(
                'Total Cash Inflows from Operating Activities: \$${_calculateTotal(operatingInflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Total Cash Outflows from Operating Activities: \$${_calculateTotal(operatingOutflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Net Cash Provided by Operating Activities: \$${_calculateTotal(operatingInflows) - _calculateTotal(operatingOutflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Total Cash Inflows from Investing Activities: \$${_calculateTotal(investingInflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Total Cash Outflows from Investing Activities: \$${_calculateTotal(investingOutflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Net Cash Used in Investing Activities: \$${_calculateTotal(investingInflows) - _calculateTotal(investingOutflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Total Cash Inflows from Financing Activities: \$${_calculateTotal(financingInflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Total Cash Outflows from Financing Activities: \$${_calculateTotal(financingOutflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Net Cash Provided by Financing Activities: \$${_calculateTotal(financingInflows) - _calculateTotal(financingOutflows)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Net Increase in Cash: \$${(_calculateTotal(operatingInflows) - _calculateTotal(operatingOutflows)) + (_calculateTotal(investingInflows) - _calculateTotal(investingOutflows)) + (_calculateTotal(financingInflows) - _calculateTotal(financingOutflows))}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Display saved statements
              Text(
                'Saved Statements:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...savedStatements.map((statement) {
                return ListTile(
                  title: Text('Statement ${savedStatements.indexOf(statement) + 1}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editStatement(statement),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}