extension StringExtension on String {
  String camelCase() {
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

  String cleanFromEntities() {
    var result = this;

    final regex = RegExp('&(.*?);');
    for (final match in regex.allMatches(this)) {
      result = result.replaceFirst(match.group(0)!, ' ');
    }

    return result;
  }
}
