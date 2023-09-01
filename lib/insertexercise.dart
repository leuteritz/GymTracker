import 'database.dart';

void insertExercises() async {
  List<Map<String, dynamic>> exercisesToAdd = [
    {
      'name': 'Bench Press',
      'muscle': 'Chest',
      'favorite': 0,
      'description':
          'Lie on training bench with your back flat and feet on the floor.\n'
              'Grip the bar slightly wider than shoulder-width apart.\n'
              'Lower the barbell to your chest in a controlled manner.\n'
              'Push the barbell back up explosively to the starting position.'
    },
    {
      'name': 'Squat',
      'muscle': 'Legs',
      'favorite': 0,
      'description':
          'Feet shoulder-width apart, bend knees as if to sit down, then straighten. Strengthens legs and gluteal muscles.',
    },
    {
      'name': 'Deadlift',
      'muscle': 'Back',
      'favorite': 0,
      'description':
          'Stand in front of barbell, grasp hands at shoulder width, keep back straight. Bend, lift barbell, straighten hips and knees. Then lower in a controlled manner. Exercises back, legs and buttocks. Ensure correct posture to avoid injury.',
    },
    {
      'name': 'Pull-up',
      'muscle': 'Back',
      'favorite': 0,
      'description':
          'Hang from a bar with palms facing away. Pull body upward until chin clears the bar. Strengthens upper back, shoulders, and arms.',
    },
    {
      'name': 'Dips',
      'muscle': 'Triceps',
      'favorite': 0,
      'description':
          'Lower body by bending arms at elbows until shoulders are below elbows, then lift back up. Strengthens triceps, shoulders, and chest.',
    },
    {
      'name': 'Leg Press',
      'muscle': 'Legs',
      'favorite': 0,
      'description':
          'Sit in a leg press machine, push platform away by extending your legs, then lower it back down. Strengthens quads, hamstrings, and glutes.',
    },
    {
      'name': 'Overhead Press',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description':
          'Hold a barbell or dumbbells at shoulder height, then press them overhead. Strengthens shoulders and triceps.',
    },
    {
      'name': 'Dumbbell Flyes',
      'muscle': 'Chest',
      'favorite': 0,
      'description':
          'Lie on bench, hold dumbbells above chest, lower and spread arms, then raise back up. Isolates chest muscles.',
    },
    {
      'name': 'Incline Bench Press',
      'muscle': 'Chest',
      'favorite': 0,
      'description':
          'Similar to bench press but on an inclined bench, targets upper chest.',
    },
    {
      'name': 'Push-ups',
      'muscle': 'Chest',
      'favorite': 0,
      'description':
          'Place hands on the floor, extend arms to raise body, then lower back down. Effective bodyweight exercise.',
    },
    {
      'name': 'Lunges',
      'muscle': 'Legs',
      'favorite': 0,
      'description':
          'Step forward and lower body until both knees are bent at 90-degree angles. Strengthens legs and glutes.',
    },
    {
      'name': 'Lat Pulldowns',
      'muscle': 'Back',
      'favorite': 0,
      'description':
          'Use lat pulldown machine, pull bar down to chest, engaging back muscles.',
    },
    {
      'name': 'Bent Over Rows',
      'muscle': 'Back',
      'favorite': 0,
      'description':
          'Bend at hips, hold barbell with palms facing you, pull barbell to lower chest. Works upper back and lats.',
    },
    {
      'name': 'Seated Rows',
      'muscle': 'Back',
      'favorite': 0,
      'description':
          'Sit at rowing machine, pull handles towards your torso, engaging back muscles.',
    },
    {
      'name': 'Tricep Dips',
      'muscle': 'Triceps',
      'favorite': 0,
      'description':
          'Similar to regular dips, but with focus on triceps. Keep elbows close to your body.',
    },
    {
      'name': 'Skull Crushers',
      'muscle': 'Triceps',
      'favorite': 0,
      'description':
          'Lie on bench, hold barbell above forehead, lower and extend arms. Isolates tricep muscles.',
    },
    {
      'name': 'Leg Extensions',
      'muscle': 'Legs',
      'favorite': 0,
      'description':
          'Use leg extension machine to extend legs, targeting quads.',
    },
    {
      'name': 'Step-Ups',
      'muscle': 'Legs',
      'favorite': 0,
      'description':
          'Step onto platform with one leg, then raise body up. Strengthens legs and glutes.',
    },
    {
      'name': 'Arnold Press',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description':
          'Hold dumbbells at shoulder height, rotate palms while pressing weights overhead.',
    },
    {
      'name': 'Lateral Raises',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description':
          'Hold dumbbells at sides, raise arms outwards to shoulder height, engaging side deltoids.',
    },
    {
      'name': 'Upright Rows',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description':
          'Hold barbell in front of thighs, pull barbell upwards to chin, targeting shoulders and upper traps.',
    },
    {
      'name': 'Face Pulls',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description':
          'Attach rope handle to cable machine, pull rope towards face, engaging rear deltoids.',
    },
    {
      'name': 'Hammer Curls',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Hold dumbbells with palms facing your body, curl weights while keeping palms facing inwards.',
    },
    {
      'name': 'Concentration Curls',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Sit on a bench, curl dumbbell with one hand while resting elbow on inner thigh.',
    },
    {
      'name': 'Preacher Curls',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Use a preacher curl bench, curl barbell or dumbbells with palms facing up.',
    },
    {
      'name': 'Cable Curls',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Attach a handle to a cable machine, curl with one arm at a time.',
    },
    {
      'name': 'Chin-ups',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Similar to pull-ups but with palms facing towards you, targets biceps and back.',
    },
  ];

  for (var exerciseData in exercisesToAdd) {
    final exerciseName = exerciseData['name'];

    // Check if the exercise already exists in the database
    final existingExercise =
        await DatabaseHelper().getExerciseByName(exerciseName);

    if (existingExercise == null) {
      await DatabaseHelper().insertExerciseList(
        name: exerciseData['name'],
        muscle: exerciseData['muscle'],
        favorite: exerciseData['favorite'],
        description: exerciseData['description'].toString(),
      );
    }
  }
}
