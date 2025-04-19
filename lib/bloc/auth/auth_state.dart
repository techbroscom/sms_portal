// auth_state.dart

import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final List<User> users;  // Keep all users
  final User activeUser;   // The selected user

  AuthAuthenticated(this.users, this.activeUser);
}


class AuthMultipleUsers extends AuthState {
  final List<User> users;

  AuthMultipleUsers(this.users);
}


class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class AuthUnauthenticated extends AuthState {} // New Logout State
