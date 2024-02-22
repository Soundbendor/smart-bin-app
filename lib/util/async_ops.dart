/// Run a function asynchronously as soon as possible.
///
/// This is useful for running functions that change state during the build phase.
void runSoon(Function() fn) {
  Future.delayed(Duration.zero, fn);
}
