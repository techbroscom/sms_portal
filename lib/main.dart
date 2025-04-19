import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sms_portal/repository/auth_repository.dart';
import 'package:sms_portal/screens/login_screen.dart';
import 'package:sms_portal/services/web_service.dart';
import 'package:sms_portal/utils/constants.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/language/language_bloc.dart';
import 'bloc/language/language_state.dart';
import 'bloc/theme/theme_bloc.dart';

void main() async{
  final WebService webService = WebService(baseUrl: Constants.baseUrl);
  final AuthRepository authRepository = AuthRepository(webService: webService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, langState) {
            return MaterialApp(
              title: 'My School',
              theme: themeState.themeData, // ✅ Dynamic Theme
              locale: langState.locale, // ✅ Dynamic Language
              home: LoginScreen(),
            );
          },
        );
      },
    );
  }
}
