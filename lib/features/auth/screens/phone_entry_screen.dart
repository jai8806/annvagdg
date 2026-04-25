import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../shared/widgets/annva_logo.dart';
import '../providers/auth_provider.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final TextEditingController _phoneController = TextEditingController();

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.length == 10) {
      ref.read(authNotifierProvider.notifier).sendOtp(phone);
      context.go('/auth/otp');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 10-digit mobile number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnnvaColors.background,
      body: Stack(
        children: [
          // Devanagari watermark: "अन्न" huge text very low opacity
          Positioned(
            top: -20,
            right: -40,
            child: Text(
              'अन्न',
              style: GoogleFonts.notoSerifDevanagari(
                fontSize: 180,
                fontWeight: FontWeight.w700,
                color: AnnvaColors.primary.withValues(alpha: 0.04),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AnnvaSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AnnvaSpacing.xl),
                  const AnnvaLogo(fontSize: 28),
                  const Spacer(flex: 2),

                  Text(
                    'Welcome to Annva',
                    style: GoogleFonts.instrumentSerif(
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                      color: AnnvaColors.primary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AnnvaSpacing.sm),
                  Text(
                    "India's food rescue network",
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      color: AnnvaColors.muted,
                    ),
                  ),
                  const SizedBox(height: AnnvaSpacing.xxl),

                  // Phone field
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AnnvaColors.border),
                      borderRadius: BorderRadius.circular(AnnvaRadius.full),
                      color: AnnvaColors.backgroundCard,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AnnvaSpacing.lg, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          '+91',
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AnnvaColors.primary,
                          ),
                        ),
                        const SizedBox(width: AnnvaSpacing.sm),
                        Container(width: 1, height: 24, color: AnnvaColors.border),
                        const SizedBox(width: AnnvaSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: GoogleFonts.workSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AnnvaColors.primary,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter mobile number',
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onSubmitted: (_) => _sendOtp(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AnnvaSpacing.xl),

                  // Primary CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AnnvaColors.primary,
                        foregroundColor: AnnvaColors.primaryForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AnnvaRadius.full),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send OTP',
                            style: GoogleFonts.workSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AnnvaSpacing.sm),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 3),
                  
                  // Bottom text
                  Center(
                    child: Text(
                      'By continuing you agree to our terms',
                      style: GoogleFonts.workSans(
                        fontSize: 10,
                        color: AnnvaColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AnnvaSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
