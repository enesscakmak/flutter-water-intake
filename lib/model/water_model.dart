class WaterModel {
  final String? id;
  final double amount;
  final DateTime dateTime;

  WaterModel(
      {this.id,
      required this.amount,
      required this.dateTime,
      required String unit});

  factory WaterModel.fromjson(Map<String, dynamic> json, String id) {
    return WaterModel(
        id: id,
        amount: json['amount'],
        dateTime: DateTime.parse(json['DateTime']),
        unit: json['unit']);
  }

  // convert watermodel to json for firebase
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'dateTime': DateTime.now(),
    };
  }
}
