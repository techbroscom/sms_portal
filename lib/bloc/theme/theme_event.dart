part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {
  final ThemeData themeData;
  ChangeThemeEvent(this.themeData);
}
