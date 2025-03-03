import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kina_tracker/model/kina_transactions.dart';
import 'package:kina_tracker/screens/transitions/nav_animation.dart';
import 'package:kina_tracker/screens/utls/expenditure_search_delegate.dart';
import 'package:kina_tracker/screens/view_transaction.dart';
import 'package:kina_tracker/services/transaction_service.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({Key? key}) : super(key: key);

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  late List<KinaTransaction> allTransactions = <KinaTransaction>[];
  final _kinaTransactionsService = TransactionService();

  getAllTransactions() async {
    var dbTransactions = await _kinaTransactionsService.readAllTransactions();
    allTransactions = <KinaTransaction>[];
    dbTransactions.forEach((_transaction) {
      // print({"from unpaid_expenses.dart: ": [transac['date'],transac['transaction_type']]});
      setState(() {
        var allTransactionsModel = KinaTransaction(
          id: _transaction['id'],
          date: DateTime.parse(_transaction['date']), //.toIso8601String(),
          transactionType: _transaction['transaction_type'],
          basket: _transaction['basket'],
          description: _transaction['description'],
          amount: _transaction['amount'],
          split: _transaction['split'] == 0 ? false : true,
          paid: _transaction['paid'] == 0 ? false : true,
        );
        allTransactions.add(allTransactionsModel);
      });
    });
  }

  @override
  void initState() {
    getAllTransactions();
    super.initState();
  }

  void _navigateToTransactionDetails(KinaTransaction transaction) {
    Navigator.of(context)
        .push(slideLeftPageRouteBuilder(
            ViewTransaction(transaction: transaction)))
        .then((data) {
      getAllTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("All Transactions"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: ExpenditureSearchDelegate(
                        expenditures: allTransactions),
                  );
                  // print('Search button pressed');
                },
              ),
            ]),
        body: ListView(children: [
          ...allTransactions.map((t) {
            return transactionCardTemplate(t, () {
              _navigateToTransactionDetails(t);
            });
          }).toList(),
        ]));
  }
}

Widget transactionCardTemplate(KinaTransaction t, VoidCallback onTap) {
  var f = NumberFormat.currency(
      locale: "EN",
      name: "Kina",
      symbol: "K",
      decimalDigits: 2,
      customPattern: "#,###.##");
  return GestureDetector(
    onTap: onTap,
    child: Card(
      margin: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0),
      color: t.paid == true ? Colors.green[200] : Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "${t.transactionType}" == "expense"
                  ? "- ${f.format(t.amount)}"
                  : "+ ${f.format(t.amount)}",
              style: TextStyle(
                fontSize: 18.0,
                color: "${t.transactionType}" == "income"
                    ? Colors.green
                    : "${t.transactionType}" == "expense"
                        ? Colors.red
                        : Colors.black,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      t.description.toString(),
                      style: const TextStyle(
                        fontSize: 18.0,
                        // color: "${t.transactionType}" == "income" ? Colors.green : "${t.transactionType}" == "expense" ? Colors.red : Colors.black,
                      ),
                    ),
                    Text(
                      t.date == null
                          ? ''
                          : "${t.date?.day}.${t.date?.month}.${t.date?.year}",
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
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
                Row(children: [
                  Text(
                    t.split != null ? "split" : "",
                    style: const TextStyle(
                      fontSize: 12.0,
                      // color: Colors.grey,
                    ),
                  ),
                  Text(
                    t.paid != null
                        ? t.split != null
                            ? "/paid"
                            : "/paid"
                        : "",
                    style: const TextStyle(
                      fontSize: 12.0,
                      // color: Colors.grey,
                    ),
                  ),
                ]),
              ],
            ),
            // const Icon(Icons.remove_red_eye_sharp),
          ],
        ),
      ),
    ),
  );
}
