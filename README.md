# MicroSync

MicroSync is a Flutter and Firebase based sales force automation application for pharmaceutical companies. It helps pharma managers and field sales representatives manage daily field operations such as employee tracking, daily call reporting, medicine orders, doctor visits, product assignments, area assignments, and weekly call planning.

This project was developed as a final year BS Computer Science project. The requirements were inspired by a real pharmaceutical sales workflow, using Micro Pharma as a case study, while keeping the system adaptable for other small and mid-sized pharmaceutical companies with similar sales-force operations.

## Project Scope

MicroSync is not limited to one company only. It is designed as a reusable pharma sales-force management system, with Micro Pharma used as the practical case study for understanding real business requirements.

- Domain: Pharmaceutical sales force automation
- Case study: Micro Pharma
- Target users: Admins, managers, and field sales representatives
- Adaptability: Other pharma companies can customize employees, products, doctors, areas, targets, reports, and order workflows according to their own structure

## Features

**Employee Location Tracking:** Managers can track field representatives in real time to monitor visits, field coverage, and daily movement.

**Daily Call Reporting:** Sales representatives can submit daily call reports for doctor visits, product discussions, samples, remarks, and follow-up information.

**Medicine Orders:** Sales representatives can submit product orders from medical stores so managers can review and process them efficiently.

**Weekly Call Planning:** Sales representatives can plan upcoming doctor visits and area coverage for the week.

**Product and Area Assignment:** Admins can assign specific products and work areas to individual employees.

**Doctor Management:** Admins and users can maintain doctor records for future visits, reporting, and planning.

## How to Use

### Admin / Manager Module

- The admin role is created during system setup.
- Admins can add employees and provide initial login credentials.
- Admins can add areas, products, and doctors.
- Products and areas can be assigned to employees for their designated work.
- Admins can view employee locations, tour plans, submitted daily call reports, and product orders.
- Admins can manage employee access when a user leaves the organization or should no longer use the system.

### User / Employee Module

- Sales representatives receive initial login credentials and are expected to change their password after first login.
- Employees can access their dashboard after successful login.
- Employees can create and submit daily call reports.
- Employees can add doctor information when needed.
- Employees can view assigned products, assigned areas, doctor listings, call planner, and order booking features.
- Employees can prepare weekly tour plans for doctor visits and area coverage.
- Employees can submit medicine/product orders to the admin.

## Technologies Used

- **Flutter:** Cross-platform mobile app development framework for Android and iOS.
- **Firebase Authentication:** User login and authentication.
- **Cloud Firestore:** Cloud-hosted NoSQL database for app data.
- **Firebase Crashlytics:** Runtime crash reporting and diagnostics.
- **Provider:** State management for Flutter screens and data flows.
- **Google Maps:** Employee location visualization and field tracking.

## Contributors

- Uzair Zia Qureshi (@github.com/UzairZQ)
- Sajjad Ahmed (@github.com/i-sajjad)

## Support

For questions or issues, contact: uzairqureshi9@gmail.com

<p align="center">
  <em>Screenshots captured on a 6.2-inch display</em>
</p>

### Authentication & Profile
<table>
  <tr>
    <td align="center"><img src="screenshots/login_screen.png" width="200" alt="Login Screen"/><br/><em>Login Screen</em></td>
    <td align="center"><img src="screenshots/user_changepassword.png" width="200" alt="Change Password"/><br/><em>Change Password</em></td>
    <td align="center"><img src="screenshots/user_profile.png" width="200" alt="User Profile"/><br/><em>User Profile</em></td>
  </tr>
</table>

### User Dashboard
<table>
  <tr>
    <td align="center"><img src="screenshots/user_homescreen.png" width="200" alt="User Home"/><br/><em>User Home Screen</em></td>
    <td align="center"><img src="screenshots/user_dashboard.png" width="200" alt="User Dashboard"/><br/><em>Performance Dashboard</em></td>
    <td></td>
  </tr>
</table>

### Call Planning
<table>
  <tr>
    <td align="center"><img src="screenshots/call_planner.png" width="200" alt="Call Planner"/><br/><em>Call Planner</em></td>
    <td align="center"><img src="screenshots/call_plans.png" width="200" alt="Call Plans"/><br/><em>Call Plans List</em></td>
    <td align="center"><img src="screenshots/call_plans2.png" width="200" alt="Call Plans Alt"/><br/><em>Call Plans (alt)</em></td>
  </tr>
</table>

