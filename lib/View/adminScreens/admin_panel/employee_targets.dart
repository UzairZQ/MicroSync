import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/widgets/production_widgets.dart';
import 'package:micro_pharma/services/database_service.dart';

class EmployeeTargets extends StatefulWidget {
  const EmployeeTargets({super.key});

  @override
  State<EmployeeTargets> createState() => _EmployeeTargetsState();
}

class _EmployeeTargetsState extends State<EmployeeTargets> {
  final _orderTargetController = TextEditingController();
  final _visitTargetController = TextEditingController();
  final _monthController =
      TextEditingController(text: DateFormat('yyyy-MM').format(DateTime.now()));
  String? _selectedUserId;
  String? _selectedUserName;
  bool _saving = false;

  @override
  void dispose() {
    _orderTargetController.dispose();
    _visitTargetController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  Future<void> _saveTarget() async {
    final orderTarget = double.tryParse(_orderTargetController.text.trim());
    final visitTarget = int.tryParse(_visitTargetController.text.trim());
    if (_selectedUserId == null ||
        _selectedUserName == null ||
        orderTarget == null ||
        visitTarget == null ||
        _monthController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select rep and enter valid targets')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('employeeTargets').add({
        'userId': _selectedUserId,
        'employeeName': _selectedUserName,
        'month': _monthController.text.trim(),
        'orderTarget': orderTarget,
        'visitTarget': visitTarget,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) {
        return;
      }
      _orderTargetController.clear();
      _visitTargetController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly target saved')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save target: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Monthly Targets'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DashboardHeader(
              title: 'Rep Targets',
              subtitle: 'Set monthly order value and doctor visit goals.',
              icon: Icons.track_changes_outlined,
            ),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: DatabaseService.streamUser(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  initialValue: _selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'Rep',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: users.map<DropdownMenuItem<String>>((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: data['uid']?.toString(),
                      child: Text(data['displayName']?.toString() ?? 'Rep'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    Map<String, dynamic>? selectedData;
                    for (final doc in users) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['uid']?.toString() == value) {
                        selectedData = data;
                        break;
                      }
                    }
                    if (selectedData == null) {
                      return;
                    }
                    setState(() {
                      _selectedUserId = value;
                      _selectedUserName =
                          selectedData?['displayName']?.toString() ?? 'Rep';
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monthController,
              decoration: const InputDecoration(
                labelText: 'Month',
                prefixIcon: Icon(Icons.calendar_month_outlined),
                helperText: 'Format: yyyy-MM',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _orderTargetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Order value target',
                prefixIcon: Icon(Icons.receipt_long_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _visitTargetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Doctor visit target',
                prefixIcon: Icon(Icons.medical_information_outlined),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _saving ? null : _saveTarget,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save Target'),
            ),
          ],
        ),
      ),
    );
  }
}
