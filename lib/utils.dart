import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HashGenerator {
  String geradorSha1Random(String key) {
    return sha1.convert(utf8.encode(key + DateTime.now().toString() + Random().nextInt(9999).toString())).toString();
  }
}

class FormatarConversoes {
  String formatCPFCNPJ(String valorData) {
    switch (valorData.length) {
      case 11:
        return valorData.substring(0, 3) + "." + valorData.substring(3, 6) + "." + valorData.substring(6, 9) + "." + valorData.substring(9, 11);
        break;

      case 14:
        return valorData.substring(0, 2) + "." + valorData.substring(2, 5) + "." + valorData.substring(5, 8) + "/" + valorData.substring(8, 12) + "-" + valorData.substring(12, 14);

        break;

      default:
        return throw Exception('A data não pode ser convertida. Implemente a conversão desejada');
    }
  }
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
