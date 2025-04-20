import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<String> history;
  final VoidCallback onClear;
  final void Function(String record) onReconvert;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.onClear,
    required this.onReconvert,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversion History"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE6E6E6),
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (history.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("No conversion history yet."),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    return InkWell(
                      onTap: () => onReconvert(record),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E6E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          record,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (history.isNotEmpty)
              ElevatedButton(
                onPressed: onClear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Clear History"),
              ),
          ],
        ),
      ),
    );
  }
}
