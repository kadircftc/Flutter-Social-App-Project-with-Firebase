class NumberFormatFor {
  String likeFormat(int number) {
    if (number >= 1000) {
      final parts = number.toString().split('');
      final length = parts.length;
      final formattedParts = <String>[];

      for (int i = 0; i < length; i++) {
        formattedParts.add(parts[i]);

        if ((length - i - 1) % 3 == 0 && i != length - 1) {
          formattedParts.add('.');
        }
      }

      return formattedParts.join('');
    }

    return number.toString();
  }
}
