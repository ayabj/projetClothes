import 'package:clothes_app/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';


class ShopContent extends StatefulWidget {
  final Map<String, dynamic>? newClothing;

  const ShopContent({Key? key, this.newClothing}) : super(key: key);

  @override
  _ShopContentState createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  final _database = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> _categories = {};

  @override
  void initState() {
    super.initState();
    _initializeShopContent();
  }

  /// Charge les vêtements existants et ajoute le nouveau, si applicable.
  Future<void> _initializeShopContent() async {
    if (widget.newClothing != null) {
      _addNewClothingToCategory(widget.newClothing!);
    }
    await _loadVetementsFromDatabase();
  }

  /// Ajoute un nouveau vêtement à une catégorie appropriée.
  void _addNewClothingToCategory(Map<String, dynamic> clothing) {
    String categoryKey = _getCategoryKey(clothing['categorie']);
    setState(() {
      _categories[categoryKey] ??= [];
      _categories[categoryKey]!.add(clothing);
    });
  }

  /// Charge les vêtements depuis Firebase et initialise `_categories`.
  Future<void> _loadVetementsFromDatabase() async {
    try {
      final snapshot = await _database.child('categories').get();
      if (snapshot.exists) {
        setState(() {
          _categories = (snapshot.value as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry(
              key.toString(),
              (value as List<dynamic>)
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList(),
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Génère une clé de catégorie normalisée à partir du nom de la catégorie.
  String _getCategoryKey(String category) {
    return category.toLowerCase().replaceAll(' ', '_');
  }

  /// Affiche les détails d'un vêtement dans une feuille modal.
  void _showVetementDetails(Map<String, dynamic> vetement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _VetementDetailsModal(vetement: vetement);
      },
    );
  }

  /// Construit une section pour une catégorie.
  Widget _buildCategorySection(String title, String categoryKey) {
    final items = _categories[categoryKey] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _VetementCard(
                vetement: items[index],
                onTap: () => _showVetementDetails(items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadVetementsFromDatabase,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _categories.entries.map((entry) {
            return _buildCategorySection(
              entry.key[0].toUpperCase() + entry.key.substring(1),
              entry.key,
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Composant pour une carte de vêtement.
class _VetementCard extends StatelessWidget {
  final Map<String, dynamic> vetement;
  final VoidCallback onTap;

  const _VetementCard({required this.vetement, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(
              vetement['image'] ?? '',
              height: 180,
              width: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Taille: ${(vetement['tailles'] as List).join(', ')}'),
                  Text(vetement['titre'] ?? '',
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text('${vetement['prix']} €',
                      style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal pour les détails d'un vêtement.
class _VetementDetailsModal extends StatelessWidget {
  final Map<String, dynamic> vetement;

  const _VetementDetailsModal({required this.vetement, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.network(vetement['image'] ?? ''),
          Text(vetement['titre'] ?? ''),
          Text('Prix: ${vetement['prix']} €'),
          ElevatedButton(
            onPressed: () {
              context.read<CartService>().addItem(vetement);
              Navigator.pop(context);
            },
            child: const Text('Ajouter au panier'),
          ),
        ],
      ),
    );
  }
}
