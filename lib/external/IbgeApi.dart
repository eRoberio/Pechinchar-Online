import 'package:dio/dio.dart';
import 'package:pechinchar_online/models/IbgeApiModel.dart';


extension on String {
  normaLize() {
    return this.replaceAll(" ", "+");
  }
}

class IbgeApi {
  List<String> valorEstados = ["12", "27", "16", "13", "29", "23", "53", "32", "52", "21", "51",
    "50", "31", "15", "25", "41", "26", "22", "33", "24", "43", "11", "14", "42", "35", "28", "17"
  ];
  List<String> _listaEstados = ["AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT",
    "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"
  ];

  Future<List<IbgeApiModel>> getSearchEstado(String searchEstado) async {
    String? sigleEstado;
    for (int i = 0; i < _listaEstados.length; i++) {
      if (_listaEstados[i] == searchEstado) {
        sigleEstado = valorEstados[i];
        break;
      }
    }
    if (sigleEstado == null) {
      throw Exception('Estado não encontrado: $searchEstado');
    }

    final response = await Dio().get(
        "https://servicodados.ibge.gov.br/api/v1/localidades/estados/${sigleEstado.normaLize()}/municipios");
    if (response.statusCode == 200) {
      final list =
          (response.data as List).map((e) => IbgeApiModel.fromMap(e)).toList();
      return list;
    } else {
      throw Exception('Erro ao buscar municípios do estado: $searchEstado');
    }
  }
}