import 'dart:async';
import 'dart:math';

class WebSocketService {
  final _controller = StreamController<String>.broadcast();
  Timer? _timer;

  Stream<String> get stream => _controller.stream;

  final List<String> _simulatedMessages = [
    "Chef uploaded a new Carbonara recipe!",
    "New 5-star review received for Aglio Olio.",
    "Recipe likes updated: 1500 people love Spicy Arrabbiata.",
    "Trending: Creamy Garlic Pasta is the dish of the day!",
    "User 'PastaLover99' just saved your recipe.",
    "Alert: Tomato prices are down, time for al Pomodoro!",
  ];

  final _random = Random();

  void connect() {
    _controller.add("Connected to live recipe stream...");

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final randomMessage =
          _simulatedMessages[_random.nextInt(_simulatedMessages.length)];
      _controller.add(randomMessage);
    });
  }

  void disconnect() {
    _timer?.cancel();
    _controller.add("Disconnected from stream.");
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
