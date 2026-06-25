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

### Authentication
<img src="screenshots_updated_design/login_screen.jpg" width="200"/>

### User Home & Dashboard
<img src="screenshots_updated_design/user_home.jpg" width="200"/> <img src="screenshots_updated_design/user_home2.jpg" width="200"/> <img src="screenshots_updated_design/user_dashboard.jpg" width="200"/>
<img src="screenshots_updated_design/user_dashboard2.jpg" width="200"/>

### User Profile
<img src="screenshots_updated_design/user_profile.jpg" width="200"/> <img src="screenshots_updated_design/user_profile2.jpg" width="200"/>

### Call Planning
<img src="screenshots_updated_design/call_planner.jpg" width="200"/> <img src="screenshots_updated_design/call_plans.jpg" width="200"/>

### Daily Call Reports
<img src="screenshots_updated_design/daily_call_report.jpg" width="200"/> <img src="screenshots_updated_design/dcr_details.jpg" width="200"/>

### Orders
<img src="screenshots_updated_design/order_screen.jpg" width="200"/> <img src="screenshots_updated_design/orders.jpg" width="200"/> <img src="screenshots_updated_design/order_detail.jpg" width="200"/>

### Location & Maps
<img src="screenshots_updated_design/location_screen.jpg" width="200"/> <img src="screenshots_updated_design/map_screen.jpg" width="200"/>

### Admin Panel
<img src="screenshots_updated_design/admin_home.jpg" width="200"/> <img src="screenshots_updated_design/admin_dashboard.jpg" width="200"/> <img src="screenshots_updated_design/admin_panel.jpeg" width="200"/>
<img src="screenshots_updated_design/admin_profile.jpg" width="200"/> <img src="screenshots_updated_design/admin_profile2.jpg" width="200"/> <img src="screenshots_updated_design/monthly_targets.jpg" width="200"/>

### Data Management
<img src="screenshots_updated_design/doctors.jpg" width="200"/> <img src="screenshots_updated_design/products.jpg" width="200"/> <img src="screenshots_updated_design/areas.jpg" width="200"/>

### Work Assignments
<img src="screenshots_updated_design/assign_products_areas.jpg" width="200"/> <img src="screenshots_updated_design/view_assigned.jpg" width="200"/>

### Dark Theme
<img src="screenshots_updated_design/black_theme.jpg" width="200"/>

