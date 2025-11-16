# User App

A Flutter application demonstrating Clean Architecture principles with user management features, including list view, detail view, search, and pagination.

## Features

- 📋 User list with infinite scroll pagination
- 🔍 Real-time search with debouncing
- 👤 User detail view
- 💾 Smart caching with offline support
- 🔄 Pull-to-refresh
- 🎨 Material Design 3 theming

## Architecture

This application follows **Clean Architecture** principles with clear separation of concerns across three layers:

### Layer Structure

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (BLoC, Pages, Widgets)                 │
└─────────────────────────────────────────┘
              ↓ Events/States
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│  (Entities, Use Cases, Repositories)    │
└─────────────────────────────────────────┘
              ↓ Interfaces
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Models, Data Sources, Repository Impl)│
└─────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── features/               # Feature-based organization
│   └── user/
│       ├── domain/         # Business logic (pure Dart)
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       ├── data/           # Data handling
│       │   ├── models/
│       │   ├── datasources/
│       │   │   ├── local/
│       │   │   └── remote/
│       │   └── repositories/
│       └── presentation/   # UI layer
│           ├── blocs/
│           ├── pages/
│           └── widgets/
├── core/                   # Shared functionality
│   ├── api/               # HTTP client
│   ├── db/                # Hive database
│   ├── di/                # Dependency injection
│   ├── error/             # Exception & failure handling
│   ├── event/             # Event bus
│   ├── network/           # Connectivity
│   └── services/          # Cache & config services
└── config/
    ├── routes/            # Navigation
    └── theme/             # Theming
```

## Tech Stack

**State Management**
- `flutter_bloc` - BLoC pattern implementation
- `equatable` - Value equality

**Dependency Injection**
- `get_it` - Service locator pattern

**Navigation**
- `go_router` - Declarative routing

**Local Storage**
- `hive` - NoSQL database
- `hive_flutter` - Flutter integration

**Networking**
- `dio` - HTTP client
- `connectivity_plus` - Network status

**Functional Programming**
- `dartz` - Either monad for error handling

**API**
- [ReqRes API](https://reqres.in) - User data source

## Key Concepts

### Error Handling: Exceptions vs Failures

The app uses two distinct error types following Clean Architecture:

**Exceptions** (Data Layer - Thrown)
- Technical errors during operations
- Used in data sources (API, cache)
- Types: `ServerException`, `CacheException`, `NetworkException`

```dart
// Data source throws exception
final users = await apiClient.get('/users');
// might throw ServerException
```

**Failures** (Domain Layer - Returned)
- Business logic errors
- Returned via `Either<Failure, Success>`
- Types: `ServerFailure`, `CacheFailure`, `NetworkFailure`

```dart
// Repository converts exception → failure
try {
  final users = await remoteDataSource.getUsers();
  return Right(users);
} on ServerException catch (e) {
  return Left(ServerFailure(message: e.message));
}
```

**Why both?**
- Repository acts as translation layer
- Data layer uses imperative error handling (throw/catch)
- Domain/Presentation use functional error handling (Either)
- BLoCs pattern match on Either - no try/catch needed

### Caching Strategy

Smart caching with offline support using Hive:

**Online Mode:**
1. Fetch from API
2. Cache response (1 hour expiry)
3. Return fresh data

**Offline Mode:**
1. Check local cache
2. Return cached data if available
3. Show error if no cache

**Fallback:**
- API fails but online → return stale cache
- Configurable in `CachedDataSource`

### Event Bus Pattern

Cross-BLoC communication without tight coupling:

```dart
// Producer BLoC
class UserListBloc {
  final AppEventBus _eventBus;
  
  void _onDelete(event, emit) {
    // After successful delete
    _eventBus.fire(UserDeletedEvent(id: event.id));
  }
}

// Consumer BLoC
class UserDetailBloc {
  late StreamSubscription _subscription;
  
  UserDetailBloc({required AppEventBus eventBus}) {
    _subscription = eventBus.stream.listen((event) {
      if (event is UserDeletedEvent) {
        add(RefreshEvent());
      }
    });
  }
  
  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
```

### Widget Best Practices

**Widget Classes vs Methods**
```dart
// ❌ BAD: Widget method
Widget _buildHeader() => Text('Header');

// ✅ GOOD: Widget class
class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(context) => const Text('Header');
}
```

**Pure Widgets with Callbacks**
```dart
// ❌ BAD: Tight coupling
class UserList extends StatelessWidget {
  Widget build(context) {
    return GestureDetector(
      onTap: () {
        context.read<UserBloc>().add(Event());
        Navigator.push(...);
      },
    );
  }
}

// ✅ GOOD: Pure widget
class UserList extends StatelessWidget {
  final Function(User) onUserTap;
  
  const UserList({required this.onUserTap});
  
  Widget build(context) {
    return GestureDetector(
      onTap: () => onUserTap(user),
    );
  }
}
```

**Why?**
- Widget methods prevent const optimization
- Direct BLoC access makes widgets untestable
- Callbacks enable reusability

### BLoC Patterns

**Creation vs Interaction**

```dart
// ✅ CREATION: Use sl<>()..add() for new instances
static Widget create({required int id}) {
  return BlocProvider(
    create: (context) => sl<UserDetailBloc>()..add(LoadEvent(id)),
    child: const UserDetailPage(),
  );
}

// ✅ INTERACTION: Use context.read<>().add() for user actions
onPressed: () => context.read<UserListBloc>().add(RefreshEvent()),
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+

### Installation

```bash
# Clone repository
git clone https://github.com/KayesAshfaQ/user_app.git

# Navigate to project
cd user_app

# Install dependencies
flutter pub get

# Run app
flutter run
```

### Project Commands

```bash
# Code generation (if needed)
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/
```

### Create New Feature

Use the scaffold script:

```bash
./scripts/create_feature.sh
# Enter feature name when prompted
```

## Project Structure

Each feature follows Clean Architecture:

```
features/user/
├── domain/              # Pure business logic
│   ├── entities/        # UserEntity, PaginatedUsersEntity
│   ├── repositories/    # UserRepository (interface)
│   └── usecases/        # GetUsersUsecase, SearchUsersUsecase
├── data/                # Data handling
│   ├── models/          # UserModel (JSON serialization)
│   ├── datasources/
│   │   ├── local/       # Hive cache
│   │   └── remote/      # API calls
│   └── repositories/    # UserRepositoryImpl
└── presentation/
    ├── blocs/           # UserListBloc, UserDetailBloc
    ├── pages/           # UserListPage, UserDetailPage
    └── widgets/         # Reusable UI components
```

## License

This project is open source and available under the [MIT License](LICENSE).
