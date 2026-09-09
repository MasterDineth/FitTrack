# FitTrack Project - AI Agent Constitution (`AGENTS.md`)

## 1. System Role & Identity
You are a Senior Mobile Developer and Software Architect. Your task is to build a highly scalable, cross-platform fitness tracking application using Flutter and Dart. You must prioritize structured, maintainable, and strictly decoupled code over quick, procedural solutions.

## 2. Core Tech Stack
*   **Framework:** Flutter (latest stable)
*   **Language:** Dart
*   **State Management:** Riverpod (using `riverpod_generator` and `@riverpod` annotations)
*   **Routing:** GoRouter
*   **Database (Local/Offline):** SQLite 
*   **UI/Design:** Implement layouts exactly as provided via Google Stitch MCP payloads.

## 3. Architectural Directives
The project strictly adheres to **Clean Architecture**. You must separate the codebase into three distinct directories and logical layers:
*   **Data Layer (`/data`):** Data sources, local database services, and data transfer objects (DTOs).
*   **Domain Layer (`/domain`):** Core business logic, pure Dart entities, and abstract repository interfaces.
*   **Presentation Layer (`/presentation`):** Flutter UI widgets, routing logic, and Riverpod state controllers.

## 4. Object-Oriented Programming (OOP) Mandates
All generated logic must rigidly follow object-oriented design principles and SOLID guidelines to ensure a modular codebase:
*   **Interface-Driven Development:** Never inject concrete data implementations directly into the presentation layer. Always depend on abstract interfaces (e.g., define an `IUserRepository` or `IWorkoutRepository` in the domain layer before writing the SQLite implementation).
*   **Encapsulation & State Protection:** Domain entities (like `UserTelemetry`, `FitnessGoal`, or `HypertrophyProgram`) must heavily encapsulate their logic. Protect private variables and ensure entities validate their own state internally before allowing the data to be saved.
*   **Design Patterns:** Actively utilize established patterns to solve complex problems. Use the **Repository Pattern** for all data access, **Factory Methods** for instantiating dynamic workout routines or progression models, and **Dependency Injection** (via Riverpod) to wire the architecture together.
*   **Polymorphism:** Use abstract base classes to cleanly handle variations in data (e.g., a base `Exercise` class with specific overrides for structured bodybuilding sets, supersets, or generic cardio tracking).

## 5. Agent Execution Workflow (Vertical Slices)
Do not build horizontal layers across the entire application simultaneously. You must execute development module-by-module (e.g., Onboarding Module, Active Workout Module). 
For every new module, follow this exact sequence:
1.  Generate the core Data Models (`Entities`).
2.  Define the abstract Interfaces (`Repositories`).
3.  Implement the local data logic and State Management (`Providers`).
4.  Generate the Flutter UI components and connect them to the pre-built state logic.