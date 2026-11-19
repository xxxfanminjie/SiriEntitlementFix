#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static void swizzle(Class cls, SEL origSel, SEL newSel) {
    Method orig = class_getInstanceMethod(cls, origSel);
    Method new = class_getInstanceMethod(cls, newSel);
    if (orig && new) {
        method_exchangeImplementations(orig, new);
    }
}

static void swizzleClass(Class cls, SEL origSel, SEL newSel) {
    Method orig = class_getClassMethod(cls, origSel);
    Method new = class_getClassMethod(cls, newSel);
    if (orig && new) {
        method_exchangeImplementations(orig, new);
    }
}

@interface INPreferences : NSObject
@end

@implementation INPreferences (SiriFix)
+ (id)fix_alloc {
    NSLog(@"[SiriFix] Block INPreferences alloc");
    return nil;
}
@end

@interface INVocabulary : NSObject
@end

@implementation INVocabulary (SiriFix)
+ (id)fix_alloc {
    NSLog(@"[SiriFix] Block INVocabulary alloc");
    return nil;
}
@end

%ctor {
    Class clzPref = objc_getClass("INPreferences");
    Class clzVoc = objc_getClass("INVocabulary");
    if(clzPref) {
        swizzleClass(clzPref, @selector(alloc), @selector(fix_alloc));
    }
    if(clzVoc) {
        swizzleClass(clzVoc, @selector(alloc), @selector(fix_alloc));
    }
}
