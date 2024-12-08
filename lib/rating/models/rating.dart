// To parse this JSON data, do
//
//     final rating = ratingFromJson(jsonString);

import 'dart:convert';

Rating ratingFromJson(String str) => Rating.fromJson(json.decode(str));

String ratingToJson(Rating data) => json.encode(data.toJson());

class Rating {
    String id;
    Food food;
    User user;
    int rating;
    String description;
    DateTime createdAt;

    Rating({
        required this.id,
        required this.food,
        required this.user,
        required this.rating,
        required this.description,
        required this.createdAt,
    });

    factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        id: json["id"],
        food: Food.fromJson(json["food"]),
        user: User.fromJson(json["user"]),
        rating: json["rating"],
        description: json["description"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "food": food.toJson(),
        "user": user.toJson(),
        "rating": rating,
        "description": description,
        "created_at": createdAt.toIso8601String(),
    };
}

class Food {
    String id;
    String name;

    Food({
        required this.id,
        required this.name,
    });

    factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class User {
    String id;
    String username;

    User({
        required this.id,
        required this.username,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
    };
}
