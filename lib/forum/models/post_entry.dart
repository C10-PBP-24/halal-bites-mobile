// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

List<Post> postFromJson(String str) => List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

String postToJson(List<Post> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Post {
    String model;
    int pk;
    Fields fields;

    Post({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Post.fromJson(Map<String, dynamic> json) => Post(
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
    String content;
    DateTime createdAt;
    String user;
    int thread;

    Fields({
        required this.content,
        required this.createdAt,
        required this.user,
        required this.thread,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        user: json["user"],
        thread: json["thread"],
    );

    Map<String, dynamic> toJson() => {
        "content": content,
        "created_at": createdAt.toIso8601String(),
        "user": user,
        "thread": thread,
    };
}
