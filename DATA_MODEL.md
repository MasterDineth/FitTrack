# FitTrack User Data Model & Database Schema

Based on the onboarding flow analysis, the data model is divided into three core domains: Authentication, Body Telemetry, and Fitness Goals.

## 1. User (Authentication)
Handles identity and security.
*   **id** `String (UUID)`: Primary Key
*   **email** `String`: Unique user email
*   **passwordHash** `String`: Encrypted password
*   **createdAt** `DateTime`: Account creation timestamp
*   **updatedAt** `DateTime`: Last update timestamp

## 2. Body Telemetry
Captures biometric data required for calculating BMI, BMR, and physical tracking.
*   **id** `String (UUID)`: Primary Key
*   **userId** `String (UUID)`: Foreign Key (User)
*   **unitSystem** `Enum`: `metric` (kg/cm) or `imperial` (lbs/ft)
*   **biologicalSex** `Enum`: `male`, `female`, `other`
*   **age** `Integer`: User's age in years (e.g., 24)
*   **weight** `Double`: Current weight
*   **height** `Double`: Standing stature
*   **recordedAt** `DateTime`: Timestamp of when the telemetry was recorded

## 3. Fitness Profile (Goals & Setup)
Captures the user's training experience, goals, and constraints to tailor the algorithm.
*   **id** `String (UUID)`: Primary Key
*   **userId** `String (UUID)`: Foreign Key (User)
*   **primaryFocus** `Enum`: 
    *   `hypertrophy` (Build Muscle)
    *   `strength` (Increase Strength & PRs)
    *   `fat_loss` (Fat Loss & Conditioning)
*   **liftingExperience** `Enum`: 
    *   `beginner` (< 6 months)
    *   `intermediate` (6m - 2 years)
    *   `advanced` (2+ years)
*   **weeklyFrequency** `Integer`: Days per week (e.g., 2, 3, 4, 5, 6)
*   **availableEquipment** `Enum`: 
    *   `full_gym`
    *   `barbell_dumbbells`
    *   `home_bodyweight`
*   **updatedAt** `DateTime`: Timestamp of the last profile update
