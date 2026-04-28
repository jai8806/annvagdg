import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../auth/providers/auth_provider.dart';

class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: AnnvaColors.background,
        elevation: 0,
        title: Text('My Missions', style: AnnvaTextStyles.h1),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AnnvaColors.primary,
          unselectedLabelColor: AnnvaColors.muted,
          indicatorColor: AnnvaColors.primary,
          tabs: const [
            Tab(text: 'ACTIVE'),
            Tab(text: 'COMPLETED'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ActiveMissionsTab(),
          _CompletedMissionsTab(),
        ],
      ),
    );
  }
}

class _ActiveMissionsTab extends ConsumerWidget {
  const _ActiveMissionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'confirmed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('❌ MissionsStream Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final docs = snapshot.data?.docs ?? [];
        debugPrint('🔍 Active Missions Found: ${docs.length}');
        
        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text('No active rescues right now.', style: AnnvaTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    'New Stage 5 rescues appear here the moment\na seller triggers the cascade.',
                    textAlign: TextAlign.center,
                    style: AnnvaTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back at closing time — 8 PM is peak\nrescue hour in Bengaluru.',
                    textAlign: TextAlign.center,
                    style: AnnvaTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final order = doc.data() as Map<String, dynamic>;
            return VolunteerActiveMissionTile(order: order, orderId: doc.id);
          },
        );
      },
    );
  }
}

