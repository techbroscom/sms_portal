import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/language_selector.dart';
import '/bloc/auth/auth_bloc.dart';
import '/bloc/auth/auth_event.dart';
import '/bloc/auth/auth_state.dart';

import '../models/user.dart';
import 'home_screen_admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _userType = 'Student';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        setState(() => _isLoading = state is AuthLoading);

        if (state is AuthFailure) {
          _showErrorSnackbar(state.error);
        } if (state is AuthAuthenticated) {
          _navigateToHomeScreen(context, state.users, state.activeUser);
        } else if (state is AuthMultipleUsers) {
          _navigateToHomeScreen(context, state.users, null); // Call user selection dialog
        } else if (state is AuthUnauthenticated) {
          if (ModalRoute.of(context)?.settings.name != '/login') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.background,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return kIsWeb && !isSmallScreen
                        ? _buildWebLayout(theme, authBloc)
                        : _buildMobileLayout(theme, authBloc);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(ThemeData theme, AuthBloc authBloc) {
    return Center(
      child: Container(
        width: 1000,
        margin: const EdgeInsets.symmetric(vertical: 32),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Left side - Illustration/Branding
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/students.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'School Management System',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Manage your educational journey efficiently with our comprehensive school management platform.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 24, // Horizontal spacing
                        runSpacing: 16, // Vertical spacing when wrapping
                        children: [
                          _buildFeatureItem(
                              Icons.security,
                              'Secure Access'),
                          _buildFeatureItem(
                              Icons.devices,
                              'Cross-Platform'),
                          _buildFeatureItem(
                              Icons.analytics,
                              'Real-time Reports'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right side - Login Form
              Expanded(
                flex: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: _buildLoginForm(theme, authBloc, isWeb: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, AuthBloc authBloc) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: _buildLoginForm(theme, authBloc, isWeb: false),
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthBloc authBloc,
      {required bool isWeb}) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isWeb) ...[
            // Mobile Logo and title
            Center(
              child: Hero(
                tag: 'logo',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/students.png',
                    width: 80.0,
                    height: 80.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            "Welcome",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isWeb
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Sign in to continue',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // User type selection
          Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Email field
          _buildTextField(
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            onChanged: (value) => _email = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              /*if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }*/
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // Password field
          _buildTextField(
            label: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            onChanged: (value) => _password = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forgot password
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login button
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _login(authBloc);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Log In',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Language Selection Dropdown (Using Bloc)
          Container(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: LanguageSelector(), // Updated class now looks better!
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeOption({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = _userType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _userType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefixIcon,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  void _login(AuthBloc authBloc) {
    authBloc.add(LoginButtonPressed(
      email: _email,
      password: _password,
      userType: _userType,
    ));
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToHomeScreen(BuildContext context, List<User> users, User? activeUser) {
    if (activeUser != null) {
      // If an active user is already selected, navigate directly
      _navigateBasedOnUserType(context, activeUser, users);
    } else {
      // Otherwise, show user selection dialog
      _showUserSelectionDialog(context, users);
    }
  }


// Navigate based on user type
  void _navigateBasedOnUserType(BuildContext context, User selectedUser, List<User> users) {
    Widget homeScreen;
    homeScreen = HomeScreen(user: selectedUser);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

  void _showUserSelectionDialog(BuildContext context, List<User> users) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: users.map((user) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    user.displayName.isNotEmpty ? user.displayName[0] : "?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user.displayName),
                subtitle: Text(user.userType),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  context.read<AuthBloc>().add(UserSelected(user, users)); // Pass all users
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }


}
