import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/mp_button.dart';
import 'widgets/pin_input_widget.dart';
import 'widgets/numeric_keyboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  String _pin = '';
  bool _isLoading = false;

  void _onDigitPressed(String digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
      });
    }
  }

  void _onBackPressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _submit() async {
    if ((_pin.length != 6 && _pin.length != 4) || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final orientador = await _authService.login(_pin);
      if (mounted && orientador != null) {
        final role = await _authService.getSavedUserRole();
        if (!mounted) return;
        if (role == 'admin' || orientador.id == 9999) {
          context.go('/admin');
        } else {
          context.go('/schools');
        }
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _pin.length == 6 || _pin.length == 4;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              // Brand Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D0085DB),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Via Audit',
                style: AppTextStyles.sans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Digite seu PIN de acesso',
                style: AppTextStyles.sans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // PIN Input Visual
              PinInputWidget(pin: _pin),
              const SizedBox(height: 32),

              // Botão Continuar
              MpButton(
                text: 'Continuar',
                onPressed: isComplete && !_isLoading ? _submit : null,
                isLoading: _isLoading,
              ),

              const Spacer(),

              // Teclado Numérico Customizado
              NumericKeyboard(
                onDigitPressed: _onDigitPressed,
                onBackPressed: _onBackPressed,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
