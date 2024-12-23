import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'shop_content.dart';
import 'cart_screen.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? newClothing;

  const HomePage({Key? key, this.newClothing}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      ShopContent(newClothing: widget.newClothing), // Pass data to ShopContent
      const CartScreen(),
      const ProfilePage(),
    ];
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex == 2) {
      return null; // No AppBar on ProfilePage
    }
    return AppBar(
      title: Text(
        _selectedIndex == 0 ? 'Explorez les Styles' : 'Panier d’Achat',
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: const Color(0xFF76C7F1), // Light blue background
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Magasin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF006C9F), // Darker blue accent
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
