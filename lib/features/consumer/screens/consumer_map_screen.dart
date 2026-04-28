import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../shared/providers/listings_provider.dart';
import '../../../shared/widgets/annva_logo.dart';

class ConsumerMapScreen extends ConsumerWidget {
  const ConsumerMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(activeListingsProvider);

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
        title: const AnnvaLogo(fontSize: 24),
      ),
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(12.9716, 77.5946),
              initialZoom: 13,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              backgroundColor: AnnvaColors.background,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'in.annva.annva',
                tileProvider: NetworkTileProvider(
                  headers: {'User-Agent': 'AnnvaApp/1.0 (contact@annva.in)'},
                ),
                maxZoom: 19,
                minZoom: 3,
              ),
              // Dynamic markers from Firestore with Urgency Rings
              listingsAsync.when(
                data: (listings) => MarkerLayer(
                  markers: listings.map((l) {
                    final color = l.stage.color;

                    return Marker(
                      point: LatLng(l.lat, l.lng),
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => context.push('/consumer/listing/${l.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: color, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              l.imageUrl, // emoji
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),
            ],
          ),

          // Search / Filter overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AnnvaColors.backgroundCard,
                borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AnnvaColors.muted),
                  const SizedBox(width: 12),
                  Text(
                    'Search for surplus near you...',
                    style: AnnvaTextStyles.bodySmall.copyWith(
                      color: AnnvaColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
