#import <substrate.h>
#import <Foundation/Foundation.h>

static id (*orig_INVocabulary_alloc)(Class, SEL);
static id hook_INVocabulary_alloc(Class self, SEL _cmd)
{
    NSLog(@"[SiriEntitlementFix] Block INVocabulary alloc");
    return nil;
}

static id (*orig_INPreferences_alloc)(Class, SEL);
static id hook_INPreferences_alloc(Class self, SEL _cmd)
{
    NSLog(@"[SiriEntitlementFix] Block INPreferences alloc");
    return nil;
}

%ctor
{
    Class cls_INVocabulary = objc_getClass("INVocabulary");
    if (cls_INVocabulary)
    {
        MSHookMessageEx(cls_INVocabulary, @selector(alloc), (IMP)hook_INVocabulary_alloc, (IMP *)&orig_INVocabulary_alloc);
    }

    Class cls_INPreferences = objc_getClass("INPreferences");
    if (cls_INPreferences)
    {
        MSHookMessageEx(cls_INPreferences, @selector(alloc), (IMP)hook_INPreferences_alloc, (IMP *)&orig_INPreferences_alloc);
    }
}
