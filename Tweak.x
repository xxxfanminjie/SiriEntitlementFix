// SiriEntitlementFix (Universal / 通用版)
// 纯 Objective-C 运行时实现：不依赖 CydiaSubstrate，LiveContainer 可直接 dlopen。
// 作用：拦截任意进程对 INVocabulary 的 +alloc / -init 并返回 nil，
// 使缺少 com.apple.developer.siri 权限的 App 不再因 INVocabulary 初始化而闪退。
// 通用性：不绑定任何进程，由 LiveContainer 注入后对容器内所有 App 生效。
// 限制：Siri 快捷指令/自定义词汇功能失效；只拦 INVocabulary；仅 LiveContainer 注入环境、仅个人学习研究。

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <objc/runtime.h>

static id hook_INVocabulary_alloc(id self, SEL _cmd) {
    NSLog(@"[SiriEntitlementFix] Block INVocabulary alloc");
    return nil;
}

static id hook_INVocabulary_init(id self, SEL _cmd) {
    NSLog(@"[SiriEntitlementFix] Block INVocabulary init");
    return nil;
}

__attribute__((constructor))
static void SiriEntitlementFixInit(void) {
    Class cls = objc_getClass("INVocabulary");
    if (!cls) {
        dlopen("/System/Library/Frameworks/Intents.framework/Intents", RTLD_NOW);
        cls = objc_getClass("INVocabulary");
    }
    if (!cls) return;

    // +alloc 是类方法（即元类的实例方法）：挂在元类上，只影响 INVocabulary 自身
    Class meta = object_getClass(cls);
    Method mAlloc = class_getInstanceMethod(meta, @selector(alloc));
    if (mAlloc) {
        const char *types = method_getTypeEncoding(mAlloc);
        if (!class_addMethod(meta, @selector(alloc), (IMP)hook_INVocabulary_alloc, types)) {
            class_replaceMethod(meta, @selector(alloc), (IMP)hook_INVocabulary_alloc, types);
        }
    }

    // -init 是实例方法：挂在类上
    Method mInit = class_getInstanceMethod(cls, @selector(init));
    if (mInit) {
        const char *types = method_getTypeEncoding(mInit);
        if (!class_addMethod(cls, @selector(init), (IMP)hook_INVocabulary_init, types)) {
            class_replaceMethod(cls, @selector(init), (IMP)hook_INVocabulary_init, types);
        }
    }

    NSLog(@"[SiriEntitlementFix] Hook INVocabulary success (runtime swizzle)");
}
