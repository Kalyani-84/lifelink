## **Lifelink – Digitized Blood Donation and Management System**

📌 Overview

Lifelink is a cross-platform mobile application designed to modernize the blood donation and management process. It bridges the gap between donors, patients, and blood banks by providing a real-time, intelligent, and user-friendly platform.

Built with Flutter (frontend) and Supabase (backend), the app leverages machine learning for donor-patient matching, ensures real-time inventory tracking, and enhances engagement with upcoming gamification features.

🚀 Features

  - Role-Based Dashboards – Separate interfaces for Donors, Patients, and Blood Bank Admins.

  - ML-Powered Donor Matching – Predicts donor suitability based on health history and proximity.

  - Request Management – Patients can raise blood requests, and blood banks can assign and manage them.

  - Real-Time Stock Tracking – Live visibility into blood availability.

  - Instant Notifications – Alerts for donor requests, approvals, and inventory changes.

  - Secure Backend – Authentication, storage, and encryption powered by Supabase.

  - Scalable Infrastructure – Designed for expansion with APIs and AI-driven demand forecasting.

🏗️ Tech Stack

Frontend: Flutter

  - Backend: Supabase (Authentication, Database, Storage)

  - Machine Learning: Predictive donor-patient matching model

  - Database: PostgreSQL (via Supabase)

  -Deployment: Cross-platform (Android & iOS)

📲 User Roles

  - Donor – Register, view requests, donate, and track donation history.

  - Patient – Request blood, track request status, and view available stock.

  - Blood Bank Admin – Manage requests, track inventory, and oversee donor suitability.

📊 Performance Highlights

  - Average Response Time: 0.4 – 1.2 seconds

  - Database Sync Latency: < 1 second

  - ML Model Accuracy: 92.5% (Precision: 0.91, Recall: 0.89, F1 Score: 0.90)

  - Load Handling: 1000+ concurrent users with stable performance

🔒 Security

  - Role-based authentication

  - Data encryption & secure storage

  - HTTPS for all communication

  - Access control for sensitive medical records

📈 Future Enhancements

  - Gamification with reward points & leaderboards

  - Integration with national/regional blood banks

  - AI-driven demand forecasting

  - Multilingual support for global reach

  - Government health service integration

📖 Project Theme

“Digitized Blood Donation and Management System with Predictive Intelligence and User Engagement.”
Lifelink demonstrates how technology can transform public health by creating a sustainable, scalable, and life-saving solution for blood donation systems.

## 📸 Screenshots

**1.Signup Screen**: 
The Signup Screen allows new users to create an account by providing essential details like name, email,
password, and role selection (Donor, Patient, or Blood Bank Admin). It ensures secure registration using
Supabase authentication and stores role-specific data for personalized access within the app.

<img width="300" height="700" alt="image" src="https://github.com/user-attachments/assets/b4c846b9-dc54-44bc-8192-87059b5fc4c1" />
<img width="300" height="700" alt="image" src="https://github.com/user-attachments/assets/e64e9940-fef3-4796-9aa8-4c585bdb8cf4" />

**2. Login Page:** Authentication screen where users enter credentials to access the app. Screenshot: Include a
screenshot with Email and Password fields.

<img width="300" height="700" alt="image" src="https://github.com/user-attachments/assets/3c2dfd2f-c548-4cd4-856f-0c3ffb332223" />

**3.Home screen:** Role selection Lets users choose their role (Donor, Patien).UI: Three cards or buttons with
icons representing roles.

<img width="320" height="708" alt="image" src="https://github.com/user-attachments/assets/775656bb-9239-436a-8fa5-113dbc6a10de" />

**4. Donor screen:** Home page showing user profile, recent requests, and navigation options. Key Features:
View incoming requests from blood banks and Floating action button to fill donation eligibility form

<img width="398" height="879" alt="image" src="https://github.com/user-attachments/assets/c65e48ea-3916-4e2f-a73c-19bbca8d3d82" />

5. Request History Page (Donor): Displays donation requests from blood banks.Columns: Blood Bank
Name, Request Message, Status, Actions (Accept/Reject)

<img width="323" height="654" alt="image" src="https://github.com/user-attachments/assets/3b404a27-38c6-4fd2-be28-fad0d871ae35" />

6. Donate Form Page (ML Integrated): Form for donors to input medical and personal info. Calls ML
API to predict eligibility and stores in donor_predictions. Age, Gender, Location, Blood Group, History.
 The ML model used to predict donor suitability was tested for:
• Accuracy: 92.5% match with manually validated records
• Precision and Recall: Precision = 0.91, Recall = 0.89

<img width="343" height="764" alt="image" src="https://github.com/user-attachments/assets/9c4b2224-f186-45c3-97e5-a80b55cd96d3" />
<img width="345" height="763" alt="image" src="https://github.com/user-attachments/assets/ce02935f-7610-4660-9283-7e748b89d60d" />
<img width="339" height="766" alt="image" src="https://github.com/user-attachments/assets/e7517393-5820-4b6f-9699-a90600caf479" />

7. Patient screen: Home screen for patients with profile and navigation. Access to nearby blood banks, stock
view.

<img width="357" height="796" alt="image" src="https://github.com/user-attachments/assets/ecdcdc10-4112-4c31-b33b-80bc03a99ed0" />
<img width="345" height="773" alt="image" src="https://github.com/user-attachments/assets/60cb8e54-133a-4219-b17d-6837073e84bc" />

8. Blood Bank List Page: Shows a list of registered blood banks. Blood Bank Name, Location, Stock
Overview

<img width="370" height="818" alt="image" src="https://github.com/user-attachments/assets/0931eaf3-9583-483e-9c5f-32fbf44493bb" />

9. Donor list Page: Shows predictions from ML model. Donor Info, Eligibable donor ,Request Button
Clicking "Request" sends data to request_to_donor.

<img width="361" height="804" alt="image" src="https://github.com/user-attachments/assets/ed3bf8fb-7aad-4dd4-b081-b076d72542b4" />

