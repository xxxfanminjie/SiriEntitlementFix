#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static Class emptyCls;

static id emptyClassStub(id self, SEL _cmd) {
    NSLog(@"[SiriFix] Blocked class %@ selector %@", NSStringFromClass(self), NSStringFromSelector(_cmd));
    return nil;
}

%ctor {
    Class INPreferences = objc_getClass("INPreferences");
    Class INVocabulary = objc_getClass("INVocabulary");
    if(!INPreferences && !INVocabulary) return;

    emptyCls = objc_getClass("NSObject");

    if (INPreferences) {
        class_addMethod(INPreferences, @selector(resolveClassMethod:), (IMP)emptyClassStub, "c@::");
    }
    if (INVocabulary) {
        class_addMethod(INVocabulary, @selector(resolveClassMethod:), (IMP)emptyClassStub, "c@::");
    }
}
