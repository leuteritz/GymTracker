import 'package:flutter/cupertino.dart';

import '/data/database.dart';
import '/constants/constants.dart';

class HomeScreenExerciseAddItem extends StatefulWidget {
  final String name;
  final String muscleGroup;

  final VoidCallback fetchExercisesCallback;
  final Function(String) onSelect;

  HomeScreenExerciseAddItem(
      {required this.muscleGroup,
      required this.name,
      required this.fetchExercisesCallback,
      required this.onSelect,
      Key? key})
      : super(key: key);

  @override
  State<HomeScreenExerciseAddItem> createState() =>
      _HomeScreenExerciseAddItemState();
}

class _HomeScreenExerciseAddItemState extends State<HomeScreenExerciseAddItem> {
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
          widget.onSelect(widget.name);

          selectedExerciseNotifier.value = widget.name;

          Navigator.of(context).pop();
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
