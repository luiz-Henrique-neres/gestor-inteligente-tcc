class Assinatura {
  final String id;
  final String nome;
  final String categoria;
  final double valor;
  final String vencimento;
  final bool ativa;

  Assinatura({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.valor,
    required this.vencimento,
    required this.ativa,
  });

  factory Assinatura.fromJson(Map<String, dynamic> json) {
    return Assinatura(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      categoria: json['categoria'] ?? '',
      valor: (json['valor'] as num).toDouble(),
      vencimento: json['vencimento'] ?? '',
      ativa: json['ativa'] ?? true,
    );
  }
}
