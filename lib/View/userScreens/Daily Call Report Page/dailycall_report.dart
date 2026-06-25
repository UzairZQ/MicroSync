import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/dcr_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/viewModel/daily_call_report_provider.dart';
import 'package:micro_pharma/viewModel/day_plans_provider.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:micro_pharma/View/userScreens/Call%20Planner%20Page/call_planner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/doctor_visit_model.dart';

// ─── Brand colours ───────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF0F766E);
const _kPrimaryLight = Color(0xFF0D9488);
const _kGreen = Color(0xFF16A34A);
const _kAmber = Color(0xFFD97706);
const _kRed = Color(0xFFDC2626);

class DailyCallReportScreen extends StatefulWidget {
  static const String id = 'dailycallreport';
  const DailyCallReportScreen({super.key});

  @override
  State<DailyCallReportScreen> createState() => _DailyCallReportScreenState();
}

class _DailyCallReportScreenState extends State<DailyCallReportScreen> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<ProductModel> products = [];
  List<ProductModel> userAssignedProducts = [];
  UserModel? userData;
  DayPlanModel? currentDayPlan;
  List<DoctorVisitModel>? doctorVisitDetailsList = [];
  List<bool>? visitedDoctor = [];
  bool samplesProvided = false;
  ProductModel? selectedProduct;
  final TextEditingController doctorRemarksController =
      TextEditingController();
  List<SelectedProduct> selectedProducts = [];
  bool isReportSubmitted = false;
  bool _isLoadingReportData = true;
  SharedPreferences? _sharedPrefs;
  String? checkInTime;
  String? checkOutTime;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReportData());
  }

  @override
  void dispose() {
    doctorRemarksController.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadReportData() async {
    final currentUserId = userId;
    if (currentUserId == null) {
      if (mounted) setState(() => _isLoadingReportData = false);
      return;
    }

    try {
      _sharedPrefs = await SharedPreferences.getInstance();
      await Future.wait([
        context.read<ProductDataProvider>().fetchProductsList(),
        context.read<DayPlanProvider>().fetchDayPlans(),
        context.read<UserDataProvider>().fetchUserData(currentUserId),
      ]);

      if (!mounted) return;

      final dayPlanProvider = context.read<DayPlanProvider>();
      final productProvider = context.read<ProductDataProvider>();
      final loadedUserData = context.read<UserDataProvider>().getUserData;
      final loadedDayPlan = dayPlanProvider.getCurrentDayPlan();

      String? checkIn;
      String? checkOut;
      try {
        final sessionDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('work_sessions')
            .doc(
                '${currentUserId}_${DateFormat('yyyyMMdd').format(DateTime.now())}')
            .get();
        if (sessionDoc.exists) {
          final data = sessionDoc.data();
          final Timestamp? startedAt = data?['startedAt'] as Timestamp?;
          final Timestamp? endedAt = data?['endedAt'] as Timestamp?;
          if (startedAt != null) {
            checkIn = DateFormat('hh:mm a').format(startedAt.toDate());
          }
          if (endedAt != null) {
            checkOut = DateFormat('hh:mm a').format(endedAt.toDate());
          }
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        currentDayPlan = loadedDayPlan;
        userData = loadedUserData;
        userAssignedProducts = loadedUserData.assignedProducts ?? [];
        products = productProvider.productsList;
        visitedDoctor =
            List<bool>.generate(loadedDayPlan?.doctors.length ?? 0, (_) => false);
        isReportSubmitted = _hasSubmittedReportToday();
        checkInTime = checkIn;
        checkOutTime = checkOut;
        _isLoadingReportData = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingReportData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load daily report data.')),
      );
    }
  }

  bool _hasSubmittedReportToday() {
    final lastSubmittedDate = _sharedPrefs?.getString('lastSubmittedDate');
    if (lastSubmittedDate != null) {
      final last = DateTime.parse(lastSubmittedDate);
      final now = DateTime.now();
      return last.day == now.day &&
          last.month == now.month &&
          last.year == now.year;
    }
    return false;
  }

  void _submitReport() async {
    setState(() => isReportSubmitted = true);
    final sharedPrefs = _sharedPrefs ?? await SharedPreferences.getInstance();
    await sharedPrefs.setString('lastSubmittedDate', DateTime.now().toString());
  }

  // ── Computed helpers ───────────────────────────────────────────────────────

  int get _visitedCount =>
      doctorVisitDetailsList?.where((v) => v.visited == true).length ?? 0;


  DoctorVisitModel? _visitFor(String doctorName) =>
      doctorVisitDetailsList?.firstWhereOrNull((v) => v.name == doctorName);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoadingReportData) {
      return const Scaffold(
        appBar: MyAppBar(appBartxt: 'Daily Call Report'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isReportSubmitted) {
      return _SubmittedState(userName: userData?.displayName);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const MyAppBar(appBartxt: 'Daily Call Report'),
      floatingActionButton: currentDayPlan == null
          ? FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            )
          : FloatingActionButton.extended(
              onPressed: _onSubmit,
              backgroundColor: _kPrimary,
              icon: const Icon(Icons.assignment_turned_in, color: Colors.white),
              label: const Text(
                'Submit Report',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
      body: currentDayPlan == null
          ? _NoPlanState()
          : _ReportBody(
              dayPlan: currentDayPlan!,
              checkInTime: checkInTime,
              checkOutTime: checkOutTime,
              visitedCount: _visitedCount,
              doctorVisitDetails: doctorVisitDetailsList ?? [],
              visitedFlags: visitedDoctor ?? [],
              onAddInfo: (index) =>
                  _showDoctorDialog(context, currentDayPlan!.doctors, index),
            ),
    );
  }

  void _onSubmit() {
    final List<DoctorVisitModel> allVisits = [];
    for (final doctor in currentDayPlan!.doctors) {
      final existing = _visitFor(doctor);
      allVisits.add(existing ??
          DoctorVisitModel(
            name: doctor,
            visited: false,
            selectedProducts: [],
            doctorRemarks: '',
          ));
    }

    final report = DailyCallReportModel(
      area: currentDayPlan!.area,
      date: currentDayPlan!.date,
      doctorVisits: allVisits,
      submittedBy: userData?.displayName ?? 'Unknown user',
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
    );

    Provider.of<DailyCallReportProvider>(context, listen: false)
        .saveReport(report);
    _submitReport();
    showCustomDialog(
      context: context,
      title: 'Report Submitted',
      content: "Today's report has been successfully submitted.",
    );
  }

  // ── Doctor visit dialog ────────────────────────────────────────────────────

  Future<void> _showDoctorDialog(
      BuildContext context, List<String> doctors, int index) async {
    final availableProducts =
        userAssignedProducts.isNotEmpty ? userAssignedProducts : products;

    // local state for dialog
    bool localVisited = visitedDoctor?[index] ?? false;
    bool localSamples = false;
    ProductModel? localProduct =
        availableProducts.isNotEmpty ? availableProducts.first : null;
    int localQty = 1;
    List<SelectedProduct> localSelectedProducts = [];
    final remarksCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.97,
              expand: false,
              builder: (_, scrollCtrl) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          height: 4,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _kPrimary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.medical_services_outlined,
                                color: _kPrimary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctors[index],
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Add visit details',
                                  style: Theme.of(ctx).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Visited toggle
                      _DialogSection(
                        title: 'Visit Status',
                        child: _ToggleRow(
                          icon: Icons.check_circle_outline,
                          label: 'Did you visit this doctor?',
                          value: localVisited,
                          onChanged: (v) => setSheet(() {
                            localVisited = v;
                            visitedDoctor?[index] = v;
                            if (!v) {
                              localSamples = false;
                              localSelectedProducts = [];
                            }
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Samples section
                      if (localVisited) ...[
                        _DialogSection(
                          title: 'Samples',
                          child: Column(
                            children: [
                              _ToggleRow(
                                icon: Icons.science_outlined,
                                label: 'Were samples provided?',
                                value: localSamples,
                                onChanged: (v) => setSheet(() {
                                  localSamples = v;
                                  if (!v) localSelectedProducts = [];
                                }),
                              ),
                              if (localSamples) ...[
                                const SizedBox(height: 16),
                                if (availableProducts.isEmpty)
                                  _InfoBanner(
                                    icon: Icons.info_outline,
                                    text:
                                        'No products available for sampling yet.',
                                    color: _kAmber,
                                  )
                                else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButtonFormField<
                                            ProductModel>(
                                          isExpanded: true,
                                          value: localProduct,
                                          items: availableProducts
                                              .map((p) =>
                                                  DropdownMenuItem<ProductModel>(
                                                    value: p,
                                                    child: Text(p.name,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ))
                                              .toList(),
                                          onChanged: (p) => setSheet(
                                              () => localProduct = p),
                                          decoration: const InputDecoration(
                                            labelText: 'Product',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          value: localQty,
                                          items: List.generate(
                                                  10, (i) => i + 1)
                                              .map((q) =>
                                                  DropdownMenuItem<int>(
                                                    value: q,
                                                    child: Text('$q'),
                                                  ))
                                              .toList(),
                                          onChanged: (q) => setSheet(
                                              () => localQty = q ?? 1),
                                          decoration: const InputDecoration(
                                            labelText: 'Qty',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                          backgroundColor: _kPrimary),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add'),
                                      onPressed: () {
                                        if (localProduct != null) {
                                          setSheet(() {
                                            localSelectedProducts.add(
                                              SelectedProduct(
                                                productName: localProduct!.name,
                                                quantity: localQty,
                                              ),
                                            );
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  if (localSelectedProducts.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    ...localSelectedProducts
                                        .map((sp) => _SampleProductTile(
                                              product: sp,
                                              onRemove: () => setSheet(() =>
                                                  localSelectedProducts
                                                      .remove(sp)),
                                            )),
                                  ],
                                ],
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Remarks
                      _DialogSection(
                        title: 'Remarks',
                        child: TextFormField(
                          controller: remarksCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Add call remarks or notes…',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(sheetCtx),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                  backgroundColor: _kPrimary),
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save Visit'),
                              onPressed: () {
                                final visit = DoctorVisitModel(
                                  name: doctors[index],
                                  selectedProducts:
                                      List.from(localSelectedProducts),
                                  doctorRemarks: remarksCtrl.text.trim(),
                                  visited: localVisited,
                                );
                                setState(() {
                                  visitedDoctor?[index] = localVisited;
                                  final existing =
                                      doctorVisitDetailsList!.indexWhere(
                                          (v) => v.name == visit.name);
                                  if (existing == -1) {
                                    doctorVisitDetailsList!.add(visit);
                                  } else {
                                    doctorVisitDetailsList![existing] = visit;
                                  }
                                });
                                Navigator.pop(sheetCtx);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
    remarksCtrl.dispose();
  }
}

// ─── Standalone extracted widgets ─────────────────────────────────────────────

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.dayPlan,
    required this.checkInTime,
    required this.checkOutTime,
    required this.visitedCount,
    required this.doctorVisitDetails,
    required this.visitedFlags,
    required this.onAddInfo,
  });

  final DayPlanModel dayPlan;
  final String? checkInTime;
  final String? checkOutTime;
  final int visitedCount;
  final List<DoctorVisitModel> doctorVisitDetails;
  final List<bool> visitedFlags;
  final void Function(int index) onAddInfo;

  @override
  Widget build(BuildContext context) {
    final total = dayPlan.doctors.length;
    final progress = total == 0 ? 0.0 : visitedCount / total;

    return CustomScrollView(
      slivers: [
        // ── Header card ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _DcrHeaderCard(
              dayPlan: dayPlan,
              checkInTime: checkInTime,
              checkOutTime: checkOutTime,
              visitedCount: visitedCount,
              total: total,
              progress: progress,
            ),
          ),
        ),
        // ── Section label ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.people_outline,
                    size: 18, color: _kPrimary),
                const SizedBox(width: 6),
                Text(
                  'Doctors on Plan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _kPrimary,
                        letterSpacing: 0.4,
                      ),
                ),
                const Spacer(),
                Text(
                  '$visitedCount / $total visited',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ),
        // ── Doctor list ───────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList.separated(
            itemCount: dayPlan.doctors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doctorName = dayPlan.doctors[index];
              final visitDetails = doctorVisitDetails
                  .firstWhereOrNull((v) => v.name == doctorName);
              final hasInfo = visitDetails != null;
              final isVisited = visitedFlags.length > index
                  ? visitedFlags[index]
                  : false;

              return _DoctorCard(
                name: doctorName,
                index: index,
                hasVisitInfo: hasInfo,
                isVisited: isVisited,
                visitDetails: visitDetails,
                onTap: () => onAddInfo(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Header card ──────────────────────────────────────────────────────────────

class _DcrHeaderCard extends StatelessWidget {
  const _DcrHeaderCard({
    required this.dayPlan,
    required this.checkInTime,
    required this.checkOutTime,
    required this.visitedCount,
    required this.total,
    required this.progress,
  });

  final DayPlanModel dayPlan;
  final String? checkInTime;
  final String? checkOutTime;
  final int visitedCount;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('EEEE, d MMM yyyy').format(dayPlan.date);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, _kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & area row
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateStr,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  dayPlan.shift,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Area
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                dayPlan.area,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Check-in / Check-out
          Row(
            children: [
              Expanded(
                child: _TimeChip(
                  icon: Icons.login_outlined,
                  label: 'Check-In',
                  time: checkInTime ?? '—',
                  color: Colors.greenAccent.shade400,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeChip(
                  icon: Icons.logout_outlined,
                  label: 'Check-Out',
                  time: checkOutTime ?? '—',
                  color: Colors.orangeAccent.shade200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Visit Progress',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '$visitedCount / $total',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doctor card ───────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.name,
    required this.index,
    required this.hasVisitInfo,
    required this.isVisited,
    required this.visitDetails,
    required this.onTap,
  });

  final String name;
  final int index;
  final bool hasVisitInfo;
  final bool isVisited;
  final DoctorVisitModel? visitDetails;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = !hasVisitInfo
        ? Colors.grey.shade400
        : isVisited
            ? _kGreen
            : _kRed;
    final statusLabel =
        !hasVisitInfo ? 'Pending' : isVisited ? 'Visited' : 'Not Visited';
    final statusIcon = !hasVisitInfo
        ? Icons.radio_button_unchecked
        : isVisited
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

    final sampleCount = visitDetails?.selectedProducts?.length ?? 0;

    return Card(
      elevation: hasVisitInfo ? 2 : 1,
      shadowColor: statusColor.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: hasVisitInfo
            ? BorderSide(color: statusColor.withOpacity(0.35), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name & meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (hasVisitInfo) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (sampleCount > 0)
                            _MiniChip(
                              icon: Icons.science_outlined,
                              label: '$sampleCount sample${sampleCount > 1 ? 's' : ''}',
                              color: _kPrimary,
                            ),
                          if ((visitDetails?.doctorRemarks ?? '').isNotEmpty)
                            _MiniChip(
                              icon: Icons.notes_outlined,
                              label: 'Has remarks',
                              color: _kAmber,
                            ),
                        ],
                      ),
                    ] else
                      Text(
                        'Tap to add visit details',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Status badge
              Column(
                children: [
                  Icon(statusIcon, color: statusColor, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Submitted state ───────────────────────────────────────────────────────────

class _SubmittedState extends StatelessWidget {
  const _SubmittedState({this.userName});
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Daily Call Report'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_turned_in_rounded,
                    color: _kGreen, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                'Report Submitted!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _kGreen,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Great work${userName != null ? ', ${userName!.split(' ').first}' : ''}! Today's daily call report has been submitted successfully.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── No plan state ─────────────────────────────────────────────────────────────

class _NoPlanState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kAmber.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_busy_outlined,
                  color: _kAmber, size: 38),
            ),
            const SizedBox(height: 20),
            Text(
              'No Day Plan Found',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'There is no day plan for today. Please go to the Call Planner and create one first.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _kPrimary),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Go to Call Planner'),
              onPressed: () =>
                  Navigator.pushNamed(context, CallPlanner.id),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable pieces ─────────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11)),
              Text(time,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  const _DialogSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(
                    color: _kPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? _kPrimary.withOpacity(0.07)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? _kPrimary.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: SwitchListTile.adaptive(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        secondary: Icon(icon, color: value ? _kPrimary : Colors.grey),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: value ? _kPrimary : null)),
        value: value,
        activeColor: _kPrimary,
        onChanged: onChanged,
      ),
    );
  }
}

class _SampleProductTile extends StatelessWidget {
  const _SampleProductTile({required this.product, required this.onRemove});
  final SelectedProduct product;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimary.withOpacity(0.2)),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.medication_outlined,
            color: _kPrimary, size: 20),
        title: Text(product.productName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Qty: ${product.quantity}'),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline,
              color: _kRed, size: 20),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner(
      {required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
