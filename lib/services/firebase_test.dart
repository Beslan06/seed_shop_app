import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<void> testFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection')
          .set({
        'message': 'Тест подключения',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Firestore тест записан успешно!');
    } catch (e) {
      print('❌ Ошибка Firestore: $e');
    }
  }
}
