import 'dart:io';

import 'package:flutter/material.dart';

class Waste {
  String pengepul;
  DateTime date;
  String? jalur;
  LocationObj? location;
  AnorganikObj? anorganik;
  OrganikObj? organik;
  B3Obj? b3;
  ResiduObj? residu;
  TpsObj? tps_location;
  bool recorded;

  Waste(this.pengepul, this.date, this.jalur, this.location, this.anorganik, this.organik, this.b3, this.residu, this.tps_location,
      this.recorded);

  factory Waste.fromJson(Map<String, dynamic> json) {
    AnorganikObj? anorganik = json['anorganik'] != null
        ? AnorganikObj.fromJson(json['anorganik'])
        : null;
    LocationObj? location = json['location'] != null
        ? LocationObj.fromJson(json['location'])
        : null;
    OrganikObj? organik =
        json['organik'] != null ? OrganikObj.fromJson(json['organik']) : null;
    B3Obj? b3 = json['b3'] != null ? B3Obj.fromJson(json['b3']) : null;
    ResiduObj? residu =
        json['residu'] != null ? ResiduObj.fromJson(json['residu']) : null;
    TpsObj? tps_location = json['tps_location'] != null
        ? TpsObj.fromJson(json['tps_location'])
        : null;

    return Waste(
        json['produsen_sampah'] as String,
        json['date'] as DateTime,
        json['jalur'] as String,
        location,
        anorganik,
        organik,
        b3,
        residu,
        tps_location,
        json['picked_up'] as bool);
  }
}

class LocationObj {
  String? lat;
  String? long;
  DateTime? time;
  int? distance_first_loc;
  int? distance_prev_loc;
  String? address;

  LocationObj(this.lat, this.long, this.time, this.distance_first_loc,
      this.distance_prev_loc, this.address);

  factory LocationObj.fromJson(Map<String, dynamic> json) {
    return LocationObj(
      json['lat'] as String?,
      json['long'] as String?,
      json['time'] as DateTime?,
      json['distance_first_loc'] as int?,
      json['distance_prev_loc'] as int?,
      json['address'] as String?,
    );
  }
}

class TpsObj {
  String? lat;
  String? long;
  String? time;
  String? address;

  TpsObj(this.lat, this.long, this.time, this.address);

  factory TpsObj.fromJson(Map<String, dynamic> json) {
    return TpsObj(
      json['lat'] as String?,
      json['long'] as String?,
      json['time'] as String?,
      json['address'] as String?,
    );
  }
}

class AnorganikObj {
  File? image;
  double? weight;

  AnorganikObj(this.image, this.weight);

  factory AnorganikObj.fromJson(Map<String, dynamic> json) {
    return AnorganikObj(
      json['image'] as File?,
      json['weight'] as double?,
    );
  }
}

class OrganikObj {
  File? image;
  double? weight;

  OrganikObj(this.image, this.weight);

  factory OrganikObj.fromJson(Map<String, dynamic> json) {
    return OrganikObj(
      json['image'] as File?,
      json['weight'] as double?,
    );
  }
}

class B3Obj {
  File? image;
  double? weight;

  B3Obj(this.image, this.weight);

  factory B3Obj.fromJson(Map<String, dynamic> json) {
    return B3Obj(
      json['image'] as File?,
      json['weight'] as double?,
    );
  }
}

class ResiduObj {
  File? image;
  double? weight;

  ResiduObj(this.image, this.weight);

  factory ResiduObj.fromJson(Map<String, dynamic> json) {
    return ResiduObj(
      json['image'] as File?,
      json['weight'] as double?,
    );
  }
}
