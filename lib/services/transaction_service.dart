import 'package:kina_tracker/db_helper/repository.dart';
import 'package:kina_tracker/model/kina_transactions.dart';

class TransactionService {
  late Repository _repository;
  TransactionService() {
    _repository = Repository();
  }
  final table = 'kina_transactions';
  saveTransaction(KinaTransaction transaction) async {
    //  print('t data in transaction_service: ${transaction.filename}');
    return await _repository.insertData(table, transaction.transactionMap());
  }

  readAllTransactions() async {
    return await _repository.readData(table);
  }

  readAllUnpaidTransactions(
      int paidStatus, int splitStatus, String transactionType) async {
    return await _repository.readUnpaidTransactions(
        table, paidStatus, splitStatus, transactionType);
  }

  readUnpaidBankTransactions(
      int paidStatus, int splitStatus, String basket) async {
    return await _repository.readUnpaidBankTransactions(
        table, paidStatus, splitStatus, basket);
  }

  updateTransaction(KinaTransaction transaction) async {
    return await _repository.updateData(table, transaction.transactionMap());
  }

  deleteTransaction(transactionId) async {
    return await _repository.deleteData(table, transactionId);
  }
}
