import 'package:flutter/material.dart';
import 'database_connection.dart';
import 'daily_plan.dart';

class InputPlan extends StatefulWidget {
  final String? initialWeekday;
  const InputPlan({Key? key, this.initialWeekday}) : super(key: key);

  @override
  State<InputPlan> createState() => _InputPlanState();
}

class _InputPlanState extends State<InputPlan> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController finishTimeController = TextEditingController();
  String selectedWeekday = 'Monday';

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final String formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        controller.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (widget.initialWeekday != null && widget.initialWeekday!.isNotEmpty) {
      selectedWeekday = widget.initialWeekday!;
    } else {
      final today = DateTime.now().weekday;
      selectedWeekday = weekdays[(today - 1) % 7];
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Add a Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 243, 243, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Title",
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 243, 243, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedWeekday,
                  items: weekdays
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => selectedWeekday = v ?? 'Monday'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(244, 243, 243, 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: startTimeController,
                        decoration: const InputDecoration(
                          labelText: "Time Start",
                          icon: Icon(Icons.access_time),
                          border: InputBorder.none,
                        ),
                        readOnly: true,
                        onTap: () => _selectTime(startTimeController),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(244, 243, 243, 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: finishTimeController,
                        decoration: const InputDecoration(
                          labelText: "Time End",
                          icon: Icon(Icons.access_time_filled),
                          border: InputBorder.none,
                        ),
                        readOnly: true,
                        onTap: () => _selectTime(finishTimeController),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 243, 243, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: descController,
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Description",
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      startTimeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Title and Description must be include"),
                      ),
                    );
                    return;
                  }

                  await DatabaseConnection.instance.addPlan(
                    DailyPlan(
                      title: titleController.text,
                      desc: descController.text,
                      startTime: startTimeController.text,
                      finishTime: finishTimeController.text,
                      weekday: selectedWeekday,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save Plan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
