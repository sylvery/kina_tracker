import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kina_tracker/model/kina_transactions.dart';
import 'package:kina_tracker/screens/transitions/nav_animation.dart';
import 'package:kina_tracker/screens/view_transaction.dart';
import 'package:kina_tracker/services/transaction_service.dart';

class BankTransactions extends StatefulWidget {
  const BankTransactions({Key? key}) : super(key: key);

  @override
  State<BankTransactions> createState() => _BankTransactionsState();
}

class _BankTransactionsState extends State<BankTransactions> {
  late List<KinaTransaction> allUnpaidBankTransactions = <KinaTransaction>[];
  final _kinaTransactionsService = TransactionService();

  getAllUnpaidBankTransactions() async{
    var dbBankTransactions = await _kinaTransactionsService.readUnpaidBankTransactions(0,0,"Ruth");
    allUnpaidBankTransactions = <KinaTransaction>[];
    dbBankTransactions.forEach((unpaidBankTransaction) {
      // print({"from unpaid_expenses.dart: ": [transac['date'],transac['transaction_type']]});
      setState(() {
        var expenseTransactionModel = KinaTransaction(
            id: unpaidBankTransaction['id'],
            date: DateTime.parse(unpaidBankTransaction['date']),//.toIso8601String(),
            transactionType: unpaidBankTransaction['transaction_type'],
            basket: unpaidBankTransaction['basket'],
            description: unpaidBankTransaction['description'],
            amount: unpaidBankTransaction['amount'],
            split: unpaidBankTransaction['split'] == 0 ? false : true,
            paid: unpaidBankTransaction['paid'] == 0 ? false : true,
        );
        allUnpaidBankTransactions.add(expenseTransactionModel);
      });
    });
  }

  @override
  void initState() {
    getAllUnpaidBankTransactions();
    super.initState();
  }

  void _navigateToTransactionDetails(KinaTransaction transaction) {
    Navigator.of(context).push(
      slideLeftPageRouteBuilder(ViewTransaction(transaction: transaction))
    ).then((data) {
      getAllUnpaidBankTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    var totalReceived = 0.0;
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("Unsettled Bank Transactions"),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            ...allUnpaidBankTransactions.map((t) {
              // if the income is Sylver's then do nothing add it onto the total
              // print({"transaction type: ":t.transactionType});
              switch(t.transactionType) {
                case "income":
                  // if the income is Ruth's then add it onto the total
                  // if the expense is Ruth's then subtract it with 5% interest from the total
                  totalReceived += t.amount!;
                  break;
                case "expense":
                  // t.amount = t.amount! + (t.amount! * 0.05);
                  totalReceived -= t.amount!;
                  break;
              }
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  direction == DismissDirection.startToEnd ? t.paid = true : '';
                  _kinaTransactionsService.updateTransaction(t);
                  getAllUnpaidBankTransactions();
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
              description: 'Total Remaining',
              basket: 'Ruth',
              amount: totalReceived,
              split: false
            ),() {
              _navigateToTransactionDetails(KinaTransaction(
                // Create a special transaction object for the total
                  description: 'Total Remaining',
                  basket: 'Ruth',
                  amount: totalReceived,
                  split: false
              ));
            }),
            const SizedBox(height: 12.0,)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'click',
          onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context)=> DetailsScreen(data: "data")));
            Navigator.pushNamed(context, '/new').then((value) {
              if(value != null) {
                getAllUnpaidBankTransactions();
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

Widget transactionCardTemplate(KinaTransaction t, VoidCallback onTap) {
  var f = NumberFormat.currency(locale: "EN",name: "Kina",symbol: "K",decimalDigits: 2,customPattern: "####.##");
  final amountText = t.transactionType == "income" ? "+ ${f.format(t.amount)}" : t.transactionType == "expense" ? "- ${f.format(t.amount)}" : f.format(t.amount);
  return GestureDetector(
    onTap: onTap,
    child: Card(
      margin: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0,12.0,16.0,12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              amountText,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  t.description.toString(),
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            const Icon(Icons.credit_card),
          ],
        ),
      ),
    ),
  );
}

