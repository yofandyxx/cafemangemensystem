import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Providers
import 'package:cafemangemensystem/data/models/presentation/providers/cart_provider.dart';
import 'package:cafemangemensystem/data/models/presentation/providers/inventory_provider.dart';

// Import ScreensA
import 'package:cafemangemensystem/data/models/presentation/screens/main_menu_screen.dart';

void main() {
  // Memastikan binding engine Flutter sudah terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cafe POS',

        // Tema Aplikasi
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.light,
        ),

        // Halaman Utama
        home: const MainMenuScreen(),
      ),
    );
  }
}
