import 'package:flutter/material.dart';

class RoutinesScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const RoutinesScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo: categorías de rutinas
    final List<Map<String, dynamic>> categories = [
      {'name': 'Strength', 'count': 12, 'icon': Icons.fitness_center},
      {'name': 'Hypertrophy', 'count': 18, 'icon': Icons.trending_up},
      {'name': 'Cardio', 'count': 8, 'icon': Icons.directions_run},
      {'name': 'Mobility', 'count': 6, 'icon': Icons.self_improvement},
      {'name': 'Full Body', 'count': 10, 'icon': Icons.accessibility_new},
      {'name': 'Core', 'count': 5, 'icon': Icons.center_focus_strong},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.fitness_center),
            const SizedBox(width: 8),
            const Text('FORGE PERFORMANCE'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: onToggleTheme,
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de búsqueda simple
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar ejercicios, rutinas...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Categorías',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Cuadrícula de categorías
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category['icon'] as IconData, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            category['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${category['count']} Rutinas',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}