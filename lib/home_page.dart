import 'package:flutter/material.dart';
import 'asset.dart';
import 'cash_flow_page.dart';
import 'financial_item_form.dart';
import 'statement_of_financial_position.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AssetPage(),
      CashFlowStatement(),
      FinancialItemForm(refreshItems: _refreshItems),
      StatementOfFinancialPosition(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _refreshItems() {
    // This method can be used to refresh the state of the HomePage if needed
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Assets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Cash Flow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Income/Exp',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Financial Pos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF4CAF50),
        onTap: _onItemTapped,
      ),
    );
  }
}