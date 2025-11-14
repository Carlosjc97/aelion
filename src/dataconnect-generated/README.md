# Generated TypeScript README
This README will guide you through the process of using the generated JavaScript SDK package for the connector `courses`. It will also provide examples on how to use your generated SDK to call your Data Connect queries and mutations.

***NOTE:** This README is generated alongside the generated SDK. If you make changes to this file, they will be overwritten when the SDK is regenerated.*

# Table of Contents
- [**Overview**](#generated-javascript-readme)
- [**Accessing the connector**](#accessing-the-connector)
  - [*Connecting to the local Emulator*](#connecting-to-the-local-emulator)
- [**Queries**](#queries)
  - [*GetCourseCatalog*](#getcoursecatalog)
  - [*GetCourseOutline*](#getcourseoutline)
- [**Mutations**](#mutations)
  - [*UpsertLessonProgress*](#upsertlessonprogress)

# Accessing the connector
A connector is a collection of Queries and Mutations. One SDK is generated for each connector - this SDK is generated for the connector `courses`. You can find more information about connectors in the [Data Connect documentation](https://firebase.google.com/docs/data-connect#how-does).

You can use this generated SDK by importing from the package `@edaptia/dataconnect-generated` as shown below. Both CommonJS and ESM imports are supported.

You can also follow the instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#set-client).

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@edaptia/dataconnect-generated';

const dataConnect = getDataConnect(connectorConfig);
```

## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code.
You can also follow the emulator instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#instrument-clients).

```typescript
import { connectDataConnectEmulator, getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@edaptia/dataconnect-generated';

const dataConnect = getDataConnect(connectorConfig);
connectDataConnectEmulator(dataConnect, 'localhost', 9399);
```

After it's initialized, you can call your Data Connect [queries](#queries) and [mutations](#mutations) from your generated SDK.

# Queries

There are two ways to execute a Data Connect Query using the generated Web SDK:
- Using a Query Reference function, which returns a `QueryRef`
  - The `QueryRef` can be used as an argument to `executeQuery()`, which will execute the Query and return a `QueryPromise`
- Using an action shortcut function, which returns a `QueryPromise`
  - Calling the action shortcut function will execute the Query and return a `QueryPromise`

The following is true for both the action shortcut function and the `QueryRef` function:
- The `QueryPromise` returned will resolve to the result of the Query once it has finished executing
- If the Query accepts arguments, both the action shortcut function and the `QueryRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Query
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `courses` connector's generated functions to execute each query. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-queries).

## GetCourseCatalog
You can execute the `GetCourseCatalog` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getCourseCatalog(vars: GetCourseCatalogVariables): QueryPromise<GetCourseCatalogData, GetCourseCatalogVariables>;

interface GetCourseCatalogRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCourseCatalogVariables): QueryRef<GetCourseCatalogData, GetCourseCatalogVariables>;
}
export const getCourseCatalogRef: GetCourseCatalogRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getCourseCatalog(dc: DataConnect, vars: GetCourseCatalogVariables): QueryPromise<GetCourseCatalogData, GetCourseCatalogVariables>;

interface GetCourseCatalogRef {
  ...
  (dc: DataConnect, vars: GetCourseCatalogVariables): QueryRef<GetCourseCatalogData, GetCourseCatalogVariables>;
}
export const getCourseCatalogRef: GetCourseCatalogRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getCourseCatalogRef:
```typescript
const name = getCourseCatalogRef.operationName;
console.log(name);
```

### Variables
The `GetCourseCatalog` query requires an argument of type `GetCourseCatalogVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetCourseCatalogVariables {
  language: string;
  limit?: number | null;
}
```
### Return Type
Recall that executing the `GetCourseCatalog` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetCourseCatalogData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetCourseCatalogData {
  courses: ({
    id: UUIDString;
    slug: string;
    languageCode: string;
    title: string;
    subtitle?: string | null;
    summary?: string | null;
    heroImageUrl?: string | null;
    estimatedMinutes?: number | null;
    difficulty?: string | null;
    updatedAt: TimestampString;
  } & Course_Key)[];
}
```
### Using `GetCourseCatalog`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getCourseCatalog, GetCourseCatalogVariables } from '@edaptia/dataconnect-generated';

// The `GetCourseCatalog` query requires an argument of type `GetCourseCatalogVariables`:
const getCourseCatalogVars: GetCourseCatalogVariables = {
  language: ..., 
  limit: ..., // optional
};

// Call the `getCourseCatalog()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getCourseCatalog(getCourseCatalogVars);
// Variables can be defined inline as well.
const { data } = await getCourseCatalog({ language: ..., limit: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getCourseCatalog(dataConnect, getCourseCatalogVars);

console.log(data.courses);

// Or, you can use the `Promise` API.
getCourseCatalog(getCourseCatalogVars).then((response) => {
  const data = response.data;
  console.log(data.courses);
});
```

### Using `GetCourseCatalog`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getCourseCatalogRef, GetCourseCatalogVariables } from '@edaptia/dataconnect-generated';

// The `GetCourseCatalog` query requires an argument of type `GetCourseCatalogVariables`:
const getCourseCatalogVars: GetCourseCatalogVariables = {
  language: ..., 
  limit: ..., // optional
};

// Call the `getCourseCatalogRef()` function to get a reference to the query.
const ref = getCourseCatalogRef(getCourseCatalogVars);
// Variables can be defined inline as well.
const ref = getCourseCatalogRef({ language: ..., limit: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getCourseCatalogRef(dataConnect, getCourseCatalogVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.courses);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.courses);
});
```

## GetCourseOutline
You can execute the `GetCourseOutline` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getCourseOutline(vars: GetCourseOutlineVariables): QueryPromise<GetCourseOutlineData, GetCourseOutlineVariables>;

interface GetCourseOutlineRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCourseOutlineVariables): QueryRef<GetCourseOutlineData, GetCourseOutlineVariables>;
}
export const getCourseOutlineRef: GetCourseOutlineRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getCourseOutline(dc: DataConnect, vars: GetCourseOutlineVariables): QueryPromise<GetCourseOutlineData, GetCourseOutlineVariables>;

interface GetCourseOutlineRef {
  ...
  (dc: DataConnect, vars: GetCourseOutlineVariables): QueryRef<GetCourseOutlineData, GetCourseOutlineVariables>;
}
export const getCourseOutlineRef: GetCourseOutlineRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getCourseOutlineRef:
```typescript
const name = getCourseOutlineRef.operationName;
console.log(name);
```

### Variables
The `GetCourseOutline` query requires an argument of type `GetCourseOutlineVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetCourseOutlineVariables {
  slug: string;
}
```
### Return Type
Recall that executing the `GetCourseOutline` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetCourseOutlineData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetCourseOutlineData {
  courses: ({
    id: UUIDString;
    slug: string;
    languageCode: string;
    title: string;
    subtitle?: string | null;
    summary?: string | null;
    estimatedMinutes?: number | null;
    difficulty?: string | null;
    updatedAt: TimestampString;
    modules: ({
      id: UUIDString;
      title: string;
      summary?: string | null;
      orderIndex: number;
      lessons: ({
        id: UUIDString;
        title: string;
        summary?: string | null;
        durationMinutes?: number | null;
        videoUrl?: string | null;
      } & Lesson_Key)[];
    } & CourseModule_Key)[];
  } & Course_Key)[];
}
```
### Using `GetCourseOutline`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getCourseOutline, GetCourseOutlineVariables } from '@edaptia/dataconnect-generated';

// The `GetCourseOutline` query requires an argument of type `GetCourseOutlineVariables`:
const getCourseOutlineVars: GetCourseOutlineVariables = {
  slug: ..., 
};

// Call the `getCourseOutline()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getCourseOutline(getCourseOutlineVars);
// Variables can be defined inline as well.
const { data } = await getCourseOutline({ slug: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getCourseOutline(dataConnect, getCourseOutlineVars);

console.log(data.courses);

// Or, you can use the `Promise` API.
getCourseOutline(getCourseOutlineVars).then((response) => {
  const data = response.data;
  console.log(data.courses);
});
```

### Using `GetCourseOutline`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getCourseOutlineRef, GetCourseOutlineVariables } from '@edaptia/dataconnect-generated';

// The `GetCourseOutline` query requires an argument of type `GetCourseOutlineVariables`:
const getCourseOutlineVars: GetCourseOutlineVariables = {
  slug: ..., 
};

// Call the `getCourseOutlineRef()` function to get a reference to the query.
const ref = getCourseOutlineRef(getCourseOutlineVars);
// Variables can be defined inline as well.
const ref = getCourseOutlineRef({ slug: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getCourseOutlineRef(dataConnect, getCourseOutlineVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.courses);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.courses);
});
```

# Mutations

There are two ways to execute a Data Connect Mutation using the generated Web SDK:
- Using a Mutation Reference function, which returns a `MutationRef`
  - The `MutationRef` can be used as an argument to `executeMutation()`, which will execute the Mutation and return a `MutationPromise`
- Using an action shortcut function, which returns a `MutationPromise`
  - Calling the action shortcut function will execute the Mutation and return a `MutationPromise`

The following is true for both the action shortcut function and the `MutationRef` function:
- The `MutationPromise` returned will resolve to the result of the Mutation once it has finished executing
- If the Mutation accepts arguments, both the action shortcut function and the `MutationRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Mutation
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `courses` connector's generated functions to execute each mutation. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-mutations).

## UpsertLessonProgress
You can execute the `UpsertLessonProgress` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
upsertLessonProgress(vars: UpsertLessonProgressVariables): MutationPromise<UpsertLessonProgressData, UpsertLessonProgressVariables>;

interface UpsertLessonProgressRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpsertLessonProgressVariables): MutationRef<UpsertLessonProgressData, UpsertLessonProgressVariables>;
}
export const upsertLessonProgressRef: UpsertLessonProgressRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
upsertLessonProgress(dc: DataConnect, vars: UpsertLessonProgressVariables): MutationPromise<UpsertLessonProgressData, UpsertLessonProgressVariables>;

interface UpsertLessonProgressRef {
  ...
  (dc: DataConnect, vars: UpsertLessonProgressVariables): MutationRef<UpsertLessonProgressData, UpsertLessonProgressVariables>;
}
export const upsertLessonProgressRef: UpsertLessonProgressRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the upsertLessonProgressRef:
```typescript
const name = upsertLessonProgressRef.operationName;
console.log(name);
```

### Variables
The `UpsertLessonProgress` mutation requires an argument of type `UpsertLessonProgressVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpsertLessonProgressVariables {
  userId: string;
  lessonId: UUIDString;
  status: string;
  score?: number | null;
}
```
### Return Type
Recall that executing the `UpsertLessonProgress` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpsertLessonProgressData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpsertLessonProgressData {
  lessonProgress_upsert: LessonProgress_Key;
}
```
### Using `UpsertLessonProgress`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, upsertLessonProgress, UpsertLessonProgressVariables } from '@edaptia/dataconnect-generated';

// The `UpsertLessonProgress` mutation requires an argument of type `UpsertLessonProgressVariables`:
const upsertLessonProgressVars: UpsertLessonProgressVariables = {
  userId: ..., 
  lessonId: ..., 
  status: ..., 
  score: ..., // optional
};

// Call the `upsertLessonProgress()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await upsertLessonProgress(upsertLessonProgressVars);
// Variables can be defined inline as well.
const { data } = await upsertLessonProgress({ userId: ..., lessonId: ..., status: ..., score: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await upsertLessonProgress(dataConnect, upsertLessonProgressVars);

console.log(data.lessonProgress_upsert);

// Or, you can use the `Promise` API.
upsertLessonProgress(upsertLessonProgressVars).then((response) => {
  const data = response.data;
  console.log(data.lessonProgress_upsert);
});
```

### Using `UpsertLessonProgress`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, upsertLessonProgressRef, UpsertLessonProgressVariables } from '@edaptia/dataconnect-generated';

// The `UpsertLessonProgress` mutation requires an argument of type `UpsertLessonProgressVariables`:
const upsertLessonProgressVars: UpsertLessonProgressVariables = {
  userId: ..., 
  lessonId: ..., 
  status: ..., 
  score: ..., // optional
};

// Call the `upsertLessonProgressRef()` function to get a reference to the mutation.
const ref = upsertLessonProgressRef(upsertLessonProgressVars);
// Variables can be defined inline as well.
const ref = upsertLessonProgressRef({ userId: ..., lessonId: ..., status: ..., score: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = upsertLessonProgressRef(dataConnect, upsertLessonProgressVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.lessonProgress_upsert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.lessonProgress_upsert);
});
```

