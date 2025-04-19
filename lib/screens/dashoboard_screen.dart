import '../bloc/theme/theme_bloc.dart';
import '../utils/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeBloc>().state.themeData;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Text("Dashboard Screen"),
    );
  }
}