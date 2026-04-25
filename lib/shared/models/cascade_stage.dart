import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';

import '../../core/theme/annva_colors.dart';

/// The five cascade stages that define Annva's core product logic.
///
/// Every food listing moves through Fresh → Good Deal → Hot Deal → Last Call → NGO as time passes.
enum CascadeStage {
  /// 0-1h elapsed · 85-90% of price
  @JsonValue('fresh')
  fresh,

  /// 1-2h elapsed · 65-75% of price
  @JsonValue('good_deal')
  goodDeal,

  /// 2-3h elapsed · 40-55% of price
  @JsonValue('hot_deal')
  hotDeal,

  /// 3-3.5h elapsed · 20-30% of price
  @JsonValue('last_call')
  lastCall,

  /// 3.5-4h elapsed · Free, auto-NGO
  @JsonValue('ngo')
  ngo;

  /// Main badge / accent colour for this stage.
  Color get color {
    switch (this) {
      case CascadeStage.fresh:
        return AnnvaColors.cascadeFresh;
      case CascadeStage.goodDeal:
        return AnnvaColors.cascadeGoodDeal;
      case CascadeStage.hotDeal:
        return AnnvaColors.cascadeMid;
      case CascadeStage.lastCall:
        return AnnvaColors.cascadeLastCall;
      case CascadeStage.ngo:
        return AnnvaColors.cascadeUrgent;
    }
  }

  /// Light background tint for cards in this stage.
  Color get backgroundColor {
    switch (this) {
      case CascadeStage.fresh:
        return AnnvaColors.cascadeFreshBg;
      case CascadeStage.goodDeal:
        return AnnvaColors.cascadeGoodDealBg;
      case CascadeStage.hotDeal:
        return AnnvaColors.cascadeMidBg;
      case CascadeStage.lastCall:
        return AnnvaColors.cascadeLastCallBg;
      case CascadeStage.ngo:
        return AnnvaColors.cascadeUrgentBg;
    }
  }

  /// Human-readable label shown on the badge.
  String get label {
    switch (this) {
      case CascadeStage.fresh:
        return 'Fresh — 15% off';
      case CascadeStage.goodDeal:
        return 'Good Deal — 35% off';
      case CascadeStage.hotDeal:
        return 'Hot Deal — 60% off';
      case CascadeStage.lastCall:
        return 'Last Call — 80% off';
      case CascadeStage.ngo:
        return 'Free Pickup';
    }
  }

  /// Short label without discount detail.
  String get shortLabel {
    switch (this) {
      case CascadeStage.fresh:
        return 'Fresh';
      case CascadeStage.goodDeal:
        return 'Good Deal';
      case CascadeStage.hotDeal:
        return 'Hot Deal';
      case CascadeStage.lastCall:
        return 'Last Call';
      case CascadeStage.ngo:
        return 'Urgent / NGO';
    }
  }

  /// Parse from Firestore string.
  static CascadeStage fromString(String value) {
    switch (value) {
      case 'fresh':
        return CascadeStage.fresh;
      case 'good_deal':
        return CascadeStage.goodDeal;
      case 'hot_deal':
        return CascadeStage.hotDeal;
      case 'last_call':
        return CascadeStage.lastCall;
      case 'ngo':
      case 'urgent': // fallback for old data
        return CascadeStage.ngo;
      default:
        return CascadeStage.fresh;
    }
  }
}
