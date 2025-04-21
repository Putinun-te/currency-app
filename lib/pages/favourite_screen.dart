import 'package:flutter/material.dart';

class FavouriteScreen extends StatefulWidget {
  final List<String> favourites;
  final VoidCallback onClear;
  final void Function(String) onReconvert;

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
  List<String> localFavourites = [];

  @override
  void initState() {
    super.initState();
    localFavourites = List.from(widget.favourites); // Copy to local
  }

  void handleClear() {
    widget.onClear(); // Clear parent and SharedPreferences
    setState(() {
      localFavourites.clear(); // Clear local list for UI update
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourites"),
        centerTitle: true,
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.black,
        foregroundColor:
            Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
        actions: [
          if (localFavourites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: handleClear,
              tooltip: "Clear Favourites",
            ),
        ],
      ),
      body:
          localFavourites.isEmpty
              ? const Center(child: Text("No favourites yet."))
              : ListView.separated(
                itemCount: localFavourites.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final fav = localFavourites[index];
                  return ListTile(
                    title: Text(
                      fav,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: isDark ? Colors.tealAccent : Colors.blue,
                      ),
                      onPressed: () => widget.onReconvert(fav),
                    ),
                  );
                },
              ),
    );
  }
}
