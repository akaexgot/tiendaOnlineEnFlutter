import 'package:flutter/material.dart';

/// Página principal de productos
class ProductListPage extends StatelessWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: const Center(
        child: Text('Lista de productos aquí'),
      ),
    );
  }
}
