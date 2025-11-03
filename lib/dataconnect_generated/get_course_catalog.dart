part of 'courses.dart';

class GetCourseCatalogVariablesBuilder {
  String language;
  Optional<int> _limit = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  GetCourseCatalogVariablesBuilder limit(int? t) {
   _limit.value = t;
   return this;
  }

  GetCourseCatalogVariablesBuilder(this._dataConnect, {required  this.language,});
  Deserializer<GetCourseCatalogData> dataDeserializer = (dynamic json)  => GetCourseCatalogData.fromJson(jsonDecode(json));
  Serializer<GetCourseCatalogVariables> varsSerializer = (GetCourseCatalogVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetCourseCatalogData, GetCourseCatalogVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetCourseCatalogData, GetCourseCatalogVariables> ref() {
    GetCourseCatalogVariables vars= GetCourseCatalogVariables(language: language,limit: _limit,);
    return _dataConnect.query("GetCourseCatalog", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetCourseCatalogCourses {
  final String id;
  final String slug;
  final String languageCode;
  final String title;
  final String? subtitle;
  final String? summary;
  final String? heroImageUrl;
  final int? estimatedMinutes;
  final String? difficulty;
  final Timestamp updatedAt;
  GetCourseCatalogCourses.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  slug = nativeFromJson<String>(json['slug']),
  languageCode = nativeFromJson<String>(json['languageCode']),
  title = nativeFromJson<String>(json['title']),
  subtitle = json['subtitle'] == null ? null : nativeFromJson<String>(json['subtitle']),
  summary = json['summary'] == null ? null : nativeFromJson<String>(json['summary']),
  heroImageUrl = json['heroImageUrl'] == null ? null : nativeFromJson<String>(json['heroImageUrl']),
  estimatedMinutes = json['estimatedMinutes'] == null ? null : nativeFromJson<int>(json['estimatedMinutes']),
  difficulty = json['difficulty'] == null ? null : nativeFromJson<String>(json['difficulty']),
  updatedAt = Timestamp.fromJson(json['updatedAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseCatalogCourses otherTyped = other as GetCourseCatalogCourses;
    return id == otherTyped.id && 
    slug == otherTyped.slug && 
    languageCode == otherTyped.languageCode && 
    title == otherTyped.title && 
    subtitle == otherTyped.subtitle && 
    summary == otherTyped.summary && 
    heroImageUrl == otherTyped.heroImageUrl && 
    estimatedMinutes == otherTyped.estimatedMinutes && 
    difficulty == otherTyped.difficulty && 
    updatedAt == otherTyped.updatedAt;
    
  }
  @override
  int get hashCode => Object.hash(id.hashCode, slug.hashCode, languageCode.hashCode, title.hashCode, subtitle.hashCode, summary.hashCode, heroImageUrl.hashCode, estimatedMinutes.hashCode, difficulty.hashCode, updatedAt.hashCode);
  

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
    if (heroImageUrl != null) {
      json['heroImageUrl'] = nativeToJson<String?>(heroImageUrl);
    }
    if (estimatedMinutes != null) {
      json['estimatedMinutes'] = nativeToJson<int?>(estimatedMinutes);
    }
    if (difficulty != null) {
      json['difficulty'] = nativeToJson<String?>(difficulty);
    }
    json['updatedAt'] = updatedAt.toJson();
    return json;
  }

  GetCourseCatalogCourses({
    required this.id,
    required this.slug,
    required this.languageCode,
    required this.title,
    this.subtitle,
    this.summary,
    this.heroImageUrl,
    this.estimatedMinutes,
    this.difficulty,
    required this.updatedAt,
  });
}

@immutable
class GetCourseCatalogData {
  final List<GetCourseCatalogCourses> courses;
  GetCourseCatalogData.fromJson(dynamic json):
  
  courses = (json['courses'] as List<dynamic>)
        .map((e) => GetCourseCatalogCourses.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseCatalogData otherTyped = other as GetCourseCatalogData;
    return courses == otherTyped.courses;
    
  }
  @override
  int get hashCode => courses.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['courses'] = courses.map((e) => e.toJson()).toList();
    return json;
  }

  GetCourseCatalogData({
    required this.courses,
  });
}

@immutable
class GetCourseCatalogVariables {
  final String language;
  late final Optional<int>limit;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetCourseCatalogVariables.fromJson(Map<String, dynamic> json):
  
  language = nativeFromJson<String>(json['language']) {
  
  
  
    limit = Optional.optional(nativeFromJson, nativeToJson);
    limit.value = json['limit'] == null ? null : nativeFromJson<int>(json['limit']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseCatalogVariables otherTyped = other as GetCourseCatalogVariables;
    return language == otherTyped.language && 
    limit == otherTyped.limit;
    
  }
  @override
  int get hashCode => Object.hash(language.hashCode, limit.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['language'] = nativeToJson<String>(language);
    if(limit.state == OptionalState.set) {
      json['limit'] = limit.toJson();
    }
    return json;
  }

  GetCourseCatalogVariables({
    required this.language,
    required this.limit,
  });
}

