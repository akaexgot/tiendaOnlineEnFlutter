import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../products/data/datasources/promotion_remote_datasource.dart';
import '../../../products/data/models/promotion_model.dart';

// Provider for promotions
final promotionsProvider = FutureProvider<List<PromotionModel>>((ref) {
  return PromotionRemoteDataSource().getPromotions();
});

/// Modern Admin Promotions Page
class AdminPromotionsPage extends ConsumerWidget {
  const AdminPromotionsPage({super.key});

  static const _bgColor = Color(0xFF0F0F23);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentGradient = [Color(0xFFF59E0B), Color(0xFFD97706)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(promotionsProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _accentGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Promociones',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showPromotionDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGradient[0],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nueva'),
            ),
          ),
        ],
      ),
      body: promotionsAsync.when(
        data: (promotions) {
          if (promotions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text('No hay promociones', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showPromotionDialog(context, ref),
                    style: ElevatedButton.styleFrom(backgroundColor: _accentGradient[0]),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear promoción'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promo = promotions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: promo.isValid 
                            ? [_accentGradient[0].withOpacity(0.3), _accentGradient[1].withOpacity(0.1)]
                            : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        promo.displayDiscount,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: promo.isValid ? _accentGradient[0] : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        promo.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: promo.isValid 
                              ? const Color(0xFF10B981).withOpacity(0.15)
                              : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          promo.isValid ? 'ACTIVO' : 'EXPIRADO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: promo.isValid ? const Color(0xFF10B981) : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.confirmation_number_outlined, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              'Usos: ${promo.timesUsed}${promo.usageLimit != null ? '/${promo.usageLimit}' : ' (ilimitado)'}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                        if (promo.validUntil != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                'Expira: ${DateFormat('dd/MM/yyyy').format(promo.validUntil!)}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                    color: _cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      _buildPopupItem('edit', Icons.edit_rounded, 'Editar', Colors.blue),
                      _buildPopupItem('delete', Icons.delete_rounded, 'Eliminar', Colors.red),
                    ],
                    onSelected: (value) => _handleAction(context, ref, value, promo),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String text, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action, PromotionModel promo) {
    switch (action) {
      case 'edit':
        _showPromotionDialog(context, ref, promotion: promo);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, promo);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, PromotionModel promo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar promoción', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar el código "${promo.code}"?',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                final dataSource = PromotionRemoteDataSource();
                await dataSource.deletePromotion(promo.id);
                ref.invalidate(promotionsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Promoción eliminada')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showPromotionDialog(BuildContext context, WidgetRef ref, {PromotionModel? promotion}) {
    final isEditing = promotion != null;
    final codeController = TextEditingController(text: promotion?.code ?? '');
    final discountValueController = TextEditingController(text: promotion?.discountValue.toString() ?? '');
    final usageLimitController = TextEditingController(text: promotion?.usageLimit?.toString() ?? '');
    String discountType = promotion?.discountType ?? 'percent';
    DateTime? validFrom = promotion?.validFrom;
    DateTime? validUntil = promotion?.validUntil;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditing ? 'Editar promoción' : 'Nueva promoción',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(codeController, 'Código *', hint: 'VERANO2024'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade700),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: discountType,
                            dropdownColor: _cardColor,
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'percent', child: Text('%')),
                              DropdownMenuItem(value: 'fixed', child: Text('€')),
                            ],
                            onChanged: (v) => setState(() => discountType = v!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildTextField(discountValueController, 'Valor *', keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(usageLimitController, 'Límite de usos', hint: 'Ilimitado', keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDateSelector(context, 'Válido desde', validFrom, (date) => setState(() => validFrom = date)),
                const SizedBox(height: 12),
                _buildDateSelector(context, 'Válido hasta', validUntil, (date) => setState(() => validUntil = date)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGradient[0],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (codeController.text.isEmpty || discountValueController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código y valor son requeridos')),
                  );
                  return;
                }

                try {
                  final dataSource = PromotionRemoteDataSource();
                  if (isEditing) {
                    await dataSource.updatePromotion(
                      id: promotion.id,
                      code: codeController.text,
                      discountType: discountType,
                      discountValue: double.tryParse(discountValueController.text) ?? 0,
                      usageLimit: int.tryParse(usageLimitController.text),
                      validFrom: validFrom,
                      validUntil: validUntil,
                    );
                  } else {
                    await dataSource.createPromotion(
                      code: codeController.text,
                      discountType: discountType,
                      discountValue: double.tryParse(discountValueController.text) ?? 0,
                      usageLimit: int.tryParse(usageLimitController.text),
                      validFrom: validFrom,
                      validUntil: validUntil,
                    );
                  }
                  ref.invalidate(promotionsProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Promoción actualizada' : 'Promoción creada')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text(isEditing ? 'Guardar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      textCapitalization: label.contains('Código') ? TextCapitalization.characters : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        hintStyle: TextStyle(color: Colors.grey.shade700),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentGradient[0]),
        ),
        filled: true,
        fillColor: _bgColor,
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, String label, DateTime? date, Function(DateTime?) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: _accentGradient[0],
                  surface: _cardColor,
                ),
              ),
              child: child!,
            );
          },
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Sin definir',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                if (date != null)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                    onPressed: () => onChanged(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today_rounded, size: 18, color: _accentGradient[0]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
