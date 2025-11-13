import 'package:doctor_appointment_app/view_model/Patient/patient.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/view/components/Common/button.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';

import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final _emailController = TextEditingController();
  @override
  void dispose() {
    _nationalIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();

    super.dispose();
  }


  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      await ref
          .read(patientNotifier.notifier)
          .registerPatient(
            nationaID: _nationalIdController.text.removeAllWhitespace,
            phoneNumber: _phoneNumberController.text.removeAllWhitespace,
            password: _passwordController.text.removeAllWhitespace,
            email: _emailController.text.removeAllWhitespace,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(patientNotifier, (previous, next) async {
      if (next.isLoading) {
        if (!Get.isDialogOpen!) {
          await Get.dialog(const Loading(),);
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
            const ErrorPopUp(
              title: 'Something went wrong',
              content: 'Please check your credintials',
            ),
              barrierDismissible: false,

          );
        },
        data: (_) async {
          if (Get.isDialogOpen!) Get.back();
          FocusManager.instance.primaryFocus?.unfocus();
          if (next.value == null) {
            await Get.dialog(
              
              ErrorPopUp(
                title: 'Account created Successfully',
                content: '',
                onOk: () async {
                  if (Get.isDialogOpen!) Get.back();
                    FocusManager.instance.primaryFocus?.unfocus();
                  await Get.offAllNamed(Sroutes.auth);
                },
              ),
              barrierDismissible: false,
            );
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
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
             onFieldSubmitted: (_)async {
            
              await _submit();
            },
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],

            cursorColor: Config.primaryColor,
            decoration: InputDecoration(
              hintText: '',
              labelText: AppLocalizations.of(context)!.nationalId,
              prefixIcon: const Icon(FontAwesomeIcons.solidIdCard),
              prefixIconColor: Config.primaryColor,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'National ID is required';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'National ID must contain numbers only';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.number,
            
             onFieldSubmitted: (_) async{
          
              await _submit();
            },
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],

            cursorColor: Config.primaryColor,
            decoration: InputDecoration(
              hintText: '09********',
              labelText: AppLocalizations.of(context)!.phoneNumber,
              prefixIcon: const Padding(
                padding: EdgeInsets.fromLTRB(
                  5,
                  12,
                  0,
                  12,
                ), // top and bottom align text
                child: Text(
                  '+963',
                  style: TextStyle(
                    color: Config.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'National ID is required';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'National ID must contain numbers only';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
             onFieldSubmitted: (_)async {
                           await _submit();

            },
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],

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
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
             onFieldSubmitted: (_) async{
                        await _submit();

            },
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],

            cursorColor: Config.primaryColor,
            decoration: InputDecoration(
              hintText: '',
              labelText: AppLocalizations.of(context)!.password,
              prefixIcon: const Icon(Icons.lock_outlined),
              prefixIconColor: Config.primaryColor,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(
                r"""^[a-zA-Z0-9\s!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]+$""",
              ).hasMatch(value)) {
                return 'Password must contain only English letters, numbers, or symbols';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _confirmPasswordController,
            keyboardType: TextInputType.visiblePassword,
             onFieldSubmitted: (_) async{
                           await _submit();

            },
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],

            cursorColor: Config.primaryColor,

            decoration: InputDecoration(
              hintText: '',
              labelText: AppLocalizations.of(context)!.confirmPassword,
              prefixIcon: const Icon(Icons.lock_outlined),
              prefixIconColor: Config.primaryColor,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          Config.spaceSmall,

          Button(
            width: double.infinity,
            title: AppLocalizations.of(context)!.signUp,
            disabled: false,
            onPressed:()async=> await _submit(),
          ),
        ],
      ),
    );
  }
}