### Daily Call Reports
<table>
  <tr>
    <td align="center"><img src="screenshots/daily_call_report.png" width="200" alt="Daily Call Report"/><br/><em>DCR Form</em></td>
    <td align="center"><img src="screenshots/add_doctorinfo_dcr.png" width="200" alt="Add Doctor to DCR"/><br/><em>Add Doctor Visit</em></td>
    <td align="center"><img src="screenshots/add_doctor_info_dcr.png" width="200" alt="Add Doctor Info"/><br/><em>Doctor Visit Details</em></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/dcr_submitted.png" width="200" alt="DCR Submitted"/><br/><em>DCR Submitted</em></td>
    <td align="center"><img src="screenshots/dcr_submitted2.png" width="200" alt="DCR Submitted Alt"/><br/><em>DCR Submitted (alt)</em></td>
    <td></td>
  </tr>
</table>

### Orders
<table>
  <tr>
    <td align="center"><img src="screenshots/submit_orders.png" width="200" alt="Submit Orders"/><br/><em>Submit Order</em></td>
    <td align="center"><img src="screenshots/order_submitted.png" width="200" alt="Order Submitted"/><br/><em>Order Submitted</em></td>
    <td align="center"><img src="screenshots/order_details.png" width="200" alt="Order Details"/><br/><em>Order Details</em></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/booked_orders.png" width="200" alt="Booked Orders"/><br/><em>Booked Orders</em></td>
    <td></td>
    <td></td>
  </tr>
</table>

### Employee Location & Tracking
<table>
  <tr>
    <td align="center"><img src="screenshots/location_screen.png" width="200" alt="Location Screen"/><br/><em>Employee Locations</em></td>
    <td align="center"><img src="screenshots/user_location.png" width="200" alt="User Location Map"/><br/><em>Live Location on Map</em></td>
    <td></td>
  </tr>
</table>

### Admin Panel
<table>
  <tr>
    <td align="center"><img src="screenshots/admin_homescreen.png" width="200" alt="Admin Home"/><br/><em>Admin Home Screen</em></td>
    <td align="center"><img src="screenshots/admin_panel.png" width="200" alt="Admin Panel"/><br/><em>Admin Panel</em></td>
    <td></td>
  </tr>
</table>

### Employee Management
<table>
  <tr>
    <td align="center"><img src="screenshots/add_employee.png" width="200" alt="Add Employee"/><br/><em>Add Employee</em></td>
    <td align="center"><img src="screenshots/remove_employee.png" width="200" alt="Remove Employee"/><br/><em>Remove Employee</em></td>
    <td></td>
  </tr>
</table>

### Data Management
<table>
  <tr>
    <td align="center"><img src="screenshots/doctors.png" width="200" alt="Doctors"/><br/><em>Doctors</em></td>
    <td align="center"><img src="screenshots/add_doctor.png" width="200" alt="Add Doctor"/><br/><em>Add Doctor</em></td>
    <td align="center"><img src="screenshots/products.png" width="200" alt="Products"/><br/><em>Products</em></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/areas.png" width="200" alt="Areas"/><br/><em>Areas</em></td>
    <td></td>
    <td></td>
  </tr>
</table>

### Work Assignments
<table>
  <tr>
    <td align="center"><img src="screenshots/assign_work.png" width="200" alt="Assign Work"/><br/><em>Assign Areas & Products</em></td>
    <td align="center"><img src="screenshots/remove_assigned.png" width="200" alt="Remove Assigned"/><br/><em>View / Remove Assignments</em></td>
    <td></td>
  </tr>
</table>

---

## Gemini's Assessment (December 2025)
*This assessment was written by the Gemini CLI agent after a review of the project's source code.*

This is an impressive and comprehensive application, particularly for a final-year university project. It successfully tackles a real-world business problem with a robust set of features. The developer should be proud of this work.

### Key Strengths:
*   **Excellent Architecture:** The project demonstrates a strong understanding of modern mobile app architecture. The clear separation of concerns into `View` (UI), `viewModel` (State Management/Providers), `models` (Data Structures), and `services` (Business Logic) makes the codebase clean, scalable, and easy to navigate.
*   **Solid Feature Set:** The application is feature-rich, with complete and distinct user flows for both `Admin` and `User` roles. Core functionalities like live location tracking, daily call reporting (DCR), order management, and call planning are all well-implemented.
*   **Good Technology Choices:** The use of Flutter with the Provider package for state management and Firebase Firestore for the backend is a proven and effective stack for this type of application.

### Potential Areas for Refinement:
This project is a fantastic foundation. For any future development or as an exercise to get back into Flutter, the following areas could be focused on:
*   **Modernizing Dart & Flutter Practices:** Refactoring some of the older code patterns to fully embrace modern null-safety and updating dependencies would be a great learning exercise.
*   **Enhancing Error Handling:** Implementing more user-facing feedback for errors (e.g., network issues, failed database writes) would improve the app's robustness.
*   **UI/UX Polish:** The UI is functional and clear. Small enhancements, like adding loading indicators to buttons during async operations, could make the user experience even smoother.

Overall, this is a high-quality project that serves as a strong portfolio piece and a great base for future work.
