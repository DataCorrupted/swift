#import <Foundation/Foundation.h>
#import "ObjCDirectTest-Swift.h"

int main() {
  @autoreleasepool {
    Calculator *calc = [[Calculator alloc] initWithInitialValue:10];
    printf("init: %ld\n", (long)[calc getValue]);

    long r1 = [calc add:5];
    printf("add 5: %ld\n", r1);

    long r2 = [calc add:3];
    printf("add 3: %ld\n", r2);

    [calc reset];
    printf("reset\n");

    printf("getValue: %ld\n", (long)[calc getValue]);
  }
  return 0;
}
