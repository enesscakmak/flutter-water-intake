import 'package:flutter/material.dart';
import 'package:water_intake/model/water_model.dart';
import 'package:http/http.dart' as http;
import 'package:water_intake/utils/date_helper.dart';
import 'dart:convert';

class WaterData extends ChangeNotifier {
  List<WaterModel> waterDataList = [];

  Map<String, double> dailyWaterSummary = {};

  void addWater(WaterModel water) async {
    final url = Uri.https(
        'water-intaker-3633a-default-rtdb.europe-west1.firebasedatabase.app',
        'water.json');

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': double.parse(water.amount.toString()),
          'unit': 'ml',
          'dateTime': DateTime.now().toString()
        }));

    if (response.statusCode == 200) {
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      waterDataList.add(WaterModel(
          id: extractedData['name'],
          amount: water.amount,
          dateTime: water.dateTime,
          unit: 'ml'));

      // Recalculate daily water summary
      _recalculateDailyWaterSummary();
    } else {
      // ignore: avoid_print
      print('Error: ${response.statusCode}');
    }

    notifyListeners();
  }

  Future<List<WaterModel>> getWater() async {
    final url = Uri.https(
        'water-intaker-3633a-default-rtdb.europe-west1.firebasedatabase.app',
        'water.json');

    final response = await http.get(url);

    if (response.statusCode == 200 && response.body != 'null') {
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      waterDataList.clear(); // Clear existing data to avoid duplication
      for (var element in extractedData.entries) {
        waterDataList.add(WaterModel(
            id: element.key,
            amount: element.value['amount'],
            dateTime: DateTime.parse(element.value['dateTime']),
            unit: element.value['unit']));
      }

      // Recalculate daily water summary
      _recalculateDailyWaterSummary();
    }

    notifyListeners();
    return waterDataList;
  }

  void delete(WaterModel waterModel) {
    final url = Uri.https(
        'water-intaker-3633a-default-rtdb.europe-west1.firebasedatabase.app',
        'water/${waterModel.id}.json');
    http.delete(url);

    waterDataList.removeWhere((element) => element.id == waterModel.id!);

    // Recalculate daily water summary
    _recalculateDailyWaterSummary();

    notifyListeners();
  }

  void _recalculateDailyWaterSummary() {
    dailyWaterSummary.clear(); // Clear existing summary

    for (var water in waterDataList) {
      String date = convertDateTimeToString(water.dateTime);
      double amount = double.parse(water.amount.toString());

      if (dailyWaterSummary.containsKey(date)) {
        dailyWaterSummary[date] = dailyWaterSummary[date]! + amount;
      } else {
        dailyWaterSummary[date] = amount;
      }
    }
  }

  Map<String, double> calculateDailyWaterSummary() {
    return dailyWaterSummary;
  }

  String getWeekday(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tues';
      case 3:
        return 'Wed';
      case 4:
        return 'Thur';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  DateTime getStartOfWeek() {
    DateTime? startOfWeek;

    DateTime dateTime = DateTime.now();

    for (var i = 0; i < 7; i++) {
      if (getWeekday(dateTime.subtract(Duration(days: i))) == 'Sun') {
        startOfWeek = dateTime.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }

  String calculateWeeklyWaterIntake(WaterData value) {
    double weeklyWaterIntake = 0;
    for (var water in value.waterDataList) {
      weeklyWaterIntake += double.parse(water.amount.toString());
    }
    return weeklyWaterIntake.toStringAsFixed(0);
  }
}
