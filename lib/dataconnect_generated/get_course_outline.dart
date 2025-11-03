part of 'courses.dart';

class GetCourseOutlineVariablesBuilder {
  String slug;

  final FirebaseDataConnect _dataConnect;
  GetCourseOutlineVariablesBuilder(this._dataConnect, {required  this.slug,});
  Deserializer<GetCourseOutlineData> dataDeserializer = (dynamic json)  => GetCourseOutlineData.fromJson(jsonDecode(json));
  Serializer<GetCourseOutlineVariables> varsSerializer = (GetCourseOutlineVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetCourseOutlineData, GetCourseOutlineVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetCourseOutlineData, GetCourseOutlineVariables> ref() {
    GetCourseOutlineVariables vars= GetCourseOutlineVariables(slug: slug,);
    return _dataConnect.query("GetCourseOutline", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetCourseOutlineCourses {
  final String id;
  final String slug;
  final String languageCode;
  final String title;
  final String? subtitle;
  final String? summary;
  final int? estimatedMinutes;
  final String? difficulty;
  final Timestamp updatedAt;
  final List<GetCourseOutlineCoursesModules> modules;
  GetCourseOutlineCourses.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  slug = nativeFromJson<String>(json['slug']),
  languageCode = nativeFromJson<String>(json['languageCode']),
  title = nativeFromJson<String>(json['title']),
  subtitle = json['subtitle'] == null ? null : nativeFromJson<String>(json['subtitle']),
  summary = json['summary'] == null ? null : nativeFromJson<String>(json['summary']),
  estimatedMinutes = json['estimatedMinutes'] == null ? null : nativeFromJson<int>(json['estimatedMinutes']),
  difficulty = json['difficulty'] == null ? null : nativeFromJson<String>(json['difficulty']),
  updatedAt = Timestamp.fromJson(json['updatedAt']),
  modules = (json['modules'] as List<dynamic>)
        .map((e) => GetCourseOutlineCoursesModules.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseOutlineCourses otherTyped = other as GetCourseOutlineCourses;
    return id == otherTyped.id && 
    slug == otherTyped.slug && 
    languageCode == otherTyped.languageCode && 
    title == otherTyped.title && 
    subtitle == otherTyped.subtitle && 
    summary == otherTyped.summary && 
    estimatedMinutes == otherTyped.estimatedMinutes && 
    difficulty == otherTyped.difficulty && 
    updatedAt == otherTyped.updatedAt && 
    modules == otherTyped.modules;
    
  }
  @override
  int get hashCode => Object.hash(id.hashCode, slug.hashCode, languageCode.hashCode, title.hashCode, subtitle.hashCode, summary.hashCode, estimatedMinutes.hashCode, difficulty.hashCode, updatedAt.hashCode, modules.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['slug'] = nativeToJson<String>(slug);
    json['languageCode'] = nativeToJson<String>(languageCode);
    json['title'] = nativeToJson<String>(title);
    if (subtitle != null) {
      json['subtitle'] = nativeToJson<String?>(subtitle);
    }
    if (summary != null) {
      json['summary'] = nativeToJson<String?>(summary);
    }
    if (estimatedMinutes != null) {
      json['estimatedMinutes'] = nativeToJson<int?>(estimatedMinutes);
    }
    if (difficulty != null) {
      json['difficulty'] = nativeToJson<String?>(difficulty);
    }
    json['updatedAt'] = updatedAt.toJson();
    json['modules'] = modules.map((e) => e.toJson()).toList();
    return json;
  }

  GetCourseOutlineCourses({
    required this.id,
    required this.slug,
    required this.languageCode,
    required this.title,
    this.subtitle,
    this.summary,
    this.estimatedMinutes,
    this.difficulty,
    required this.updatedAt,
    required this.modules,
  });
}

@immutable
class GetCourseOutlineCoursesModules {
  final String id;
  final String title;
  final String? summary;
  final int orderIndex;
  final List<GetCourseOutlineCoursesModulesLessons> lessons;
  GetCourseOutlineCoursesModules.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  summary = json['summary'] == null ? null : nativeFromJson<String>(json['summary']),
  orderIndex = nativeFromJson<int>(json['orderIndex']),
  lessons = (json['lessons'] as List<dynamic>)
        .map((e) => GetCourseOutlineCoursesModulesLessons.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseOutlineCoursesModules otherTyped = other as GetCourseOutlineCoursesModules;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    summary == otherTyped.summary && 
    orderIndex == otherTyped.orderIndex && 
    lessons == otherTyped.lessons;
    
  }
  @override
  int get hashCode => Object.hash(id.hashCode, title.hashCode, summary.hashCode, orderIndex.hashCode, lessons.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    if (summary != null) {
      json['summary'] = nativeToJson<String?>(summary);
    }
    json['orderIndex'] = nativeToJson<int>(orderIndex);
    json['lessons'] = lessons.map((e) => e.toJson()).toList();
    return json;
  }

  GetCourseOutlineCoursesModules({
    required this.id,
    required this.title,
    this.summary,
    required this.orderIndex,
    required this.lessons,
  });
}

@immutable
class GetCourseOutlineCoursesModulesLessons {
  final String id;
  final String title;
  final String? summary;
  final int? durationMinutes;
  final String? videoUrl;
  GetCourseOutlineCoursesModulesLessons.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  summary = json['summary'] == null ? null : nativeFromJson<String>(json['summary']),
  durationMinutes = json['durationMinutes'] == null ? null : nativeFromJson<int>(json['durationMinutes']),
  videoUrl = json['videoUrl'] == null ? null : nativeFromJson<String>(json['videoUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseOutlineCoursesModulesLessons otherTyped = other as GetCourseOutlineCoursesModulesLessons;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    summary == otherTyped.summary && 
    durationMinutes == otherTyped.durationMinutes && 
    videoUrl == otherTyped.videoUrl;
    
  }
  @override
  int get hashCode => Object.hash(id.hashCode, title.hashCode, summary.hashCode, durationMinutes.hashCode, videoUrl.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    if (summary != null) {
      json['summary'] = nativeToJson<String?>(summary);
    }
    if (durationMinutes != null) {
      json['durationMinutes'] = nativeToJson<int?>(durationMinutes);
    }
    if (videoUrl != null) {
      json['videoUrl'] = nativeToJson<String?>(videoUrl);
    }
    return json;
  }

  GetCourseOutlineCoursesModulesLessons({
    required this.id,
    required this.title,
    this.summary,
    this.durationMinutes,
    this.videoUrl,
  });
}

@immutable
class GetCourseOutlineData {
  final List<GetCourseOutlineCourses> courses;
  GetCourseOutlineData.fromJson(dynamic json):
  
  courses = (json['courses'] as List<dynamic>)
        .map((e) => GetCourseOutlineCourses.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseOutlineData otherTyped = other as GetCourseOutlineData;
    return courses == otherTyped.courses;
    
  }
  @override
  int get hashCode => courses.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['courses'] = courses.map((e) => e.toJson()).toList();
    return json;
  }

  GetCourseOutlineData({
    required this.courses,
  });
}

@immutable
class GetCourseOutlineVariables {
  final String slug;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetCourseOutlineVariables.fromJson(Map<String, dynamic> json):
  
  slug = nativeFromJson<String>(json['slug']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseOutlineVariables otherTyped = other as GetCourseOutlineVariables;
    return slug == otherTyped.slug;
    
  }
  @override
  int get hashCode => slug.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['slug'] = nativeToJson<String>(slug);
    return json;
  }

  GetCourseOutlineVariables({
    required this.slug,
  });
}

