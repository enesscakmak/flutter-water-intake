import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_intake/components/water_intake_summary.dart';
import 'package:water_intake/components/water_tile.dart';
import 'package:water_intake/data/water_data.dart';
import 'package:water_intake/model/water_model.dart';
import 'package:water_intake/pages/about_screen.dart';
import 'package:water_intake/pages/settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final amountController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    await Provider.of<WaterData>(context, listen: false)
        .getWater()
        .then((waters) => {
              if (waters.isNotEmpty)
                {
                  setState(() {
                    _isLoading = false;
                  })
                }
              else
                {
                  setState(() {
                    _isLoading = true;
                  })
                }
            });
  }

  void saveWater() async {
    Provider.of<WaterData>(context, listen: false).addWater(WaterModel(
        amount: double.parse(amountController.text.toString()),
        dateTime: DateTime.now(),
        unit: 'ml'));

    if (!context.mounted) {
      return; // if widget is not mounted don't do anything
    }

    clearWater();
  }

  void addWater() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Center(
                  child: Text(
                'Add Water',
              )),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Add today's water intake"),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Amount'),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      // save to db
                      saveWater();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(top: 17.0),
              child: IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu)),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.map)),
            )
          ],
          centerTitle: true,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You drank ",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  Text(
                    value.calculateWeeklyWaterIntake(value),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    " ml this week",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: [
              WaterSummary(startOfWeek: value.getStartOfWeek()),
              const SizedBox(height: 20), // Add a SizedBox for spacing
              !_isLoading
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: value.waterDataList.length,
                      itemBuilder: (context, index) {
                        final waterModel = value.waterDataList[index];
                        return WaterTile(waterModel: waterModel);
                      })
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ],
          ),
        ),
        drawer: Drawer(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 80,
                    child: DrawerHeader(
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 17, 97, 201)),
                        child: Text(
                          "Daily Water Tracker",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                        )),
                  ),
                  // User Details Section
                  Container(
                    padding: const EdgeInsets.only(right: 20, left: 10),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              'https://via.placeholder.com/150'), // Placeholder image URL
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User Name',
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            Text(
                              'user@example.com',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 20), // Add another SizedBox for spacing
                  // Days and Water Intake Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var entry
                            in value.calculateDailyWaterSummary().entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${_getDayOfWeek(entry.key)}: ",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19),
                                ),
                                Text("${entry.value} ml",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 17)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text(
                        'Settings',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()));
                      },
                    ),
                    ListTile(
                      title: const Text(
                        'About',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: addWater,
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }

  void clearWater() {
    amountController.clear();
  }

  String _getDayOfWeek(String date) {
    final parsedDate = DateTime.parse(date);
    switch (parsedDate.weekday) {
      case DateTime.sunday:
        return 'Sunday';
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      default:
        return '';
    }
  }
}
