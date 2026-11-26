import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DebugScreenGalleryScreen extends StatelessWidget {
  const DebugScreenGalleryScreen({super.key, required this.routes});

  final List<({String title, String routeName})> routes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug screen gallery')),
      body: ListView(
        children: [
          for (final route in routes)
            ListTile(
              title: Text(route.title),
              onTap: () => context.goNamed(route.routeName),
            ),
        ],
      ),
    );
  }
}
