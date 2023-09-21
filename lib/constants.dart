import 'package:flutter/cupertino.dart';

List<Map<String, dynamic>> exerciseList = [];
List<Map<String, dynamic>> exerciseDurationList = [];
String selectedExercise = 'Select Exercise';
ValueNotifier<String> selectedExerciseNotifier =
    ValueNotifier<String>(selectedExercise);
