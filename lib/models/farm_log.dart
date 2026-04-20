class FarmLog {
  final DateTime date;
  final String actionType;
  final String cropName;
  final String note;

  const FarmLog({
    required this.date,
    required this.actionType,
    required this.cropName,
    required this.note,
  });
}
