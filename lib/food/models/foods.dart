// To parse this JSON data, do
//
//     final food = foodFromJson(jsonString);

import 'dart:convert';

List<Food> foodFromJson(String str) => List<Food>.from(json.decode(str).map((x) => Food.fromJson(x)));

String foodToJson(List<Food> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Food {
    Model model;
    int pk;
    Fields fields;

    Food({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Food.fromJson(Map<String, dynamic> json) => Food(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String name;
    String price;
    String image;
    Promo promo;

    Fields({
        required this.name,
        required this.price,
        required this.image,
        required this.promo,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        price: json["price"],
        image: json["image"],
        promo: promoValues.map[json["promo"]]!,
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "image": image,
        "promo": promoValues.reverse[promo],
    };
}

enum Promo {
    BUY_1_GET_1,
    CASHBACK_20,
    DISCOUNT_10,
    FREE_SHIPPING,
    NO_PROMO
}

final promoValues = EnumValues({
    "Buy 1 Get 1": Promo.BUY_1_GET_1,
    "Cashback 20%": Promo.CASHBACK_20,
    "Discount 10%": Promo.DISCOUNT_10,
    "Free Shipping": Promo.FREE_SHIPPING,
    "No Promo": Promo.NO_PROMO
});

enum Model {
    FOOD_FOOD
}

final modelValues = EnumValues({
    "food.food": Model.FOOD_FOOD
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
