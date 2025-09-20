// lib/core/error/exceptions.dart (مبسط)

/// استثناء أساسي للتطبيق
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// استثناءات الشبكة (أساسية)
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

/// استثناءات البيانات (أساسية)
class DataLoadException extends AppException {
  DataLoadException(super.message, {super.code});
}

class DataNotFoundException extends AppException {
  DataNotFoundException(super.message, {super.code});
}

/// استثناءات الخدمات الأساسية فقط
class LocationException extends AppException {
  LocationException(super.message, {super.code});
}

class NotificationException extends AppException {
  NotificationException(super.message, {super.code});
}

class StorageException extends AppException {
  StorageException(super.message, {super.code});
}

class PermissionException extends AppException {
  PermissionException(super.message, {super.code});
}

/// استثناءات التحقق (أساسية)
class ValidationException extends AppException {
  final String? field;
  
  ValidationException(super.message, {this.field, super.code});
}