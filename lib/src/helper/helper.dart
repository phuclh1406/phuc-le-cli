abstract class Helper {
  const Helper();

  Future<void> init() async {
    await onInit();
    // logInfo("Initialized ${runtimeType.toString()}");
  }

  Future<void> onInit();
}
