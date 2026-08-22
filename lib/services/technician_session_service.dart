import 'package:shared_preferences/shared_preferences.dart';

class TechnicianSessionService {
  // The name is kept for compatibility with the existing project, but this
  // now stores the logged-in user's Firestore document ID for both admins and
  // technicians.
  static const _key = 'employee_user_doc_id';

  Future<void> saveUserId(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, docId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Compatibility methods for any old code that may still call these names.
  Future<void> saveTechnicianId(String docId) => saveUserId(docId);

  Future<String?> getTechnicianId() => getUserId();
}
