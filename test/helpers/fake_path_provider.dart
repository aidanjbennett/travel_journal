import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;
  FakePathProvider(this.tempPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;
}
