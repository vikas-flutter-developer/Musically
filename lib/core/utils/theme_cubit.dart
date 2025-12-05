
import 'package:flutter_bloc/flutter_bloc.dart';
import 'local_storage_service.dart';

class ThemeCubit extends Cubit<bool> {
  final LocalStorageService _localStorageService;

  ThemeCubit(this._localStorageService) : super(_localStorageService.isDarkMode());

  void toggleTheme({required bool isDark}) {
    _localStorageService.saveThemeMode(isDark);
    emit(isDark);
  }

  bool get initialThemeMode => _localStorageService.isDarkMode();
}
