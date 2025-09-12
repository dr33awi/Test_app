// lib/features/statistics/providers/statistics_provider.dart

import 'package:athkar_app/app/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/statistics_service.dart';

class StatisticsProvider extends StatelessWidget {
  final Widget child;

  const StatisticsProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<StatisticsService>(),
        ),
      ],
      child: child,
    );
  }
}