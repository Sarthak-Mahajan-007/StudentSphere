import 'package:flutter/material.dart';

class HostelManagerDashboard extends StatelessWidget {
  const HostelManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Hostel Manager Dashboard\n(Use bottom navigation)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
