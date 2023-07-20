import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/layout/todo_app/cubit/states.dart';
import '../../../modules/archived/archived_screen.dart';
import '../../../modules/done/done_screen.dart';
import '../../../modules/tasks/tasks_screen.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(InitialState());
  static AppCubit getObject(context) => BlocProvider.of(context);

  int curIndex = 0;
  List<String> titles = ['tasks', 'done', 'archived'];
  List<Widget> screens = [TaskScreen(), DoneScreen(), ArchivedScreen()];
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(label: 'Tasks', icon: Icon(Icons.menu)),
    BottomNavigationBarItem(
        label: 'Done', icon: Icon(Icons.watch_later_outlined)),
    BottomNavigationBarItem(
        label: 'Archived', icon: Icon(Icons.archive_outlined))
  ];
  IconData fabIcon = Icons.edit;
  bool isBottomSheetClosed = true;
  String databaseName = "todo.db";
  Database? database;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void changeBottomNavBarIndex(index) {
    curIndex = index;
    print(index);
    emit(ChangeNavBarState());
  }

  void changeBottomSheetState() {
    if (fabIcon == Icons.edit) {
      fabIcon = Icons.add;
    } else {
      fabIcon = Icons.edit;
    }
    isBottomSheetClosed = !isBottomSheetClosed;
    emit(ChangeBottomSheetState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);

        print('database opened ${newTasks.length}');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) {
      txn
          .rawInsert(
        'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")',
      )
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });

      return Future.value(null);
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });

      emit(AppGetDatabaseState());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    database!.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  }) async {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }
}
