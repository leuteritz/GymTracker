import 'package:flutter/cupertino.dart';
import '/pages/exerciseDetailPage.dart';
import '/data/database.dart';

class ExerciseScreenExerciseItem extends StatefulWidget {
  final String name;

  final String muscleGroup;
  final VoidCallback fetchExercisesCallback;

  ExerciseScreenExerciseItem(
      {required this.muscleGroup,
      required this.fetchExercisesCallback,
      required this.name,
      Key? key})
      : super(key: key);

  @override
  State<ExerciseScreenExerciseItem> createState() =>
      _ExerciseScreenExerciseItemState();
}

class _ExerciseScreenExerciseItemState
    extends State<ExerciseScreenExerciseItem> {
  @override
  void initState() {
    super.initState();
    fetchFavoriteStatus();
  }

  void fetchFavoriteStatus() async {
    final dbHelper = DatabaseHelper();
    bool isFavorite = await dbHelper.isExerciseFavorite(widget.name);

    if (mounted) {
      setState(() {
        isPressed = isFavorite;
      });
    }
  }

  bool isPressed = false;

  void _toggleHeart() {
    setState(() {
      isPressed = !isPressed;
    });
  }

  void updateFavorite(String name) async {
    final dbHelper = DatabaseHelper();
    if (isPressed) {
      await dbHelper.updateExerciseFavoriteStatus(name, 1);
    } else {
      await dbHelper.updateExerciseFavoriteStatus(name, 0);
    }
  }

  String getFirstLetter() {
    return widget.name[0];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ExerciseDetailPage(exercise: widget.name),
            ),
          );
        },
        child: CupertinoListTile(
          leading: Text(getFirstLetter()),
          title: Text(widget.name),
          subtitle: Text(widget.muscleGroup),
          trailing: CupertinoButton(
            child: Icon(
              isPressed ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            ),
            onPressed: () {
              _toggleHeart();
              updateFavorite(widget.name);
              widget.fetchExercisesCallback();

              fetchFavoriteStatus();
            },
          ),
        ));
  }
}
