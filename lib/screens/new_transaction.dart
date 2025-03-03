import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kina_tracker/model/kina_transactions.dart';
import 'package:kina_tracker/services/transaction_service.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class NewTransaction extends StatefulWidget {
  const NewTransaction({Key? key}) : super(key: key);
  // TransactionCategory _transactionCategory = TransactionCategory.expense;
  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

final List<String> transactionTypes = [
  'income',
  'expense',
  'balance',
];
final List<String> incomeCategory = [
  'cups',
  'shirts',
  'caps',
  'dinau',
  'boat',
];
final List<String> expenseCategory = [
  'house shopping',
  'transportation',
  'recreation',
  '',
];
final List<String> baskets = ['Ruth', 'Sylver'];

class _NewTransactionState extends State<NewTransaction> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _transactionService = TransactionService();
  // TransactionCategory? _transactionCategory = TransactionCategory.expense;
  String basketDropDownValueActive = baskets[1];
  String transactionTypeRadioValue = transactionTypes[1];
  bool? splitCostsCheckedValue = false;
  DateTime transactionDateSelectedValue = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Add New Transaction"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      showDatePicker(
                              context: context,
                              initialDate: transactionDateSelectedValue,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030))
                          .then((value) {
                        setState(() {
                          transactionDateSelectedValue = value!;
                        });
                      });
                    },
                    icon: const Icon(Icons.calendar_month),
                    tooltip: "Choose date",
                  ),
                  Text(
                      "${transactionDateSelectedValue.day}/${transactionDateSelectedValue.month}/${transactionDateSelectedValue.year}",
                      style: const TextStyle(fontSize: 24)),
                ],
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text("Amount"),
                  hintText: "0.00",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter something";
                  }
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  label: Text("Description"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter something";
                  }
                },
              ),
              CheckboxListTile(
                value: splitCostsCheckedValue,
                onChanged: (bool? value) {
                  setState(() {
                    splitCostsCheckedValue = value;
                    basketDropDownValueActive = 'Sylver';
                  });
                },
                title: const Text("Split costs"),
              ),
              const Text("Transaction Type"),
              RadioListTile(
                title: const Text("Income"),
                value: transactionTypes[0],
                groupValue: transactionTypeRadioValue,
                onChanged: (value) {
                  setState(() {
                    transactionTypeRadioValue = value.toString();
                    basketDropDownValueActive = 'Ruth';
                  });
                },
              ),
              RadioListTile(
                title: const Text("Expense"),
                value: transactionTypes[1],
                groupValue: transactionTypeRadioValue,
                onChanged: (value) {
                  setState(() {
                    transactionTypeRadioValue = value.toString();
                    basketDropDownValueActive = 'Sylver';
                  });
                },
              ),
              const Text("Billing Account"),
              DropdownButton(
                value: basketDropDownValueActive,
                onChanged: (value) {
                  setState(() {
                    basketDropDownValueActive = value.toString();
                  });
                },
                items: baskets.map((basket) {
                  return DropdownMenuItem(
                    value: basket,
                    child: Text(basket),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  // print('FAB Image Path: ${_image?.path} and $_imageFilename');
                  var transaction = KinaTransaction(
                    date: transactionDateSelectedValue,
                    transactionType: transactionTypeRadioValue,
                    basket: basketDropDownValueActive,
                    description: _descriptionController.text,
                    amount: double.parse(_amountController.text),
                    split: splitCostsCheckedValue!,
                    paid: false,
                  );
                  // print('FAB Transaction Image Path: ${transaction.filename}');
                  var result =
                      await _transactionService.saveTransaction(transaction);
                  if (result != null) {
                    Navigator.pop(context, result);
                  }
                },
                child: const Text("Savim!"),
              ),
            ],
          )),
        )),
      ),
    );
  }
}
