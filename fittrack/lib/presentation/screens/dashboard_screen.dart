import 'package:flutter/material.dart';
import '../widgets/ft_exit_confirmation.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FtExitConfirmation(
      child: Scaffold(body: Center(child: Text('DashboardScreen'))),
    );
  }
}
