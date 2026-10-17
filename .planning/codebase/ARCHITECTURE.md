# EBS BioCrop Science - Architecture Documentation

## Architectural Pattern
Clean Architecture with Flutter BLoC pattern:
- **Presentation Layer**: Stateless and Stateful widgets consuming BLoC states via `BlocBuilder` and `BlocConsumer`. No business logic in UI widgets.
- **Logic Layer (BLoC)**: Pure Dart business logic classes extending `Bloc<Event, State>` with immutable states (`Equatable`).
- **Data Layer**: Data models with immutability, JSON/serialization mapping, and repositories abstracting catalog and cart data sources.
- **Core Layer**: Color tokens, theme definitions, constants, and utilities.
