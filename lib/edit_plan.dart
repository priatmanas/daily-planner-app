import 'package:flutter/material.dart';
import 'database_connection.dart';
import 'daily_plan.dart';

class EditPlan extends StatefulWidget {
  final DailyPlan plan;
  const EditPlan({Key? key, required this.plan}) : super(key: key);

  @override
  State<EditPlan> createState() => _EditPlanState();
}

class _EditPlanState extends State<EditPlan> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController startTimeController;
  late TextEditingController finishTimeController;
  String selectedWeekday = 'Monday';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.plan.title);
    descController = TextEditingController(text: widget.plan.desc);
    startTimeController = TextEditingController(text: widget.plan.startTime);
    finishTimeController = TextEditingController(text: widget.plan.finishTime);
    selectedWeekday = widget.plan.weekday.isNotEmpty
        ? widget.plan.weekday
        : 'Monday';
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
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
                  items:
                      [
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                            'Sunday',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) =>
                      setState(() => selectedWeekday = v ?? 'Monday'),
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: InputBorder.none,
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
                  minLines: 4,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Description",
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await DatabaseConnection.instance.updatePlan(
                        DailyPlan(
                          id: widget.plan.id, // ID Tetap sama
                          title: titleController.text,
                          desc: descController.text,
                          startTime: startTimeController.text,
                          finishTime: finishTimeController.text,
                          weekday: selectedWeekday,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Update"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
