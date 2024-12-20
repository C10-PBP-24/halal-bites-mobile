// To parse this JSON data, do
//
//     final thread = threadFromJson(jsonString);

import 'dart:convert';

List<Thread> threadFromJson(String str) => List<Thread>.from(json.decode(str).map((x) => Thread.fromJson(x)));

String threadToJson(List<Thread> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Thread {
    String model;
    int pk;
    Fields fields;

    Thread({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Thread.fromJson(Map<String, dynamic> json) => Thread(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String title;
    DateTime createdAt;
    String user;
    List<int> foods;

    Fields({
        required this.title,
        required this.createdAt,
        required this.user,
        required this.foods,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        createdAt: DateTime.parse(json["created_at"]),
        user: json["user"],
        foods: List<int>.from(json["foods"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "created_at": createdAt.toIso8601String(),
        "user": user,
        "foods": List<dynamic>.from(foods.map((x) => x)),
    };
}
