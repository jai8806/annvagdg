import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';

class DemoHeatmap extends StatelessWidget {
  const DemoHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AnnvaSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text('LIVE HEATMAP · BENGALURU', style: AnnvaTextStyles.label),
          const SizedBox(height: AnnvaSpacing.sm),

          // Map container
          SizedBox(
            height: 280,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AnnvaRadius.xl),
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(12.9716, 77.5946),
                  initialZoom: 11.5,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.none, // non-interactive in demo
                  ),
                  backgroundColor: AnnvaColors.background,
                ),
                children: [
                  // OpenStreetMap tile layer — free, no API key
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'in.annva.annva',
                    tileProvider: NetworkTileProvider(
                      headers: {
                        'User-Agent': 'AnnvaApp/1.0 (contact@annva.in)',
                      },
                    ),
                    maxZoom: 19,
                    minZoom: 3,
                  ),
                  // Cascade markers
                  CircleLayer(
                    circles: [
                      // URGENT — red
                      CircleMarker(
                        point: const LatLng(12.9507, 77.5848),
                        radius: 14,
                        color: AnnvaColors.cascadeUrgent.withValues(alpha: 0.35),
                        borderColor: AnnvaColors.cascadeUrgent,
                        borderStrokeWidth: 2,
                      ),
                      CircleMarker(
                        point: const LatLng(12.9116, 77.6389),
                        radius: 14,
                        color: AnnvaColors.cascadeUrgent.withValues(alpha: 0.35),
                        borderColor: AnnvaColors.cascadeUrgent,
                        borderStrokeWidth: 2,
                      ),
                      CircleMarker(
                        point: const LatLng(12.9756, 77.6099),
                        radius: 14,
                        color: AnnvaColors.cascadeUrgent.withValues(alpha: 0.35),
                        borderColor: AnnvaColors.cascadeUrgent,
                        borderStrokeWidth: 2,
                      ),
                      // MID — ochre
                      CircleMarker(
                        point: const LatLng(12.9352, 77.6245),
                        radius: 12,
                        color: AnnvaColors.cascadeMid.withValues(alpha: 0.35),
                        borderColor: AnnvaColors.cascadeMid,
                        borderStrokeWidth: 2,
                      ),
                      CircleMarker(
                        point: const LatLng(12.9698, 77.7500),
                        radius: 12,
                        color: AnnvaColors.cascadeMid.withValues(alpha: 0.35),
                        borderColor: AnnvaColors.cascadeMid,
                        borderStrokeWidth: 2,
                      ),
                      CircleMarker(
                        point: const LatLng(12.9010, 77.6860),
                        radius: 12,
                        color: AnnvaColors.cascadeMid.withValues(alpha: 0.35),
                        borderColor: AnnvaColors.cascadeMid,
                        borderStrokeWidth: 2,
                      ),
                      // FRESH — green
                      CircleMarker(
                        point: const LatLng(12.9784, 77.6408),
                        radius: 10,
                        color: AnnvaColors.cascadeFresh.withValues(alpha: 0.35),
                        borderColor: AnnvaColors.cascadeFresh,
                        borderStrokeWidth: 2,
                      ),
                      CircleMarker(
                        point: const LatLng(12.9250, 77.5938),
                        radius: 10,
                        color: AnnvaColors.cascadeFresh.withValues(alpha: 0.35),
                        borderColor: AnnvaColors.cascadeFresh,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Map legend
          const SizedBox(height: AnnvaSpacing.sm),
          Row(
            children: [
              _legendDot(AnnvaColors.cascadeUrgent),
              Text(' Urgent  ', style: AnnvaTextStyles.bodySmall),
              _legendDot(AnnvaColors.cascadeMid),
              Text(' Mid cascade  ', style: AnnvaTextStyles.bodySmall),
              _legendDot(AnnvaColors.cascadeFresh),
              Text(' Fresh', style: AnnvaTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
