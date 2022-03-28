//
// Created by Milker on 2019-03-04.
// Copyright (c) 2019 lanjingren. All rights reserved.
//

#import "JDHotfix.h"
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <Aspects/Aspects.h>

static JDHotfix *fixManager = nil;

@interface JDHotfix()

@property(nonatomic, copy)JSContext *context;

@end

@implementation JDHotfix

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fixManager = [[JDHotfix alloc] init];
    });
    return fixManager;
}
- (instancetype)init {
    if(self = [super init]) {
        [self setup];
    }
    return self;
}
- (JSContext *)context {
    if(!_context) {
        _context = [[JSContext alloc] init];
        _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"Ohooo: %@",exception);
        };
    }
    return _context;
}
- (void)fix:(NSString *)js {
    [self.context evaluateScript:js];
}

- (void)fixAtPath:(NSString *)path {
    NSString *js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self fix:js];
}

#pragma mark- 初始化js方法
- (void)setup {
   
    __weak typeof(self) wkself = self;
    self.context[@"fixInstanceMethodBefore"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:NO aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    [self context][@"fixInstanceMethodReplace"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:NO aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    [self context][@"fixInstanceMethodAfter"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:NO aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    [self context][@"fixClassMethodBefore"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:YES aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    [self context][@"fixClassMethodReplace"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:YES aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    [self context][@"fixClassMethodAfter"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:YES aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    [self context][@"runClassWithNoParamter"] = ^id(NSString *className, NSString *selectorName) {
        return [wkself runClassWithClassName:className selector:selectorName obj1:nil obj2:nil];
    };
    [self context][@"runClassWith1Paramter"] = ^id(NSString *className, NSString *selectorName, id obj1) {
        return [wkself runClassWithClassName:className selector:selectorName obj1:obj1 obj2:nil];
    };
    [self context][@"runClassWith2Paramters"] = ^id(NSString *className, NSString *selectorName, id obj1, id obj2) {
        return [wkself runClassWithClassName:className selector:selectorName obj1:obj1 obj2:obj2];
    };
    [self context][@"runVoidClassWithNoParamter"] = ^(NSString *className, NSString *selectorName) {
        [wkself runClassWithClassName:className selector:selectorName obj1:nil obj2:nil];
    };
    [self context][@"runVoidClassWith1Paramter"] = ^(NSString *className, NSString *selectorName, id obj1) {
        [wkself runClassWithClassName:className selector:selectorName obj1:obj1 obj2:nil];
    };
    [self context][@"runVoidClassWith2Paramters"] = ^(NSString *className, NSString *selectorName, id obj1, id obj2) {
        [wkself runClassWithClassName:className selector:selectorName obj1:obj1 obj2:obj2];
    };
    [self context][@"runInstanceWithNoParamter"] = ^id(id instance, NSString *selectorName) {
        return [wkself runInstanceWithInstance:instance selector:selectorName obj1:nil obj2:nil];
    };
    [self context][@"runInstanceWith1Paramter"] = ^id(id instance, NSString *selectorName, id obj1) {
        return [wkself runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:nil];
    };
    [self context][@"runInstanceWith2Paramters"] = ^id(id instance, NSString *selectorName, id obj1, id obj2) {
        return [wkself runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:obj2];
    };
    [self context][@"runVoidInstanceWithNoParamter"] = ^(id instance, NSString *selectorName) {
        [wkself runInstanceWithInstance:instance selector:selectorName obj1:nil obj2:nil];
    };
    [self context][@"runVoidInstanceWith1Paramter"] = ^(id instance, NSString *selectorName, id obj1) {
        [wkself runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:nil];
    };
    [self context][@"runVoidInstanceWith2Paramters"] = ^(id instance, NSString *selectorName, id obj1, id obj2) {
        [wkself runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:obj2];
    };
    [self context][@"runInvocation"] = ^id(NSInvocation *invocation) {
        [invocation invoke];
        if (invocation.methodSignature.methodReturnLength) {
            return [self getReturnValue:invocation];
        }
        return nil;
    };
    [self context][@"setInvocationParameter"] = ^(NSInvocation *invocation, id value, NSInteger index) {
        [self setArgument:invocation value:value index:index + 2];
        [invocation retainArguments];
    };
    [[self context] evaluateScript:@"var console = {}"];
    [self context][@"console"][@"log"] = ^(id message) {
        printf("HotFix:%s\n", [message UTF8String]);
    };
    
    ////新hotfix API
    self.context[@"runInstanceMethod"] = ^(id instance, NSString *selectorName, NSArray* arguments) {
        return [wkself runInstanceWithInstance:instance selector:selectorName arguments:arguments];
    };
    self.context[@"runClassMethod"] = ^(NSString *className, NSString *selectorName, NSArray* arguments) {
        return [wkself runClassWithClassName:className selector:selectorName arguments:arguments];
    };
    self.context[@"fixMethodBefore"] = ^(NSString *instanceName, BOOL isClsMethod, NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:isClsMethod aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    [self context][@"fixMethodReplace"] = ^(NSString *instanceName, BOOL isClsMethod, NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:isClsMethod aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    [self context][@"fixeMethodAfter"] = ^(NSString *instanceName, BOOL isClsMethod,NSString *selectorName, JSValue *fixImpl) {
        [wkself fixWithMethod:isClsMethod aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
}

# pragma mark Fix Method
- (void)fixWithMethod:(BOOL)isClassMethod aspectionOptions:(AspectOptions)option instanceName:(NSString *)instanceName selectorName:(NSString *)selectorName fixImpl:(JSValue *)fixImpl {
    Class klass = NSClassFromString(instanceName);
    if (isClassMethod) {
        klass = object_getClass(klass);
    }
    SEL sel = NSSelectorFromString(selectorName);
    [klass aspect_hookSelector:sel withOptions:option usingBlock:^(id<AspectInfo> aspectInfo){
        JSValue *returnV = [fixImpl callWithArguments:@[aspectInfo.instance, aspectInfo.originalInvocation, aspectInfo.arguments]];
        if (aspectInfo.originalInvocation.methodSignature.methodReturnLength > 0) {
            [self setReturnValue:aspectInfo.originalInvocation value:returnV];
        }
    } error:nil];
}

- (id)runClassWithClassName:(NSString *)className selector:(NSString *)selector obj1:(id)obj1 obj2:(id)obj2 {
    Class class = NSClassFromString(className);
    SEL method = NSSelectorFromString(selector);
    if ([class.class respondsToSelector:method]) {
        NSMethodSignature *signature = [class.class methodSignatureForSelector:method];
        return [self invocationValueForSignature:signature target:class.class sel:method obj1:obj1 obj2:obj2];
    }
    return nil;
}

- (id)runClassWithClassName:(NSString *)className selector:(NSString *)selector arguments:(NSArray *)arguments {
    Class class = NSClassFromString(className);
    SEL method = NSSelectorFromString(selector);
    if ([class.class respondsToSelector:method]) {
        NSMethodSignature *signature = [class.class methodSignatureForSelector:method];
        return [self invocationValueForSignature:signature target:class.class sel:method arguments:arguments];
    };
    return nil;
}

- (id)runInstanceWithInstance:(id)instance selector:(NSString *)selector obj1:(id)obj1 obj2:(id)obj2 {
    SEL method = NSSelectorFromString(selector);
    if ([instance respondsToSelector:method]) {
        NSMethodSignature *signature = [[instance class] instanceMethodSignatureForSelector:method];
        return [self invocationValueForSignature:signature target:instance sel:method obj1:obj1 obj2:obj2];
    }
    return nil;
}

- (id)runInstanceWithInstance:(id)instance selector:(NSString *)selector arguments:(NSArray *)arguments {
    SEL method = NSSelectorFromString(selector);
    if ([instance respondsToSelector:method]) {
        NSMethodSignature *signature = [[instance class] instanceMethodSignatureForSelector:method];
        return [self invocationValueForSignature:signature target:instance sel:method arguments:arguments];
    }
    return nil;
}

- (id)invocationValueForSignature:(NSMethodSignature *)signature target:(id)instance sel:(SEL)method obj1:(id)obj1 obj2:(id)obj2 {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:instance];
    [invocation setSelector:method];
    if (obj1) {
       invocation = [self invocation:invocation signature:signature configArgum:obj1 atIndex:2];
    }
    if (obj2) {
       invocation = [self invocation:invocation signature:signature configArgum:obj2 atIndex:3];
    }
    [invocation invoke];
    
    char returnType[255];
    strcpy(returnType, [signature methodReturnType]);
    
    if (strcmp(returnType, @encode(void)) == 0) {
       return nil;
    }

    __unsafe_unretained id returnValue;
    switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
        #define MPHotFixReturnCase(_typeString, _type) \
        case _typeString: {                              \
            _type tempResultSet; \
            [invocation getReturnValue:&tempResultSet];\
            returnValue = @(tempResultSet); \
            break; \
        }
        MPHotFixReturnCase('c', char)
        MPHotFixReturnCase('C', unsigned char)
        MPHotFixReturnCase('s', short)
        MPHotFixReturnCase('S', unsigned short)
        MPHotFixReturnCase('i', int)
        MPHotFixReturnCase('I', unsigned int)
        MPHotFixReturnCase('l', long)
        MPHotFixReturnCase('L', unsigned long)
        MPHotFixReturnCase('q', long long)
        MPHotFixReturnCase('Q', unsigned long long)
        MPHotFixReturnCase('f', float)
        MPHotFixReturnCase('d', double)
        MPHotFixReturnCase('B', BOOL)
        case '{': {
            NSString *typeString = mp_destructionStructtName([NSString stringWithUTF8String:returnType]);
            #define MPHotFixReturnStruct(_type, _methodName) \
            if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                _type result;   \
                [invocation getReturnValue:&result];    \
                return [JSValue _methodName:result inContext:_context];    \
            }
            MPHotFixReturnStruct(CGRect, valueWithRect)
            MPHotFixReturnStruct(CGPoint, valueWithPoint)
            MPHotFixReturnStruct(CGSize, valueWithSize)
            MPHotFixReturnStruct(NSRange, valueWithRange)
            break;
        }
        default: {
            void *pointer;
            [invocation getReturnValue:&pointer];
             returnValue = (__bridge id)pointer;
            break;
        }
    }
    return returnValue;
}

- (id)invocationValueForSignature:(NSMethodSignature *)signature target:(id)instance sel:(SEL)method arguments:(NSArray *)arguments {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:instance];
    [invocation setSelector:method];
    if (signature.numberOfArguments != arguments.count+2) {
        return nil;
    }
    for (NSInteger i = 0; i < arguments.count; i++) {
        id arg = arguments[i];
        if (![arg isKindOfClass:[NSNull class]]) {
            [self invocation:invocation signature:signature configArgum:arg atIndex:i+2];
        }
        
    }
    [invocation invoke];
    
    char returnType[255];
    strcpy(returnType, [signature methodReturnType]);
    
    if (strcmp(returnType, @encode(void)) == 0) {
       return nil;
    }

    __unsafe_unretained id returnValue;
    switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
        #define MPHotFixReturnCase(_typeString, _type) \
        case _typeString: {                              \
            _type tempResultSet; \
            [invocation getReturnValue:&tempResultSet];\
            returnValue = @(tempResultSet); \
            break; \
        }
        MPHotFixReturnCase('c', char)
        MPHotFixReturnCase('C', unsigned char)
        MPHotFixReturnCase('s', short)
        MPHotFixReturnCase('S', unsigned short)
        MPHotFixReturnCase('i', int)
        MPHotFixReturnCase('I', unsigned int)
        MPHotFixReturnCase('l', long)
        MPHotFixReturnCase('L', unsigned long)
        MPHotFixReturnCase('q', long long)
        MPHotFixReturnCase('Q', unsigned long long)
        MPHotFixReturnCase('f', float)
        MPHotFixReturnCase('d', double)
        MPHotFixReturnCase('B', BOOL)
        case '{': {
            NSLog([NSString stringWithUTF8String:returnType]);
            NSString *typeString = mp_destructionStructtName([NSString stringWithUTF8String:returnType]);
            #define MPHotFixReturnStruct(_type, _methodName) \
            if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                _type result;   \
                [invocation getReturnValue:&result];    \
                return [JSValue _methodName:result inContext:_context];    \
            }
            MPHotFixReturnStruct(CGRect, valueWithRect)
            MPHotFixReturnStruct(CGPoint, valueWithPoint)
            MPHotFixReturnStruct(CGSize, valueWithSize)
            MPHotFixReturnStruct(NSRange, valueWithRange)
            break;
        }
        default: {
            void *pointer;
            [invocation getReturnValue:&pointer];
             returnValue = (__bridge id)pointer;
            break;
        }
    }
    return returnValue;

}

- (NSInvocation *)invocation:(NSInvocation *)invocation signature:(NSMethodSignature *)signature configArgum:(id)object atIndex:(NSInteger)index {
    const char *objectType = [signature getArgumentTypeAtIndex:index];
    switch (objectType[0] == 'r' ? objectType[1] : objectType[0]) {
            #define MPHotFixArgCase(_typeString, _type, _selector) \
            case _typeString: {                              \
                _type value = [object _selector];                     \
                [invocation setArgument:&value atIndex:index];\
                break; \
            }
            MPHotFixArgCase('c', char, charValue)
            MPHotFixArgCase('C', unsigned char, unsignedCharValue)
            MPHotFixArgCase('s', short, shortValue)
            MPHotFixArgCase('S', unsigned short, unsignedShortValue)
            MPHotFixArgCase('i', int, intValue)
            MPHotFixArgCase('I', unsigned int, unsignedIntValue)
            MPHotFixArgCase('l', long, longValue)
            MPHotFixArgCase('L', unsigned long, unsignedLongValue)
            MPHotFixArgCase('q', long long, longLongValue)
            MPHotFixArgCase('Q', unsigned long long, unsignedLongLongValue)
            MPHotFixArgCase('f', float, floatValue)
            MPHotFixArgCase('d', double, doubleValue)
            MPHotFixArgCase('B', BOOL, boolValue)
        case '{': {
            JSValue *jsValue = [JSValue valueWithObject:object inContext:_context];
            NSString *typeString = mp_destructionStructtName([NSString stringWithUTF8String:objectType]);
            #define MPHotFixArguStruct(_type, _methodName) \
            if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                _type value = [jsValue _methodName];  \
                [invocation setArgument:&value atIndex:index];  \
                break; \
            }
            MPHotFixArguStruct(CGRect, toRect)
            MPHotFixArguStruct(CGPoint, toPoint)
            MPHotFixArguStruct(CGSize, toSize)
            MPHotFixArguStruct(NSRange, toRange)
            break;
        }
        default: {
            [invocation setArgument:&object atIndex:index];
            break;
        }
    }
    return invocation;
}


// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html

- (void)setReturnValue:(NSInvocation *)invocation value:(JSValue *)v {
    const char *type = invocation.methodSignature.methodReturnType;
    if (!strcmp(type, @encode(float))) {
        float rv = [v.toNumber floatValue];
        [invocation setReturnValue:&rv];
    } else if (!strcmp(type, @encode(BOOL))) {
        BOOL rv = [v.toNumber boolValue];
        [invocation setReturnValue:&rv];
    } else if (!strcmp(type, @encode(int)) || !strcmp(type, @encode(unsigned int))) {
        int rv = [v.toNumber intValue];
        [invocation setReturnValue:&rv];
    } else if (!strcmp(type, @encode(long)) || !strcmp(type, @encode(unsigned long))) {
        long rv = [v.toNumber longValue];
        [invocation setReturnValue:&rv];
    } else if (!strcmp(type, @encode(short)) || !strcmp(type, @encode(unsigned short))) {
        short rv = [v.toNumber shortValue];
        [invocation setReturnValue:&rv];
    } else if (!strcmp(type, @encode(char)) || !strcmp(type, @encode(unsigned char))) {
        char rv = [v.toNumber charValue];
        [invocation setReturnValue:&rv];
    } else if (!strcmp(type, @encode(long long)) || !strcmp(type, @encode(unsigned long long))) {
        long long rv = [v.toNumber longLongValue];
        [invocation setReturnValue:&rv];
    } else if (!strcmp(type, @encode(double))) {
        double rv = [v.toNumber doubleValue];
        [invocation setReturnValue:&rv];
    } else if (!strcmp(type, @encode(Class))) {
        Class clazz;
        if (v.isString) {
            clazz = NSClassFromString(v.toString);
        } else {
            clazz = v.toObject;
        }
        [invocation setReturnValue:&clazz];
    } else /*if (!strcmp(type, @encode(id)))*/ {
        id rv = [v toObject];
        [invocation setReturnValue:&rv];
    } /*else if (!strcmp(type, @encode(Class))) {
        Class rv = [v toObject];
        [invocation setReturnValue:&rv];
    }*/
}

- (void)setArgument:(NSInvocation *)invocation value:(id)v index:(NSInteger)index {
    const char *type = [invocation.methodSignature getArgumentTypeAtIndex:index];
    if (!strcmp(type, @encode(float))) {
        if ([v isKindOfClass:NSNumber.class]) {
            float rv = [(NSNumber *)v floatValue];
            [invocation setArgument:&rv atIndex:index];
        }
    } else if (!strcmp(type, @encode(BOOL))) {
        if ([v isKindOfClass:NSNumber.class]) {
            BOOL rv = [(NSNumber *)v boolValue];
            [invocation setArgument:&rv atIndex:index];
        }
    } else if (!strcmp(type, @encode(int)) || !strcmp(type, @encode(unsigned int))) {
        if ([v isKindOfClass:NSNumber.class]) {
            int rv = [(NSNumber *)v intValue];
            [invocation setArgument:&rv atIndex:index];
        }
    } else if (!strcmp(type, @encode(long)) || !strcmp(type, @encode(unsigned long))) {
        if ([v isKindOfClass:NSNumber.class]) {
            long rv = [(NSNumber *)v longValue];
            [invocation setArgument:&rv atIndex:index];
        }
    } else if (!strcmp(type, @encode(short)) || !strcmp(type, @encode(unsigned short))) {
        if ([v isKindOfClass:NSNumber.class]) {
            short rv = [(NSNumber *)v shortValue];
            [invocation setArgument:&rv atIndex:index];
        }
    } else if (!strcmp(type, @encode(char)) || !strcmp(type, @encode(unsigned char))) {
        if ([v isKindOfClass:NSString.class]) {
            char rv = [(NSString *)v characterAtIndex:0];
            [invocation setArgument:&rv atIndex:index];
        }
    } else if (!strcmp(type, @encode(long long)) || !strcmp(type, @encode(unsigned long long))) {
        if ([v isKindOfClass:NSNumber.class]) {
            long long rv = [(NSNumber *)v longLongValue];
            [invocation setArgument:&rv atIndex:index];
        }
    } else if (!strcmp(type, @encode(double))) {
        if ([v isKindOfClass:NSNumber.class]) {
            double rv = [(NSNumber *)v doubleValue];
            [invocation setArgument:&rv atIndex:index];
        }
    } else if (!strcmp(type, @encode(Class))) {
        Class clazz = NSClassFromString(v);
        [invocation setArgument:&clazz atIndex:index];
    } else /*if (!strcmp(type, @encode(id)))*/ {
        id rv = v;
        [invocation setArgument:&rv atIndex:index];
    } /*else if (!strcmp(type, @encode(Class))) {
        Class rv = [v toObject];
        [invocation setReturnValue:&rv];
    }*/
}

- (id)getReturnValue:(NSInvocation *)invocation {
    const char *type = invocation.methodSignature.methodReturnType;
    if (!strcmp(type, @encode(float))) {
        float rv;
        [invocation getReturnValue:&rv];
        return @(rv);
    } else if (!strcmp(type, @encode(BOOL))) {
        BOOL rv;
        [invocation getReturnValue:&rv];
        return @(rv);
    } else if (!strcmp(type, @encode(int)) || !strcmp(type, @encode(unsigned int))) {
        int rv;
        [invocation getReturnValue:&rv];
        return @(rv);
    } else if (!strcmp(type, @encode(long)) || !strcmp(type, @encode(unsigned long))) {
        long rv;
        [invocation getReturnValue:&rv];
        return @(rv);
    } else if (!strcmp(type, @encode(short)) || !strcmp(type, @encode(unsigned short))) {
        short rv;
        [invocation getReturnValue:&rv];
        return @(rv);
    } else if (!strcmp(type, @encode(char)) || !strcmp(type, @encode(unsigned char))) {
        char rv;
        [invocation getReturnValue:&rv];
        return @(rv);
    } else if (!strcmp(type, @encode(long long)) || !strcmp(type, @encode(unsigned long long))) {
        long long rv;
        [invocation getReturnValue:&rv];
        return @(rv);
    } else if (!strcmp(type, @encode(double))) {
        double rv;
        [invocation getReturnValue:&rv];
        return @(rv);
    } else /*if (!strcmp(type, @encode(id)))*/ {
        id rv;
        [invocation getReturnValue:&rv];
        return rv;
    }
}


static NSString *mp_destructionStructtName(NSString *typeEncodeString)
{
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];
    int firstValidIndex = 0;
    for (int i = 0; i< typeString.length; i++) {
        char c = [typeString characterAtIndex:i];
        if (c == '{' || c=='_') {
            firstValidIndex++;
        }else {
            break;
        }
    }
    return [typeString substringFromIndex:firstValidIndex];
}


@end
