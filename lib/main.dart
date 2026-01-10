import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_connection.dart';
import 'daily_plan.dart';
import 'input_plan.dart';
import 'edit_plan.dart';
import 'delete_plan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      title: 'Daily Planner',
      home: const HomePlan(),
    );
  }
}

class HomePlan extends StatefulWidget {
  const HomePlan({Key? key}) : super(key: key);

  @override
  State<HomePlan> createState() => _HomePlanState();
}

class _HomePlanState extends State<HomePlan> {
  Future<void> _refresh() async {
    setState(() {});
  }

  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  String selectedWeekday = '';
  String todayDate = "";

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().weekday;
    selectedWeekday = weekdays[(today - 1) % 7];

    todayDate = weekdays[(today - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 24,
                  ),
                  title: const Text('About'),
                  content: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Daily Planner.\nA simple daily planning app.'),
                        SizedBox(height: 12),
                        Text(
                          'This Flutter project was created for a college end semester.',
                        ),
                        SizedBox(height: 12),
                        Text(
                          '~ Love and Made by\n@TamaFawx / @Fawzan Priatmana',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, today is...",
                  style: TextStyle(color: Colors.black87, fontSize: 20),
                ),
                Text(
                  "$todayDate",
                  style: TextStyle(color: Colors.black, fontSize: 40),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: weekdays.map((d) {
                  final isSelected = d == selectedWeekday;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedWeekday = d;
                        });
                      },
                      selectedColor: Colors.black12,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DailyPlan>>(
              future: DatabaseConnection.instance.getPlansByWeekday(
                selectedWeekday,
              ),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<DailyPlan>> snapshot,
                  ) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text("There's no plan for $selectedWeekday."),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final plan = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.black54,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  "${plan.startTime} - ${plan.finishTime}",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                                Divider(),
                                if (plan.desc.isNotEmpty)
                                  Text(
                                    plan.desc,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                SizedBox(height: 10),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPlan(plan: plan),
                                ),
                              );
                              _refresh();
                            },
                            onLongPress: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeletePlan(plan: plan),
                                ),
                              );
                              _refresh();
                            },
                          ),
                        );
                      },
                    );
                  },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black87,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputPlan(initialWeekday: selectedWeekday),
            ),
          );
          _refresh();
        },
      ),
    );
  }
}
