import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../shared/models/cascade_stage.dart';
import '../../../shared/models/food_listing.dart';
import '../../../shared/providers/listings_provider.dart';
import '../services/food_classifier_service.dart';

class SellerListItemScreen extends ConsumerStatefulWidget {
  const SellerListItemScreen({super.key});

  @override
  ConsumerState<SellerListItemScreen> createState() => _SellerListItemScreenState();
}

class _SellerListItemScreenState extends ConsumerState<SellerListItemScreen> {
  bool _isScanning = false;
  bool _isScanned = false;
  XFile? _selectedImage;

  final _classifier = FoodClassifierService();
  bool _classifierReady = false;
  List<FoodPrediction> _suggestions = [];
  String _debugStatus = 'Initializing...';
  String _predictedName = '';

  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedVertical = 'Restaurant';
  final List<String> _selectedDiets = [];
  int _cookedMinutesElapsed = 0;
  bool _isRefrigerated = false;

  final _verticals = [
    'Restaurant',
    'Kirana',
    'Bakery',
    'Event',
    'Corporate',
    'Temple / Gurudwara',
    'Mosque',
  ];
  final _allDiets = ['Veg', 'Non-veg', 'Jain', 'Halal'];

  @override
  void initState() {
    super.initState();
    _priceCtrl.addListener(() => setState(() {}));
    _classifier.init().then((_) {
      if (mounted) setState(() {
        _classifierReady = true;
        _debugStatus = 'Model Ready';
      });
    }).catchError((e) {
      if (mounted) setState(() => _debugStatus = 'Model Error');
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _classifier.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 85);
    if (image == null) return;

    setState(() {
      _selectedImage = image;
      _isScanning = true;
      _isScanned = false;
      _suggestions = [];
      _debugStatus = 'Scanning...';
    });

    try {
      final bytes = await image.readAsBytes();
      final result = await _classifier.classify(bytes);

      if (!mounted) return;

      setState(() {
        _isScanning = false;
        if (result != null) {
          _isScanned = true;
          _predictedName = result.top.displayName;
          _nameCtrl.text = _predictedName;
          _suggestions = result.top3;
          _debugStatus = 'Got: $_predictedName';
        } else {
          _debugStatus = 'Failed to identify';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _debugStatus = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: AnnvaColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AnnvaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('List Surplus', style: TextStyle(fontFamily: 'InstrumentSerif', color: AnnvaColors.primary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('List surplus food', style: AnnvaTextStyles.h2),
                    const Text('Snap a photo. Our AI fills the rest.', style: TextStyle(fontFamily: 'WorkSans', color: AnnvaColors.muted, fontSize: 13)),
                  ],
                ),
                const Text('✦ AI-assisted', style: TextStyle(fontFamily: 'WorkSans', color: AnnvaColors.ochre, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 24),
            _buildUploadBox(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
              child: Text(_debugStatus, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 10)),
            ),
            const SizedBox(height: 24),
            _buildForm(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _listSurplus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnnvaColors.primary,
                  foregroundColor: AnnvaColors.primaryForeground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AnnvaRadius.full)),
                ),
                child: const Text('List this item →', style: TextStyle(fontFamily: 'WorkSans', fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AnnvaColors.backgroundSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AnnvaRadius.xl),
          border: Border.all(color: AnnvaColors.border, style: BorderStyle.solid),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                    child: Image.file(File(_selectedImage!.path), width: double.infinity, height: 200, fit: BoxFit.cover),
                  ),
                  if (_isScanning)
                    Container(
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(AnnvaRadius.xl)),
                      child: const Center(child: CircularProgressIndicator(color: AnnvaColors.ochre)),
                    ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: AnnvaColors.primary, size: 40),
                  SizedBox(height: 8),
                  Text('ADD PHOTO FOR AI SCAN', style: TextStyle(fontFamily: 'WorkSans', color: AnnvaColors.muted, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AnnvaColors.backgroundCard,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () { Navigator.pop(ctx); _pickImageFromSource(ImageSource.gallery); },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () { Navigator.pop(ctx); _pickImageFromSource(ImageSource.camera); },
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Item name', _nameCtrl, suffixIcon: _isScanned ? const Icon(Icons.auto_awesome, color: AnnvaColors.ochre, size: 18) : null),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDropdown('Vertical', _verticals, _selectedVertical, (v) => setState(() => _selectedVertical = v!))),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Servings', _qtyCtrl, isNumeric: true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Original price ₹', _priceCtrl, isNumeric: true),
        _buildPriceCalculation(),
        const SizedBox(height: 24),
        Text('WHEN WAS THIS COOKED?', style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre)),
        const SizedBox(height: 12),
        _buildCookTimeSelector(),
        const SizedBox(height: 24),
        _buildRefrigerationToggle(),
        const SizedBox(height: 12),
        _buildTimeRemaining(),
        const SizedBox(height: 24),
        Text('DIET TAGS', style: AnnvaTextStyles.label),
        const SizedBox(height: 12),
        _buildMultiSelect(),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isNumeric = false, Widget? suffixIcon}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AnnvaColors.backgroundCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AnnvaRadius.md), borderSide: const BorderSide(color: AnnvaColors.border)),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AnnvaColors.backgroundCard, border: Border.all(color: AnnvaColors.border), borderRadius: BorderRadius.circular(AnnvaRadius.md)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCookTimeSelector() {
    final options = [
      {'label': 'Just now', 'mins': 0},
      {'label': '30m ago', 'mins': 30},
      {'label': '1h ago', 'mins': 60},
      {'label': '2h ago', 'mins': 120},
      {'label': '3h ago', 'mins': 180},
    ];
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = _cookedMinutesElapsed == opt['mins'];
        return ChoiceChip(
          label: Text(opt['label'] as String),
          selected: isSelected,
          onSelected: (val) { if (val) setState(() => _cookedMinutesElapsed = opt['mins'] as int); },
          selectedColor: AnnvaColors.primary,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }

  Widget _buildRefrigerationToggle() {
    return Row(
      children: [
        const Text('Refrigerated?', style: TextStyle(fontFamily: 'WorkSans')),
        const SizedBox(width: 8),
        Switch(
          value: _isRefrigerated,
          activeColor: AnnvaColors.ochre,
          onChanged: (val) => setState(() => _isRefrigerated = val),
        ),
      ],
    );
  }

  Widget _buildTimeRemaining() {
    if (_isRefrigerated) return const Text('⏱ 24h remaining', style: TextStyle(color: AnnvaColors.cascadeFresh, fontWeight: FontWeight.bold));
    final remaining = 240 - _cookedMinutesElapsed;
    return Text('⏱ ${remaining ~/ 60}h ${remaining % 60}m remaining', style: const TextStyle(color: AnnvaColors.primary, fontWeight: FontWeight.bold));
  }

  Widget _buildPriceCalculation() {
    final orig = int.tryParse(_priceCtrl.text) ?? 0;
    if (orig == 0) return const SizedBox.shrink();
    final factor = 1.0 - (_cookedMinutesElapsed / 240.0);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4),
      child: Text('Live price: ₹${(orig * factor).round()}', style: const TextStyle(color: AnnvaColors.primary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMultiSelect() {
    return Wrap(
      spacing: 8,
      children: _allDiets.map((diet) {
        final isSelected = _selectedDiets.contains(diet);
        return ChoiceChip(
          label: Text(diet),
          selected: isSelected,
          onSelected: (val) {
            setState(() { if (val) _selectedDiets.add(diet); else _selectedDiets.remove(diet); });
          },
        );
      }).toList(),
    );
  }

  Future<void> _listSurplus() async {
    if (_nameCtrl.text.isEmpty || _qtyCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;

    final remainingMins = _isRefrigerated ? (24 * 60) : (240 - _cookedMinutesElapsed);
    final expiresAt = DateTime.now().add(Duration(minutes: remainingMins));
    final originalPrice = int.tryParse(_priceCtrl.text) ?? 0;
    final factor = 1.0 - (_cookedMinutesElapsed / 240.0);

    final newListing = FoodListing(
      id: 'L${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text,
      sellerId: 's1',
      sellerName: "Ravi's Kitchen",
      vertical: _selectedVertical,
      address: 'Lalbagh',
      diet: _selectedDiets.map((e) => e.toLowerCase()).toList(),
      qtyKg: double.tryParse(_qtyCtrl.text) ?? 0.0,
      servings: ((double.tryParse(_qtyCtrl.text) ?? 0.0) * 4).round(),
      originalPrice: originalPrice,
      currentPrice: (originalPrice * factor).round(),
      stage: CascadeStage.fresh, // simplified
      expiresAt: expiresAt,
      lat: 12.9507,
      lng: 77.5848,
      imageUrl: '🍲',
      createdAt: DateTime.now(),
      isActive: true,
    );

    await FirebaseFirestore.instance.collection('listings').doc(newListing.id).set(newListing.toJson());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Listed! Your item is now live.')));
      ref.invalidate(activeListingsProvider);
      context.go('/seller');
    }
  }
}
