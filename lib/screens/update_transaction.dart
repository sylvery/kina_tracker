import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kina_tracker/model/kina_transactions.dart';
import 'package:kina_tracker/services/transaction_service.dart';

class UpdateTransaction extends StatefulWidget {
  final KinaTransaction transaction;
  const UpdateTransaction({required this.transaction});
  // TransactionCategory _transactionCategory = TransactionCategory.expense;
  @override
  State<UpdateTransaction> createState() => _UpdateTransactionState();
}

final List<String> transactionTypes = ['income', 'expense', 'balance'];
final List<String> baskets = ['Ruth', 'Sylver'];

class _UpdateTransactionState extends State<UpdateTransaction> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final _transactionService = TransactionService();
  // TransactionCategory? _transactionCategory = TransactionCategory.expense;
  String basketDropDownValueActive = baskets[1];
  String transactionTypeRadioValue = transactionTypes[1];
  bool? splitCostsCheckedValue = false;
  bool? paidCheckedValue = false;
  DateTime transactionDateSelectedValue = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.transaction.amount.toString();
    _descriptionController.text = widget.transaction.description!;
    basketDropDownValueActive = widget.transaction.basket.toString();
    transactionTypeRadioValue = widget.transaction.transactionType.toString();
    splitCostsCheckedValue = widget.transaction.split;
    paidCheckedValue = widget.transaction.paid;
    transactionDateSelectedValue = DateTime.parse(widget.transaction.date!.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Update Transaction"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030)
                          ).then((value) {
                            setState(() {
                              transactionDateSelectedValue = value!;
                            });
                          });
                        },
                        icon: const Icon(Icons.calendar_month),
                        tooltip: "Choose date",
                      ),
                      Text("${transactionDateSelectedValue.day}/${transactionDateSelectedValue.month}/${transactionDateSelectedValue.year}",
                      style: const TextStyle(
                        fontSize: 24
                      )),
                    ],
                  ),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "0.00 - amount",
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
                      hintText: "Description",
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
                      });
                    },
                    title: const Text("Split costs"),
                  ),
                  const Text("Transaction Category"),
                  RadioListTile(
                    title: const Text("Income"),
                    value: transactionTypes[0],
                    groupValue: transactionTypeRadioValue,
                    onChanged: (value) {
                      setState(() {
                        transactionTypeRadioValue = value.toString();
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
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text("Admin"),
                    value: transactionTypes[2],
                    groupValue: transactionTypeRadioValue,
                    onChanged: (value) {
                      setState(() {
                        transactionTypeRadioValue = value.toString();
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
                      widget.transaction.date = transactionDateSelectedValue;
                      widget.transaction.transactionType = transactionTypeRadioValue;
                      widget.transaction.basket = basketDropDownValueActive;
                      widget.transaction.description = _descriptionController.text;
                      widget.transaction.amount = double.parse(_amountController.text);
                      widget.transaction.split = splitCostsCheckedValue!;
                      widget.transaction.paid = false;
                      // save data
                      // print({'t data in update_transaction': widget.transaction.amount, 'split status: ': splitCostsCheckedValue, 'paid status: ': widget.transaction.paid, 'data': widget.transaction});
                      var result = await _transactionService.updateTransaction(widget.transaction);
                      Navigator.pop(context,result);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              )),
            )
          ],
        ),
      ),
    );
  }
}
