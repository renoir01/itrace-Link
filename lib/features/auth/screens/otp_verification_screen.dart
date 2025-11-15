import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../services/sms_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/custom_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? userType;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.userType,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _remainingSeconds = 600; // 10 minutes
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 600; // Reset to 10 minutes
    _isResendEnabled = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter complete OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final success = await authService.verifyOTP(otp);

      if (!mounted) return;

      if (success) {
        // OTP verified successfully
        if (widget.userType != null) {
          // Go to registration form for the specific user type
          context.go('/registration', extra: widget.userType);
        } else {
          // Phone verified, go to dashboard or complete profile
          context.go('/dashboard');
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP. Please try again.';
          _isLoading = false;
        });
        _clearOTP();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error verifying OTP: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final smsService = SmsService();
      final localization = context.read<LocalizationService>();

      // Send new OTP
      final success = await authService.sendOTP(widget.phoneNumber);

      if (!mounted) return;

      if (success) {
        _startTimer();
        _clearOTP();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localization.isEnglish
                  ? 'OTP sent successfully'
                  : 'Kode yoherejwe neza',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to send OTP. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error sending OTP: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearOTP() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all 6 digits entered
    if (index == 5 && value.isNotEmpty) {
      final allFilled = _controllers.every((c) => c.text.isNotEmpty);
      if (allFilled) {
        _verifyOTP();
      }
    }

    // Clear error when user starts typing
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.isEnglish ? 'Verify OTP' : 'Emeza Kode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  size: 60,
                  color: AppTheme.primaryGreen,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                localization.isEnglish
                    ? 'Verification Code'
                    : 'Kode yo Kwemeza',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                localization.isEnglish
                    ? 'We sent a 6-digit code to'
                    : 'Twohereje kode y\'imibare 6 kuri',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Phone number
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
              ),

              const SizedBox(height: 40),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => _buildOTPBox(index),
                ),
              ),

              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Timer
              if (!_isResendEnabled)
                Text(
                  localization.isEnglish
                      ? 'Code expires in ${_formatTime(_remainingSeconds)}'
                      : 'Kode irangira mu ${_formatTime(_remainingSeconds)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),

              const SizedBox(height: 32),

              // Verify Button
              CustomButton(
                text: localization.isEnglish ? 'Verify' : 'Emeza',
                onPressed: _isLoading ? null : _verifyOTP,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localization.isEnglish
                        ? "Didn't receive code?"
                        : 'Ntawe wakiriye kode?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _isResendEnabled && !_isLoading
                        ? _resendOTP
                        : null,
                    child: Text(
                      localization.isEnglish ? 'Resend' : 'Ongera wohereze',
                      style: TextStyle(
                        color: _isResendEnabled
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Change number
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        context.pop();
                      },
                child: Text(
                  localization.isEnglish
                      ? 'Change phone number'
                      : 'Hindura nimero ya telefoni',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? AppTheme.primaryGreen
              : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _onOTPChanged(index, value),
        onTap: () {
          // Select all text when tapping on a box
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        },
      ),
    );
  }
}
