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
      _buildHomePage(), // Home page with welcome message
      ViewAssetPage(), // Navigate to ViewAssetPage for asset management
      CashFlowStatement(),
      FinancialItemForm(refreshItems: _refreshItems),
      StatementOfFinancialPosition(),
    ];
  }

  Widget _buildHomePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Welcome to Financial Management! \nTrack and manage your assets, cash flow, and financial position with ease.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
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
        title:
            Text('Financial Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
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
