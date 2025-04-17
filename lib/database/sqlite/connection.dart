import 'dart:async';
import 'package:milkroute_tecnico/database/sqlite/scriptClearTables.dart';
import 'package:milkroute_tecnico/database/sqlite/scriptCreateTables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:milkroute_tecnico/constants.dart';

class Connection {
  static final int _dbVersion = 0;
  static Database? _db;

  // Construtor privado para garantir que a classe siga o padrão Singleton.
  Connection._privateConstructor();

  // Método para obter a instância do banco de dados.
  static Future<Database?> get() async {
    try {
      if (_db != null) {
        return _db;
      } else if (_db == null) {
        // Define o caminho do banco de dados.
        var path = join(await getDatabasesPath(), dbName);

        // Abre ou cria o banco de dados, executando os scripts de criação de tabelas.
        _db = await openDatabase(
          path,
          version: _dbVersion,
          onCreate: (Database db, int version) async {
            // Executa o script de criação de tabelas definido em `scriptCreateTables.dart`.
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
            await db.execute('');
          },
        );
      }
      return _db;
    } catch (ex) {
      print("--> ERRO NA CRIAÇÃO DO DB <--");
      throw Exception('Erro na Criação do Banco de Dados: ${ex.toString()}');
    }
  }

  // Método para limpar as tabelas do banco de dados.
  static Future<void> clearDB() async {
    try {
      if (_db != null) {
        // Executa o script de limpeza de tabelas definido em `scriptClearTables.dart`.
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');
        await _db?.execute('');

        await _db?.close();
        _db = null;

        var path = join(await getDatabasesPath(), dbName);
        await deleteDatabase(path);
      }
    } catch (ex) {
      print("--> ERRO NA LIMPEZA DO DB <--");
      throw Exception('Erro na Limpeza do Banco de Dados: ${ex.toString()}');
    }
  }
}
