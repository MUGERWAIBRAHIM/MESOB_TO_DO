import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:todo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:todo_app/core/network/api_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Back to HomeScreen
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 👤 Account Details
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account Details'),
            subtitle: const Text('View or update your account info'),
            onTap: user == null
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => AccountDetailsDialog(
                        name: user.name,
                        email: user.email,
                        authProvider: authProvider,
                      ),
                    );
                  },
          ),

          const Divider(),

          /// 🚪 Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await authProvider.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// ACCOUNT DETAILS DIALOG
/// ===============================
class AccountDetailsDialog extends StatefulWidget {
  final String name;
  final String email;
  final AuthProvider authProvider;

  const AccountDetailsDialog({
    super.key,
    required this.name,
    required this.email,
    required this.authProvider,
  });

  @override
  State<AccountDetailsDialog> createState() => _AccountDetailsDialogState();
}

class _AccountDetailsDialogState extends State<AccountDetailsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final api = ApiService();
    setState(() => _isUpdating = true);

    try {
      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      await api.updateProfile(data);

      // Refresh user info in provider
      await widget.authProvider.init();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// Password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUpdating ? null : _updateProfile,
          child: _isUpdating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}

