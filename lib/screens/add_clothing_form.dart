import 'dart:convert';
import 'dart:typed_data';
import 'package:clothes_app/services/clothing_classifier_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';

class AddClothingForm extends StatefulWidget {
  const AddClothingForm({Key? key}) : super(key: key);

  @override
  _AddClothingFormState createState() => _AddClothingFormState();
}

class _AddClothingFormState extends State<AddClothingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _predictedCategory;
  bool _isLoading = false;

  Future<void> _getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isLoading = true;
        });

        final result = await ClothingClassifierService.classifyImage(_imageBytes!);

        setState(() {
          // Assurez-vous que 'category' existe dans la réponse
          _predictedCategory = result['category'] ?? 'Inconnu';
          _categoryController.text = _predictedCategory!;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la classification: $e')),
      );
    }
  }

  Future<void> _addArticle() async {
    if (!_formKey.currentState!.validate() || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newClothing = {
        'titre': _titleController.text,
        'tailles': [_sizeController.text],
        'marque': _brandController.text,
        'prix': double.parse(_priceController.text),
        'categorie': _predictedCategory,
        'image': base64Encode(_imageBytes!),
      };

      // Sauvegarder l'article dans Firebase ou ailleurs
      final ref = FirebaseDatabase.instance.ref('clothes').push();
      await ref.set(newClothing);

      // Naviguer vers la page d'accueil sans passer newClothing
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(), // Pas besoin de passer newClothing ici
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de l\'article: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un article',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section
                GestureDetector(
                  onTap: _getImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.deepPurpleAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageBytes == null
                        ? const Center(
                            child: Text(
                              'Appuyez pour ajouter une image',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildTextField(
                    controller: _titleController,
                    label: 'Titre',
                    validatorMessage: 'Ce champ est requis',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _categoryController,
                    label: 'Catégorie (prédite)',
                    enabled: false,
                    fillColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _sizeController,
                    label: 'Taille',
                    validatorMessage: 'Ce champ est requis',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _brandController,
                    label: 'Marque',
                    validatorMessage: 'Ce champ est requis',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    label: 'Prix',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est requis';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _addArticle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? validatorMessage,
    String? Function(String?)? validator,
    Color? fillColor,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 16,
          color: Colors.blueGrey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: fillColor != null,
        fillColor: fillColor,
      ),
      validator: validator ??
          (value) =>
              (value?.isEmpty ?? true) && validatorMessage != null
                  ? validatorMessage
                  : null,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
