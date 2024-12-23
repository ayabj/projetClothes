import 'package:clothes_app/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';


void main() async {
  // S'assurer que Flutter a bien initialisé avant d'utiliser Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec les options de la plateforme actuelle
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Définir l'URL de la base de données Firebase
  FirebaseDatabase.instance.databaseURL =
      'https://clothesapp-7743b-default-rtdb.firebaseio.com/';

  // Lancer l'application avec les services nécessaires
  runApp(
    MultiProvider(
      providers: [
        // Fournisseur pour le service du panier
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: ClothesApp(),
    ),
  );
}

class ClothesApp extends StatelessWidget {
  const ClothesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Désactiver le bandeau de debug
      debugShowCheckedModeBanner: false,

      // Définir le titre de l'application
      title: 'ClothesApp',

      // Définir le thème de l'application
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      // Définir les routes de l'application
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => const HomePage(),
      },

      // Initialiser la première route
      initialRoute: '/login',
    );
  }
}
