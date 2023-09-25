import 'package:flutter/cupertino.dart';
import 'exerciseadd.dart';
import 'database.dart';
import 'constants.dart';

class ExercisePage extends StatefulWidget {
  ExercisePage({Key? key}) : super(key: key);
  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<Map<String, dynamic>> exercises = [];
  Map<String, List<ExerciseAdd>> exerciseMap = {};

  @override
  void initState() {
    fetchExercises(setState);
    super.initState();
  }

  void updateSelectedExercise(String exercise, StateSetter setState) {
    setState(() {
      selectedExercise = exercise;
    });
  }

  void fetchExercises(StateSetter setState) async {
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

    Map<String, List<ExerciseAdd>> initialExerciseMap = {};

    exercises.forEach((exercise) {
      final muscleGroup = exercise['muscle'];
      final exerciseName = exercise['name'];

      if (initialExerciseMap[muscleGroup] == null) {
        initialExerciseMap[muscleGroup] = [];
      }

      initialExerciseMap[muscleGroup]!.add(
        ExerciseAdd(
          name: exerciseName,
          muscleGroup: muscleGroup,
          onSelect: (exerciseName) {
            updateSelectedExercise(exerciseName,
                setState); // Call the callback when exercise is selected
          },
          fetchExercisesCallback: () => fetchExercises(setState),

          // Pass a callback function
          key: Key(exercise['name']),
        ),
      );
    });
    setState(() {
      exerciseMap = initialExerciseMap;
    });
  }

  void _searchExercise(String searchText, StateSetter setState) {
    if (searchText.isEmpty) {
      fetchExercises(setState);
    } else {
      List<Map<String, dynamic>> filteredExercises = [];

      for (var exercise in exercises) {
        if (exercise['name'].toLowerCase().contains(searchText.toLowerCase())) {
          filteredExercises.add(exercise);
        }
      }

      // Rebuild exerciseMap based on the filtered exercises
      Map<String, List<ExerciseAdd>> filteredExerciseMap = {};

      for (var exercise in filteredExercises) {
        final muscleGroup = exercise['muscle'];
        final exerciseName = exercise['name'];

        if (filteredExerciseMap[muscleGroup] == null) {
          filteredExerciseMap[muscleGroup] = [];
        }

        filteredExerciseMap[muscleGroup]!.add(
          ExerciseAdd(
            name: exerciseName,
            muscleGroup: muscleGroup,
            onSelect: (exerciseName) {
              updateSelectedExercise(exerciseName,
                  setState); // Call the callback when exercise is selected
            },
            fetchExercisesCallback: () => fetchExercises(setState),
            key: Key(exercise['name']),
          ),
        );
      }

      setState(() {
        exerciseMap = filteredExerciseMap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Container(
          width: 200,
          child: CupertinoSearchTextField(
            placeholder: 'Übung durchsuchen',
            onChanged: (searchText) {
              _searchExercise(searchText, setState);
            },
          ),
        ),
      ),
      child: SafeArea(
          child: ListView.builder(
        itemCount: exerciseMap.length + 1,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGrey),
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
                        return ExerciseAdd(
                          name: exercise['name'],
                          fetchExercisesCallback: () => fetchExercises(
                              setState), // Pass a callback function
                          onSelect: (exerciseName) {
                            updateSelectedExercise(exerciseName,
                                setState); // Call the callback when exercise is selected
                          },
                          muscleGroup: exercise['muscle'],

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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemGrey),
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
            var muscleGroup = exerciseMap.keys.elementAt(index - 1);
            var exercisesForGroup = exerciseMap[muscleGroup] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    muscleGroup,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemGrey),
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
                      return ExerciseAdd(
                        name: exercise.name,
                        muscleGroup: exercise.muscleGroup,
                        onSelect: (exerciseName) {
                          updateSelectedExercise(exerciseName,
                              setState); // Call the callback when exercise is selected
                        },

                        fetchExercisesCallback: () => fetchExercises(
                            setState), // Pass a callback function
// Pass the setState function

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
