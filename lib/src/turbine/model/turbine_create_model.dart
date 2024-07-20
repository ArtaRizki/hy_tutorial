// To parse this JSON data, do
//
//     final turbineCreateModel = turbineCreateModelFromJson(jsonString);

import 'dart:convert';

TurbineCreateModel turbineCreateModelFromJson(String str) =>
    TurbineCreateModel.fromJson(json.decode(str));

String? turbineCreateModelToJson(TurbineCreateModel data) =>
    json.encode(data.toJson());

class TurbineCreateModel {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  TurbineCreateModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory TurbineCreateModel.fromJson(Map<String, dynamic> json) =>
      TurbineCreateModel(
        success: json["Success"],
        statusCode: json["StatusCode"],
        message: json["Message"],
        data: Data.fromJson(json["Data"]),
      );

  Map<String, dynamic> toJson() => {
        "Success": success,
        "StatusCode": statusCode,
        "Message": message,
        "Data": data?.toJson(),
      };
}

class Data {
  String? id;
  String? towerName;
  Shaft? shaft;
  Chart? chart;
  DetailData? detailData;
  double? acCrockedness;
  double? bdCrockedness;
  double? totalCrockedness;
  String? createdAt;
  String? createdBy;
  bool? status;
  int? totalBolts;
  int? currentTorque;
  int? maxTorque;
  int? torqueGap;
  TorqueCalculation? torqueCalculation;

  Data({
    this.id,
    this.towerName,
    this.shaft,
    this.chart,
    this.detailData,
    this.acCrockedness,
    this.bdCrockedness,
    this.totalCrockedness,
    this.createdAt,
    this.createdBy,
    this.status,
    this.totalBolts,
    this.currentTorque,
    this.maxTorque,
    this.torqueGap,
    this.torqueCalculation,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["Id"],
        towerName: json["TowerName"],
        shaft: Shaft.fromJson(json["Shaft"]),
        chart: Chart.fromJson(json["Chart"]),
        detailData: DetailData.fromJson(json["DetailData"]),
        acCrockedness: json["ACCrockedness"]?.toDouble(),
        bdCrockedness: json["BDCrockedness"]?.toDouble(),
        totalCrockedness: json["TotalCrockedness"]?.toDouble(),
        createdAt: json["CreatedAt"],
        createdBy: json["CreatedBy"],
        status: json["Status"],
        totalBolts: json["TotalBolts"],
        currentTorque: json["CurrentTorque"],
        maxTorque: json["MaxTorque"],
        torqueGap: json["TorqueGap"],
        torqueCalculation:
            TorqueCalculation.fromJson(json["TorqueCalculation"]),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "TowerName": towerName,
        "Shaft": shaft?.toJson(),
        "Chart": chart?.toJson(),
        "DetailData": detailData?.toJson(),
        "ACCrockedness": acCrockedness,
        "BDCrockedness": bdCrockedness,
        "TotalCrockedness": totalCrockedness,
        "CreatedAt": createdAt,
        "CreatedBy": createdBy,
        "Status": status,
        "TotalBolts": totalBolts,
        "CurrentTorque": currentTorque,
        "MaxTorque": maxTorque,
        "TorqueGap": torqueGap,
        "TorqueCalculation": torqueCalculation?.toJson(),
      };
}

class Chart {
  Ac? ac;
  Ac? bd;
  String? upper;

  Chart({
    this.ac,
    this.bd,
    this.upper,
  });

  factory Chart.fromJson(Map<String, dynamic> json) => Chart(
        ac: Ac.fromJson(json["AC"]),
        bd: Ac.fromJson(json["BD"]),
        upper: json["Upper"],
      );

  Map<String, dynamic> toJson() => {
        "AC": ac?.toJson(),
        "BD": bd?.toJson(),
        "Upper": upper,
      };
}

class Ac {
  String? clutch;
  String? turbine;
  String? upper;

  Ac({
    this.clutch,
    this.turbine,
    this.upper,
  });

  factory Ac.fromJson(Map<String, dynamic> json) => Ac(
        clutch: json["Clutch"],
        turbine: json["Turbine"],
        upper: json["Upper"],
      );

  Map<String, dynamic> toJson() => {
        "Clutch": clutch,
        "Turbine": turbine,
        "Upper": upper,
      };
}

class DetailData {
  Clutch? clutch;
  Clutch? turbine;
  Clutch? upper;

  DetailData({
    this.clutch,
    this.turbine,
    this.upper,
  });

  factory DetailData.fromJson(Map<String, dynamic> json) => DetailData(
        clutch: Clutch.fromJson(json["Clutch"]),
        turbine: Clutch.fromJson(json["Turbine"]),
        upper: Clutch.fromJson(json["Upper"]),
      );

  Map<String, dynamic> toJson() => {
        "Clutch": clutch?.toJson(),
        "Turbine": turbine?.toJson(),
        "Upper": upper?.toJson(),
      };
}

class Clutch {
  Map<String, double>? a;
  Map<String, double>? b;
  Map<String, double>? c;
  Map<String, double>? d;

  Clutch({
    this.a,
    this.b,
    this.c,
    this.d,
  });

  factory Clutch.fromJson(Map<String, dynamic> json) => Clutch(
        a: Map.from(json["A"])
            .map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
        b: Map.from(json["B"])
            .map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
        c: Map.from(json["C"])
            .map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
        d: Map.from(json["D"])
            .map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "A": Map.from(a ?? {}).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "B": Map.from(b ?? {}).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "C": Map.from(c ?? {}).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "D": Map.from(d ?? {}).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

class Shaft {
  int? genBearingToCoupling;
  int? couplingToTurbine;
  int? total;
  double? ratio;

  Shaft({
    this.genBearingToCoupling,
    this.couplingToTurbine,
    this.total,
    this.ratio,
  });

  factory Shaft.fromJson(Map<String, dynamic> json) => Shaft(
        genBearingToCoupling: json["GenBearingToCoupling"],
        couplingToTurbine: json["CouplingToTurbine"],
        total: json["Total"],
        ratio: json["Ratio"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "GenBearingToCoupling": genBearingToCoupling,
        "CouplingToTurbine": couplingToTurbine,
        "Total": total,
        "Ratio": ratio,
      };
}

class TorqueCalculation {
  Map<String, String>? details;
  Map<String, int>? torqueSuggestions;

  TorqueCalculation({
    this.details,
    this.torqueSuggestions,
  });

  factory TorqueCalculation.fromJson(Map<String, dynamic> json) =>
      TorqueCalculation(
        details: Map.from(json["Details"])
            .map((k, v) => MapEntry<String, String>(k, v)),
        torqueSuggestions: Map.from(json["TorqueSuggestions"])
            .map((k, v) => MapEntry<String, int>(k, v?.toInt())),
      );

  Map<String, dynamic> toJson() => {
        "Details": Map.from(details ?? {})
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "TorqueSuggestions": Map.from(torqueSuggestions ?? {})
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
