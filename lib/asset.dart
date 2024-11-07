import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({Key? key}) : super(key: key);

  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _assetBox = Hive.box('asset_box');
  final _formKey = GlobalKey<FormState>();

  String _assetName = '';
  String _assetState = 'Good';
  DateTime _purchaseDate = DateTime.now();
  String _serialNumber = '';
  double _fairValue = 0.0;
  double _purchaseValue = 0.0;

  List<String> _assetStates = ['Excellent', 'Good', 'Fair', 'Poor'];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Add asset to the Hive box
      _assetBox.add({
        'assetName': _assetName,
        'assetState': _assetState,
        'purchaseDate': _purchaseDate.toIso8601String(),
        'serialNumber': _serialNumber,
        'fairValue': _fairValue,
        'purchaseValue': _purchaseValue,
      });

      // Redirect to the ViewAssetPage after successful submission
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ViewAssetPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Asset')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Asset Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the asset name'
                    : null,
                onSaved: (value) => _assetName = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Asset State'),
                value: _assetState,
                items: _assetStates.map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) => setState(() => _assetState = value!),
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _purchaseDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Purchase Date'),
                  child: Text(DateFormat('yyyy-MM-dd').format(_purchaseDate)),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Serial Number'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the serial number'
                    : null,
                onSaved: (value) => _serialNumber = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Fair Value'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the fair value'
                    : null,
                onSaved: (value) => _fairValue = double.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Purchase Value'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the purchase value'
                    : null,
                onSaved: (value) => _purchaseValue = double.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Asset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// viewing assets page

class ViewAssetPage extends StatefulWidget {
  const ViewAssetPage({Key? key}) : super(key: key);

  @override
  _ViewAssetPageState createState() => _ViewAssetPageState();
}

class _ViewAssetPageState extends State<ViewAssetPage> {
  final _assetBox = Hive.box('asset_box');

  List<Map<String, dynamic>> _getAllAssets() {
    return _assetBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _deleteAsset(int index) {
    setState(() => _assetBox.deleteAt(index));
  }

  void _editAsset(int index) {
    final asset = _assetBox.getAt(index);
    // Navigate to edit page (create the page if needed)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddAssetPage(), // Assuming this page will handle both add and edit
      ),
    );
  }

  void _printAssetSheet() async {
    final assets = _getAllAssets();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: assets.map((asset) {
              return pw.Text(
                'Asset: ${asset['assetName']}\nSerial: ${asset['serialNumber']}\nState: ${asset['assetState']}\nPurchase Date: ${asset['purchaseDate']}\nFair Value: ${asset['fairValue']}\nPurchase Value: ${asset['purchaseValue']}\n\n',
                style: pw.TextStyle(fontSize: 12),
              );
            }).toList(),
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  void _shareAssetSheet() {
    final assets = _getAllAssets();
    String assetDetails = '';
    for (var asset in assets) {
      assetDetails +=
          'Asset: ${asset['assetName']}\nSerial: ${asset['serialNumber']}\nState: ${asset['assetState']}\nPurchase Date: ${asset['purchaseDate']}\nFair Value: ${asset['fairValue']}\nPurchase Value: ${asset['purchaseValue']}\n\n';
    }
    Share.share(assetDetails);
  }

  void _saveAssetSheet() async {
    final assets = _getAllAssets();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: assets.map((asset) {
              return pw.Text(
                'Asset: ${asset['assetName']}\nSerial: ${asset['serialNumber']}\nState: ${asset['assetState']}\nPurchase Date: ${asset['purchaseDate']}\nFair Value: ${asset['fairValue']}\nPurchase Value: ${asset['purchaseValue']}\n\n',
                style: pw.TextStyle(fontSize: 12),
              );
            }).toList(),
          );
        },
      ),
    );

    final output =
        await getExternalStorageDirectory(); // Make sure you have permission for storage access
    final file = File('${output!.path}/assets.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final assets = _getAllAssets();
    return Scaffold(
      appBar: AppBar(
        title: Text('View Assets'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddAssetPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: _printAssetSheet,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareAssetSheet,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveAssetSheet,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          return ListTile(
            title: Text(asset['assetName']),
            subtitle: Text('Serial: ${asset['serialNumber']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editAsset(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteAsset(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
