import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, MutationRef, MutationPromise } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;




export interface CourseModule_Key {
  id: UUIDString;
  __typename?: 'CourseModule_Key';
}

export interface Course_Key {
  id: UUIDString;
  __typename?: 'Course_Key';
}

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

export interface GetCourseCatalogVariables {
  language: string;
  limit?: number | null;
}

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

export interface GetCourseOutlineVariables {
  slug: string;
}

export interface LessonProgress_Key {
  id: UUIDString;
  __typename?: 'LessonProgress_Key';
}

export interface Lesson_Key {
  id: UUIDString;
  __typename?: 'Lesson_Key';
}

export interface UpsertLessonProgressData {
  lessonProgress_upsert: LessonProgress_Key;
}

export interface UpsertLessonProgressVariables {
  userId: string;
  lessonId: UUIDString;
  status: string;
  score?: number | null;
}

interface UpsertLessonProgressRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpsertLessonProgressVariables): MutationRef<UpsertLessonProgressData, UpsertLessonProgressVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpsertLessonProgressVariables): MutationRef<UpsertLessonProgressData, UpsertLessonProgressVariables>;
  operationName: string;
}
export const upsertLessonProgressRef: UpsertLessonProgressRef;

export function upsertLessonProgress(vars: UpsertLessonProgressVariables): MutationPromise<UpsertLessonProgressData, UpsertLessonProgressVariables>;
export function upsertLessonProgress(dc: DataConnect, vars: UpsertLessonProgressVariables): MutationPromise<UpsertLessonProgressData, UpsertLessonProgressVariables>;

interface GetCourseCatalogRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCourseCatalogVariables): QueryRef<GetCourseCatalogData, GetCourseCatalogVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetCourseCatalogVariables): QueryRef<GetCourseCatalogData, GetCourseCatalogVariables>;
  operationName: string;
}
export const getCourseCatalogRef: GetCourseCatalogRef;

export function getCourseCatalog(vars: GetCourseCatalogVariables): QueryPromise<GetCourseCatalogData, GetCourseCatalogVariables>;
export function getCourseCatalog(dc: DataConnect, vars: GetCourseCatalogVariables): QueryPromise<GetCourseCatalogData, GetCourseCatalogVariables>;

interface GetCourseOutlineRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCourseOutlineVariables): QueryRef<GetCourseOutlineData, GetCourseOutlineVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetCourseOutlineVariables): QueryRef<GetCourseOutlineData, GetCourseOutlineVariables>;
  operationName: string;
}
export const getCourseOutlineRef: GetCourseOutlineRef;

export function getCourseOutline(vars: GetCourseOutlineVariables): QueryPromise<GetCourseOutlineData, GetCourseOutlineVariables>;
export function getCourseOutline(dc: DataConnect, vars: GetCourseOutlineVariables): QueryPromise<GetCourseOutlineData, GetCourseOutlineVariables>;

