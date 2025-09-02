import 'package:flutter/cupertino.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';

class CreateAccountPage extends StatelessWidget {
  final ThemeProvider themeProvider;

  const CreateAccountPage({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Create Account',
          style: ThemeHelper.title3,
        ),
        backgroundColor: ThemeHelper.background,
        border: Border(
          bottom: BorderSide(
            color: ThemeHelper.divider,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // Welcome message
              Text(
                'Welcome to Cal AI!',
                style: ThemeHelper.title1,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Let\'s get you started with your nutrition journey',
                style: ThemeHelper.body1.copyWith(
                  color: ThemeHelper.textSecondary,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Form fields
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeHelper.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeHelper.divider,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Name field
                    CupertinoTextField(
                      placeholder: 'Full Name',
                      style: ThemeHelper.body1,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeHelper.divider,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email field
                    CupertinoTextField(
                      placeholder: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      style: ThemeHelper.body1,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeHelper.divider,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password field
                    CupertinoTextField(
                      placeholder: 'Password',
                      obscureText: true,
                      style: ThemeHelper.body1,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeHelper.divider,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Create Account button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: () {
                    // TODO: Handle account creation
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Account Created!'),
                        content: const Text('Welcome to Cal AI! Your account has been created successfully.'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('Continue'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              // TODO: Navigate to main app
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Create Account',
                    style: ThemeHelper.body1.copyWith(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sign in link
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // TODO: Navigate to sign in page
                  },
                  child: Text(
                    'Already have an account? Sign In',
                    style: ThemeHelper.body1.copyWith(
                      color: CupertinoColors.systemGreen,
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
}
