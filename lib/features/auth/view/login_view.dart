import 'package:country_code_picker/country_code_picker.dart';
import 'package:delivery_boy/features/auth/controller/auth_ctrl.dart';
import 'package:delivery_boy/features/settings/controller/settings_ctrl.dart';
import 'package:delivery_boy/main.export.dart';
import 'package:delivery_boy/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lottie/lottie.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCtrl = useCallback(() => ref.read(authCtrlProvider.notifier));
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final hidePass = useState(true);
    final settingCtrl = ref.watch(localSettingsCtrlProvider);
    final appSettingsCtrl =
        useCallback(() => ref.read(appSettingsCtrlProvider.notifier));
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => appSettingsCtrl().reload(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Assets.lottie.signUp.lottie(
                      fit: BoxFit.cover,
                      height: context.height / 4,
                      width: context.width,
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.colorFilter(
                            ['Layer 3', '**'],
                            value: const ColorFilter.mode(
                                Colors.blue, BlendMode.src),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      child: SizedBox(
                        height: context.height / 3,
                        width: context.width,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: Insets.padH,
                  child: ShadowContainer(
                    padding: Insets.padAllContainer,
                    offset: const Offset(0, 0),
                    child: Column(
                      children: [
                        Text(
                          TR.of(context).continueWithPhone,
                          style: context.textTheme.titleLarge,
                        ),
                        const Gap(Insets.offset),
                        Row(
                          children: [
                            FormBuilderField<String>(
                              name: 'phone_code',
                              builder: (state) => Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: context.colorTheme.surface,
                                ),
                                child: CountryCodePicker(
                                  boxDecoration: BoxDecoration(
                                    borderRadius: Corners.lgBorder,
                                    color: context.colorTheme.surfaceBright
                                        .withOpacity(.05),
                                  ),
                                 // initialSelection: 'bd',
                                  initialSelection: 'UG', // 'UG' is the ISO country code for Uganda

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                  onInit: (value) {
                                    Future.delayed(
                                      0.seconds,
                                      () => state.didChange(
                                        value?.dialCode?.replaceAll('+', ''),
                                      ),
                                    );
                                  },
                                  flagDecoration: const BoxDecoration(
                                    borderRadius: Corners.smBorder,
                                  ),
                                  onChanged: (code) {
                                    state.didChange(
                                      code.dialCode?.replaceAll('+', ''),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Gap(Insets.med),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'phone',
                                initialValue: '',
                                decoration: InputDecoration(
                                  fillColor: context.colorTheme.surfaceBright
                                      .withOpacity(.05),
                                  hintText: TR.of(context).enterPhoneNumber,
                                ),
                                validator: FormBuilderValidators.required(),
                              ),
                            ),
                          ],
                        ),
                        const Gap(Insets.lg),
                        FormBuilderTextField(
                          name: 'password',
                          initialValue: '',
                          obscureText: hidePass.value,
                          decoration: InputDecoration(
                            fillColor: context.colorTheme.surfaceBright
                                .withOpacity(.05),
                            prefixIcon: const Icon(Icons.lock),
                            hintText: TR.of(context).enterPassword,
                            suffixIcon: IconButton(
                              onPressed: () => hidePass.value = !hidePass.value,
                              icon: Icon(
                                hidePass.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push(RoutePaths.verifyPhone),
                            child: Text(TR.of(context).forgotPassword),
                          ),
                        ),
                        const Gap(Insets.offset),
                        SubmitButton(
                          onPressed: (l) async {
                            final state = formKey.currentState!;
                            if (!state.saveAndValidate()) return;
                            l.value = true;
                            await authCtrl().login(state.value);
                            l.value = false;
                          },
                          child: Text(TR.of(context).login),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(Insets.offset),
                if (settingCtrl!.config.deliverymanRegistration)
                  GestureDetector(
                    onTap: () => context.push(RoutePaths.signUp),
                    child: Text(
                      TR.of(context).becomeADeliveryBoy,
                      style: context.textTheme.bodyLarge!.copyWith(
                        color: context.colorTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
