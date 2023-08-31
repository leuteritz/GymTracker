import 'package:flutter/cupertino.dart';
import 'exercise.dart';
import 'database.dart';

class ExerciseScreen extends StatefulWidget {
  ExerciseScreen({Key? key}) : super(key: key); // Add Key parameter

  @override
  State<ExerciseScreen> createState() => ExerciseScreenState();
}

class ExerciseScreenState extends State<ExerciseScreen> {
  List<Map<String, dynamic>> exercises = [];
  List<String> desiredMuscleGroupOrder = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Triceps',
    'Biceps'
  ];

  void fetchExercises() async {
    final List<Map<String, dynamic>> allExerciseData =
        await DatabaseHelper().getAllExerciseListInformation();

    List<Map<String, dynamic>> favoriteExerciseData = [];
    List<Map<String, dynamic>> nonFavoriteExerciseData = [];

    for (var exerciseData in allExerciseData) {
      if (exerciseData['favorite'] == 1) {
        favoriteExerciseData.add(exerciseData);
      } else {
        nonFavoriteExerciseData.add(exerciseData);
      }
    }

    setState(() {
      exercises = favoriteExerciseData + nonFavoriteExerciseData;
    });

    print("favorite exercises: $favoriteExerciseData");
    print("non-favorite exercises: $nonFavoriteExerciseData");
  }

  @override
  void initState() {
    super.initState();

    fetchExercises();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Exercise>> exerciseMap = {};

    // Group exercises by muscle group
    exercises.forEach((exercise) {
      final muscleGroup = exercise['muscle'];
      final exerciseName = exercise['name'];
      final exerciseDescription = exercise['description'];

      if (exerciseMap[muscleGroup] == null) {
        exerciseMap[muscleGroup] = [];
      }

      exerciseMap[muscleGroup]!.add(
        Exercise(
          name: exerciseName,
          description: exerciseDescription,
          muscleGroup: muscleGroup,
          fetchExercisesCallback: fetchExercises,
          key: Key(
              exercise['name']), // Use a unique identifier, like exercise name
          // Pass the callback
        ),
      );
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: SizedBox(
          width: 150,
          child: CupertinoSearchTextField(
            placeholder: 'Übung durchsuchen',
          ),
        ),
      ),
      child: Center(
          child: ListView.builder(
        itemCount: desiredMuscleGroupOrder.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            // Favorites section
            var favoriteExercises = exercises
                .where((exercise) => exercise['favorite'] == 1)
                .toList();

            if (favoriteExercises.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "Favorites" + " (${favoriteExercises.length})",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: favoriteExercises.map((exercise) {
                        return Exercise(
                          name: exercise['name'],
                          description: exercise['description'],
                          muscleGroup: exercise['muscle'],
                          fetchExercisesCallback: fetchExercises,
                          key: Key(exercise[
                              'name']), // Use a unique identifier, like exercise name
                          // Pass the callback
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Favorites" + " (${favoriteExercises.length})",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              );
            }
          } else {
            // Regular muscle group section
            var muscleGroup = desiredMuscleGroupOrder[index - 1];
            var exercisesForGroup =
                exerciseMap[muscleGroup] ?? []; // Use null-aware operator

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    muscleGroup,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: exercisesForGroup.map((exercise) {
                      return Exercise(
                        name: exercise.name,
                        description: exercise.description,
                        muscleGroup: exercise.muscleGroup,
                        fetchExercisesCallback: fetchExercises,
                        key: Key(exercise.name),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
        },
      )),
    );
  }
}
