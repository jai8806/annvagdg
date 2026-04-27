import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    // Initialise the ONNX classifier asynchronously
    _classifier
        .init()
        .then((_) {
          if (mounted) setState(() => _classifierReady = true);
        })
        .catchError((e) {
          debugPrint('FoodClassifier init error: $e');
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

  /// Opens a modal bottom sheet so the user can choose between
  /// uploading from their gallery or taking a photo with the camera.
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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
              Text(
                'ADD FOOD PHOTO',
                style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.muted),
              ),
              const SizedBox(height: 12),
              // Upload from gallery
              _sheetOption(
                ctx: ctx,
                icon: Icons.photo_library_outlined,
                title: 'Upload from device',
                subtitle: 'Choose from gallery · JPG, PNG',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              // Take photo with camera
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
              const SizedBox(height: 8),
              // Cancel
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A single tappable row inside the bottom sheet.
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
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AnnvaColors.muted, size: 18),
          ],
        ),
      ),
    );
  }

  /// Picks an image from [source] (gallery or camera) then runs REAL AI classification.
  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null) return;

    setState(() {
      _selectedImage = image;
      _isScanning = true;
      _isScanned = false;
      _classifyResult = null;
      _suggestions = [];
      _nameCtrl.clear();
    });

    try {
      final bytes = await image.readAsBytes();
      debugPrint('>>> Image bytes: ${bytes.length}');
      debugPrint('>>> Classifier initialized: $_classifierReady');

      final result = await _classifier.classify(bytes);

      debugPrint('>>> Result: $result');
      debugPrint('>>> Top label: ${result?.top.displayName}');
      debugPrint('>>> Confidence: ${result?.top.confidence}');

      if (!mounted) return;

      setState(() {
        _isScanning = false;

        _classifyResult = result;

        if (result != null) {
          _isScanned = true;
          _nameCtrl.text =
              result.top.displayName; // always fill, regardless of confidence
          _suggestions = result.shouldAutoFill ? [] : result.top3;
        } else {
          // Confidence < 65% — leave blank, show suggestion chips
          _isScanned = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _isScanned = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not identify food: $e')));
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
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AnnvaColors.primary,
                  size: 18,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        title: GestureDetector(
          onTap: () => context.go('/'),
          child: const AnnvaLogo(fontSize: 24),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. SELLER HEADER
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
                  Text(
                    'MTR — Lalbagh · Restaurant partner since 2024',
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

          // 2. STATS ROW
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AnnvaSpacing.containerPadding,
                ),
                children: [
                  _buildPrimaryStatCard(),
                  const SizedBox(width: AnnvaSpacing.sm),
                  _buildLightStatCard(
                    label: 'ALCHEMYSCORE ✦',
                    value: '782 / 900',
                    subtext: 'Eligible: ₹1.8L credit via partner banks',
                    actionText: 'View breakdown →',
                  ),
                  const SizedBox(width: AnnvaSpacing.sm),
                  Container(
                    width: 280,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AnnvaColors.backgroundCard,
                      borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                      border: Border.all(color: AnnvaColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BRSR / ESG EXPORT',
                          style: AnnvaTextStyles.label.copyWith(
                            color: AnnvaColors.ochre,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '1,842 kg rescued · 4.6T CO₂e avoided',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            color: AnnvaColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AnnvaColors.border),
                            borderRadius: BorderRadius.circular(
                              AnnvaRadius.full,
                            ),
                          ),
                          child: Text(
                            'Download PDF',
                            style: AnnvaTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. LIST SURPLUS SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AnnvaSpacing.lg),
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
                            Text(
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
                      Text(
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
                      final isWide = constraints.maxWidth > 600;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUploadBox(),
                            const SizedBox(width: AnnvaSpacing.lg),
                            Expanded(child: _buildForm()),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUploadBox(),
                            const SizedBox(height: AnnvaSpacing.md),
                            _buildForm(),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AnnvaSpacing.lg),
                  const SizedBox.shrink(), // placeholder
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
                      child: Text(
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

          // 4. LIVE LISTINGS
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

  Widget _buildPrimaryStatCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnnvaColors.primary,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOVERED TODAY',
            style: AnnvaTextStyles.label.copyWith(
              color: AnnvaColors.creamLight.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Text(
            '₹9,840',
            style: AnnvaTextStyles.h1.copyWith(
              color: AnnvaColors.creamLight,
              fontSize: 40,
            ),
          ),
          Text(
            'vs ₹34,200 would-have-wasted',
            style: TextStyle(
              fontFamily: 'WorkSans',
              color: AnnvaColors.creamLight.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AnnvaColors.creamLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.29,
              child: Container(
                decoration: BoxDecoration(
                  color: AnnvaColors.ochre,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightStatCard({
    required String label,
    required String value,
    required String subtext,
    String? actionText,
    Widget? actionWidget,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
          ),
          const Spacer(),
          Text(
            value,
            style: AnnvaTextStyles.h1.copyWith(
              color: AnnvaColors.primary,
              fontSize: 24,
            ),
          ),
          if (subtext.isNotEmpty)
            Text(
              subtext,
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.muted,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 12),
          if (actionText != null)
            Text(
              actionText,
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.ochre,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (actionWidget != null) actionWidget,
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    // ── State: image selected (preview + scanning overlay) ──────────────────
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
              // Image emoji placeholder (swap with Image.file when not scanning)
              const Center(child: Text('🍲', style: TextStyle(fontSize: 64))),
              // Scanning overlay
              if (_isScanning)
                Container(
                  decoration: BoxDecoration(
                    color: AnnvaColors.background.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: AnnvaColors.ochre,
                          strokeWidth: 2.5,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Identifying food…',
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
              // Success badge
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
                    child: Text(
                      '✓ AI identified',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(),
              // Re-shoot hint
              if (!_isScanning)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AnnvaColors.background.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh,
                      size: 14,
                      color: AnnvaColors.muted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // ── State: idle — show two explicit option buttons ───────────────────────
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border, style: BorderStyle.solid),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label
          Text(
            'ADD PHOTO',
            textAlign: TextAlign.center,
            style: AnnvaTextStyles.label.copyWith(
              color: AnnvaColors.muted,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 10),
          // Upload from gallery button
          _uploadOptionButton(
            icon: Icons.photo_library_outlined,
            label: 'Upload',
            sublabel: 'from gallery',
            onTap: () => _pickImageFromSource(ImageSource.gallery),
          ),
          const SizedBox(height: 8),
          // Divider with OR
          Row(
            children: [
              Expanded(
                child: Divider(color: AnnvaColors.border, thickness: 0.5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'or',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 10,
                    color: AnnvaColors.muted,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: AnnvaColors.border, thickness: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Take photo with camera button
          _uploadOptionButton(
            icon: Icons.camera_alt_outlined,
            label: 'Camera',
            sublabel: 'take a photo',
            onTap: () => _pickImageFromSource(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  /// A compact tappable card for each upload option shown in the idle state.
  Widget _uploadOptionButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AnnvaColors.backgroundCard,
          borderRadius: BorderRadius.circular(AnnvaRadius.md),
          border: Border.all(color: AnnvaColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AnnvaColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Item name', _nameCtrl)),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                'Vertical',
                _verticals,
                _selectedVertical,
                (v) => setState(() => _selectedVertical = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'for how many people?',
                _qtyCtrl,
                isNumeric: true,
              ),
            ),
            const SizedBox(width: 16),
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
        Text(
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
          Padding(
            padding: const EdgeInsets.only(left: 8),
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
      return Text(
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
      style: TextStyle(
        fontFamily: 'WorkSans',
        color: AnnvaColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool isNumeric = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'WorkSans',
          color: AnnvaColors.muted,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AnnvaColors.backgroundCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          hint: Text(label),
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
        children: _allDiets.map((diet) {
          final isSelected = _selectedDiets.contains(diet);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(diet),
              selected: isSelected,
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
                color: isSelected ? AnnvaColors.primary : AnnvaColors.border,
              ),
            ),
          );
        }).toList(),
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
          return SliverToBoxAdapter(
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
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.xl),
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

        final listings = docs
            .map((doc) => FoodListing.fromFirestore(doc))
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
}
