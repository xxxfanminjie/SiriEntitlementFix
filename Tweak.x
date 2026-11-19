#import <substrate.h>
#import <Foundation/Foundation.h>
#include <dlfcn.h>
// 补上 RTLD_NEXT 定义
#ifndef RTLD_NEXT
#define RTLD_NEXT ((void *)-1)
#endif

static void (*orig_objc_exception_throw)(id exception);

static void hook_objc_exception_throw(id exception) {
    if ([exception isKindOfClass:[NSException class]]) {
        NSString *reason = [(NSException *)exception reason];
        if (reason && [reason containsString:@"com.apple.developer.siri"]) {
            NSLog(@"[SiriFix] Catch Siri entitlement exception, dropped");
            return;
        }
    }
    orig_objc_exception_throw(exception);
}

%ctor {
    void *sym = dlsym(RTLD_NEXT, "objc_exception_throw");
    if (sym) {
        MSHookFunction(sym, (void *)hook_objc_exception_throw, (void **)&orig_objc_exception_throw);
    }
}
