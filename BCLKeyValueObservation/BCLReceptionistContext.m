//
//  BCLReceptionistContext.m
//  BCLKeyValueObservation
//
//  Created by Benedict Cohen on 25/11/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "BCLReceptionistContext.h"



@implementation BCLReceptionistContext
#pragma mark instance life cycle
-(instancetype)initWithObserver:(id)observer changeHandler:(SEL)changeHandler keyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    self = [super init];
    if (self == nil) return nil;

    _observer = observer;
    _changeHandler = changeHandler;
    _keyPath = [keyPath copy];
    _queue = queue;
    _asynchronous = asynchronous;

#ifdef DEBUG
    BOOL shouldLogDeadlockWarning = queue != NULL && !asynchronous;
    if (shouldLogDeadlockWarning) {
        NSLog(@"WARNING: A KVO changeHandler has been registered for synchronous dispatch. Synchronous dispatch is strongly discouraged as it is likely to cause deadlocks. KVO registration details: %@\n This is a DEBUG warning, it will not appear in release builds.", self);
    }
#endif
    return self;
}



#pragma mark properties
-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ (%p): observer = %p; changeHandler = %@; keyPath = %@; queue = %s; asynchronous = %@>", NSStringFromClass([self class]), self, self.observer, NSStringFromSelector(self.changeHandler), self.keyPath, dispatch_queue_get_label(self.queue), (self.asynchronous) ? @"YES" : @"NO"];
}



#pragma mark equality
-(NSUInteger)hash
{
    //Note that we normalize BOOL values.
    return [self.observer hash] ^ (uintptr_t)sel_getName(self.changeHandler) ^ self.keyPath.hash ^ (uintptr_t)self.queue ^ !!self.asynchronous;
}



-(BOOL)isEqual:(id)object
{
    return [object hash] == [self hash];
}



#pragma mark callback invocation
-(void)invokeWithKeyPath:(NSString *)keyPath object:(id)object change:(NSDictionary *)change
{
    NSMethodSignature *methodSignature = [self.observer methodSignatureForSelector:self.changeHandler];

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = self.changeHandler;
    [invocation setTarget:self.observer];
    //Note the intentional lack of 'break;'s
    switch ([methodSignature numberOfArguments]) {
        case 5: {
            __unsafe_unretained id arg4 = keyPath;
            [invocation setArgument:&arg4 atIndex:4];
        }
        case 4: {
            __unsafe_unretained id arg3 = change;
            [invocation setArgument:&arg3 atIndex:3];
        }
        case 3: {
            __unsafe_unretained id arg2 = object;
            [invocation setArgument:&arg2 atIndex:2];
        }
    }

    if (self.queue == NULL) {
        [invocation invoke];
        return;
    }

    if (self.asynchronous) {
        dispatch_async(self.queue, ^{
            [invocation invoke];
        });
        return;
    }

    //There is a risk of dead lock that we can't mitigate against:
    //1. Thread A sync calls Thread B.
    //2. Thread B triggers a KVO for sync on Thread A.
    //3. Thread B is waiting for Thread A but Thread A is already waiting for Thread B -> Dead lock!
    dispatch_sync(self.queue, ^{
        [invocation invoke];
    });
}

@end

