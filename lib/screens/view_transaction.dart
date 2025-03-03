import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kina_tracker/model/kina_transactions.dart';
import 'package:kina_tracker/screens/update_transaction.dart';
import 'package:kina_tracker/services/transaction_service.dart';

class ViewTransaction extends StatelessWidget {
  // const DetailsScreen({super.key});
  final _transactionService = TransactionService();
  final KinaTransaction transaction;
  ViewTransaction({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final transactionService = TransactionService();
    var paidStatus = transaction.paid;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Transaction Details"),
      ),
      body: ListView(children: [
        transactionCardTemplate(transaction),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) =>
                            UpdateTransaction(transaction: transaction)))
                    .then((data) async {
                  // transaction.amount = data.amount!;
                  // print([data.id,data.amount]);
                  ViewTransaction(
                    key: data.key,
                    transaction: data,
                  );
                  // var result = await transactionService.updateTransaction(transaction);
                });
                // Navigator.pop(context);
              },
              //// back: Colors.green,
              icon: const Icon(Icons.edit),
              label: const Text("edit"),
            ),
            if (transaction.paid != true)
              ElevatedButton.icon(
                onPressed: () async {
                  transaction.paid = true;
                  var result =
                      await transactionService.updateTransaction(transaction);
                  Navigator.pop(context, result);
                },
                icon: const Icon(Icons.check),
                label: const Text("paid"),
              ),
            if (transaction.paid == true)
              ElevatedButton.icon(
                onPressed: () async {
                  transaction.paid = false;
                  var result =
                      await transactionService.updateTransaction(transaction);
                  Navigator.pop(context, result);
                },
                icon: const Icon(Icons.check),
                label: const Text("unpaid"),
              ),
            ElevatedButton.icon(
              onPressed: () async {
                var result =
                    await transactionService.deleteTransaction(transaction.id);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete),
              label: const Text("remove"),
            ),
          ],
        ),
      ]),
    );
  }

  Widget transactionCardTemplate(KinaTransaction t) {
    var f = NumberFormat.currency(
        locale: "EN",
        name: "Kina",
        symbol: "K",
        decimalDigits: 2,
        customPattern: "#,###.##");
    const lw = 200.0;
    // print('Image filename: ${t.filename}');
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: lw,
          height: lw,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow,
          ),
          child: Center(
            child: Text(
              f.format(t.amount).toString(),
              style: const TextStyle(fontSize: 48.0, color: Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Card(
          // color: Colors.lightGreen[100],
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 12),
                Text(
                  "${t.basket.toString()}'s ${t.transactionType.toString()}",
                  style: const TextStyle(
                    fontSize: 24.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${t.date!.day} / ${t.date!.month} / ${t.date!.year}",
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    const Text("Description: "),
                    Text(
                      t.description.toString(),
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text("Split Costs? "),
                Text(
                  t.split != false ? "yes" : "no",
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Already Paid? "),
                Text(
                  t.paid != false ? "yes" : "no",
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
