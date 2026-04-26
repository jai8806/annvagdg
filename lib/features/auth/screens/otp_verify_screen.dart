import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../providers/auth_provider.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      ref.read(authNotifierProvider.notifier).verifyOtp(otp);
      context.go('/auth/role');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final phoneStr = authState.phoneNumber ?? '0000000000';
    final last4 = phoneStr.length >= 4
        ? phoneStr.substring(phoneStr.length - 4)
        : 'XXXX';

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AnnvaColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AnnvaSpacing.containerPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AnnvaSpacing.xl),
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontFamily: 'InstrumentSerif',
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                  color: AnnvaColors.primary,
                ),
              ),
              const SizedBox(height: AnnvaSpacing.sm),
              Text(
                'Sent to +91 XXXXXX$last4',
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 16,
                  color: AnnvaColors.muted,
                ),
              ),
              const SizedBox(height: AnnvaSpacing.xxl),

              // OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),

              const SizedBox(height: AnnvaSpacing.xl),

              // Resend text
              Center(
                child: _countdown > 0
                    ? Text(
                        'Resend OTP in 0:${_countdown.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 14,
                          color: AnnvaColors.muted,
                        ),
                      )
                    : GestureDetector(
                        onTap: _startCountdown,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AnnvaColors.ochre,
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: _controllers[index].text.isNotEmpty
            ? AnnvaColors.backgroundCard
            : AnnvaColors.backgroundSecondary,
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? AnnvaColors.primary
              : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AnnvaRadius.sm),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AnnvaColors.primary,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (val) => _onChanged(val, index),
        ),
      ),
    );
  }
}
