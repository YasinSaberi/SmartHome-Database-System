# Smart Home Database System 🏠
### Database Laboratory Project

This repository contains the source code for a comprehensive **Smart Home Management Database** implemented in **Microsoft SQL Server**. The system is designed to handle device management, sensor data logging, automation scenes, and security alerts efficiently.

## 📌 Executive Summary
The project simulates a real-world IoT environment where devices (Lights, Thermostats, Cameras) interact via a central database. It features complex logic using **Stored Procedures** for actions, **Triggers** for audit logs, and **Analytical Queries** for sensor data interpretation.

## 🛠 Tech Stack
* **Database Engine:** SQL Server (T-SQL)
* **Key Concepts:** Normalization, ACID Transactions, Indexing, Automation Logic.

## 📂 Project Structure
The solution is modularized into 8 sequential scripts for better maintainability:

| File | Description |
| :--- | :--- |
| `01_Base_Tables.sql` | Core schema definitions (Users, Rooms, DeviceTypes). |
| `02_Main_Structure.sql` | Operational tables with Foreign Key constraints (Devices, SensorReadings). |
| `03_Data_Seeding.sql` | Initial mock data for testing scenarios. |
| `04_Views_And_Functions.sql` | `View_CriticalSensors` and UDFs for temperature calculation. |
| `05_Procedures_And_Triggers.sql` | `SP_ActivateScene` and Triggers for security/auditing. |
| `06_Testing_And_Verification.sql` | Execution scripts to validate system integrity. |
| `07_Phase3_Refinement.sql` | Indexing and bulk data generation loop. |
| `08_Advanced_Analytics.sql` | Analytical queries using CTEs and Window Functions. |

## 🚀 Key Features
1.  **Scene Automation:** Grouped device actions (e.g., "Good Night" mode locks doors and turns off lights).
2.  **Security Auditing:** Triggers automatically log critical state changes and intruder alerts.
3.  **Data Analytics:** Advanced queries to analyze room temperature trends and device activity.

## 👤 Author
**Yasin** - Computer Engineering Student
