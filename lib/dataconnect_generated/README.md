# edaptia/dataconnect_generated/generated.dart SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
CoursesConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetCourseCatalog
#### Required Arguments
```dart
String language = ...;
CoursesConnector.instance.getCourseCatalog(
  language: language,
).execute();
```

#### Optional Arguments
We return a builder for each query. For GetCourseCatalog, we created `GetCourseCatalogBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class GetCourseCatalogVariablesBuilder {
  ...
   GetCourseCatalogVariablesBuilder limit(int? t) {
   _limit.value = t;
   return this;
  }

  ...
}
CoursesConnector.instance.getCourseCatalog(
  language: language,
)
.limit(limit)
.execute();
```

#### Return Type
`execute()` returns a `QueryResult<GetCourseCatalogData, GetCourseCatalogVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await CoursesConnector.instance.getCourseCatalog(
  language: language,
);
GetCourseCatalogData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String language = ...;

final ref = CoursesConnector.instance.getCourseCatalog(
  language: language,
).ref();
ref.execute();

ref.subscribe(...);
```


### GetCourseOutline
#### Required Arguments
```dart
String slug = ...;
CoursesConnector.instance.getCourseOutline(
  slug: slug,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetCourseOutlineData, GetCourseOutlineVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await CoursesConnector.instance.getCourseOutline(
  slug: slug,
);
GetCourseOutlineData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String slug = ...;

final ref = CoursesConnector.instance.getCourseOutline(
  slug: slug,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### UpsertLessonProgress
#### Required Arguments
```dart
String userId = ...;
String lessonId = ...;
String status = ...;
CoursesConnector.instance.upsertLessonProgress(
  userId: userId,
  lessonId: lessonId,
  status: status,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpsertLessonProgress, we created `UpsertLessonProgressBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpsertLessonProgressVariablesBuilder {
  ...
   UpsertLessonProgressVariablesBuilder score(double? t) {
   _score.value = t;
   return this;
  }

  ...
}
CoursesConnector.instance.upsertLessonProgress(
  userId: userId,
  lessonId: lessonId,
  status: status,
)
.score(score)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpsertLessonProgressData, UpsertLessonProgressVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await CoursesConnector.instance.upsertLessonProgress(
  userId: userId,
  lessonId: lessonId,
  status: status,
);
UpsertLessonProgressData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
String lessonId = ...;
String status = ...;

final ref = CoursesConnector.instance.upsertLessonProgress(
  userId: userId,
  lessonId: lessonId,
  status: status,
).ref();
ref.execute();
```

