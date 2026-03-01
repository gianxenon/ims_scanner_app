 
import 'package:flutter_riverpod/legacy.dart';

class HomeDotNavigator extends StateNotifier<int> {
  HomeDotNavigator() : super(0);

  void updatePageIndicator(int index) {
    if (index != state) state = index; // same optimization
  }
}

final homeDotNavigatorProvider =
    StateNotifierProvider<HomeDotNavigator, int>(
  (ref) => HomeDotNavigator(),
);