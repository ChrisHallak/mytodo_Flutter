/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/shared/components/components.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class HomeLayout extends StatelessWidget {
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (BuildContext context) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(listener: (context, state) {
        print('--------------------------------');
        print(state);
      }, builder: (context, state) {
        AppCubit cubit = AppCubit.getObject(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(title: Text(cubit.titles[cubit.curIndex])),
          body: cubit.screens[cubit.curIndex],
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (cubit.isBottomSheetClosed) {
                scaffoldKey.currentState!
                    .showBottomSheet((context) => Container(
                          padding: EdgeInsets.all(10.0),
                          color: Colors.grey[300],
                          child: Form(
                            key: formKey,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultFormField(
                                      controller: titleController,
                                      type: TextInputType.text,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'task title can not be null';
                                        }
                                      },
                                      label: "Task Title",
                                      prefix: Icons.title),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  defaultFormField(
                                      controller: timeController,
                                      type: TextInputType.text,
                                      validate: (value) {
                                        if (value!.isEmpty)
                                          return 'Task time can not be null';
                                      },
                                      label: 'Task Time',
                                      prefix: Icons.watch_outlined),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  defaultFormField(
                                      controller: dateController,
                                      type: TextInputType.text,
                                      validate: (value) {
                                        if (value!.isEmpty)
                                          return 'Task date can not be null';
                                      },
                                      label: 'Task Date',
                                      prefix: Icons.calendar_today_outlined),
                                ]),
                          ),
                        ))
                    .closed
                    .then((value) {
                  cubit.changeBottomSheetState();
                });
                cubit.changeBottomSheetState();
              } else {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  cubit.changeBottomSheetState();
                }
              }
            },
            child: Icon(cubit.fabIcon),
          ),
          bottomNavigationBar: BottomNavigationBar(
            curIndex: cubit.curIndex,
            items: cubit.items,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              cubit.changeBottomNavBarIndex(index);
            },
          ),
        );
      }),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/shared/components/components.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

// 1. create database
// 2. create tables
// 3. open database
// 4. insert to database
// 5. get from database
// 6. update in database
// 7. delete from database

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (BuildContext context, AppState state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppState state) {
          AppCubit cubit = AppCubit.getObject(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.curIndex],
              ),
            ),
            body: (state is! AppGetDatabaseLoadingState)
                ? cubit.screens[cubit.curIndex]
                : Center(child: CircularProgressIndicator()),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (!cubit.isBottomSheetClosed) {
                  if (formKey.currentState!.validate()) {
                    print('-----------------------------------');
                    print(cubit.newTasks.length);
                    cubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    );
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(
                            20.0,
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: titleController,
                                  type: TextInputType.text,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'title must not be empty';
                                    }

                                    return null;
                                  },
                                  label: 'Task Title',
                                  prefix: Icons.title,
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      timeController.text =
                                          value!.format(context).toString();
                                      print(value.format(context));
                                    });
                                  },
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'time must not be empty';
                                    }
                                  },
                                  label: 'Task Time',
                                  prefix: Icons.watch_later_outlined,
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2023-08-03'),
                                    ).then((value) {
                                      dateController.text =
                                          DateFormat.yMMMd().format(value!);
                                    });
                                  },
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'date must not be empty';
                                    }

                                    return null;
                                  },
                                  label: 'Task Date',
                                  prefix: Icons.calendar_today,
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState();
                  });

                  cubit.changeBottomSheetState();
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.curIndex,
              onTap: (index) {
                cubit.changeBottomNavBarIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
