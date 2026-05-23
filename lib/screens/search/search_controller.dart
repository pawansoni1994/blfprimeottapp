import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../routes/app_pages.dart';
import '../../core/widgets/voice_search_dialog.dart';

class SearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
  final RxList<String> searchHistory = <String>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
    // Listen to text changes
    searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    searchText.value = searchController.text;
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    super.onClose();
  }

  void loadSearchHistory() {
    final history = hiveManager.getStringList(
      HiveManager.searchHistoryKey,
      defaultValue: [],
    );
    // Reverse to show most recent first
    searchHistory.value = history.reversed.toList();
  }

  void addToHistory(String query) {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();
    final history = hiveManager.getStringList(
      HiveManager.searchHistoryKey,
      defaultValue: [],
    );

    // Remove if already exists (to avoid duplicates)
    history.remove(trimmedQuery);

    // Add to the beginning
    history.insert(0, trimmedQuery);

    // Keep only last 10 searches
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    // Save to Hive
    hiveManager.setStringList(HiveManager.searchHistoryKey, history);

    // Update observable
    loadSearchHistory();
  }

  void clearHistory() {
    hiveManager.setStringList(HiveManager.searchHistoryKey, []);
    searchHistory.clear();
    Utils.showToast('Search history cleared');
  }

  void removeFromHistory(String query) {
    final history = hiveManager.getStringList(
      HiveManager.searchHistoryKey,
      defaultValue: [],
    );
    history.remove(query);
    hiveManager.setStringList(HiveManager.searchHistoryKey, history);
    loadSearchHistory();
  }

  void performSearch(String query) {
    if (query.trim().isEmpty) {
      Utils.showToast('Please enter a search query');
      return;
    }

    addToHistory(query.trim());
    navigateToResults(query.trim());
  }

  void navigateToResults(String query) {
    Get.toNamed(
      '${AppRoutes.viewAll}?title=${Uri.encodeComponent('Search Results')}&search=${Uri.encodeComponent(query)}',
    );
  }

  void onHistoryItemTap(String query) {
    searchController.text = query;
    searchText.value = query;
    performSearch(query);
  }

  void startVoiceSearch(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VoiceSearchDialog(
        onResult: (searchText) {
          if (searchText.isNotEmpty) {
            searchController.text = searchText;
            this.searchText.value = searchText;
            performSearch(searchText);
          }
        },
      ),
    );
  }

  void clearSearch() {
    searchController.clear();
    searchText.value = '';
  }
}

