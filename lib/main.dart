import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kina_tracker/screens/all_transactions.dart';
import 'package:kina_tracker/screens/bank_transactions.dart';
import 'package:kina_tracker/screens/chart_example.dart';
import 'package:kina_tracker/screens/settings.dart';
import 'package:kina_tracker/screens/transitions/nav_animation.dart';
import 'package:kina_tracker/screens/unpaid_expenses.dart';
import 'package:kina_tracker/screens/new_transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize FFI
  Platform.isAndroid ? sqfliteFfiInit() : Sqflite();

  // Set the database factory
  databaseFactory = databaseFactoryFfi;
  runApp(MaterialApp(
    home: const KinaList(),
    routes: {
      // '/': (context) => const KinaList(),
      '/new': (context) => const NewTransaction(),
      '/all-transactions': (context) => const AllTransactions(),
      // '/view-transaction': (context) => const ViewTransaction(transaction: ),
      '/settings': (context) => const Settings(),
      '/unpaid-expenses': (context) => const UnpaidExpenses(),
      '/bank-transactions': (context) => const BankTransactions(),
    },
    title: "Kina Tracker",
    theme: ThemeData(primarySwatch: Colors.green),
  ));
}

class KinaList extends StatefulWidget {
  const KinaList({super.key});

  @override
  State<KinaList> createState() => _KinaListState();
}

class _KinaListState extends State<KinaList> {
  @override
  Widget build(BuildContext context) {
    var bottomNavSelectedItemIndex = 0;
    void _onBottomNavItemTapped(int index) {
      switch (index) {
        case 0:
          // Navigator.pop(context);
          break;
        case 1:
          Navigator.of(context)
              .push(slideLeftPageRouteBuilder(const Settings()));
          break;
        case 2:
          Navigator.pushNamed(context, '/settings');
          break;
      }
      setState(() {
        bottomNavSelectedItemIndex = index;
      });
    }

    String transactionDescription =
        "these are all transactions (income/expenses) which has been and has not been settled yet from both primary and secondary accounts";
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Finance Tracker Home',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(slideLeftPageRouteBuilder(const UnpaidExpenses()));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).primaryColorLight),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 24.0),
                  child: Column(
                    children: [
                      Text("Unpaid Expenses", style: TextStyle(fontSize: 24)),
                      SizedBox(
                        height: 12,
                      ),
                      Text("these are expenses that have not been settled yet",
                          style: TextStyle(fontWeight: FontWeight.w300)),
                    ],
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(slideLeftPageRouteBuilder(const BankTransactions()));
                // Navigator.pushNamed(context, '/bank-transactions');
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 24.0),
                child: Column(
                  children: [
                    Text(
                      "Primary Account Balance",
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "these are income into the primary account that have not been settled yet",
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(slideLeftPageRouteBuilder(const AllTransactions()));
                  // Navigator.pushNamed(context, '/all-transactions');
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 24.0),
                  child: Column(
                    children: [
                      const Text(
                        "All Transactions",
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(transactionDescription,
                          style: const TextStyle(fontWeight: FontWeight.w300)),
                    ],
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(slideLeftPageRouteBuilder(ChartExample()));
                // Navigator.pushNamed(context, '/unpaid-expenses');
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 24.0),
                child: Column(
                  children: [
                    Text(
                      "Reports",
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text("this is an extra button, you can ignore this",
                        style: TextStyle(fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),
        ],
        // children: allTransactions.map((t) {
        //   // print(t.paid);
        //   return transactionCardTemplate(t);
        // }).toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'add transaction',
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context)=> DetailsScreen(data: "data")));
          Navigator.pushNamed(context, '/new').then((value) {
            if (value != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction saved!'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nothing was saved!'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            }
          });
        },
        shape: CircleBorder(eccentricity: 0.0),
        backgroundColor: Colors.purple,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              label: "Settings", icon: Icon(Icons.settings)),
        ],
        currentIndex: bottomNavSelectedItemIndex,
        onTap: _onBottomNavItemTapped,
      ),
    );
  }
}
