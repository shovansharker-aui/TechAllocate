class Machine {
  final String id;
  final String equipmentId;
  final String equipmentName;
  final String brand;
  final String category; // 'Engineering' | 'Production' | 'Warehouse'

  Machine({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.brand,
    required this.category,
  });

  factory Machine.fromMap(String id, Map<String, dynamic> data) {
    return Machine(
      id: id,
      equipmentId: data['equipmentId'] ?? '',
      equipmentName: data['equipmentName'] ?? '',
      brand: data['brand'] ?? '',
      category: data['category'] ?? 'Production',
    );
  }
}
