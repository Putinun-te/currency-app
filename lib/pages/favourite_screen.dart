import 'package:flutter/material.dart';

class FavouriteScreen extends StatefulWidget {
  final List<String> favourites;
  final VoidCallback onClear;
  final ValueChanged<String> onReconvert;

  const FavouriteScreen({
    super.key,
    required this.favourites,
    required this.onClear,
    required this.onReconvert,
  });

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  late List<String> _favourites;

  @override
  void initState() {
    super.initState();
    _favourites = List.from(widget.favourites);
  }

  void removeFavourite(String item) {
    setState(() {
      _favourites.remove(item);
    });
    // You can also update shared preferences if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Conversions"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (_favourites.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Clear All Favourites?"),
                    content: const Text("Are you sure you want to remove all?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onClear();
                          setState(() => _favourites.clear());
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _favourites.isEmpty
          ? const Center(child: Text("No favourites yet"))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _favourites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final fav = _favourites[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, fav); // return selected item
                    widget.onReconvert(fav);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.star, color: Colors.orange),
                          onPressed: () => removeFavourite(fav),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            fav,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
