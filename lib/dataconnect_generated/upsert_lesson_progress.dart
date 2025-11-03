part of 'courses.dart';

class UpsertLessonProgressVariablesBuilder {
  String userId;
  String lessonId;
  String status;
  Optional<double> _score = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  UpsertLessonProgressVariablesBuilder score(double? t) {
   _score.value = t;
   return this;
  }

  UpsertLessonProgressVariablesBuilder(this._dataConnect, {required  this.userId,required  this.lessonId,required  this.status,});
  Deserializer<UpsertLessonProgressData> dataDeserializer = (dynamic json)  => UpsertLessonProgressData.fromJson(jsonDecode(json));
  Serializer<UpsertLessonProgressVariables> varsSerializer = (UpsertLessonProgressVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpsertLessonProgressData, UpsertLessonProgressVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpsertLessonProgressData, UpsertLessonProgressVariables> ref() {
    UpsertLessonProgressVariables vars= UpsertLessonProgressVariables(userId: userId,lessonId: lessonId,status: status,score: _score,);
    return _dataConnect.mutation("UpsertLessonProgress", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpsertLessonProgressLessonProgressUpsert {
  final String id;
  UpsertLessonProgressLessonProgressUpsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertLessonProgressLessonProgressUpsert otherTyped = other as UpsertLessonProgressLessonProgressUpsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpsertLessonProgressLessonProgressUpsert({
    required this.id,
  });
}

@immutable
class UpsertLessonProgressData {
  final UpsertLessonProgressLessonProgressUpsert lessonProgress_upsert;
  UpsertLessonProgressData.fromJson(dynamic json):
  
  lessonProgress_upsert = UpsertLessonProgressLessonProgressUpsert.fromJson(json['lessonProgress_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertLessonProgressData otherTyped = other as UpsertLessonProgressData;
    return lessonProgress_upsert == otherTyped.lessonProgress_upsert;
    
  }
  @override
  int get hashCode => lessonProgress_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['lessonProgress_upsert'] = lessonProgress_upsert.toJson();
    return json;
  }

  UpsertLessonProgressData({
    required this.lessonProgress_upsert,
  });
}

@immutable
class UpsertLessonProgressVariables {
  final String userId;
  final String lessonId;
  final String status;
  late final Optional<double>score;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpsertLessonProgressVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  lessonId = nativeFromJson<String>(json['lessonId']),
  status = nativeFromJson<String>(json['status']) {
  
  
  
  
  
    score = Optional.optional(nativeFromJson, nativeToJson);
    score.value = json['score'] == null ? null : nativeFromJson<double>(json['score']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertLessonProgressVariables otherTyped = other as UpsertLessonProgressVariables;
    return userId == otherTyped.userId && 
    lessonId == otherTyped.lessonId && 
    status == otherTyped.status && 
    score == otherTyped.score;
    
  }
  @override
  int get hashCode => Object.hash(userId.hashCode, lessonId.hashCode, status.hashCode, score.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['lessonId'] = nativeToJson<String>(lessonId);
    json['status'] = nativeToJson<String>(status);
    if(score.state == OptionalState.set) {
      json['score'] = score.toJson();
    }
    return json;
  }

  UpsertLessonProgressVariables({
    required this.userId,
    required this.lessonId,
    required this.status,
    required this.score,
  });
}

