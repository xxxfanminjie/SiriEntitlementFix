#import <substrate.h>
#import <Foundation/Foundation.h>

static void (*orig_objc_exception_throw)(id exception);

static void hook_objc_exception_throw(id exception) {
    if ([exception isKindOfClass:[NSException class]]) {
        NSString *reason = [(NSException *)exception reason];
        if (reason && [reason containsString:@"com.apple.developer.siri"]) {
            NSLog(@"[SiriFix] 捕获Siri权限异常，直接丢弃");
            return;
        }
    }
    orig_objc_exception_throw(exception);
}

%ctor {
    MSHookFunction((void *)dlsym(RTLD_NEXT, "objc_exception_throw"), (void *)hook_objc_exception_throw, (void **)&orig_objc_exception_throw);
}
