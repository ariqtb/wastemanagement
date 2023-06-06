import 'package:flutter/material.dart';
import 'dart:convert';

class WasteProdusen {
  String produsen_sampah;
  DateTime date;
  LocationObj location;
  AnorganikObj? anorganik;
  OrganikObj? organik;
  B3Obj? b3;
  ResiduObj? residu;
  bool picked_up;

  WasteProdusen(this.produsen_sampah, this.date, this.location, this.anorganik,
      this.organik, this.b3, this.residu, this.picked_up);

  factory WasteProdusen.fromJson(Map<String, dynamic> json) {
    AnorganikObj? anorganik = json['anorganik'] != null
        ? AnorganikObj.fromJson(json['anorganik'])
        : null;
    OrganikObj? organik =
        json['organik'] != null ? OrganikObj.fromJson(json['organik']) : null;
    B3Obj? b3 = json['b3'] != null ? B3Obj.fromJson(json['b3']) : null;
    ResiduObj? residu =
        json['residu'] != null ? ResiduObj.fromJson(json['residu']) : null;

    return WasteProdusen(
        json['produsen_sampah'] as String,
        json['date'] as DateTime,
        json['location'] as LocationObj,
        anorganik,
        organik,
        b3,
        residu,
        json['picked_up'] as bool);
  }
}

class LocationObj {
  String lat;
  String long;
  String address;

  LocationObj(this.lat, this.long, this.address);

  factory LocationObj.fromJson(Map<String, dynamic> json) {
    return LocationObj(
      json['lat'] as String,
      json['long'] as String,
      json['address'] as String,
    );
  }
}

class AnorganikObj {
  AssetImage? image;
  double? weight;

  AnorganikObj(this.image, this.weight);

  factory AnorganikObj.fromJson(Map<String, dynamic> json) {
    return AnorganikObj(
      json['image'] as AssetImage?,
      json['weight'] as double?,
    );
  }
}

class OrganikObj {
  AssetImage? image;
  double? weight;

  OrganikObj(this.image, this.weight);

  factory OrganikObj.fromJson(Map<String, dynamic> json) {
    return OrganikObj(
      json['image'] as AssetImage?,
      json['weight'] as double?,
    );
  }
}

class B3Obj {
  AssetImage? image;
  double? weight;

  B3Obj(this.image, this.weight);

  factory B3Obj.fromJson(Map<String, dynamic> json) {
    return B3Obj(
      json['image'] as AssetImage?,
      json['weight'] as double?,
    );
  }
}

class ResiduObj {
  AssetImage? image;
  double? weight;

  ResiduObj(this.image, this.weight);

  factory ResiduObj.fromJson(Map<String, dynamic> json) {
    return ResiduObj(
      json['image'] as AssetImage?,
      json['weight'] as double?,
    );
  }
}
