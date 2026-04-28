import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../shared/models/cascade_stage.dart';
import '../../../shared/models/food_listing.dart';
import '../../../shared/providers/listings_provider.dart';
import '../../../shared/widgets/annva_logo.dart';
import '../../../shared/widgets/food_listing_card.dart';
import '../services/food_classifier_service.dart';

class SellerHomeScreen extends ConsumerStatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  ConsumerState<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends ConsumerState<SellerHomeScreen> {
  bool _isScanning = false;
  bool _isScanned = false;
  XFile? _selectedImage;

  // AI classifier
  final _classifier = FoodClassifierService();
  bool _classifierReady = false;
  ClassifyResult? _classifyResult;
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
    _priceCtrl.addListener(() {
      setState(() {});
    });
    _classifier
        .init()
        .then((_) {
          if (mounted) {
            setState(() {
              _classifierReady = true;
              _debugStatus = 'Model Ready';
            });
          }
        })
        .catchError((e) {
          debugPrint('FoodClassifier init error: $e');
          if (mounted) setState(() => _debugStatus = 'Model Error: $e');
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

  /// Picks an image and auto-fills the Item Name field
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
      _predictedName = '';
    });

    try {
      final bytes = await image.readAsBytes();
      final result = await _classifier.classify(bytes);

      if (!mounted) return;

      setState(() {
        _isScanning = false;
        if (result != null) {
          _classifyResult = result;
          _isScanned = true;
          _predictedName = result.top.displayName;
          // 1. AUTO-FILL: "Print" the name into the controller
          _nameCtrl.text = _predictedName;
          // 2. SUGGESTIONS: Keep other top predictions for manual correction
          _suggestions = result.top3;
          _debugStatus = 'Got: $_predictedName ${(result.top.confidence * 100).toStringAsFixed(0)}%';
        } else {
          _debugStatus = 'Failed to identify';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _isScanned = false;
        _debugStatus = 'Error: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not identify food: $e')));
    }
  }

  // UI Helper for Form TextFields
  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool isNumeric = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
          fontFamily: 'WorkSans',
          color: AnnvaColors.muted,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AnnvaColors.backgroundCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.md),
          borderSide: const BorderSide(color: AnnvaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.md),
          borderSide: const BorderSide(color: AnnvaColors.primary),
        ),
      ),
    );
  }

  Widget _buildPredictionDisplay() {
    if (!_isScanned || _predictedName.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Predicted:',
            style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
          ),
          Text(
            _predictedName,
            style: AnnvaTextStyles.h1,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PREDICTION DISPLAY
        _buildPredictionDisplay(),

        // ITEM NAME (Model result printed here)
        _buildTextField(
          'Item name',
          _nameCtrl,
          suffixIcon: _isScanned
              ? const Icon(
                  Icons.auto_awesome,
                  color: AnnvaColors.ochre,
                  size: 18,
                )
              : null,
        ),

        // RE-TYPE / SUGGESTIONS SECTION
        if (_isScanned && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: const Text(
              'Not correct? Tap to change or re-type above:',
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.muted,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestions
                  .map(
                    (pred) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(pred.displayName),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'WorkSans',
                        ),
                        onPressed: () {
                          setState(() => _nameCtrl.text = pred.displayName);
                        },
                        backgroundColor: AnnvaColors.backgroundSecondary,
                        shape: const StadiumBorder(
                          side: BorderSide(color: AnnvaColors.border),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                'Vertical',
                _verticals,
                _selectedVertical,
                (v) => setState(() => _selectedVertical = v!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'Servings (People)',
                _qtyCtrl,
                isNumeric: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    'Original price ₹',
                    _priceCtrl,
                    isNumeric: true,
                  ),
                  const SizedBox(height: 4),
                  _buildPriceCalculation(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'WHEN WAS THIS COOKED?',
          style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
        ),
        const SizedBox(height: 8),
        _buildCookTimeSelector(),
        const SizedBox(height: 16),
        _buildRefrigerationToggle(),
        const SizedBox(height: 12),
        _buildTimeRemaining(),
        const SizedBox(height: 24),
        _buildMultiSelect(),
      ],
    );
  }

  // ─── Existing Helper Methods ───────────────────────────────────────────────

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AnnvaColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AnnvaColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _sheetOption(
                ctx: ctx,
                icon: Icons.photo_library_outlined,
                title: 'Upload from device',
                subtitle: 'Choose from gallery',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              _sheetOption(
                ctx: ctx,
                icon: Icons.camera_alt_outlined,
                title: 'Take a photo',
                subtitle: 'Opens rear camera',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required BuildContext ctx,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AnnvaRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AnnvaColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AnnvaRadius.lg),
          border: Border.all(color: AnnvaColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AnnvaColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AnnvaRadius.md),
              ),
              child: Icon(icon, color: AnnvaColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AnnvaColors.muted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    if (_selectedImage != null) {
      return GestureDetector(
        onTap: _showImageSourceSheet,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AnnvaColors.backgroundSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AnnvaRadius.xl),
            border: Border.all(color: AnnvaColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Display actual image if possible, else emoji
              ClipRRect(
                borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                child: Image.file(
                  File(_selectedImage!.path),
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              if (_isScanning)
                Container(
                  decoration: BoxDecoration(
                    color: AnnvaColors.background.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AnnvaColors.ochre,
                          strokeWidth: 2.5,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Identifying…',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_isScanned && !_isScanning)
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AnnvaColors.cascadeFresh,
                      borderRadius: BorderRadius.circular(AnnvaRadius.sm),
                    ),
                    child: const Text(
                      '✓ AI identified',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: AnnvaColors.backgroundSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AnnvaRadius.xl),
          border: Border.all(
            color: AnnvaColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              color: AnnvaColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'ADD PHOTO',
              style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  // (Remainder of original helper methods like _buildDropdown, _buildMultiSelect, _listSurplus, _buildLiveListings etc. stay exactly as you wrote them)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: AnnvaColors.background,
        elevation: 0,
        title: const AnnvaLogo(fontSize: 24),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELLER',
                    style: AnnvaTextStyles.label.copyWith(
                      color: AnnvaColors.ochre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Ravi\'s Kitchen', style: AnnvaTextStyles.h1),
                  const SizedBox(height: 4),
                  const Text(
                    'MTR — Lalbagh · Partner since 2024',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'List surplus food',
                              style: AnnvaTextStyles.h2,
                            ),
                            const Text(
                              'Snap a photo. Our AI fills the rest.',
                              style: TextStyle(
                                fontFamily: 'WorkSans',
                                color: AnnvaColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '✦ AI-assisted',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          color: AnnvaColors.ochre,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AnnvaSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUploadBox(),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _debugStatus,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.greenAccent,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: AnnvaSpacing.md),
                          _buildForm(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AnnvaSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _listSurplus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AnnvaColors.primary,
                        foregroundColor: AnnvaColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AnnvaRadius.full),
                        ),
                      ),
                      child: const Text(
                        'List this item →',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildIncomingOrders(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.xl,
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.sm,
              ),
              child: Text(
                'YOUR LIVE LISTINGS',
                style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
              ),
            ),
          ),
          _buildLiveListings(),
          const SliverToBoxAdapter(child: SizedBox(height: AnnvaSpacing.xxl)),
        ],
      ),
    );
  }

  // --- Placeholder methods for functionality you already have ---
  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        border: Border.all(color: AnnvaColors.border),
        borderRadius: BorderRadius.circular(AnnvaRadius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMultiSelect() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _allDiets
            .map(
              (diet) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(diet),
                  selected: _selectedDiets.contains(diet),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedDiets.add(diet);
                      } else {
                        _selectedDiets.remove(diet);
                      }
                    });
                  },
                  selectedColor: AnnvaColors.primary.withValues(alpha: 0.1),
                  backgroundColor: AnnvaColors.backgroundCard,
                  side: BorderSide(
                    color: _selectedDiets.contains(diet)
                        ? AnnvaColors.primary
                        : AnnvaColors.border,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCookTimeSelector() {
    final options = [
      {'label': 'Just now', 'mins': 0},
      {'label': '30 min ago', 'mins': 30},
      {'label': '1 hour ago', 'mins': 60},
      {'label': '2 hours ago', 'mins': 120},
      {'label': '3 hours ago', 'mins': 180},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = _cookedMinutesElapsed == opt['mins'];
        return ChoiceChip(
          label: Text(opt['label'] as String),
          selected: isSelected,
          onSelected: (val) {
            if (val) setState(() => _cookedMinutesElapsed = opt['mins'] as int);
          },
          selectedColor: AnnvaColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AnnvaColors.background : AnnvaColors.foreground,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: AnnvaColors.backgroundCard,
          side: BorderSide(
            color: isSelected ? AnnvaColors.primary : AnnvaColors.border,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRefrigerationToggle() {
    return Row(
      children: [
        const Text(
          'Currently refrigerated?',
          style: TextStyle(fontFamily: 'WorkSans', fontSize: 14),
        ),
        const SizedBox(width: 8),
        Switch(
          value: _isRefrigerated,
          activeThumbColor: AnnvaColors.ochre,
          activeTrackColor: AnnvaColors.ochre.withValues(alpha: 0.4),
          onChanged: (val) => setState(() => _isRefrigerated = val),
        ),
        if (_isRefrigerated)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Safe for 24h',
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.cascadeFresh,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeRemaining() {
    if (_isRefrigerated) {
      return const Text(
        '⏱ 24h 0m remaining before NGO cascade',
        style: TextStyle(
          fontFamily: 'WorkSans',
          color: AnnvaColors.cascadeFresh,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final remainingMins = 240 - _cookedMinutesElapsed;
    final hrs = remainingMins ~/ 60;
    final mins = remainingMins % 60;

    Color color = AnnvaColors.cascadeFresh;
    if (remainingMins < 60) {
      color = AnnvaColors.cascadeUrgent;
    } else if (remainingMins <= 120) {
      color = AnnvaColors.cascadeMid;
    }

    return Text(
      '⏱ ${hrs}h ${mins}m remaining before NGO cascade',
      style: TextStyle(
        fontFamily: 'WorkSans',
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPriceCalculation() {
    final orig = int.tryParse(_priceCtrl.text) ?? 0;
    if (orig == 0) return const SizedBox.shrink();

    final discountFactor = 1.0 - (_cookedMinutesElapsed / 240.0);
    final listingPrice = (orig * discountFactor).round();
    final discountPercent = ((1.0 - discountFactor) * 100).round();

    return Text(
      'Annva price: ₹$listingPrice ($discountPercent% off)',
      style: const TextStyle(
        fontFamily: 'WorkSans',
        color: AnnvaColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  Widget _buildLiveListings() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('sellerId', isEqualTo: 's1')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text(
                'Error loading listings',
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  color: AnnvaColors.muted,
                ),
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AnnvaSpacing.xl),
              child: Text(
                'No active listings. List your first item above.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  color: AnnvaColors.muted,
                ),
              ),
            ),
          );
        }

        final now = DateTime.now();
        final listings = docs
            .map((doc) => FoodListing.fromFirestore(doc))
            .where((listing) => listing.expiresAt.isAfter(now))
            .toList();
        listings.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AnnvaSpacing.containerPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AnnvaSpacing.md),
                child: FoodListingCard(
                  listing: listings[index],
                  onTap: () {},
                  onRescueTap: () {},
                ),
              );
            }, childCount: listings.length),
          ),
        );
      },
    );
  }

  Widget _buildIncomingOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: 's1')
          .where('status', isEqualTo: 'confirmed')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final orders = snapshot.data!.docs;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INCOMING ORDERS',
                  style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
                ),
                const SizedBox(height: 12),
                ...orders.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildOrderCard(doc.id, data);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(String orderId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Row(
        children: [
          const Text('📦', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['foodName'] ?? 'Rescue Order',
                  style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Code: ${data['pickupCode']}',
                  style: AnnvaTextStyles.mono,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _confirmPickup(orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AnnvaColors.cascadeFresh,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Confirm Pickup'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPickup(String orderId) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': 'picked_up'});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup confirmed! ✓')),
      );
    }
  }

  Future<void> _listSurplus() async {
    if (_nameCtrl.text.isEmpty ||
        _qtyCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    final remainingMins = _isRefrigerated
        ? (24 * 60)
        : (240 - _cookedMinutesElapsed);
    final expiresAt = DateTime.now().add(Duration(minutes: remainingMins));

    CascadeStage stage;
    if (_cookedMinutesElapsed >= 210) {
      // 3.5h
      stage = CascadeStage.ngo;
    } else if (_cookedMinutesElapsed >= 180) {
      // 3h
      stage = CascadeStage.lastCall;
    } else if (_cookedMinutesElapsed >= 120) {
      // 2h
      stage = CascadeStage.hotDeal;
    } else if (_cookedMinutesElapsed >= 60) {
      // 1h
      stage = CascadeStage.goodDeal;
    } else {
      stage = CascadeStage.fresh;
    }

    final originalPrice = int.tryParse(_priceCtrl.text) ?? 0;
    final discountFactor = 1.0 - (_cookedMinutesElapsed / 240.0);
    int currentPrice = (originalPrice * discountFactor).round();
    if (stage == CascadeStage.ngo) {
      currentPrice = 0;
    }

    final newListing = FoodListing(
      id: 'L${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text,
      sellerId: 's1', // MTR hardcoded for demo
      sellerName: 'MTR',
      vertical: _selectedVertical,
      address: 'Lalbagh',
      diet: _selectedDiets.map((e) => e.toLowerCase()).toList(),
      qtyKg: double.tryParse(_qtyCtrl.text) ?? 0.0,
      servings: ((double.tryParse(_qtyCtrl.text) ?? 0.0) * 4)
          .round(), // arbitrary calculation
      originalPrice: originalPrice,
      currentPrice: currentPrice,
      stage: stage,
      expiresAt: expiresAt,
      lat: 12.9507,
      lng: 77.5848,
      imageUrl: '🍲',
      createdAt: DateTime.now(),
      isActive: true,
    );

    await FirebaseFirestore.instance
        .collection('listings')
        .doc(newListing.id)
        .set(newListing.toJson());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Listed! Your item is now live on the cascade.'),
        ),
      );
      ref.invalidate(activeListingsProvider);

      setState(() {
        _nameCtrl.clear();
        _qtyCtrl.clear();
        _priceCtrl.clear();
        _selectedDiets.clear();
        _selectedImage = null;
        _isScanned = false;
        _cookedMinutesElapsed = 0;
        _isRefrigerated = false;
      });
    }
  }
}
