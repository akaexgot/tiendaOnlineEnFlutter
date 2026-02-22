import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda y Soporte')),
      body: ListView(
        children: [
          _buildFaqSection(context),
          const Divider(),
          _buildContactSection(context),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Preguntas Frecuentes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _buildExpansionTile(
          '¿Cómo realizo un pedido?',
          'Navega por el catálogo, añade productos al carrito y procede al pago siguiendo los pasos indicados en pantalla.',
        ),
        _buildExpansionTile(
          '¿Cuáles son los métodos de pago?',
          'Aceptamos tarjeta de crédito/débito y pagos en efectivo en la entrega (si está disponible en tu zona).',
        ),
        _buildExpansionTile(
          '¿Puedo cancelar mi pedido?',
          'Sí, puedes cancelar tu pedido desde la sección "Mis Pedidos" siempre y cuando no haya sido enviado aún.',
        ),
        _buildExpansionTile(
          '¿Cómo funcionan las devoluciones?',
          'Tienes 30 días para devolver cualquier producto no utilizado. Contacta con soporte para iniciar el proceso.',
        ),
        _buildExpansionTile(
          '¿Hacen envíos internacionales?',
          'Actualmente solo realizamos envíos nacionales. Estamos trabajando para expandirnos pronto.',
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Necesitas más ayuda?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Envíanos un correo'),
            subtitle: const Text('soporte@tiendaflutter.com'),
            onTap: () {
              // Launch email
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Llámanos'),
            subtitle: const Text('+34 900 123 456'),
            onTap: () {
              // Launch phone
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Chat en vivo'),
            subtitle: const Text('Disponible 9:00 - 18:00'),
            onTap: () {
              // Open chat
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(content),
        ),
      ],
    );
  }
}
