import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart'; // Import Pdf package for PdfPageFormat
import 'package:pdf/widgets.dart' as pw; // Import widgets from pdf package

class AssetPage extends StatefulWidget {
  const AssetPage({Key? key}) : super(key: key);

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  final _assetBox = Hive.box('asset_box');
  final _formKey = GlobalKey<FormState>();

  String _assetName = '';
  String _assetState = 'Good';
  DateTime _purchaseDate = DateTime.now();
  String _serialNumber = '';
  double _fairValue = 0.0;
  double _purchaseValue = 0.0;

  List<String> _assetStates = ['Excellent', 'Good', 'Fair', 'Poor'];

  List<Map<String, dynamic>> _getAllAssets() {
    return _assetBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _editAsset(int index) {
    final asset = _getAllAssets()[index];
    setState(() {
      _assetName = asset['assetName'];
      _assetState = asset['assetState'];
      _purchaseDate = DateTime.parse(asset['purchaseDate']);
      _serialNumber = asset['serialNumber'];
      _fairValue = asset['fairValue'];
      _purchaseValue = asset['purchaseValue'];
    });

    // Remove the asset from the box
    _assetBox.deleteAt(index);

    // Show the form with pre-filled values
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Asset'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: asset['assetName'],
                  decoration: InputDecoration(labelText: 'Asset Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the asset name';
                    }
                    return null;
                  },
                  onSaved: (value) => _assetName = value!,
                ),
                DropdownButtonFormField<String>(
                  value: asset['assetState'],
                  decoration: InputDecoration(labelText: 'Asset State'),
                  items: _assetStates.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _assetState = value!;
                    });
                  },
                ),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(asset['purchaseDate']),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != _purchaseDate) {
                      setState(() {
                        _purchaseDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Purchase Date'),
                    child: Text(DateFormat('yyyy-MM-dd').format(_purchaseDate)),
                  ),
                ),
                TextFormField(
                  initialValue: asset['serialNumber'],
                  decoration: InputDecoration(labelText: 'Serial Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the serial number';
                    }
                    return null;
                  },
                  onSaved: (value) => _serialNumber = value!,
                ),
                TextFormField(
                  initialValue: asset['fairValue'].toString(),
                  decoration: InputDecoration(labelText: 'Fair Value'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the fair value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _fairValue = double.parse(value!),
                ),
                TextFormField(
                  initialValue: asset['purchaseValue'].toString(),
                  
                  decoration: InputDecoration(labelText: 'Purchase Value'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the purchase value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _purchaseValue = double.parse(value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // Add updated asset back to the box
                  _assetBox.add({
                    'assetName': _assetName,
                    'assetState': _assetState,
                    'purchaseDate': _purchaseDate.toIso8601String(),
                    'serialNumber': _serialNumber,
                    'fairValue': _fairValue,
                    'purchaseValue': _purchaseValue,
                  });

                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAsset(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Asset'),
          content: Text('Are you sure you want to delete this asset?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete the asset from the box
                setState(() {
                  _assetBox.deleteAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _printAssets() async {
    final assets = _getAllAssets();
    final pdfDocument = pw.Document();

    // Build PDF content
    pdfDocument.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // Use PdfPageFormat here
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Registered Assets', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              for (var asset in assets)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(asset['assetName']),
                    pw.Text('Serial: ${asset['serialNumber']}'),
                    pw.Text('Value: \$${asset['fairValue']}'),
                  ],
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfDocument.save());
  }

  Future<void> _saveToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/assets.txt';

    final assets = _getAllAssets();
    StringBuffer content = StringBuffer();

    for (var asset in assets) {
      content.writeln('Asset Name: ${asset['assetName']}');
      content.writeln('Serial Number: ${asset['serialNumber']}');
      content.writeln('State: ${asset['assetState']}');
      content.writeln('Fair Value: \$${asset['fairValue']}');
      content.writeln('----------------------------------');
    }

    File file = File(filePath);
    await file.writeAsString(content.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assets saved to $filePath')),
    );
  }

  void _shareAssets() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/assets.txt';

    // Check if the file exists before sharing
    File file = File(filePath);

    if (await file.exists()) {
      await Share.shareFiles([file.path], text: "Check out my registered assets!");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No assets found to share')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asset Registration'),
        actions: [
          IconButton(icon: Icon(Icons.print), onPressed: _printAssets),
          IconButton(icon: Icon(Icons.save), onPressed: _saveToFile),
          IconButton(icon: Icon(Icons.share), onPressed: _shareAssets),
        ],
      ),
      body: Row(
 
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registered Assets',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: _buildAssetList(),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Add New Asset',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Asset Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the asset name';
                              }
                              return null;
                            },
                            onSaved: (value) => _assetName = value!,
                          ),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(labelText: 'Asset State'),
                            value: _assetState,
                            items: _assetStates.map((state) {
                              return DropdownMenuItem(
                                value: state,
                                child: Text(state),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _assetState = value!;
                              });
                            },
                          ),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _purchaseDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && picked != _purchaseDate) {
                                setState(() {
                                  _purchaseDate = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Purchase Date'),
                              child: Text(DateFormat('yyyy-MM-dd').format(_purchaseDate)),
                            ),
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Serial Number'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the serial number';
                              }
                              return null;
                            },
                            onSaved: (value) => _serialNumber = value!,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Fair Value'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the fair value';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onSaved: (value) => _fairValue = double.parse(value!),
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Purchase Value'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the purchase value';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onSaved: (value) => _purchaseValue = double.parse(value!),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text('Register Asset'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetList() {
    // Implement the method to build the asset list
    return ListView.builder(
      itemCount: _getAllAssets().length,
      itemBuilder: (context, index) {
        final asset = _getAllAssets()[index];
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
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Add new asset to the box
      
      _assetBox.add({
        'assetName': _assetName,
        'assetState': _assetState,
        'purchaseDate': _purchaseDate.toIso8601String(),
        'serialNumber': _serialNumber,
        'fairValue': _fairValue,
        'purchaseValue': _purchaseValue,
      });

      // Clear the form fields
      setState(() {
        _assetName = '';
        _assetState = 'Good';
        _purchaseDate = DateTime.now();
        _serialNumber = '';
        _fairValue = 0.0;
        _purchaseValue = 0.0;
      });
    }
  }
}