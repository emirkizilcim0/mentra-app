// lib/pages/home/home_logic_loader.dart
import 'package:mentra_app/services/dairy/dairy_service.dart';
import 'data_processor.dart';

class HomeLogicLoader {
  static Future<Map<String, dynamic>> load() async {
    final entries = await DiaryService.getDiaryEntries();
    final analyses = await DiaryService.getAnalysisHistory();

    final p = DataProcessor.processAnalyses(analyses);
    final d = DataProcessor.processEntries(entries, p);

    return {'days': d, 'percents': p};
  }
}
