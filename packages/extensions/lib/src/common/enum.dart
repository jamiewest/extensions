// Mixin to create Enum for bitflags uses.
mixin EnumFlags on Enum {
  // value receive a bitwise shift operation. It means "shift the
  // bits of 1 to the left by index places".
  //
  //So,  "1,10,100,1000..." == 1,2,4,8,16....
  int get value => 1 << index;
  // Creates a operator "|" for enum.
  int operator |(other) => value | other.value;

  int operator &(other) => value & other.value;

  int operator ^(other) => value ^ other.value;
}

// Extension "int" to verify that value contains the enum flag.
extension EnumFlagsExtension on int {
  bool hasFlag(EnumFlags flag) => this & flag.value == flag.value;
}

void main() {
  final x = Car.ford | Car.honda;
  print(x);
  print(x.hasFlag(Car.honda));
  final y = Car.ford & Car.subaru;
  print(y);
  print(y.hasFlag(Car.ford));
}

enum Car with EnumFlags {
  ford,
  honda,
  subaru,
}