class VolunteerActiveMissionTile extends ConsumerWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const VolunteerActiveMissionTile({super.key, required this.order, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = order['items'] as List?;
    final foodName = (items != null && items.isNotEmpty) ? items[0]['name'] : 'Food Rescue';
    final sellerName = order['sellerName'] ?? 'Unknown Seller';
    final address = order['sellerAddress'] ?? '';
    final totalKg = order['totalKg'] ?? 0.0;
    final pickupCode = order['pickupCode'] ?? 'UNKNOWN';
    final lat = order['lat'] ?? 0.0;
    final lng = order['lng'] ?? 0.0;
    
    final expiresAt = (order['expiresAt'] as Timestamp?)?.toDate();
    final remainingMins = expiresAt != null 
        ? max(0, expiresAt.difference(DateTime.now()).inMinutes)
        : 60;
        
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: const Border(
          left: BorderSide(color: AnnvaColors.cascadeMid, width: 3),
          top: BorderSide(color: AnnvaColors.border, width: 1),
          right: BorderSide(color: AnnvaColors.border, width: 1),
          bottom: BorderSide(color: AnnvaColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AnnvaColors.cascadeMid.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('ACTIVE', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AnnvaColors.cascadeMid)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$foodName · $sellerName', 
                  style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${totalKg.toStringAsFixed(1).replaceAll('.0', '')}kg · Pickup code: $pickupCode', 
            style: AnnvaTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text('📍 $address · 0.8km away', style: AnnvaTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text('⏱ ${remainingMins}m remaining', 
            style: AnnvaTextStyles.bodySmall.copyWith(
              color: remainingMins < 30 ? AnnvaColors.cascadeUrgent : AnnvaColors.primary
            )),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  final url = Uri.parse('https://maps.google.com/?q=$lat,$lng');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AnnvaColors.primary,
                ),
                child: const Text('Navigate →'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showCompleteMissionSheet(context, ref, order, orderId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnnvaColors.cascadeFresh,
                  foregroundColor: AnnvaColors.creamLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Complete ✓'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCompleteMissionSheet(BuildContext context, WidgetRef ref, Map<String, dynamic> order, String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompleteMissionBottomSheet(order: order, orderId: orderId),
    );
  }
}

class CompleteMissionBottomSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const CompleteMissionBottomSheet({super.key, required this.order, required this.orderId});

  @override
  ConsumerState<CompleteMissionBottomSheet> createState() => _CompleteMissionBottomSheetState();
}

class _CompleteMissionBottomSheetState extends ConsumerState<CompleteMissionBottomSheet> {
  String _selectedNgo = 'Akshaya Patra';
  final List<String> _ngos = ['Akshaya Patra', 'Robin Hood Army', 'Feeding India', 'Goonj'];
  XFile? _imageFile;
  bool _isCompleting = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  String _generatePickupCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _completeMission() async {
    setState(() => _isCompleting = true);
    final user = ref.read(authNotifierProvider);
    final userId = user.userId;
    
    if (userId == null) {
      setState(() => _isCompleting = false);
      return;
    }

    try {
      final items = widget.order['items'] as List?;
      final listingId = (items != null && items.isNotEmpty) ? items[0]['listingId'] : 'unknown';
      final totalKg = widget.order['totalKg'] ?? 0.0;

      // Update order status
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'status': 'picked_up'
      });

      // Write certificate
      await FirebaseFirestore.instance.collection('certificates').add({
        'volunteerId': userId,
        'listingId': listingId,
        'ngoName': _selectedNgo,
        'kgRescued': totalKg,
        'completedAt': FieldValue.serverTimestamp(),
        'polygonHash': 'mock_${DateTime.now().millisecondsSinceEpoch}',
        'qrData': 'ANNVA-CERT-${_generatePickupCode()}',
        'foodName': (items != null && items.isNotEmpty) ? items[0]['name'] : 'Food Rescue',
        'sellerName': widget.order['sellerName'] ?? 'Unknown Seller',
      });

      // Update stats
      ref.read(authNotifierProvider.notifier).incrementRescues(totalKg.toDouble());

      if (mounted) {
        Navigator.pop(context); // close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Mission complete! Certificate earned.')),
        );
        // Optionally navigate to certificates tab if it existed
        // context.go('/volunteer/certificates');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AnnvaColors.creamLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AnnvaRadius.xl)),
          ),
          padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AnnvaColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('CONFIRM DELIVERY', style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre)),
              const SizedBox(height: 16),
              Text('Delivered to:', style: AnnvaTextStyles.body),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ngos.map((ngo) {
                  final isSelected = _selectedNgo == ngo;
                  return ChoiceChip(
                    label: Text(ngo),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedNgo = ngo);
                    },
                    selectedColor: AnnvaColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AnnvaColors.creamLight : AnnvaColors.primary,
                    ),
                    backgroundColor: AnnvaColors.background,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Photo proof (optional)', style: AnnvaTextStyles.body),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.centerLeft,
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_imageFile!.path), width: 100, height: 100, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: AnnvaColors.border, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: AnnvaColors.muted),
                                SizedBox(height: 4),
                                Text('Tap to add', style: TextStyle(fontSize: 10, color: AnnvaColors.muted)),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCompleting ? null : _completeMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnnvaColors.primary,
                    foregroundColor: AnnvaColors.primaryForeground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: _isCompleting 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm delivery ✓', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompletedMissionsTab extends ConsumerWidget {
  const _CompletedMissionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authNotifierProvider).userId;

    if (userId == null) {
      return const Center(child: Text('Please login first.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('certificates')
          .where('volunteerId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text('Your rescue history will appear here.', style: AnnvaTextStyles.h2, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Accept your first rescue from the Rescues tab.', style: AnnvaTextStyles.bodySmall),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/volunteer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AnnvaColors.primary,
                      foregroundColor: AnnvaColors.primaryForeground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('Go to Rescues →'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final cert = doc.data() as Map<String, dynamic>;
            return CompletedMissionTile(cert: cert, certId: doc.id);
          },
        );
      },
    );
  }
}

class CompletedMissionTile extends StatelessWidget {
  final Map<String, dynamic> cert;
  final String certId;

  const CompletedMissionTile({super.key, required this.cert, required this.certId});

  @override
  Widget build(BuildContext context) {
    final foodName = cert['foodName'] ?? 'Food Rescue';
    final sellerName = cert['sellerName'] ?? 'Unknown Seller';
    final ngoName = cert['ngoName'] ?? 'NGO';
    final kgRescued = cert['kgRescued'] ?? 0.0;
    final completedAt = (cert['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final dateStr = DateFormat('MMM d').format(completedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍲', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$foodName → $ngoName', 
                  style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$sellerName · $dateStr · ${kgRescued.toStringAsFixed(1).replaceAll('.0', '')}kg', 
            style: AnnvaTextStyles.bodySmall),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AnnvaColors.cascadeFresh),
                  const SizedBox(width: 4),
                  Text('RESCUED', style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.cascadeFresh)),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to certificate page
                  context.push('/volunteer/certificates/$certId');
                },
                style: TextButton.styleFrom(
                  foregroundColor: AnnvaColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View Certificate', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
