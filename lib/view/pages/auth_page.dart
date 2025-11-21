import 'package:doctor_appointment_app/view/components/login_form.dart';
import 'package:doctor_appointment_app/view/components/sign_up_form.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';

import 'package:doctor_appointment_app/utils/config.dart';

import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignIn = true;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Improved Header Section
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.1,
                        child: Image.asset(
                          "assets/logo.png",
                          width: Config.screenWidth! * 0.18,
                          height: Config.screenWidth! * 0.18,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Shifa",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Config.textLight
                              : Config.textDark,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  Config.spaceMedium,

                  // Welcome Text Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          AppLocalizations.of(context)!.welcome,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            color:
                                Colors.white, // Will be overridden by gradient
                          ),
                        ),
                      ),
                      Config.spaceSmall,
                      Text(
                        _isSignIn
                            ? AppLocalizations.of(context)!.signInToYourAccount
                            : AppLocalizations.of(context)!.signUpDescription,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsetsGeometry.all(6),
                    child: _isSignIn ? const LoginForm() : const SignUpForm(),
                  ),

                  // Form Section

                  // Toggle Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignIn
                            ? AppLocalizations.of(context)!.dontHaveAccount
                            : AppLocalizations.of(context)!.alreadyHaveAccount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignIn = !_isSignIn;
                          });
                        },
                        child: Text(
                          _isSignIn
                              ? AppLocalizations.of(context)!.signUp
                              : AppLocalizations.of(context)!.signIn,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
