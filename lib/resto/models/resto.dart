// To parse this JSON data, do
//
//     final resto = restoFromJson(jsonString);

import 'dart:convert';

List<Resto> restoFromJson(String str) => List<Resto>.from(json.decode(str).map((x) => Resto.fromJson(x)));

String restoToJson(List<Resto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Resto {
    int pk;
    Model model;
    Fields fields;

    Resto({
        required this.pk,
        required this.model,
        required this.fields,
    });

    factory Resto.fromJson(Map<String, dynamic> json) => Resto(
        pk: json["pk"],
        model: modelValues.map[json["model"]]!,
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "pk": pk,
        "model": modelValues.reverse[model],
        "fields": fields.toJson(),
    };
}

class Fields {
    String nama;
    int makanan;
    String lokasi;

    Fields({
        required this.nama,
        required this.makanan,
        required this.lokasi,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        nama: json["nama"],
        makanan: json["makanan"],
        lokasi: json["lokasi"],
    );

    Map<String, dynamic> toJson() => {
        "nama": nama,
        "makanan": makanan,
        "lokasi": lokasi,
    };
}

enum Model {
    RESTO_RESTO
}

final modelValues = EnumValues({
    "resto.resto": Model.RESTO_RESTO
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
