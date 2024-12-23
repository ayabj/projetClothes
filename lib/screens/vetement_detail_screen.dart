import 'package:flutter/material.dart';
import '../models/vetement.dart';

class VetementDetailScreen extends StatefulWidget {
  final Vetement vetement;

  const VetementDetailScreen({Key? key, required this.vetement})
      : super(key: key);

  @override
  _VetementDetailScreenState createState() => _VetementDetailScreenState();
}

class _VetementDetailScreenState extends State<VetementDetailScreen> {
  String? selectedTaille;
  String? selectedCouleur;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vetement.titre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                widget.vetement.image,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.vetement.titre,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    '${widget.vetement.prix.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Available Sizes
                  const Text(
                    'Tailles disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.vetement.tailles
                        .map((taille) => ChoiceChip(
                              label: Text(
                                taille,
                                style: TextStyle(
                                  color: selectedTaille == taille
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              selected: selectedTaille == taille,
                              selectedColor: Colors.deepPurpleAccent,
                              backgroundColor: Colors.grey[200],
                              onSelected: (selected) {
                                setState(() {
                                  selectedTaille = selected ? taille : null;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  // Available Colors
                  const Text(
                    'Couleurs disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Rouge', 'Bleu', 'Vert']
                        .map((couleur) => ChoiceChip(
                              label: Text(
                                couleur,
                                style: TextStyle(
                                  color: selectedCouleur == couleur
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              selected: selectedCouleur == couleur,
                              selectedColor: Colors.deepPurpleAccent,
                              backgroundColor: Colors.grey[200],
                              onSelected: (selected) {
                                setState(() {
                                  selectedCouleur = selected ? couleur : null;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: (selectedTaille != null && selectedCouleur != null)
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ajouté au panier'),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            disabledBackgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Ajouter au panier',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
