// SiriEntitlementFix (Universal / 通用版)
//
// 作用：拦截任意进程对 INVocabulary 的 +alloc / -init 并返回 nil，
//       使缺少 com.apple.developer.siri 权限的 App 不再因 INVocabulary 初始化而闪退。
// 通用性：不绑定任何进程，由 LiveContainer 注入后对容器内所有 App 生效。
//
// 已声明限制：
//   - 拦截后，所有 App 的 Siri 快捷指令、自定义词汇功能失效（INVocabulary 无法创建）；
//   - 只拦截 INVocabulary，不触碰 INIntent、INRequest 等其他 Intents 类；
//   - 仅用于 LiveContainer 这类注入环境，仅个人学习研究。

#import <substrate.h>
#import <Foundation/Foundation.h>
#include <dlfcn.h>

// +alloc 是类方法，位于元类（metaclass）上，hook 时必须传 object_getClass(cls)
static id (*orig_INVocabulary_alloc)(Class, SEL);
static id hook_INVocabulary_alloc(Class self, SEL _cmd) {
    NSLog(@"[SiriEntitlementFix] Block INVocabulary +alloc, prevent entitlement crash");
    return nil;
}

// -init 是实例方法，防御性兜底：正常情况下 +alloc 已返回 nil，不会走到这里
static id (*orig_INVocabulary_init)(id, SEL);
static id hook_INVocabulary_init(id self, SEL _cmd) {
    NSLog(@"[SiriEntitlementFix] Block INVocabulary -init");
    return nil;
}

%ctor {
    Class cls = objc_getClass("INVocabulary");
    if (!cls) {
        // 保险：Intents framework 可能尚未加载，尝试主动加载
        dlopen("/System/Library/Frameworks/Intents.framework/Intents", RTLD_NOW);
        cls = objc_getClass("INVocabulary");
    }
    if (cls) {
        MSHookMessageEx(object_getClass(cls), @selector(alloc),
                        (IMP)hook_INVocabulary_alloc, (IMP *)&orig_INVocabulary_alloc);
        MSHookMessageEx(cls, @selector(init),
                        (IMP)hook_INVocabulary_init, (IMP *)&orig_INVocabulary_init);
        NSLog(@"[SiriEntitlementFix] Hook INVocabulary success (universal)");
    } else {
        NSLog(@"[SiriEntitlementFix] INVocabulary not found, skip");
    }
}
