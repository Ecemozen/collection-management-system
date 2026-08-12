# Collection Management System

A full-stack collection management system developed with Flutter and ASP.NET Core Web API.

The application provides centralized management of customers, debts, payments, collection processes and reporting operations.

---

## Demo Login

**Email:** `admin@yigit.com`

**Password:** `123456`

The demo account is provided for testing and demonstration purposes.

---

## About the Project

Collection Management System is a full-stack application designed to manage customer accounts, debts, payments, collection processes and reporting operations through a centralized digital platform.

The project consists of two main layers:

- **Frontend:** Flutter / Dart
- **Backend:** ASP.NET Core Web API / C#

The Flutter application communicates with the backend through RESTful APIs and retrieves application data from backend services.

---

## Features

### Authentication

- Admin login
- Email and password authentication
- Backend-based authentication
- Authorization infrastructure
- API-based authentication flow

### Dashboard

- Total collections
- Total debts
- Remaining debts
- Customer count
- Payment statistics
- Collection statistics
- Financial summary cards
- Visual data representation

### Customer Management

- List customers
- View customer details
- Create customers
- Update customer information
- Delete customers

### Debt Management

- List debts
- View debt details
- Create debt records
- Update debt records
- Delete debt records
- View overdue debts
- Search by customer name
- Filter debts
- Sort debts
- Paginate debt records

### Payment and Collection Management

- List payments
- View payment details
- Create payments
- Update payments
- Delete payments
- Track payment dates and amounts
- Track payment status
- Add payment descriptions
- Associate payments with debt records

---

## Reporting

### Monthly Collection Report

The monthly report provides detailed information about collection activity for a selected month.

It includes:

- Total collection amount
- Number of collections
- Customer count
- Collection success rate
- Average collection amount
- Daily collection statistics
- Highest collection day
- Pending amounts
- Monthly payment list
- Collection charts

Reports can be exported as PDF and printed directly.

### Customer Reports

Customer-based reporting provides:

- Total customers
- Active customers
- Pending transactions
- Average collection
- Most active customer
- Highest collection customer
- Number of transactions
- Collection success rate
- Customer-based collection ranking

---

## Technologies

### Frontend

- Flutter
- Dart
- Material Design
- Responsive UI
- REST API integration
- JSON parsing
- HTTP communication
- PDF handling
- Printing
- File management

### Backend

- C#
- ASP.NET Core Web API
- RESTful API
- Entity Framework Core
- Dependency Injection
- Service Layer
- Interface-based architecture
- DTOs
- Entity models
- Controller architecture
- Authentication
- Authorization
- Logging
- CRUD operations
- Filtering
- Sorting
- Pagination

### Database

The backend uses a relational database architecture.

Main entities include:

- Customers
- Debts
- Payments
- Fee Types

Entity Framework Core is used for database communication and data access.

### Reporting

- PDF generation
- PDF file handling
- Flutter Printing
- Backend reporting services

---

## Architecture

The application follows a layered full-stack architecture.

```text
Flutter Frontend
       |
       | HTTP / REST API
       v
ASP.NET Core Web API
       |
       +-- Controllers
       +-- Services
       +-- Interfaces
       +-- DTOs
       +-- Entities
       |
       v
Entity Framework Core
       |
       v
Database
```

The frontend does not directly access the database. All application data is requested through the backend API.

---

## API Integration

The Flutter application communicates with the ASP.NET Core backend through RESTful HTTP requests.

API requests are centralized through an `ApiService` structure.

Example:

```dart
final response = await api.get("Customers");
```

Corresponding backend endpoint:

```http
GET /api/Customers
```

The backend processes the request and returns JSON data to the Flutter application.

---

## API Endpoints

### Authentication

```http
POST /api/Auth/login
```

### Customers

```http
GET    /api/Customers
GET    /api/Customers/{id}
POST   /api/Customers
PUT    /api/Customers/{id}
DELETE /api/Customers/{id}
```

### Debts

```http
GET    /api/Debts
GET    /api/Debts/{id}
GET    /api/Debts/paged
GET    /api/Debts/sort
GET    /api/Debts/filter
GET    /api/Debts/overdue
GET    /api/Debts/search
POST   /api/Debts
PUT    /api/Debts/{id}
DELETE /api/Debts/{id}
```

### Debt Reports

```http
GET /api/Debts/report
GET /api/Debts/excel
```

### Payments

```http
GET    /api/Payments
GET    /api/Payments/{id}
POST   /api/Payments
PUT    /api/Payments/{id}
DELETE /api/Payments/{id}
```

### Dashboard

```http
GET /api/Dashboard
```

---

## Data Flow

```text
Flutter UI
     |
     v
ApiService
     |
     | GET /api/Customers
     v
CustomersController
     |
     v
ICustomerService
     |
     v
CustomerService
     |
     v
Entity Framework Core
     |
     v
Database
     |
     v
JSON Response
     |
     v
Flutter UI
```

This architecture separates the presentation layer, business logic and data access layer.

---

## Project Structure

