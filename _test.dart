var a = 1;
var temp;

for (var b = 1; a < 10000; b = temp + b) {
  print a;
  temp = a;
  a = b;
  if(a == 8) {
    break;
  }
}