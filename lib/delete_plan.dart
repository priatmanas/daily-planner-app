import 'package:flutter/material.dart';
import 'database_connection.dart';
import 'daily_plan.dart';

class DeletePlan extends StatelessWidget {
  final DailyPlan plan;
  const DeletePlan({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delete Plan")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure want to delete this plan?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromRGBO(244, 243, 243, 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextFormField(
                initialValue: plan.title,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: "Title",
                  prefixIcon: Icon(Icons.title),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromRGBO(244, 243, 243, 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextFormField(
                initialValue: plan.weekday,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: "Date",
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
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
                      initialValue: plan.startTime,
                      decoration: const InputDecoration(
                        labelText: "Time Start",
                        icon: Icon(Icons.access_time),
                        border: InputBorder.none,
                      ),
                      readOnly: true,
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
                      initialValue: plan.finishTime,
                      decoration: const InputDecoration(
                        labelText: "Time End",
                        icon: Icon(Icons.access_time_filled),
                        border: InputBorder.none,
                      ),
                      readOnly: true,
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
                initialValue: plan.desc,
                readOnly: true,
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.delete),
                label: const Text("Delete Permanent"),
                onPressed: () async {
                  if (plan.id != null) {
                    await DatabaseConnection.instance.removePlan(plan.id!);
                  }
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.black87),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
