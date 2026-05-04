extension TimingHelper on Duration {
  String toMillisecondsText() {
    return duration.totalMilliseconds.toString(
      "F2",
      CultureInfo.invariantCulture,
    );
  }
}
