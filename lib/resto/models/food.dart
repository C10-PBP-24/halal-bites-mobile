// To parse this JSON data, do
//
//     final food = foodFromJson(jsonString);

import 'dart:convert';

List<Food> foodFromJson(String str) => List<Food>.from(json.decode(str).map((x) => Food.fromJson(x)));

String foodToJson(List<Food> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Food {
    int id;
    Model model;
    Fields fields;

    Food({
        required this.id,
        required this.model,
        required this.fields,
    });

    factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json["id"],
        model: modelValues.map[json["model"]]!,
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "model": modelValues.reverse[model],
        "fields": fields.toJson(),
    };
}

class Fields {
    String name;
    int price;
    Promo promo;
    String? image;

    Fields({
        required this.name,
        required this.price,
        required this.promo,
        this.image,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        price: json["price"],
        promo: promoValues.map[json["promo"]]!,
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "promo": promoValues.reverse[promo],
        "image": image,
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
