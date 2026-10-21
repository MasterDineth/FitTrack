/// Rich seed content for the canonical FitTrack exercise library.
///
/// Every entry mirrors exactly what the Create Exercise screen records:
/// a name, equipment, movement classification, a cover image, a YouTube
/// guide, a description, up to three execution steps, up to three form cues
/// and up to three muscle activations.
library;

/// One recorded execution step.
class SeedStep {
  const SeedStep(this.title, this.instructions);

  final String title;
  final String instructions;
}

/// One recorded form cue. [isPositive] marks a "do" cue, otherwise a "don't".
class SeedCue {
  const SeedCue(this.description, {this.isPositive = true});

  final String description;
  final bool isPositive;
}

/// One recorded muscle activation.
class SeedMuscle {
  const SeedMuscle(this.name, this.role, this.percentage);

  final String name;

  /// Matches `MuscleRole` names: `agonist`, `synergist`, `stabilizer`.
  final String role;
  final int percentage;
}

/// A fully populated library exercise.
class SeedExercise {
  const SeedExercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.movementClassification,
    required this.imageAsset,
    required this.description,
    required this.steps,
    required this.cues,
    required this.muscles,
  });

  final String id;
  final String name;
  final String equipment;
  final String movementClassification;
  final String imageAsset;
  final String description;
  final List<SeedStep> steps;
  final List<SeedCue> cues;
  final List<SeedMuscle> muscles;

  /// YouTube guide link for this exercise.
  String get youtubeUrl =>
      'https://www.youtube.com/results?search_query='
      '${Uri.encodeComponent('$name proper form technique')}';
}

/// Legacy exercise ids mapped to their canonical id.
///
/// Each alias is a separate row in the `exercises` table, so it receives the
/// same details and the same child records as the exercise it points at.
const Map<String, String> kSeedExerciseAliases = {
  'ex_barbell_bench_press': 'ex1',
  'ex_incline_dumbbell_press': 'ex2',
  'ex_cable_flyes': 'ex3',
  'ex_cable_chest_flyes': 'ex3',
  'ex_standing_overhead_press': 'ex4',
  'ex_cable_lateral_raise': 'ex5',
  'ex_tricep_pushdowns': 'ex6',
  'ex_overhead_triceps_extension': 'ex7',
  'ex_barbell_squat': 'ex8',
  'ex_bent_over_row': 'ex9',
  'ex_conventional_deadlift': 'ex10',
  'ex_romanian_deadlift': 'ex11',
  'ex_lat_pulldown': 'ex12',
  'ex_pull_ups': 'ex13',
  'ex_dumbbell_bicep_curl': 'ex14',
  'ex_hammer_curl': 'ex15',
  'ex_bulgarian_split_squat': 'ex16',
  'ex_seated_leg_curl': 'ex17',
  'ex_leg_extension': 'ex18',
  'ex_standing_calf_raise': 'ex19',
  'ex_face_pull': 'ex20',
  'ex_hanging_leg_raise': 'ex21',
  'ex_kettlebell_swing': 'ex22',
  'ex_goblet_squat': 'ex23',
  'ex_snatch_burpee': 'ex24',
};

const String _hero = 'assets/images/dashboard/hero_workout.webp';
const String _bench = 'assets/images/dashboard/coaching_bench.webp';

