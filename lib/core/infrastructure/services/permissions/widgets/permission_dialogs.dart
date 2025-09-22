// lib/core/infrastructure/services/permissions/widgets/permission_dialogs.dart (منظف)

import 'package:flutter/material.dart';
import '../permission_service.dart';
import '../permission_constants.dart';

/// Dialog بسيط وموحد لشرح الأذونات
class PermissionDialogs {
  
  /// عرض dialog شرح الأذونات المتعددة
  static Future<bool> showExplanation({
    required BuildContext context,
    required List<AppPermissionType> permissions,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.security,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('أذونات مطلوبة'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نحتاج الأذونات التالية لتشغيل هذه الميزة:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...permissions.map((permission) {
                final info = PermissionConstants.getInfo(permission);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: info.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          info.icon,
                          size: 20,
                          color: info.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              info.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('متابعة'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// عرض dialog لإذن واحد
  static Future<bool> showSinglePermission({
    required BuildContext context,
    required AppPermissionType permission,
    String? customMessage,
  }) async {
    final info = PermissionConstants.getInfo(permission);
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(info.icon, color: info.color, size: 24),
            ),
            const SizedBox(width: 12),
            Text('إذن ${info.name}'),
          ],
        ),
        content: Text(
          customMessage ?? info.description,
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('السماح'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// عرض dialog الإعدادات
  static Future<void> showSettingsDialog({
    required BuildContext context,
    required List<AppPermissionType> permissions,
    required VoidCallback onOpenSettings,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('فتح الإعدادات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الأذونات التالية تحتاج تفعيلها من الإعدادات:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...permissions.map((permission) {
              final info = PermissionConstants.getInfo(permission);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.block,
                      size: 16,
                      color: Colors.red[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      info.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ستنتقل إلى إعدادات التطبيق في النظام',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onOpenSettings();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }
  
  /// عرض dialog نتيجة طلب الأذونات
  static Future<void> showResultDialog({
    required BuildContext context,
    required List<AppPermissionType> granted,
    required List<AppPermissionType> denied,
  }) async {
    final allGranted = denied.isEmpty;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (allGranted ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                allGranted ? Icons.check_circle : Icons.warning,
                color: allGranted ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(allGranted ? 'تم بنجاح!' : 'بعض الأذونات غير مفعلة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (granted.isNotEmpty) ...[
              const Text(
                'الأذونات المفعلة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...granted.map((permission) {
                final info = PermissionConstants.getInfo(permission);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 8),
                      Text(info.name, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                );
              }),
            ],
            if (denied.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'الأذونات غير المفعلة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...denied.map((permission) {
                final info = PermissionConstants.getInfo(permission);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        size: 18,
                        color: Colors.red[600],
                      ),
                      const SizedBox(width: 8),
                      Text(info.name, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'يمكنك تفعيلها لاحقاً من الإعدادات',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!allGranted)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لاحقاً'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(allGranted ? 'ممتاز!' : 'موافق'),
          ),
        ],
      ),
    );
  }
}