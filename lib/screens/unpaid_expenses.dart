import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kina_tracker/model/kina_transactions.dart';
import 'package:kina_tracker/screens/transitions/nav_animation.dart';
import 'package:kina_tracker/screens/view_transaction.dart';
import 'package:kina_tracker/services/transaction_service.dart';

class UnpaidExpenses extends StatefulWidget {
  const UnpaidExpenses({Key? key}) : super(key: key);

  @override
  State<UnpaidExpenses> createState() => _UnpaidExpensesState();
}

class _UnpaidExpensesState extends State<UnpaidExpenses> {
  late List<KinaTransaction> allUnpaidExpenses = <KinaTransaction>[];
  final _kinaTransactionsService = TransactionService();

  getAllUnpaidExpenseTransactions() async{
    // get all expense transactions that are unpaid but marked for cost splitting
    var dbTransactions = await _kinaTransactionsService.readAllUnpaidTransactions(0,1,"expense");
    allUnpaidExpenses = <KinaTransaction>[];
    dbTransactions.forEach((unpaidExpenseTransaction) {
      // print({"from unpaid_expenses.dart: ": [transac['date'],transac['transaction_type']]});
      setState(() {
        var expenseTransactionModel = KinaTransaction(
            id: unpaidExpenseTransaction['id'],
            date: DateTime.parse(unpaidExpenseTransaction['date']),//.toIso8601String(),
            transactionType: unpaidExpenseTransaction['transaction_type'],
            basket: unpaidExpenseTransaction['basket'],
            description: unpaidExpenseTransaction['description'],
            amount: double.parse(unpaidExpenseTransaction['amount'].toStringAsFixed(2)),
            split: unpaidExpenseTransaction['split'] == 0 ? false : true,
            paid: unpaidExpenseTransaction['paid'] == 0 ? false : true,
        );
        allUnpaidExpenses.add(expenseTransactionModel);
      });
    });
  }

  @override
  void initState() {
    getAllUnpaidExpenseTransactions();
    super.initState();
  }

  void _navigateToTransactionDetails(KinaTransaction transaction) {
    Navigator.of(context).push(
      slideLeftPageRouteBuilder(ViewTransaction(transaction: transaction))
    ).then((data) {
      getAllUnpaidExpenseTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    var totalSpent = 0.0;
    var f = NumberFormat.currency(locale: "EN",name: "Kina",symbol: "K",decimalDigits: 2,customPattern: "####.##");
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text("Unsettled & Shared Expenses"),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            ...allUnpaidExpenses.map((t) {
              // print({"transaction type: ":t.transactionType});
              switch(t.basket) {
                case "Sylver":
                  // track if its my money coming in and if the money is spent on kids/house it will be indicated as split
                  t.split! ? t.amount = (t.amount! / 2.0) : '';
                  // add it on the total if its spent on Ruth's things (SP/Dinau)
                  totalSpent += t.amount!;
                  // print({t.amount!: totalSpent,"S":"E"});
                  break;
                case "Ruth":
                  t.split! ? t.amount = (t.amount! / 2.0) : '';
                  // if its money spent on me, then subtract from the total
                  totalSpent -= t.amount!;
                  // print({t.amount!: totalSpent, "R":"E"});
                  break;
              }
              // print({"from balance: ": _totalSpent});
              return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    direction == DismissDirection.startToEnd ? t.paid = true : '';
                    var result = _kinaTransactionsService.updateTransaction(t);
                    getAllUnpaidExpenseTransactions();
                  },
                  child:
                    transactionCardTemplate(t, () {
                    _navigateToTransactionDetails(t);
                  })
              );
            }).toList(),
            // Insert the total at the end of the list
            transactionCardTemplate(KinaTransaction(
              // Create a special transaction object for the total
                description: 'Total Owed',
                basket: 'Sylver',
                amount: double.parse(f.format(totalSpent)),
                split: false
            ), () {
              _navigateToTransactionDetails(KinaTransaction(
                // Create a special transaction object for the total
                  description: 'Total Remaining',
                  basket: 'Ruth',
                  amount: double.parse(f.format(totalSpent.toStringAsFixed(2))),
                  split: false
              ));
            }),
            const SizedBox(height: 12.0)
          ],
        ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'click',
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context)=> DetailsScreen(data: "data")));
          Navigator.pushNamed(context, '/new').then((value) {
            if(value != null) {
              getAllUnpaidExpenseTransactions();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction saved!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nothing was saved!')),
              );
            }
          });
        },
        // backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget transactionCardTemplate(t, VoidCallback onTap) {
  var f = NumberFormat.currency(locale: "EN",name: "Kina",symbol: "K",decimalDigits: 2,customPattern: "####.##");
  return GestureDetector(
    onTap: onTap,
    child: Card(
      // color: t.isSelected ? Colors.grey : Colors.transparent,
      margin: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0,12.0,16.0,12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "${t.basket}" == "Ruth" ? "- ${f.format(t.amount)}" : "+ ${f.format(t.amount)}",
              style: TextStyle(
                fontSize: 18.0,
                color: "${t.basket}" == "Sylver" ? Colors.green : "${t.basket}" == "Ruth" ? Colors.red : Colors.black,
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget> [
                  Text(
                    t.description.toString(),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: "${t.basket}" == "Sylver" ? Colors.green : "${t.basket}" == "Ruth" ? Colors.red : Colors.black,
                    ),
                  ),
                  Text(
                    t.date == null ? '' : "${t.date.day}.${t.date.month}.${t.date.year}",
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ]
              ),
            ),
            Column(
              children: [
                Text(
                  t.basket.toString(),
                  style: const TextStyle(
                    fontSize: 12.0,
                    // color: Colors.grey,
                  ),
                ),
                Text(
                  t.split ? "split" : "",
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            // const Icon(Icons.check_box_outline_blank),
          ],
        ),
      ),
    ),
  );
}

