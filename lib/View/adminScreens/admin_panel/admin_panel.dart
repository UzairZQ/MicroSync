import 'package:flutter/material.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/products_page.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/show_assigned_areas_products.dart';
import 'package:micro_pharma/components/constants.dart';

import 'package:micro_pharma/View/adminScreens/admin_panel/doctors_page.dart';
import 'areas_page.dart';
import 'employee_targets.dart';
import 'assign_areas_products.dart';

class AdminPanel extends StatelessWidget {
  static const String id = 'addoctor';
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _AdminPanelTileData(
        title: 'Doctors',
        subtitle: 'Manage doctors and specialties',
        icon: Icons.person_outline_outlined,
        color: kappbarColor,
        page: const DoctorsPage(),
      ),
      _AdminPanelTileData(
        title: 'Areas',
        subtitle: 'Maintain city and route areas',
        icon: Icons.location_pin,
        color: const Color(0xFF0891B2),
        page: const Areas(),
      ),
      _AdminPanelTileData(
        title: 'Products',
        subtitle: 'Medicine catalog and packing',
        icon: Icons.medication_outlined,
        color: const Color(0xFFEA580C),
        page: const ProductListScreen(),
      ),
      _AdminPanelTileData(
        title: 'Assign Areas & Products',
        subtitle: 'Connect reps with catalog coverage',
        icon: Icons.assignment_add,
        color: const Color(0xFF7C3AED),
        page: const AssignAreasProductsToEmployees(),
      ),
      _AdminPanelTileData(
        title: 'Assigned Coverage',
        subtitle: 'Review employee assignments',
        icon: Icons.assignment_ind_outlined,
        color: const Color(0xFF0D9488),
        page: const ShowAssignedAreasProducts(),
      ),
      _AdminPanelTileData(
        title: 'Monthly Targets',
        subtitle: 'Plan and monitor employee targets',
        icon: Icons.add_chart_outlined,
        color: const Color(0xFF2563EB),
        page: const EmployeeTargets(),
      ),
    ];

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Admin Panel'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: tiles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: constraints.maxWidth < 380 ? 0.92 : 1.08,
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  return _AdminPanelTile(
                    data: tile,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => tile.page),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminPanelTileData {
  const _AdminPanelTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _AdminPanelTile extends StatelessWidget {
  const _AdminPanelTile({
    required this.data,
    required this.onTap,
  });

  final _AdminPanelTileData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: data.color.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.14),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(data.icon, color: data.color),
                ),
                const Spacer(),
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
