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
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.welcome,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Config.spaceSmall,
                          Text(
                            _isSignIn
                                ? AppLocalizations.of(
                                    context,
                                  )!.signInToYourAccount
                                : AppLocalizations.of(
                                    context,
                                  )!.signUpDescription,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        "assets/logo.png",

                        width: Config.screenWidth! * 0.15,
                        height: Config.screenWidth! * 0.15,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  Config.spaceSmall,

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _isSignIn ? const LoginForm() : const SignUpForm(),
                  ),

                  Config.spaceSmall,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignIn
                            ? AppLocalizations.of(context)!.dontHaveAccount
                            : AppLocalizations.of(
                                context,
                              )!.alreadyHaveAccount,
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
