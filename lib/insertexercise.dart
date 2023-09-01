import 'database.dart';

void insertExercises() async {
  List<Map<String, dynamic>> exercisesToAdd = [
    {
      'name': 'Bench Press',
      'muscle': 'Chest',
      'favorite': 0,
      'description':
          'Lie on a flat training bench with your back against it and your feet flat on the floor.\n'
              'Grip the barbell with your hands slightly wider than shoulder-width apart.\n'
              'Lower the barbell slowly and under control to your chest.\n'
              'Push the barbell upward explosively until your arms are fully extended.'
    },
    {
      'name': 'Squat',
      'muscle': 'Legs',
      'favorite': 0,
      'description': 'Stand with feet shoulder-width apart.\n'
          'Keep back straight, chest up.\n'
          'Bend knees and hips to lower body.\n'
          'Go as low as comfortable.\n'
          'Push through heels to stand up.'
    },
    {
      'name': 'Deadlift',
      'muscle': 'Back',
      'favorite': 0,
      'description': 'Stand with feet hip-width apart, toes under the barbell.\n'
          'Bend at hips and knees to grip the bar with hands shoulder-width apart.\n'
          'Keep back straight, chest up, and core engaged.\n'
          'Lift the bar by straightening hips and knees.\n'
          'Stand up fully, keeping the bar close to your body.\n'
          'Lower the bar by bending hips and knees while maintaining good form.'
    },
    {
      'name': 'Pull-up',
      'muscle': 'Back',
      'favorite': 0,
      'description':
          'Hang from a pull-up bar with palms facing away and hands shoulder-width apart.\n'
              'Engage your shoulder blades and core.\n'
              'Pull your body upward, leading with your chest, until chin is above the bar.\n'
              'Lower your body with control until arms are fully extended.'
    },
    {
      'name': 'Dips',
      'muscle': 'Triceps',
      'favorite': 0,
      'description': 'Stand between parallel bars or use dip station equipment.\n'
          'Grip the bars with your palms facing down, shoulder-width apart.\n'
          'Lower your body by bending your elbows until your shoulders are below your elbows.\n'
          'Push your body back up to the starting position, fully extending your arms.'
    },
    {
      'name': 'Leg Press',
      'muscle': 'Legs',
      'favorite': 0,
      'description': 'Sit down on the leg press machine with your back against the pad.\n'
          'Place your feet shoulder-width apart on the platform.\n'
          'Release the safety handles and push the weight up, extending your legs fully.\n'
          'Bend your knees to lower the weight until your thighs are parallel to the ground.\n'
          'Push the weight back up to the starting position, straightening your legs.'
    },
    {
      'name': 'Overhead Press',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description': 'Stand with feet shoulder-width apart.\n'
          'Hold a barbell at shoulder height with palms facing forward and elbows bent.\n'
          'Press the barbell overhead by extending your arms fully.\n'
          'Lower the barbell back to shoulder height with control.'
    },
    {
      'name': 'Dumbbell Flyes',
      'muscle': 'Chest',
      'favorite': 0,
      'description': 'Lie flat on a bench with your feet flat on the floor.\n'
          'Hold a dumbbell in each hand with your palms facing each other, arms extended upward.\n'
          'Lower the dumbbells out to the sides in a wide arc, keeping a slight bend in your elbows.\n'
          'Lower them until your chest feels stretched, then reverse the motion.\n'
          'Bring the dumbbells back to the starting position, squeezing your chest muscles.'
    },
    {
      'name': 'Incline Bench Press',
      'muscle': 'Chest',
      'favorite': 0,
      'description':
          'Lie on an incline bench with your back and shoulders against the pad.\n'
              'Grip the barbell slightly wider than shoulder-width apart, with palms facing forward.\n'
              'Unrack the barbell and lower it to your chest, keeping your elbows at a 45-degree angle.\n'
              'Press the barbell upward until your arms are fully extended.\n'
              'Lower the barbell back to your chest with control.'
    },
    {
      'name': 'Push-ups',
      'muscle': 'Chest',
      'favorite': 0,
      'description': 'Start in a plank position with your hands placed slightly wider than shoulder-width apart.\n'
          'Keep your body in a straight line from head to heels.\n'
          'Lower your body by bending your elbows, keeping them close to your sides.\n'
          'Lower yourself until your chest touches the ground or hovers slightly above it.\n'
          'Push your body back up to the starting position, fully extending your arms.'
    },
    {
      'name': 'Lunges',
      'muscle': 'Legs',
      'favorite': 0,
      'description': 'Stand with feet together and hands on your hips.\n'
          'Take a step forward with one leg, bending both knees to 90-degree angles.\n'
          'Keep your front knee directly above your ankle.\n'
          'Push off your front foot to return to the starting position.\n'
          'Repeat with the other leg, alternating sides.'
    },
    {
      'name': 'Lat Pulldowns',
      'muscle': 'Back',
      'favorite': 0,
      'description': 'Sit down at a lat pulldown machine with your thighs snugly under the pads.\n'
          'Grip the bar wider than shoulder-width apart, palms facing forward.\n'
          'Pull the bar down to your chest, squeezing your shoulder blades together.\n'
          'Control the bar as you raise it back up, fully extending your arms.'
    },
    {
      'name': 'Bent Over Rows',
      'muscle': 'Back',
      'favorite': 0,
      'description': 'Stand with feet hip-width apart, holding a barbell or dumbbells in front of you.\n'
          'Bend at your hips to lower your torso, keeping your back straight and knees slightly bent.\n'
          'Engage your core and pull the weight toward your lower ribcage by bending your elbows.\n'
          'Squeeze your shoulder blades together at the top of the movement.\n'
          'Lower the weight back down with control, fully extending your arms.'
    },
    {
      'name': 'Seated Rows',
      'muscle': 'Back',
      'favorite': 0,
      'description':
          'Sit at a seated row machine with your feet flat on the footrests.\n'
              'Grab the handle with both hands, palms facing each other, and sit up straight.\n'
              'Pull the handle toward your lower ribcage, squeezing your shoulder blades together.\n'
              'Keep your back straight and avoid using momentum.\n'
              'Slowly release the handle, extending your arms.'
    },
    {
      'name': 'Skull Crushers',
      'muscle': 'Triceps',
      'favorite': 0,
      'description': 'Lie on a flat bench with a barbell or dumbbells held directly above your chest.\n'
          'Bend your elbows and lower the weight toward your forehead, keeping upper arms vertical.\n'
          'Extend your arms to lift the weight back to the starting position.\n'
          'Keep your elbows stationary, and engage your triceps throughout the movement.'
    },
    {
      'name': 'Leg Extensions',
      'muscle': 'Legs',
      'favorite': 0,
      'description':
          'Sit on a leg extension machine with your back against the pad and feet under the padded bar.\n'
              'Adjust the weight and settings as needed.\n'
              'Extend your legs, lifting the weight until your knees are almost fully straight.\n'
              'Lower the weight with control, bending your knees back to the starting position.'
    },
    {
      'name': 'Step-Ups',
      'muscle': 'Legs',
      'favorite': 0,
      'description': 'Stand in front of a sturdy bench or platform.\n'
          'Step one foot onto the bench and push through that heel to lift your body up.\n'
          'Bring your other foot up and stand fully on the bench.\n'
          'Step back down with one foot, followed by the other.'
    },
    {
      'name': 'Arnold Press',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description': 'Stand in front of a sturdy bench or platform.\n'
          'Step one foot onto the bench and push through that heel to lift your body up.\n'
          'Bring your other foot up and stand fully on the bench.\n'
          'Step back down with one foot, followed by the other.'
    },
    {
      'name': 'Lateral Raises',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description':
          'Stand with feet shoulder-width apart, holding dumbbells at your sides, palms facing in.\n'
              'Maintain a slight bend in your elbows throughout the exercise.\n'
              'Raise the dumbbells directly out to the sides until they reach shoulder level.\n'
              'Pause briefly at the top of the movement.\n'
              'Lower the dumbbells back down with control.'
    },
    {
      'name': 'Upright Rows',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description':
          'Stand with your feet shoulder-width apart, holding a barbell or dumbbells in front of your thighs, palms facing your body.\n'
              'Keeping the weights close to your body, raise them upward toward your chin, leading with your elbows.\n'
              'Lift the weights until they reach chest height, keeping them close to your body.\n'
              'Pause briefly at the top of the movement.\n'
              'Lower the weights back down with control.'
    },
    {
      'name': 'Face Pulls',
      'muscle': 'Shoulders',
      'favorite': 0,
      'description': 'Attach a rope handle to a cable machine at chest height.\n'
          'Stand with your feet shoulder-width apart and grab the rope with a neutral grip (palms facing each other).\n'
          'Step back to create tension in the cable.\n'
          'Pull the rope toward your face by squeezing your shoulder blades together and keeping your elbows high.\n'
          'Focus on bringing the rope to the level of your forehead or above.\n'
          'Hold for a moment, then return the rope to the starting position with control.'
    },
    {
      'name': 'Hammer Curls',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Stand with a dumbbell in each hand, arms fully extended by your sides, palms facing your torso (neutral grip).\n'
              'Keep your back straight and core engaged.\n'
              'Curl one dumbbell upward by bending your elbow while keeping your palm facing your torso.\n'
              'Lift the dumbbell as high as possible while maintaining control.\n'
              'Lower the dumbbell back to the starting position with control.'
    },
    {
      'name': 'Concentration Curls',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Sit on a bench with your legs spread apart and a dumbbell in one hand.\n'
              'Place the back of your upper arm against your inner thigh, allowing your arm to fully extend.\n'
              'Curl the dumbbell upward toward your shoulder while keeping your upper arm stationary.\n'
              'Squeeze your bicep at the top of the movement.\n'
              'Lower the dumbbell back to the starting position with control.'
    },
    {
      'name': 'Preacher Curls',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Sit at a preacher curl bench with your upper arms resting on the padded surface.\n'
              'Hold a barbell or dumbbell with an underhand grip (palms facing up).\n'
              'Start with your arms fully extended and the weight hanging down.\n'
              'Curl the weight upward, contracting your biceps.\n'
              'Lift until your forearms are almost vertical and the biceps are fully contracted.\n'
              'Lower the weight back to the starting position with control.'
    },
    {
      'name': 'Cable Curls',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Stand in front of a cable machine with a straight or EZ-curl bar attached to the low pulley.\n'
              'Grasp the bar with an underhand grip (palms facing up) at shoulder width.\n'
              'Stand up straight with your back and chest held high.\n'
              'Keep your elbows close to your sides and fully extend your arms.\n'
              'Curl the bar upward, contracting your biceps, until your forearms are almost vertical.\n'
              'Pause briefly at the top of the movement.\n'
              'Lower the bar back to the starting position with control.'
    },
    {
      'name': 'Chin-ups',
      'muscle': 'Biceps',
      'favorite': 0,
      'description':
          'Find a horizontal bar with an underhand grip (palms facing you), slightly wider than shoulder-width apart.\n'
              'Hang from the bar with your arms fully extended.\n'
              'Engage your core and pull your body upward by bending your elbows.\n'
              'Continue pulling until your chin is above the bar.\n'
              'Lower your body back down to the starting position with control.'
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
