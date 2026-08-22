class Helper {
  final String uid;
  final String employeeId;
  final String name;
  final String status;
  final String? currentTaskId;

  Helper({
    required this.uid,
    required this.employeeId,
    required this.name,
    required this.status,
    this.currentTaskId,
  });

  factory Helper.fromMap(String uid, Map<String, dynamic> data) {
    return Helper(
      uid: uid,
      employeeId: (data['employeeId'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      status: (data['status'] ?? 'available').toString(),
      currentTaskId: data['currentTaskId']?.toString(),
    );
  }
}
