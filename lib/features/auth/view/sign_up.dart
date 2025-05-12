import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:delivery_boy/features/auth/controller/auth_ctrl.dart';
import 'package:delivery_boy/features/profile/view/map_view.dart';
import 'package:delivery_boy/features/settings/controller/settings_ctrl.dart';
import 'package:delivery_boy/main.export.dart';
import 'package:delivery_boy/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SignUpView extends HookConsumerWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries =
        ref.watch(localSettingsCtrlProvider.select((v) => v?.countries ?? []));

    final file = useState<File?>(null);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());

    final authCtrl = useCallback(() => ref.read(authCtrlProvider.notifier));

    final country = useState<int?>(null);
    final hidePass = useState<bool>(true);
    final hidePassConfirm = useState<bool>(true);
    final settingCtrl = ref.watch(localSettingsCtrlProvider);
    return Scaffold(
      body: FormBuilder(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Assets.lottie.signUp.lottie(
                    fit: BoxFit.cover,
                    height: context.height / 4,
                    width: context.width,
                  ),
                  Positioned(
                    top: 30,
                    left: 20,
                    child: IconButton.filled(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    ),
                  ),
                ],
              ),
              const Gap(60),
              Padding(
                padding: Insets.padH,
                child: ShadowContainer(
                  offset: const Offset(0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: Corners.medBorder,
                          color: context.colorTheme.surface,
                        ),
                        child: Padding(
                          padding: Insets.padAllContainer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  TR.of(context).signUp,
                                  style: context.textTheme.titleLarge,
                                ),
                              ),
                              const Gap(Insets.sm),
                              Center(
                                child: Text(
                                  TR.of(context).becomeADeliveryPartnerToday,
                                  style: context.textTheme.bodyLarge,
                                ),
                              ),
                              const Gap(Insets.lg),
                              TextFieldWithHeader(
                                name: 'first_name',
                                title: 'First Name',
                                isRequired: true,
                                hintText: TR.of(context).enterFirstName,
                              ),
                              TextFieldWithHeader(
                                name: 'last_name',
                                title: 'Last Name',
                                hintText: TR.of(context).enterLastName,
                              ),
                              TextFieldWithHeader(
                                name: 'username',
                                title: 'User Name',
                                isRequired: true,
                                hintText: TR.of(context).enterUserName,
                              ),
                              TextFieldWithHeader(
                                title: 'Email Address',
                                name: 'email',
                                isRequired: true,
                                hintText: TR.of(context).enterEmailAddress,
                              ),
                              const Gap(Insets.lg),
                              Row(
                                children: [
                                  Text(
                                    TR.of(context).address,
                                    style: context.textTheme.bodyLarge,
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          context.colorTheme.primary,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AddressMapView(
                                          onLocationSelect:
                                              (latLng, address, cc) {
                                            final state = formKey.currentState!;
                                            state.patchValue(
                                              {
                                                'address': address,
                                                if (latLng != null) ...{
                                                  'latitude':
                                                      '${latLng.latitude}',
                                                  'longitude':
                                                      '${latLng.longitude}',
                                                },
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    icon: Assets.icon.location.svg(
                                      colorFilter: ColorFilter.mode(
                                        context.colorTheme.onPrimary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    label: Text(
                                      TR.of(context).selectLocation,
                                      style: TextStyle(
                                        color: context.colorTheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(Insets.med),
                              FormBuilderTextField(
                                name: 'address',
                                decoration: InputDecoration(
                                  hintText: TR.of(context).enterAddress,
                                  fillColor: context.colorTheme.surfaceBright
                                      .withOpacity(.05),
                                ),
                                validator: FormBuilderValidators.required(),
                              ),
                              const Gap(Insets.med),
                              Visibility(
                                visible: false,
                                maintainState: true,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FormBuilderTextField(
                                        name: 'latitude',
                                      ),
                                    ),
                                    Expanded(
                                      child: FormBuilderTextField(
                                        name: 'longitude',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(Insets.med),
                              Text(
                                TR.of(context).country,
                                style: context.textTheme.bodyLarge,
                              ),
                              const Gap(Insets.med),
                              DropDownField<(int id, String name)>(
                                hintText: TR.of(context).selectCountry,
                                itemCount: countries.length,
                                onChanged: (value) {
                                  country.value = value?.$1;
                                },
                                color: context.colorTheme.surfaceBright
                                    .withOpacity(.05),
                                searchMatchFn: (item, searchValue) {
                                  return item.value?.$2.lc
                                          .contains(searchValue.lc) ??
                                      false;
                                },
                                itemBuilder: (context, index) {
                                  final country = countries[index];
                                  return DropdownMenuItem(
                                    value: (
                                      country.id,
                                      '${country.name} (${country.code})'
                                    ),
                                    child: Text(
                                        '${country.name} (${country.code})'),
                                  );
                                },
                              ),
                              const Gap(Insets.lg),
                              Text(
                                TR.of(context).phone,
                                style: context.textTheme.bodyLarge,
                              ),
                              const Gap(Insets.med),
                              Row(
                                children: [
                                  FormBuilderField<String>(
                                    name: 'phone_code',
                                    builder: (state) => Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: context.colorTheme.surface,
                                      ),
                                      child: CountryCodePicker(
                                        initialSelection: 'UG',
                                        
                                        boxDecoration: BoxDecoration(
                                          borderRadius: Corners.lgBorder,
                                          color: context
                                              .colorTheme.surfaceBright
                                              .withOpacity(.05),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 0,
                                        ),
                                        onInit: (value) {
                                          Future.delayed(
                                            0.seconds,
                                            () => state.didChange(
                                              value?.dialCode
                                                  ?.replaceAll('+', ''),
                                            ),
                                          );
                                        },
                                        flagDecoration: const BoxDecoration(
                                          borderRadius: Corners.smBorder,
                                        ),
                                        onChanged: (code) {
                                          state.didChange(code.dialCode
                                              ?.replaceAll('+', ''));
                                        },
                                      ),
                                    ),
                                  ),
                                  const Gap(Insets.med),
                                  Expanded(
                                    child: FormBuilderTextField(
                                      name: 'phone',
                                      decoration: InputDecoration(
                                        fillColor: context
                                            .colorTheme.surfaceBright
                                            .withOpacity(.05),
                                        hintText:
                                            TR.of(context).enterPhoneNumber,
                                      ),
                                      validator:
                                          FormBuilderValidators.required(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(Insets.med),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: Corners.medBorder,
                          color: context.colorTheme.surface,
                        ),
                        child: Padding(
                          padding: Insets.padAllContainer,
                          child: Column(
                            children: [
                              TextFieldWithHeader(
                                title: TR.of(context).password,
                                name: 'password',
                                isRequired: true,
                                hintText: TR.of(context).enterPassword,
                                obscureText: hidePass,
                              ),
                              TextFieldWithHeader(
                                title: TR.of(context).confirmPassword,
                                name: 'password_confirmation',
                                isRequired: true,
                                hintText: TR.of(context).enterConfirmPassword,
                                obscureText: hidePassConfirm,
                              ),
                              if (settingCtrl!.config.referralSystem)
                                TextFieldWithHeader(
                                  title: TR.of(context).referralCode,
                                  name: 'referral_code',
                                  isRequired: false,
                                  hintText: TR.of(context).enterReferralCode,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(Insets.med),
                      const Gap(Insets.lg),
                      Padding(
                        padding: Insets.padH,
                        child: SubmitButton(
                          onPressed: (l) async {
                            final state = formKey.currentState!;
                            if (!state.saveAndValidate()) return;
                            l.value = true;
                            final image = file.value;
                            final data = {
                              ...state.value,
                              'country_id': country.value
                            };
                            await authCtrl().registration(data, image);
                            Logger.json(data);
                            l.value = false;
                          },
                          child: Text(TR.of(context).register),
                        ),
                      ),
                      const Gap(Insets.lg),
                    ],
                  ),
                ),
              ),
              const Gap(Insets.lg),
            ],
          ),
        ),
      ),
    );
  }
}