### Frontend

```text
tahsilat_mobile/
|
+-- lib/
|   |
|   +-- core/
|   |   +-- constants/
|   |   +-- services/
|   |       +-- api_service.dart
|   |
|   +-- features/
|       +-- auth/
|       +-- dashboard/
|       +-- customer/
|       +-- payment/
|       +-- receipt/
|       +-- reports/
|
+-- assets/
|   +-- images/
|
+-- android/
+-- ios/
+-- linux/
+-- macos/
+-- web/
+-- windows/
|
+-- pubspec.yaml
+-- main.dart
```

### Backend

```text
YigitTahsilat.API/
|
+-- Controllers/
|   +-- AuthController.cs
|   +-- DashboardController.cs
|   +-- CustomersController.cs
|   +-- DebtsController.cs
|   +-- PaymentsController.cs
|   +-- FeeTypesController.cs
|   +-- ReceiptsController.cs
|
+-- DTOs/
|   +-- Auth/
|   +-- Common/
|   +-- Customer/
|   +-- Dashboard/
|   +-- Debt/
|   +-- FeeType/
|   +-- Payment/
|   +-- Receipt/
|
+-- Entities/
+-- Interfaces/
+-- Services/
+-- Data/
+-- Mappings/
+-- Middlewares/
+-- Migrations/
|
+-- Program.cs
+-- appsettings.json
```

---

## Installation

### Requirements

- Flutter SDK
- Dart SDK
- .NET SDK
- Visual Studio or Visual Studio Code
- Git
- Supported relational database

### Clone the Repository

```bash
git clone https://github.com/Ecemozen/collection-management-system.git
cd collection-management-system
```

### Frontend Setup

```bash
cd Mobile/tahsilat_mobile
flutter pub get
flutter doctor
flutter devices
flutter run
```

For Windows:

```bash
flutter run -d windows
```

### Backend Setup

```bash
cd Backend
dotnet restore
dotnet build
dotnet run
```

---

## Database Configuration

Configure the database connection in `appsettings.json`.

Example:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "YOUR_CONNECTION_STRING"
  }
}
```

Production credentials and sensitive database information should not be committed to the repository.

---

## Frontend API Configuration

Configure the backend URL in the Flutter application.

Example:

```dart
const String baseUrl = "http://localhost:5000/api/";
```

When using an Android emulator, `localhost` may need to be replaced with `10.0.2.2`.

```dart
const String baseUrl = "http://10.0.2.2:5000/api/";
```

The correct API address depends on the development environment and target platform.

---

## API Testing

The ASP.NET Core API can be tested through Swagger.

After starting the backend, open:

```text
/swagger
```

Swagger can be used to test:

- GET requests
- POST requests
- PUT requests
- DELETE requests
- Authentication endpoints
- Dashboard endpoints
- Report endpoints

---

## Security

Sensitive information should not be stored directly inside the public repository.

Keep the following outside the repository:

- Database passwords
- JWT secrets
- API keys
- Production credentials
- Private configuration values

Recommended approaches include:

- Environment Variables
- .NET User Secrets
- Development configuration
- Production secret management

---

## Main Modules

| Module | Description |
|---|---|
| Authentication | Admin authentication and login |
| Dashboard | General system statistics |
| Customers | Customer management |
| Debts | Debt management |
| Payments | Payment and collection management |
| Receipts | Receipt management |
| Monthly Reports | Monthly collection analysis |
| Customer Reports | Customer-based reporting |
| PDF Reports | PDF report generation |
| Printing | Report printing |

---

## Technical Skills Demonstrated

- Flutter application development
- Dart programming
- C# programming
- ASP.NET Core Web API
- RESTful API development
- API integration
- JSON serialization and deserialization
- Entity Framework Core
- CRUD operations
- DTO architecture
- Service Layer architecture
- Repository pattern
- Dependency Injection
- Interface-based programming
- Authentication and Authorization
- Database operations
- Data filtering
- Data sorting
- Pagination
- Dashboard development
- Responsive UI design
- PDF report generation
- Printing
- Git and GitHub

---

## Project Goals

The main goal is to provide a centralized digital platform for managing collection processes.

The system aims to:

- Reduce manual collection tracking
- Centralize customer and debt information
- Simplify payment management
- Improve financial visibility
- Provide meaningful reports
- Enable faster access to collection data
- Connect a modern Flutter frontend with a scalable backend API

---

## Future Improvements

- [ ] Advanced JWT authentication
- [ ] Role-based authorization
- [ ] Advanced dashboard charts
- [ ] Date-range reporting
- [ ] Advanced filtering
- [ ] Push notifications
- [ ] Email notifications
- [ ] Cloud deployment
- [ ] Production database deployment
- [ ] Unit testing
- [ ] Integration testing
- [ ] Automated CI/CD pipeline
- [ ] Improved mobile responsiveness

---

## Developer

### Ecem Özen

Computer Engineering Student

Zonguldak Bülent Ecevit University


Copyright 2026 Ecem Özen. All rights reserved.
