enum DetectionClasses {
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  H,
  I,
  J,
  K,
  L,
  M,
  N,
  O,
  P,
  Q,
  R,
  S,
  T,
  U,
  V,
  W,
  X,
  Y,
  Z,
  nothing
}

extension DetectionClassesExtension on DetectionClasses {
  String get label {
    switch (this) {
      case DetectionClasses.A:
        return "A";
      case DetectionClasses.B:
        return "B";
      case DetectionClasses.C:
        return "C";
      case DetectionClasses.D:
        return "D";
      case DetectionClasses.E:
        return "E";
      case DetectionClasses.F:
        return "F";
      case DetectionClasses.G:
        return "G";
      case DetectionClasses.H:
        return "H";
      case DetectionClasses.I:
        return "I";
      case DetectionClasses.J:
        return "J";
      case DetectionClasses.K:
        return "K";
      case DetectionClasses.L:
        return "L";
      case DetectionClasses.M:
        return "M";
      case DetectionClasses.N:
        return "N";
      case DetectionClasses.O:
        return "O";
      case DetectionClasses.P:
        return "P";
      case DetectionClasses.Q:
        return "Q";
      case DetectionClasses.R:
        return "R";
      case DetectionClasses.S:
        return "S";
      case DetectionClasses.T:
        return "T";
      case DetectionClasses.U:
        return "U";
      case DetectionClasses.V:
        return "V";
      case DetectionClasses.W:
        return "W";
      case DetectionClasses.X:
        return "X";
      case DetectionClasses.Y:
        return "Y";
      case DetectionClasses.Z:
        return "Z";
      case DetectionClasses.nothing:
        return "";
    }
  }
}
