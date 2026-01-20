import 'package:flutter/material.dart';

/// Widget específico de la tarjeta de producto
class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$$price'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
