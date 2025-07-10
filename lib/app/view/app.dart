import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queens/app/router/app_router.dart' as app_router;
import 'package:queens/l10n/l10n.dart';
import 'package:queens/theme/app_theme.dart';
import 'package:queens/theme/cubit/theme_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((ThemeCubit cubit) => cubit.state);
    final materialTheme = MaterialTheme();

    return MaterialApp.router(
      routerConfig: app_router.router,
      theme: materialTheme.light(context),
      darkTheme: materialTheme.dark(context),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
