class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final List<DateTime> specificTimes;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.specificTimes,
  });
}
