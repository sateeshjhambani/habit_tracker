import 'package:flutter/material.dart';
import 'package:habit_tracker/components/month_summary.dart';
import 'package:habit_tracker/components/my_fab.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:hive/hive.dart';

import '../components/habit_tile.dart';
import '../components/my_alert_box.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box('Habit_Database');

  @override
  void initState() {
    if (_myBox.get('CURRENT_HABIT_LIST') == null) {
      db.createDefaultData();
    } else {
      db.loadData();
    }

    db.updateDatabase();
  }

  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value!;
    });

    db.updateDatabase();
  }

  final _newHabitNameController = TextEditingController();
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          onSave: saveNewHabit,
          onCancel: cancelDialogBox,
          hintText: 'Enter habbit name',
        );
      },
    );
  }

  void saveNewHabit() {
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });
    _newHabitNameController.clear();
    Navigator.of(context).pop();

    db.updateDatabase();
  }

  void cancelDialogBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.of(context).pop();

    db.updateDatabase();
  }

  void openHabitSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          onSave: () => saveExistingHabit(index),
          onCancel: cancelDialogBox,
          hintText: db.todaysHabitList[index][0],
        );
      },
    );
  }

  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });

    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: MyFloatingActionButton(
        onPressed: createNewHabit,
      ),
      body: ListView(
        children: [
          MonthlySummary(
            datasets: db.heatMapDataSet,
            startDate: _myBox.get(
              'START_DATE',
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: db.todaysHabitList.length,
            itemBuilder: (BuildContext context, int index) => HabitTile(
              habitName: db.todaysHabitList[index][0],
              habitCompleted: db.todaysHabitList[index][1],
              onChanged: (value) => checkBoxTapped(value, index),
              settingsTaped: (context) => openHabitSettings(index),
              deleteTaped: (context) => deleteHabit(index),
            ),
          )
        ],
      ),
    );
  }
}
