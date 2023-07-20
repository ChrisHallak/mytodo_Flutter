import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../layout/todo_app/cubit/cubit.dart';
import '../../layout/todo_app/cubit/states.dart';
import 'package:todo/shared/components/components.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var tasks = AppCubit.getObject(context).newTasks;
        print('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh ${tasks.length}');
        return tasksBuilder(
          tasks: tasks,
        );
      },
    );
  }
}
