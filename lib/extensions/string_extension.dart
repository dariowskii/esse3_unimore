extension on String {
  String get camelCase {
    var result = '';

    for (var i = 0; i < length; i++) {
      if (i == 0) {
        result += this[i].toUpperCase();
        continue;
      }

      if (this[i] == ' ') {
        i++;
        result += ' ';
        result += this[i].toUpperCase();
      } else {
        result += this[i];
      }
    }

    return result;
  }
}
