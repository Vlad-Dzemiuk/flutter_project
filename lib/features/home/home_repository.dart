abstract class HomeRepository {
  Future<String> fetchWelcomeMessage();
}

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<String> fetchWelcomeMessage() async {
    // Тут пізніше буде виклик API
    await Future.delayed(const Duration(seconds: 1));
    return 'Welcome to Movie Discovery App!';
  }
}