/// Complete library content for all 25 canonical exercises.
const List<SeedExercise> kSeedExercises = [
  SeedExercise(
    id: 'ex1',
    name: 'Barbell Bench Press',
    equipment: 'barbell',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'The foundational horizontal press. It builds raw pushing strength '
        'across the chest, front deltoids and triceps, and is the benchmark '
        'every pressing movement is measured against.',
    steps: [
      SeedStep(
        'Set Up & Grip',
        'Lie on a flat bench with your feet planted flat and your eyes '
            'directly under the bar. Grip the bar just outside shoulder '
            'width with a balanced, closed grip.',
      ),
      SeedStep(
        'Unrack & Lower',
        'Lift the bar clear of the rack with straight arms and settle it '
            'over your mid-chest. Bend the elbows to roughly 45 degrees '
            'from the torso and lower the bar under control to the lower chest.',
      ),
      SeedStep(
        'Press & Lock Out',
        'Drive the bar back up and slightly toward your face, finishing with '
            'the elbows locked out and the shoulder blades retracted down '
            'into the bench.',
      ),
    ],
    cues: [
      SeedCue(
        'Keep the shoulder blades pinned into the bench for the whole set to '
            'build a stable base.',
      ),
      SeedCue('Touch the lower chest with the bar, not the neck or the joint.'),
      SeedCue(
        'Do not flare the elbows to 90 degrees. Keeping them closer to the '
            'body spares the shoulder.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Pectoralis Major', 'agonist', 70),
      SeedMuscle('Anterior Deltoid', 'synergist', 55),
      SeedMuscle('Triceps Brachii', 'stabilizer', 35),
    ],
  ),
  SeedExercise(
    id: 'ex2',
    name: 'Incline Dumbbell Press',
    equipment: 'dumbbell',
    movementClassification: 'compound',
    imageAsset: _bench,
    description:
        'An angled press that biases the upper chest and anterior deltoid. '
        'The independent handles let each side correct its own range of '
        'motion, and the angle is far kinder to the shoulders than a flat bar.',
    steps: [
      SeedStep(
        'Set the Bench & Seat',
        'Set the bench to 30 to 45 degrees and sit back with the dumbbells '
            'resting on your thighs. Walk your feet forward so your knees '
            'sit under your ankles.',
      ),
      SeedStep(
        'Press to the Top',
        'With a neutral grip, press the dumbbells up and slightly inward '
            'until your arms are straight and the weights sit above your '
            'shoulders.',
      ),
      SeedStep(
        'Lower to a Stretch',
        'Lower the dumbbells slowly under control to just below chest level, '
            'keeping a soft bend in the elbows so the upper chest opens up.',
      ),
    ],
    cues: [
      SeedCue('Press up and slightly together to keep the load over the joint.'),
      SeedCue('Keep the lower back against the pad so the hips never lift.'),
      SeedCue(
        'Do not drop the dumbbells far below the chest — stay above that line.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Upper Pectoralis', 'agonist', 70),
      SeedMuscle('Anterior Deltoid', 'synergist', 55),
      SeedMuscle('Triceps Brachii', 'stabilizer', 40),
    ],
  ),
  SeedExercise(
    id: 'ex3',
    name: 'Cable Chest Fly',
    equipment: 'cable',
    movementClassification: 'isolation',
    imageAsset: _hero,
    description:
        'A continuous-tension fly that isolates the pectorals. The cable keeps '
        'tension through the whole arc, so the chest works right through the '
        'stretched position without the shoulder pinch of a dumbbell fly.',
    steps: [
      SeedStep(
        'Set the Cable',
        'Set both pulleys to shoulder height and step forward into a split '
            'stance, holding the handles with a soft, slightly bent elbow.',
      ),
      SeedStep(
        'Bring the Arms Together',
        'Sweep the handles together in a wide arc in front of the chest and '
            'squeeze the pectorals at the end of the range.',
      ),
      SeedStep(
        'Open with Control',
        'Allow the arms to open slowly back to the start, resisting the pull '
            'so the chest does the work rather than the shoulders.',
      ),
    ],
    cues: [
      SeedCue('Think of hugging someone with your elbows to keep the chest loaded.'),
      SeedCue('Keep a soft bend in the elbows the whole time and never lock them out.'),
      SeedCue(
        'Do not let the shoulders roll forward as the arms open.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Pectoralis Major', 'agonist', 75),
      SeedMuscle('Anterior Deltoid', 'synergist', 40),
      SeedMuscle('Serratus Anterior', 'stabilizer', 30),
    ],
  ),
  SeedExercise(
    id: 'ex4',
    name: 'Standing Overhead Press',
    equipment: 'barbell',
    movementClassification: 'compound',
    imageAsset: _bench,
    description:
        'A vertical press that builds overhead strength and shoulder '
        'stability. Standing means the trunk has to stay braced and stacked '
        'under the load instead of being supported by the bench.',
    steps: [
      SeedStep(
        'Set the Stance',
        'Stand with the feet shoulder-width, squeeze the glutes and brace the '
            'core. Set the bar at collarbone height with the hands just '
            'outside shoulder width.',
      ),
      SeedStep(
        'Dip and Drive',
        'Dip slightly by bending the knees, then drive the bar straight up '
            'past the forehead while keeping the ribs pulled down.',
      ),
      SeedStep(
        'Lock Out and Descend',
        'Finish with the bar over the mid-foot and the arms locked, then '
            'lower it back under control to the collarbone.',
      ),
    ],
    cues: [
      SeedCue('Squeeze the glutes and brace the abs so the lower back stays flat.'),
      SeedCue('Move your head back slightly as the bar passes your forehead.'),
      SeedCue(
        'Do not let the bar drift out in front of your face — that turns it '
            'into an incline press.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Deltoids', 'agonist', 70),
      SeedMuscle('Triceps Brachii', 'synergist', 50),
      SeedMuscle('Core', 'stabilizer', 30),
    ],
  ),
  SeedExercise(
    id: 'ex5',
    name: 'Cable Lateral Raise',
    equipment: 'cable',
    movementClassification: 'isolation',
    imageAsset: _bench,
    description:
        'Unilateral cable work for the side deltoid. The constant line of '
        'tension and the single-arm setup remove the momentum that lets dumbbell '
        'raises cheat the traps.',
    steps: [
      SeedStep(
        'Take the Handle',
        'Stand side-on to the low pulley and grip the single handle with the '
            'far hand, letting that arm hang across the body.',
      ),
      SeedStep(
        'Raise to Shoulder Height',
        'Lead with the elbow and lift the arm out to the side until the upper '
            'arm is level with the shoulder.',
      ),
      SeedStep(
        'Lower Past the Hip',
        'Take a full second to lower the arm slowly back across the body, '
            'stopping just past the opposite thigh.',
      ),
    ],
    cues: [
      SeedCue('Stop the raise at shoulder height — going higher shifts the work to the traps.'),
      SeedCue('Keep the neck relaxed and the shoulders down throughout the set.'),
      SeedCue(
        'Do not swing the torso to heave the weight upward.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Lateral Deltoid', 'agonist', 80),
      SeedMuscle('Trapezius', 'synergist', 30),
      SeedMuscle('Supraspinatus', 'stabilizer', 25),
    ],
  ),
  SeedExercise(
    id: 'ex6',
    name: 'Triceps Pushdown',
    equipment: 'cable',
    movementClassification: 'isolation',
    imageAsset: _hero,
    description:
        'Direct triceps work with the shoulder fixed, so the arms do all of '
        'the moving. The cable keeps steady tension at the hardest part of the '
        'rep, the lockout.',
    steps: [
      SeedStep(
        'Set the Rope',
        'Set the rope attachment at chest height, grip it with both hands and '
            'pin the elbows against the sides of the torso.',
      ),
      SeedStep(
        'Extend the Elbows',
        'Keeping the upper arms still, push the bar down until the arms are '
            'fully straight and the triceps are squeezed hard.',
      ),
      SeedStep(
        'Return Under Control',
        'Allow the bar to rise slowly back to chest height, elbows still '
            'pinned and the tension staying on the triceps.',
      ),
    ],
    cues: [
      SeedCue('Pin the elbows to the ribs and let only the forearms move.'),
      SeedCue('Squeeze hard at full extension and hold for a one-second count.'),
      SeedCue(
        'Do not let the shoulders drift forward as the bar returns.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Triceps Brachii', 'agonist', 80),
      SeedMuscle('Anconeus', 'synergist', 25),
      SeedMuscle('Forearms', 'stabilizer', 20),
    ],
  ),
  SeedExercise(
    id: 'ex7',
    name: 'Overhead Triceps Extension',
    equipment: 'cable',
    movementClassification: 'isolation',
    imageAsset: _hero,
    description:
        'An overhead extension that loads the long head of the triceps — the '
        'hardest portion to reach with a cable pressdown. The overhead angle '
        'also gives the shoulders a useful stretch.',
    steps: [
      SeedStep(
        'Set the Rope',
        'Attach a rope to a high pulley and step forward until the rope is '
            'behind your head, with the elbows pointing forward.',
      ),
      SeedStep(
        'Extend Overhead',
        'Keeping the upper arms still, straighten the elbows and press the '
            'rope away from your head until the arms are vertical.',
      ),
      SeedStep(
        'Lower to a Deep Stretch',
        'Bend the elbows and let the rope travel back behind the head slowly, '
            'keeping the ribs down and the abs braced.',
      ),
    ],
    cues: [
      SeedCue('Keep the elbows pointing forward the whole time instead of flaring out.'),
      SeedCue('Squeeze the glutes and brace the core so the lower back stays flat.'),
      SeedCue(
        'Do not drop the rope behind your head with no control — keep it loaded.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Triceps Brachii', 'agonist', 80),
      SeedMuscle('Deltoids', 'stabilizer', 25),
      SeedMuscle('Forearms', 'synergist', 20),
    ],
  ),
  SeedExercise(
    id: 'ex8',
    name: 'Barbell Back Squat',
    equipment: 'barbell',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'The foundational lower-body lift. It trains the quads, glutes and '
        'trunk to produce force from a deep, braced position, and it is the '
        'best lower-body builder for strength and hypertrophy alike.',
    steps: [
      SeedStep(
        'Set Up the Bar',
        'Set the bar at mid-chest height, duck under with the bar across the '
            'upper back, pull the elbows down and brace the core hard.',
      ),
      SeedStep(
        'Descend to Depth',
        'Sit down and back, keeping the knees tracking over the toes and the '
            'chest tall, until the hips are below parallel.',
      ),
      SeedStep(
        'Drive Up Through Mid-Foot',
        'Drive the floor away through the whole foot, keeping the knees and '
            'hips rising together and finishing tall at the top.',
      ),
    ],
    cues: [
      SeedCue('Brace the abs before every rep and keep the chest proud on the way down.'),
      SeedCue('Spread the floor with your feet and push the knees out of the way.'),
      SeedCue(
        'Do not let the knees collapse inward — track them over the middle toes.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Quadriceps', 'agonist', 70),
      SeedMuscle('Glutes', 'synergist', 60),
      SeedMuscle('Erector Spinae', 'stabilizer', 40),
    ],
  ),
  SeedExercise(
    id: 'ex9',
    name: 'Barbell Bent-Over Row',
    equipment: 'barbell',
    movementClassification: 'compound',
    imageAsset: _bench,
    description:
        'A horizontal pull for the lats and upper back with a pronounced '
        'stretch at the top of every rep. Holding a fixed torso angle makes it '
        'a pure pulling movement.',
    steps: [
      SeedStep(
        'Take the Hip Hinge',
        'Hold the bar with an overhand grip, hinge at the hips until the torso '
            'is around 45 degrees and the knees are softly bent.',
      ),
      SeedStep(
        'Pull to the Lower Ribs',
        'Pull the bar toward the lower ribs by driving the elbows past the '
            'hips, keeping the torso angle fixed throughout.',
      ),
      SeedStep(
        'Lower with a Stretch',
        'Let the bar travel down slowly until the arms are straight and the '
            'lats are stretched wide.',
      ),
    ],
    cues: [
      SeedCue('Pull the bar to the hips and lower ribs, not up toward the chest.'),
      SeedCue('Keep the torso flat and still — the torso does not row the bar.'),
      SeedCue(
        'Do not round the back or use the hips to heave the weight up.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Latissimus Dorsi', 'agonist', 70),
      SeedMuscle('Rhomboids', 'synergist', 50),
      SeedMuscle('Lower Traps', 'stabilizer', 30),
    ],
  ),
  SeedExercise(
    id: 'ex10',
    name: 'Conventional Deadlift',
    equipment: 'barbell',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'The heaviest compound lift in the gym. It pulls the bar from the '
        'floor with the hips, hamstrings and back all loaded, and it is the '
        'best full-body builder there is.',
    steps: [
      SeedStep(
        'Set the Bar & Grip',
        'Bar over mid-foot, shins vertical, grip just outside the knees. '
            'Squeeze the bar, push the floor away and keep the lats tight.',
      ),
      SeedStep(
        'Break the Floor',
        'Push the hips up and the knees back slightly, keeping the bar close '
            'to the legs until it clears the knees.',
      ),
      SeedStep(
        'Lock Out and Reverse',
        'Finish by driving the hips forward until the body is upright and the '
            'bar is locked out, then lower it back under control.',
      ),
    ],
    cues: [
      SeedCue('Keep the bar close to your legs the whole rep — a drifting bar wrecks the back.'),
      SeedCue('Squeeze the bar hard in the hands and think about pulling the floor toward you.'),
      SeedCue(
        'Do not round the back to get the bar off the floor.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Glutes', 'agonist', 65),
      SeedMuscle('Hamstrings', 'synergist', 60),
      SeedMuscle('Lower Back', 'stabilizer', 45),
    ],
  ),
  SeedExercise(
    id: 'ex11',
    name: 'Romanian Deadlift',
    equipment: 'barbell',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'A hip hinge that loads the hamstrings and glutes through a long '
        'stretch while the spine stays completely neutral. The bar only ever '
        'moves because the hips do.',
    steps: [
      SeedStep(
        'Stand Tall',
        'Hold the bar with an overhand grip, feet hip-width, and stand tall '
            'with the bar resting against the thighs.',
      ),
      SeedStep(
        'Push the Hips Back',
        'Keeping the back flat, push the hips backward and let the bar slide '
            'down the legs until you feel a strong hamstring stretch.',
      ),
      SeedStep(
        'Stand Up by Squeezing',
        'Drive the hips forward to stand tall, leading with the chest and '
            'finishing with the glutes squeezed.',
      ),
    ],
    cues: [
      SeedCue('Keep the back flat and the chest proud — the hips travel back, not down.'),
      SeedCue('Feel the hamstring stretch at the bottom before you reverse the rep.'),
      SeedCue(
        'Do not bend the knees deeply or round the lower back to go lower.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Hamstrings', 'agonist', 70),
      SeedMuscle('Glutes', 'synergist', 65),
      SeedMuscle('Erector Spinae', 'stabilizer', 40),
    ],
  ),
  SeedExercise(
    id: 'ex12',
    name: 'Wide-Grip Lat Pulldown',
    equipment: 'cable',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'A vertical pull that loads the lats across a wide, stretching range '
        'of motion. The wide grip biases the upper back and makes the stretch '
        'at the top far more pronounced.',
    steps: [
      SeedStep(
        'Set the Grip',
        'Fix the wide grip overhead, sit down and secure the thigh pads so the '
            'body stays anchored through the set.',
      ),
      SeedStep(
        'Pull to the Collarbone',
        'Lean back slightly and pull the bar down toward the upper chest with '
            'the elbows driving toward the ribs.',
      ),
      SeedStep(
        'Return Slowly',
        'Let the bar rise in a controlled path until the arms are straight and '
            'the lats are fully stretched.',
      ),
    ],
    cues: [
      SeedCue('Drive the elbows down toward the back pockets instead of pulling with the hands.'),
      SeedCue('Keep the chest tall and the torso only slightly leaned back.'),
      SeedCue(
        'Do not let the shoulders roll forward at the top of the rep.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Latissimus Dorsi', 'agonist', 70),
      SeedMuscle('Biceps', 'synergist', 45),
      SeedMuscle('Lower Traps', 'stabilizer', 30),
    ],
  ),
  SeedExercise(
    id: 'ex13',
    name: 'Pull-Up',
    equipment: 'bodyweight',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'A bodyweight vertical pull that trains the lats while forcing the '
        'core to stay braced under your own bodyweight. Nothing to load, '
        'nothing to hide behind.',
    steps: [
      SeedStep(
        'Hang & Grip',
        'Grip the bar slightly wider than shoulder width, hang with straight '
            'arms and pull the shoulders down away from your ears.',
      ),
      SeedStep(
        'Pull the Chest to the Bar',
        'Drive the elbows down and back until the chest reaches the bar, '
            'keeping the ribs down and the legs together.',
      ),
      SeedStep(
        'Lower to a Dead Hang',
        'Control the descent all the way to straight arms without swinging or '
            'dropping.',
      ),
    ],
    cues: [
      SeedCue('Start every rep by pulling the shoulder blades down before bending the elbows.'),
      SeedCue('Keep the legs still and the body moving as one straight line.'),
      SeedCue(
        'Do not kick or swing to get the chin over the bar.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Latissimus Dorsi', 'agonist', 70),
      SeedMuscle('Biceps', 'synergist', 45),
      SeedMuscle('Core', 'stabilizer', 30),
    ],
  ),
  SeedExercise(
    id: 'ex14',
    name: 'Dumbbell Biceps Curl',
    equipment: 'dumbbell',
    movementClassification: 'isolation',
    imageAsset: _hero,
    description:
        'Direct arm work for the biceps. With the elbow fixed and the forearm '
        'doing all the moving, every degree of the range is loaded with '
        'nothing else compensating.',
    steps: [
      SeedStep(
        'Stand Tall',
        'Stand with the dumbbells at your sides, palms facing forward and the '
            'elbows tucked close to the ribs.',
      ),
      SeedStep(
        'Curl to the Peak',
        'Bend the elbows and curl the weights up to the shoulders, keeping the '
            'upper arms still and the wrists flat.',
      ),
      SeedStep(
        'Lower Fully',
        'Lower the dumbbells slowly all the way until the arms are straight and '
            'the biceps are fully stretched.',
      ),
    ],
    cues: [
      SeedCue('Keep the elbows pinned to the sides and the shoulders pulled back.'),
      SeedCue('Squeeze the biceps hard at the top of every rep.'),
      SeedCue(
        'Do not swing the elbows forward or lean back to lift the weight.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Biceps Brachii', 'agonist', 75),
      SeedMuscle('Brachialis', 'synergist', 35),
      SeedMuscle('Forearms', 'stabilizer', 25),
    ],
  ),
  SeedExercise(
    id: 'ex15',
    name: 'Hammer Curl',
    equipment: 'dumbbell',
    movementClassification: 'isolation',
    imageAsset: _hero,
    description:
        'A neutral-grip curl that hits the brachialis and the outer biceps, '
        'filling out the arm and making it look thicker from every angle.',
    steps: [
      SeedStep(
        'Take a Neutral Grip',
        'Hold the dumbbells with the palms facing each other and stand tall '
            'with the elbows against the ribs.',
      ),
      SeedStep(
        'Curl Without Twisting',
        'Curl the weights up in front of the body, keeping the palms facing '
            'each other the whole way.',
      ),
      SeedStep(
        'Lower to Full Extension',
        'Lower the dumbbells slowly to a straight-arm position, keeping the '
            'tension on the biceps.',
      ),
    ],
    cues: [
      SeedCue('Keep the palms facing each other — the neutral grip is the whole point.'),
      SeedCue('Control the lowering half of the rep as much as the lift.'),
      SeedCue(
        'Do not let the wrists roll over or the elbows drift forward.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Brachialis', 'agonist', 60),
      SeedMuscle('Biceps Brachii', 'synergist', 55),
      SeedMuscle('Forearms', 'stabilizer', 25),
    ],
  ),
  SeedExercise(
    id: 'ex16',
    name: 'Bulgarian Split Squat',
    equipment: 'dumbbell',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'A single-leg squat that builds real leg strength and quietly fixes '
        'any side-to-side imbalance. The rear foot elevated forces the front '
        'leg to do all the work.',
    steps: [
      SeedStep(
        'Set the Rear Foot',
        'Rest the top of the rear foot on a bench behind you, stand a stride '
            'length in front and hold the dumbbells at your sides.',
      ),
      SeedStep(
        'Sink Straight Down',
        'Lower the back knee toward the floor while keeping the front foot '
            'planted and the torso upright.',
      ),
      SeedStep(
        'Drive Up',
        'Push through the front heel to bring the body back to standing, '
            'finishing with the glute squeezed on the working side.',
      ),
    ],
    cues: [
      SeedCue('Keep most of the weight in the front heel with the knee tracking over the toes.'),
      SeedCue('Keep the torso upright and the ribs pulled down throughout the set.'),
      SeedCue(
        'Do not let the front knee shoot past the toes or the heel lift.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Quadriceps', 'agonist', 65),
      SeedMuscle('Glutes', 'synergist', 60),
      SeedMuscle('Adductors', 'stabilizer', 30),
    ],
  ),
  SeedExercise(
    id: 'ex17',
    name: 'Seated Leg Curl',
    equipment: 'machine',
    movementClassification: 'isolation',
    imageAsset: _hero,
    description:
        'Machine isolation for the hamstrings. The hip is fixed against the '
        'seat, so the knee does all the moving and the hamstrings take the '
        'full load.',
    steps: [
      SeedStep(
        'Set the Machine',
        'Sit with the knee pivot aligned with the machine hinge, set the pad '
            'just above the ankle and adjust the thigh pad snugly above the knee.',
      ),
      SeedStep(
        'Curl the Hamstrings',
        'Curl the pad down and back as far as the hamstrings allow without '
            'lifting the hips from the seat.',
      ),
      SeedStep(
        'Extend Slowly',
        'Return the pad slowly under control until the leg is nearly straight, '
            'keeping the tension on the hamstrings.',
      ),
    ],
    cues: [
      SeedCue('Keep the hips glued to the seat for the whole set.'),
      SeedCue('Curl as far as you can without the stretch lifting the hips.'),
      SeedCue(
        'Do not use momentum or let the pad slam back.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Hamstrings', 'agonist', 80),
      SeedMuscle('Gastrocnemius', 'synergist', 20),
      SeedMuscle('Calves', 'stabilizer', 15),
    ],
  ),
  SeedExercise(
    id: 'ex18',
    name: 'Leg Extension',
    equipment: 'machine',
    movementClassification: 'isolation',
    imageAsset: _hero,
    description:
        'Knee extension isolation for the quadriceps. The hip is locked against '
        'the pad, so the quads are the only thing left to do the work.',
    steps: [
      SeedStep(
        'Set the Pad',
        'Sit back into the machine and position the roller pad just above the '
            'ankles, adjusting the seat so the knee pivot lines up with the '
            'machine hinge.',
      ),
      SeedStep(
        'Extend to Straight',
        'Extend the knees until the legs are straight and the quads are '
            'squeezed hard, keeping the hips down in the seat.',
      ),
      SeedStep(
        'Lower Under Control',
        'Lower the weight slowly to about 90 degrees of knee bend, stopping '
            'before the heel lifts off the floor.',
      ),
    ],
    cues: [
      SeedCue('Squeeze the quads hard at full extension and hold for a one-second count.'),
      SeedCue('Keep the hips pushed down into the seat for the whole set.'),
      SeedCue(
        'Do not swing the weight up — control it all the way back down.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Quadriceps', 'agonist', 85),
      SeedMuscle('Sartorius', 'synergist', 20),
      SeedMuscle('Calves', 'stabilizer', 10),
    ],
  ),
  SeedExercise(
    id: 'ex19',
    name: 'Standing Calf Raise',
    equipment: 'machine',
    movementClassification: 'isolation',
    imageAsset: _bench,
    description:
        'Loaded calf work that trains both the gastrocnemius and the deeper '
        'soleus. The machine allows a full stretch below the platform, which '
        'is where most of the growth happens.',
    steps: [
      SeedStep(
        'Position the Feet',
        'Step onto the platform with the balls of the feet, heels hanging off '
            'the edge and the toes pointing straight ahead.',
      ),
      SeedStep(
        'Rise to the Top',
        'Push through the balls of the feet and rise onto the toes as high as '
            'you can, squeezing the calves hard at the top.',
      ),
      SeedStep(
        'Sink to a Deep Stretch',
        'Lower the heels slowly below the level of the platform for a full '
            'stretch, then drive back up.',
      ),
    ],
    cues: [
      SeedCue('Pause for a full second at the top with the calves squeezed.'),
      SeedCue('Keep the knees straight for the gastrocnemius and the heels dropping low.'),
      SeedCue(
        'Do not bounce through the reps or roll onto the outside of the foot.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Gastrocnemius', 'agonist', 65),
      SeedMuscle('Soleus', 'synergist', 45),
      SeedMuscle('Tibialis Posterior', 'stabilizer', 20),
    ],
  ),
  SeedExercise(
    id: 'ex20',
    name: 'Cable Face Pull',
    equipment: 'cable',
    movementClassification: 'isolation',
    imageAsset: _bench,
    description:
        'A high-rep rear-delt and rotator-cuff movement that balances out all '
        'the pressing in a training week. Light weight and honest form matter '
        'far more than load here.',
    steps: [
      SeedStep(
        'Set the Rope',
        'Set the pulley at roughly face height and step back until the arms '
            'are stretched out in front with the palms facing back.',
      ),
      SeedStep(
        'Pull to the Face',
        'Pull the rope toward the forehead by rotating the upper arms outward, '
            'and spread the hands apart at the finish.',
      ),
      SeedStep(
        'Return Slowly',
        'Allow the arms to reach back out in front slowly, keeping the ribs '
            'down and the shoulders active.',
      ),
    ],
    cues: [
      SeedCue('Think about pulling the hands apart as you reach the end of the rep.'),
      SeedCue('Finish with the upper arms roughly level with the shoulders.'),
      SeedCue(
        'Do not shrug the shoulders up toward the ears.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Rear Deltoid', 'agonist', 55),
      SeedMuscle('Rotator Cuff', 'synergist', 45),
      SeedMuscle('Rhomboids', 'stabilizer', 30),
    ],
  ),
  SeedExercise(
    id: 'ex21',
    name: 'Hanging Leg Raise',
    equipment: 'bodyweight',
    movementClassification: 'isolation',
    imageAsset: _hero,
    description:
        'A hanging core drill that loads the lower abdominals and hip flexors '
        'while the lats hold you up. The hanging position removes all cheating '
        'support from the lower back.',
    steps: [
      SeedStep(
        'Hang and Tuck',
        'Hang from the bar with straight arms and pull the shoulder blades down '
            'before anything else moves.',
      ),
      SeedStep(
        'Lift the Legs',
        'Raise the legs together, curling the pelvis up so the lower back stays '
            'flat rather than arching.',
      ),
      SeedStep(
        'Lower with Control',
        'Let the legs descend slowly without swinging and without letting the '
            'lower back take over.',
      ),
    ],
    cues: [
      SeedCue('Curl the pelvis up at the top — that is what hits the lower abs.'),
      SeedCue('Keep the legs together and the movement slow and controlled.'),
      SeedCue(
        'Do not swing the legs — momentum takes the work straight off the abs.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Lower Abdominals', 'agonist', 70),
      SeedMuscle('Hip Flexors', 'synergist', 40),
      SeedMuscle('Lower Back', 'stabilizer', 25),
    ],
  ),
  SeedExercise(
    id: 'ex22',
    name: 'Russian Kettlebell Swing',
    equipment: 'other',
    movementClassification: 'compound',
    imageAsset: _bench,
    description:
        'A ballistic hinge that trains the glutes and hamstrings to produce '
        'power through the hips. The arms are only along for the ride — the '
        'force comes from the snap of the hips.',
    steps: [
      SeedStep(
        'Hinge and Reach',
        'Stand with the kettlebell in front of you, hinge at the hips and '
            'reach the arms down between the legs with a flat back.',
      ),
      SeedStep(
        'Snap the Hips',
        'Drive the hips forward sharply so the bell floats to chest height, '
            'letting the arms go along for the ride.',
      ),
      SeedStep(
        'Let It Float',
        'Let the bell swing back between the legs as the hips fold, keeping the '
            'lats engaged on the way down.',
      ),
    ],
    cues: [
      SeedCue('The power comes from snapping the hips, not from throwing the bell with the arms.'),
      SeedCue('Squeeze the glutes hard at the top of every swing.'),
      SeedCue(
        'Do not squat the weight up or round the back on the descent.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Glutes', 'agonist', 60),
      SeedMuscle('Hamstrings', 'synergist', 55),
      SeedMuscle('Latissimus Dorsi', 'stabilizer', 40),
    ],
  ),
  SeedExercise(
    id: 'ex23',
    name: 'Goblet Squat to Press',
    equipment: 'dumbbell',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'A leg press that finishes with an overhead press, pairing a lower-body '
        'pattern with a push in the same set. Efficient, satisfying and a '
        'great conditioning finisher.',
    steps: [
      SeedStep(
        'Hold the Goblet',
        'Hold one dumbbell vertically against the chest with both hands, '
            'elbows tucked in and the chest tall.',
      ),
      SeedStep(
        'Squat to Depth',
        'Squat down between the knees until the thighs are at least parallel, '
            'keeping the weight close to the body.',
      ),
      SeedStep(
        'Drive Up and Press',
        'Stand up powerfully and then press the dumbbell overhead, finishing '
            'with the arms straight.',
      ),
    ],
    cues: [
      SeedCue('Keep the weight racked at the chest until the legs are fully extended.'),
      SeedCue('Squat deep and drive up through the whole foot before pressing overhead.'),
      SeedCue(
        'Do not press the weight overhead from the bottom of the squat.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Quadriceps', 'agonist', 60),
      SeedMuscle('Glutes', 'synergist', 50),
      SeedMuscle('Deltoids', 'stabilizer', 35),
    ],
  ),
  SeedExercise(
    id: 'ex24',
    name: 'Alternating Snatch Burpee',
    equipment: 'other',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'A full-body conditioning movement that links a burpee to an overhead '
        'snatch on alternating sides. It builds engine, coordination and a '
        'serious appetite for hard circuits.',
    steps: [
      SeedStep(
        'Drop and Chest to Floor',
        'From standing, drop into a squat, plant the hands and kick the feet '
            'back into a plank.',
      ),
      SeedStep(
        'Jump and Snap',
        'Jump the feet back in, drive up and pull the dumbbell from the floor '
            'to an overhead lockout, switching sides each rep.',
      ),
      SeedStep(
        'Reset Under Control',
        'Lower the dumbbell back to the floor, reset the stance and repeat on '
            'the opposite side.',
      ),
    ],
    cues: [
      SeedCue('Fully extend the hips and knees on every jump so the feet land under the hips.'),
      SeedCue('Alternate sides so each shoulder does exactly the same amount of work.'),
      SeedCue(
        'Do not let the lower back sag while you are in the plank position.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Full Body', 'agonist', 55),
      SeedMuscle('Quadriceps', 'synergist', 45),
      SeedMuscle('Core', 'stabilizer', 40),
    ],
  ),
  SeedExercise(
    id: 'ex25',
    name: 'Dumbbell Chest Press',
    equipment: 'dumbbell',
    movementClassification: 'compound',
    imageAsset: _hero,
    description:
        'A flat dumbbell press that offers a freer range of motion than the '
        'barbell and lets each arm correct its own path. Much easier on the '
        'shoulders for most people.',
    steps: [
      SeedStep(
        'Set Up on the Bench',
        'Lie on a flat bench with the dumbbells resting on your thighs, then '
            'roll them up to the shoulders as your feet plant on the floor.',
      ),
      SeedStep(
        'Press to Lockout',
        'Press the dumbbells up and slightly together until the arms are '
            'straight and the weights are stacked over the chest.',
      ),
      SeedStep(
        'Lower to a Stretch',
        'Lower the dumbbells slowly to just below chest level with a soft bend '
            'in the elbows.',
      ),
    ],
    cues: [
      SeedCue('Bring the dumbbells close together at the top to finish the chest contraction.'),
      SeedCue('Keep the shoulder blades pulled down into the bench throughout the set.'),
      SeedCue(
        'Do not drop the weights below the chest or flare the elbows straight out.',
        isPositive: false,
      ),
    ],
    muscles: [
      SeedMuscle('Pectoralis Major', 'agonist', 70),
      SeedMuscle('Anterior Deltoid', 'synergist', 50),
      SeedMuscle('Triceps Brachii', 'stabilizer', 35),
    ],
  ),
];
