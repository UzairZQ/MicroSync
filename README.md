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

### Authentication
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/login_screen.jpg" width="200" alt="Login Screen"/><br/><em>Login Screen</em></td>
    <td></td>
    <td></td>
  </tr>
</table>

### User Home & Dashboard
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/user_home.jpg" width="200" alt="User Home"/><br/><em>User Home</em></td>
    <td align="center"><img src="screenshots_updated_design/user_home2.jpg" width="200" alt="User Home Alt"/><br/><em>User Home (alt)</em></td>
    <td align="center"><img src="screenshots_updated_design/user_dashboard.jpg" width="200" alt="User Dashboard"/><br/><em>User Dashboard</em></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots_updated_design/user_dashboard2.jpg" width="200" alt="User Dashboard Alt"/><br/><em>User Dashboard (alt)</em></td>
    <td></td>
    <td></td>
  </tr>
</table>

### User Profile
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/user_profile.jpg" width="200" alt="User Profile"/><br/><em>User Profile</em></td>
    <td align="center"><img src="screenshots_updated_design/user_profile2.jpg" width="200" alt="User Profile Alt"/><br/><em>User Profile (alt)</em></td>
    <td></td>
  </tr>
</table>

### Call Planning
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/call_planner.jpg" width="200" alt="Call Planner"/><br/><em>Call Planner</em></td>
    <td align="center"><img src="screenshots_updated_design/call_plans.jpg" width="200" alt="Call Plans"/><br/><em>Call Plans</em></td>
    <td></td>
  </tr>
</table>

### Daily Call Reports
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/daily_call_report.jpg" width="200" alt="Daily Call Report"/><br/><em>Daily Call Report</em></td>
    <td align="center"><img src="screenshots_updated_design/dcr_details.jpg" width="200" alt="DCR Details"/><br/><em>DCR Details</em></td>
    <td></td>
  </tr>
</table>

### Orders
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/order_screen.jpg" width="200" alt="Order Screen"/><br/><em>Order Screen</em></td>
    <td align="center"><img src="screenshots_updated_design/orders.jpg" width="200" alt="Orders List"/><br/><em>Orders List</em></td>
    <td align="center"><img src="screenshots_updated_design/order_detail.jpg" width="200" alt="Order Detail"/><br/><em>Order Detail</em></td>
  </tr>
</table>

### Location & Maps
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/location_screen.jpg" width="200" alt="Location Screen"/><br/><em>Employee Locations</em></td>
    <td align="center"><img src="screenshots_updated_design/map_screen.jpg" width="200" alt="Map Screen"/><br/><em>Live Location on Map</em></td>
    <td></td>
  </tr>
</table>

### Admin Panel
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/admin_home.jpg" width="200" alt="Admin Home"/><br/><em>Admin Home</em></td>
    <td align="center"><img src="screenshots_updated_design/admin_dashboard.jpg" width="200" alt="Admin Dashboard"/><br/><em>Admin Dashboard</em></td>
    <td align="center"><img src="screenshots_updated_design/admin_panel.jpeg" width="200" alt="Admin Panel"/><br/><em>Admin Panel</em></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots_updated_design/admin_profile.jpg" width="200" alt="Admin Profile"/><br/><em>Admin Profile</em></td>
    <td align="center"><img src="screenshots_updated_design/admin_profile2.jpg" width="200" alt="Admin Profile Alt"/><br/><em>Admin Profile (alt)</em></td>
    <td align="center"><img src="screenshots_updated_design/monthly_targets.jpg" width="200" alt="Monthly Targets"/><br/><em>Monthly Targets</em></td>
  </tr>
</table>

### Data Management
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/doctors.jpg" width="200" alt="Doctors"/><br/><em>Doctors</em></td>
    <td align="center"><img src="screenshots_updated_design/products.jpg" width="200" alt="Products"/><br/><em>Products</em></td>
    <td align="center"><img src="screenshots_updated_design/areas.jpg" width="200" alt="Areas"/><br/><em>Areas</em></td>
  </tr>
</table>

### Work Assignments
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/assign_products_areas.jpg" width="200" alt="Assign Products & Areas"/><br/><em>Assign Products & Areas</em></td>
    <td align="center"><img src="screenshots_updated_design/view_assigned.jpg" width="200" alt="View Assigned"/><br/><em>View / Remove Assignments</em></td>
    <td></td>
  </tr>
</table>

### Dark Theme
<table>
  <tr>
    <td align="center"><img src="screenshots_updated_design/black_theme.jpg" width="200" alt="Dark Theme"/><br/><em>Dark Theme</em></td>
    <td></td>
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
