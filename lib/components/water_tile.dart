import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_intake/data/water_data.dart';
import 'package:water_intake/model/water_model.dart';

class WaterTile extends StatelessWidget {
  const WaterTile({
    super.key,
    required this.waterModel,
  });

  final WaterModel waterModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Row(
          children: [
            const Icon(
              Icons.water_drop,
              size: 20,
              color: Colors.blue,
            ),
            Text(
              '${waterModel.amount.toStringAsFixed(0)} ml',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        subtitle: Text(
            'Date: ${waterModel.dateTime.day}/${waterModel.dateTime.month}/${waterModel.dateTime.year}\nTime: ${waterModel.dateTime.hour}:${waterModel.dateTime.minute} '),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            Provider.of<WaterData>(context, listen: false).delete(waterModel);
          },
        ),
      ),
    );
  }
}
