import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ims_scanner_app/features/authentication/presentation/providers/auth_controller.dart';
import 'package:ims_scanner_app/features/authentication/data/local/network_config_storage.dart';
import 'package:ims_scanner_app/routers/app_route_paths.dart';
import 'package:ims_scanner_app/utils/constants/colors.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart';
import 'package:ims_scanner_app/utils/constants/text_strings.dart';
import 'package:ims_scanner_app/utils/helpers/helper_functions.dart';
import 'package:ims_scanner_app/utils/http/http_client.dart';
import 'package:ims_scanner_app/utils/validators/validation.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userIdController;
  late final TextEditingController _passwordController; 
  bool _obscurePassword = true;
  bool _isLoading = false;
 final logger = Logger();
  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authNotifier = ref.read(authControllerProvider.notifier);
    final selectedUrl = await NetworkConfigStorage.readSelectedUrl();
    if (!mounted) return;

    if (selectedUrl == null || selectedUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure your server URL first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } 
    logger.d("Selected URL: $selectedUrl"); 

    AppHttpClient.setBaseUrl(selectedUrl);

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _userIdController.text.trim();
      final password = _passwordController.text.trim();
      final ok = await authNotifier.signIn(
        userId,
        password,
      );

      if (!mounted) return;

      if (!ok) {
        final authState = ref.read(authControllerProvider);
        final message = authState.errorMessage ?? 'Invalid credentials. Please try again.';
        logger.w('Login failed for user: $userId, message: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      logger.i('Login successful for user: $userId');
      context.go(AppRoutePaths.home);
      return;
    } catch (e) {
      logger.e('Unexpected login error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isLoading,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spaceBtwSections,
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _userIdController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (value) => AppValidator.validateEmptyText('Username', value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.direct_right),
                      labelText: AppTextStrings.userName,
                      floatingLabelStyle: TextStyle(
                        color: dark ? AppColors.white : AppColors.black,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwInputFields),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: AppValidator.validatePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_isLoading) _submit();
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      floatingLabelStyle: TextStyle(
                        color: dark ? AppColors.white : AppColors.black,
                      ),
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwInputFields / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.push(AppRoutePaths.networkConfig),
                            child: Text(
                              'Network Configuration',
                              style: TextStyle(
                                color: dark ? AppColors.white : AppColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spaceBtwItems),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: const Text(AppTextStrings.signInTitle),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.push(AppRoutePaths.login),
                      child: const Text(AppTextStrings.createAccount),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.2),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                      SizedBox(width: 12),
                      Text('Signing in... Please wait'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
