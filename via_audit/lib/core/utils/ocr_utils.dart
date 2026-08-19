class OcrUtils {
  /// Regex para validação estrita do patrimônio Via Education: V seguido de exatamente 6 dígitos (ex: V000026, V018922)
  static final RegExp patrimonioRegex = RegExp(r'V\d{6}', caseSensitive: false);

  /// Extrai o código de patrimônio V000000 do texto ou lê o padrão esperado
  static String? extractPatrimonioCode(String text) {
    final match = patrimonioRegex.firstMatch(text);
    if (match != null) {
      return match.group(0)?.toUpperCase();
    }
    return null;
  }
}
