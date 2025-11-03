import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'upsert_lesson_progress.dart';

part 'get_course_catalog.dart';

part 'get_course_outline.dart';







class CoursesConnector {
  
  
  UpsertLessonProgressVariablesBuilder upsertLessonProgress ({required String userId, required String lessonId, required String status, }) {
    return UpsertLessonProgressVariablesBuilder(dataConnect, userId: userId,lessonId: lessonId,status: status,);
  }
  
  
  GetCourseCatalogVariablesBuilder getCourseCatalog ({required String language, }) {
    return GetCourseCatalogVariablesBuilder(dataConnect, language: language,);
  }
  
  
  GetCourseOutlineVariablesBuilder getCourseOutline ({required String slug, }) {
    return GetCourseOutlineVariablesBuilder(dataConnect, slug: slug,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'courses',
    'edaptia',
  );

  CoursesConnector({required this.dataConnect});
  static CoursesConnector get instance {
    return CoursesConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}

