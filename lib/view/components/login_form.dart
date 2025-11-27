import 'package:doctor_appointment_app/view/components/Common/button.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/loading.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/view_model/Patient/patient.dart';

import 'package:doctor_appointment_app/routes/routes.dart';

import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/route_manager.dart';
import 'package:get/utils.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obsecurePassword = true;

  Future<void> _submit() async {
     FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      await ref
          .read(patientNotifier.notifier)
          .login(_emailController.text.removeAllWhitespace, _passwordController.text.removeAllWhitespace);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(patientNotifier, (previous, next) async {
      if (next.isLoading) {
        if (!Get.isDialogOpen!) {
          await Get.dialog(const Loading(), barrierDismissible: false);
        }
      } else {
        if (Get.isDialogOpen!) Get.back();
       FocusManager.instance.primaryFocus?.unfocus();
      }

      next.whenOrNull(
        error: (error, _) async {
          if (Get.isDialogOpen!) Get.back();

       FocusManager.instance.primaryFocus?.unfocus();

          await Get.dialog(
             ErrorPopUp(
              title: 'Something went wrong',
              content: error.toString(),
            ),
          );
        },
        data: (_) async {
          if (Get.isDialogOpen!) Get.back();
        FocusManager.instance.primaryFocus?.unfocus();
          if (next.value != null) {
            await Get.offAllNamed(Sroutes.main);
          }
        },
      );
    });
   
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            onFieldSubmitted: (_) async{
              
             await  _submit();
            },
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: InputDecoration(
              hintText: 'example@gmail.com',
             
              labelText: AppLocalizations.of(context)!.email,
              prefixIcon: const Icon(
                (Icons.email_outlined),
              ),
              prefixIconColor: Config.primaryColor,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com)$',
              ).hasMatch(value)) {
                return 'Enter a valid email (must include @ and end with .com)';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            onFieldSubmitted: (_) async{
             
              await _submit();
            },
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: _obsecurePassword,
            decoration: InputDecoration(
              hintText: '',
              labelText: AppLocalizations.of(context)!.password,
              prefixIcon: const Icon(Icons.lock_outlined),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obsecurePassword = !_obsecurePassword;
                  });
                },
                icon: _obsecurePassword
                    ? const Icon(
                        Icons.visibility_off_outlined,
                        color: Config.primaryColor,
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: Config.primaryColor,
                      ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required';
              }

              if (!RegExp(
                r"""^[a-zA-Z0-9!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]+$""",
              ).hasMatch(value)) {
                return 'Password must contain only English letters, numbers, or symbols';
              }

              return null;
            },
          ),
          Config.spaceSmall,

          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                AppLocalizations.of(context)!.forgotYourPassword,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // color: Colors.black,
                ),
              ),
            ),
          ),
          Config.spaceSmall,
          Button(
            width: double.infinity,
            title: AppLocalizations.of(context)!.signIn,
            disabled: false,
            onPressed: () async=> await _submit(),
          ),
        ],
      ),
    );
  }
}
