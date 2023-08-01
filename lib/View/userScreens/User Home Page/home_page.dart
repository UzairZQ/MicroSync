import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/View/userScreens/User%20Home%20Page/privacy_consent_dialog.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:micro_pharma/services/location_services.dart';
import '../../adminScreens/admin_panel/doctors_page.dart';
import '../../../components/widgets/container_row.dart';
import '../../../viewModel/day_plans_provider.dart';
import '../Daily Call Report Page/dailycall_report.dart';
import '../Call Planner Page/call_planner.dart';
import 'package:micro_pharma/View/userScreens/user_dashboard.dart';
import 'package:micro_pharma/View/userScreens/day_plans.dart';
import 'package:provider/provider.dart';
import '../OrderPage/order_page.dart';
import 'bacground_location.dart';
import 'bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  static String id = 'home';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  DayPlanModel? currentDayPlan;

  @override
  void initState() {
    super.initState();
    showPrivacyConsentDialog(currentUser!.uid);
    getBackgroundLocation(currentUser!.uid);
    Provider.of<UserDataProvider>(context, listen: false)
        .fetchUserData(currentUser!.uid);
    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
    currentDayPlan = Provider.of<DayPlanProvider>(context, listen: false)
        .getCurrentDayPlan();
  }

  @override
  Widget build(BuildContext context) {
    userLocation(currentUser!.uid);
    return Scaffold(
      bottomNavigationBar: const HomeNavigationBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Material(
                elevation: 5,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0)),
                child: Container(
                  height: 250.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0xFF1FB7CC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Consumer<UserDataProvider>(
                        builder: (context, dataProvider, child) {
                          UserModel? userData = dataProvider.getUserData;
                          print(userData.displayName);

                          if (userData.displayName == null ||
                              userData.displayName!.isEmpty) {
                            return const CircularProgressIndicator();
                          } else {
                            return Text(
                              'Welcome ${userData.displayName} !',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 17.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                          Consumer<DayPlanProvider>(
                            builder: (context, dayPlanProvier, child) {
                              DayPlanModel? currentDayPlan =
                                  dayPlanProvier.getCurrentDayPlan();
                              if (currentDayPlan == null) {
                                return const CircularProgressIndicator();
                              } else {
                                return Flexible(
                                  child: MyTextwidget(
                                    text:
                                        'Today\'s Scheduled Plan: ${currentDayPlan?.area ?? 'No Area Found'} ',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontColor: Colors.white,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.medication_rounded,
                            color: Colors.white,
                          ),
                          Consumer<DayPlanProvider>(
                            builder: (context, dayPlanProvider, child) {
                              DayPlanModel? dayplandoctors =
                                  dayPlanProvider.getCurrentDayPlan();
                              if (dayplandoctors == null) {
                                return const CircularProgressIndicator();
                              } else {
                                return Flexible(
                                  child: Text(
                                    'Doctors to meet: ${dayplandoctors.doctors.join(',') ?? 'No Doctors found'}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyButton(
                              onPressed: () {
                                LocationServices()
                                    .getLocation(currentUser!.uid);
                              },
                              color: const Color(0xFF009AAF),
                              text: 'Start Your Day'),
                          const SizedBox(
                            width: 15.0,
                          ),
                          MyButton(
                              onPressed: () {
                                Navigator.pushNamed(context, DayPlansScreen.id);
                              },
                              color: const Color.fromARGB(255, 171, 75, 95),
                              text: 'Change Plan'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ContainerRow(
                  container1Clr: const Color(0xFFF0DCFF),
                  container1Icon: Icons.dashboard_outlined,
                  container1Text: 'Dashboard',
                  container1Tap: () =>
                      Navigator.pushNamed(context, Dashboard.id),
                  container2Clr: const Color(0xFFFFC8C8),
                  container2Icon: Icons.calendar_month_outlined,
                  container2Text: 'Call Planner',
                  container2Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const CallPlanner())));
                  }),
              const SizedBox(
                height: 30.0,
              ),
              ContainerRow(
                container1Clr: const Color.fromARGB(255, 133, 254, 226),
                container1Icon: Icons.assignment_outlined,
                container1Text: 'My Call Plans',
                container1Tap: () =>
                    Navigator.pushNamed(context, DayPlansScreen.id),
                container2Clr: const Color(0xffFFE974),
                container2Icon: Icons.assignment_turned_in_outlined,
                container2Text: 'Daily Call Reports',
                container2Tap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const DailyCallReportScreen()))),
              ),
              const SizedBox(
                height: 30.0,
              ),
              ContainerRow(
                container1Clr: Colors.blue.shade200,
                container1Icon: Icons.medical_services_outlined,
                container1Text: 'Doctors',
                container2Clr: Colors.orange.shade200,
                container2Icon: Icons.add_shopping_cart_outlined,
                container2Text: 'Send Orders',
                container1Tap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const DoctorsPage()),
                  ),
                ),
                container2Tap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => OrderScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
