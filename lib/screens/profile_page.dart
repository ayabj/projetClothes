import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_clothing_form.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: '******');
  final _anniversaireController = TextEditingController();
  final _adresseController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _villeController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _emailController.text = _auth.currentUser?.email ?? '';
  }

  void _handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _anniversaireController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _database.child('users/$userId').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _anniversaireController.text = data['anniversaire'] ?? '';
          _adresseController.text = data['adresse'] ?? '';
          _codePostalController.text = data['code_postal'] ?? '';
          _villeController.text = data['ville'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données : $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _database.child('users/$userId').update({
        'anniversaire': _anniversaireController.text,
        'adresse': _adresseController.text,
        'code_postal': _codePostalController.text,
        'ville': _villeController.text,
      });

      if (_passwordController.text.isNotEmpty &&
          _passwordController.text != '******') {
        try {
          await _auth.currentUser?.updatePassword(_passwordController.text);
          _passwordController.text = '******';
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Erreur lors du changement de mot de passe. Le mot de passe doit contenir au moins 6 caractères.'),
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,  // Couleur de fond de l'AppBar
        actions: [
          TextButton(
            onPressed: _handleLogout,
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],  // Couleur de fond
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    _auth.currentUser?.email ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,  // Couleur du texte
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileField(
                    label: 'Email',
                    controller: _emailController,
                    readOnly: true,
                  ),
                  _buildProfileField(
                    label: 'Mot de passe',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  _buildProfileField(
                    label: 'Date de naissance',
                    controller: _anniversaireController,
                    hintText: 'JJ/MM/AAAA',
                  ),
                  _buildProfileField(
                    label: 'Adresse',
                    controller: _adresseController,
                  ),
                  _buildProfileField(
                    label: 'Code postal',
                    controller: _codePostalController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildProfileField(
                    label: 'Ville',
                    controller: _villeController,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddClothingForm()),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Ajouter un vêtement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,  // Couleur des boutons
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveUserData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blueAccent,  // Couleur des boutons
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[200]!),  // Couleur des bordures des champs de texte
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          labelStyle: const TextStyle(color: Colors.black87),  // Couleur du texte du label
        ),
        style: const TextStyle(color: Colors.black87),  // Couleur du texte principal
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ce champ est requis';
          }
          return null;
        },
      ),
    );
  }
}
