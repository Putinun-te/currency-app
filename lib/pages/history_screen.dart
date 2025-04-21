import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<String> history;
  final VoidCallback onClear;
  final void Function(String) onReconvert;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.onClear,
    required this.onReconvert,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversion History"),
        centerTitle: true,
      ),
      body:
          history.isEmpty
              ? const Center(
                child: Text(
                  "No conversion history yet.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => onReconvert(item),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          history.isNotEmpty
              ? FloatingActionButton(
                onPressed: onClear,
                child: const Icon(Icons.delete),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              )
              : null,
    );
  }
}
