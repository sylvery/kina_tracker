import 'package:flutter/material.dart';
import 'package:kina_tracker/model/kina_transactions.dart';

class ExpenditureSearchDelegate extends SearchDelegate<String> {
  final List<KinaTransaction> expenditures;

  ExpenditureSearchDelegate({required this.expenditures});

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Handle results here if needed
    return const Center(child: Text('Results'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // final query = query.toLowerCase(); // This line should be removed

    final suggestions = expenditures
        .where((expenditureItem) =>
            expenditureItem.description!.toLowerCase().contains(query))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final expenditureItem = suggestions[index];
        return ListTile(
          title: Text(expenditureItem.description!),
          onTap: () {
            query = expenditureItem.amount!.toString();
            showResults(context);
          },
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    // throw UnimplementedError();
  }
}
