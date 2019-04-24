#import "RNHeapInit.h"
#import <Foundation/Foundation.h>
#import "Heap.h"

@implementation RNHeapInit

+ (void)load {
    NSBundle *heapBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HeapSettings.bundle"]];
    NSString *heapPlistPath = [heapBundle pathForResource:@"HeapSettings" ofType:@"plist"];
    NSDictionary *heapPlistData = [NSDictionary dictionaryWithContentsOfFile:heapPlistPath];
    NSString *heapAppId = heapPlistData[@"HeapAppId"];

    NSLog(@"Auto-initializing the Heap library with app ID %@.", heapAppId);
    
    SEL setRootUrlSelector = @selector(setRootUrl:);
    if ([[Heap class] respondsToSelector:setRootUrlSelector]) {
        [[Heap class] performSelector:setRootUrlSelector withObject:@"http://localhost:3000"];
    }
    
    // Set timer interval shorter so tests complete in a reasonable amount of time!
    SEL changeIntervalSelector = @selector(changeInterval:);
    if ([[Heap class] respondsToSelector:changeIntervalSelector]) {
        [[Heap class] performSelector:changeIntervalSelector withObject:@1.0];
    }
    
    [Heap setAppId:heapAppId];
}

@end
