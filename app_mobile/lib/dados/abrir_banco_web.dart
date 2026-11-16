import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

QueryExecutor abrirBanco() => LazyDatabase(() async {
      final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
      final sistema = await IndexedDbFileSystem.open(dbName: 'iceibank');
      sqlite.registerVirtualFileSystem(sistema, makeDefault: true);
      return WasmDatabase(sqlite3: sqlite, path: '/iceibank.db', fileSystem: sistema);
    });
