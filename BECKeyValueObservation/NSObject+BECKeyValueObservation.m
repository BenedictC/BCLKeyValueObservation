//
//  NSObject+BECKeyValueObservation.m
//  BECKeyValueObservation
//
//  Created by Benedict Cohen on 25/05/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "NSObject+BECKeyValueObservation.h"



#pragma mark - BECReceptionistContext
/**
 BECReceptionistContext is essentially a command object. It stores the details required to invoke a callback on the
 observer. BECReceptionistContext are considered equal if observer, changeHandler, keyPath and queue are all equal.
 */
@interface BECReceptionistContext : NSObject

/**
 Observer is not retained to avoid creating retain cycles and because KVO should not be concerned with memory 
 management. unsafe_unretained is used instead of weak to because not all OS X classes support weak.
 */
@property(nonatomic, readonly, unsafe_unretained) id observer;

/**
 The selector to invoke on the observer. See header for the acceptable forms.
 */
@property(nonatomic, readonly) SEL changeHandler;

/**
 keyPath is needed so that when contexts are unregistered we can find the currently registered context. (It is not need
 for the invocation because observeValueForKeyPath:ofObject:change:context: provides keyPath when an observation fires.)
 */
@property(nonatomic, readonly) NSString *keyPath;

/**
 If queue is NULL then the callback will be invoked synchronously on the current thread. If non-NULL then it's invoked
 asynchronously on queue.
 */
@property(nonatomic, readonly) dispatch_queue_t queue;

/**
 If YES then the callback is invoked asynchronously on queue. If NO then the callback is invoked synchronously on queue.
 */
@property(nonatomic, readonly) BOOL asynchronous;

@end



@implementation BECReceptionistContext
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



#pragma mark - BECReceptionist
/**
 TODO:
 */
@interface BECReceptionist : NSObject
{
    @private NSMutableSet *_contexts;
}
@end



@implementation BECReceptionist

#pragma mark singleton
+(BECReceptionist *)sharedReceptionist
{
    static BECReceptionist *receptionist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        receptionist = [BECReceptionist new];
    });

    return receptionist;
}



#pragma mark instance life
-(instancetype)init
{
    self = [super init];
    if (self == nil) return nil;

    _contexts = [NSMutableSet new];

    return self;
}



#pragma mark accessors
-(void)getContexts:(void(^)(NSMutableSet *context))getter
{
    @synchronized(self) {
        getter(_contexts);
    }
}



#pragma mark KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)contextPointer
{
    BECReceptionistContext *context = (__bridge BECReceptionistContext *)contextPointer;

    [context invokeWithKeyPath:keyPath object:object change:change];
}



#pragma mark observation registration
-(void)registerObservationOfObject:(NSObject *)object forObserver:(id)observer changeHandler:(SEL)changeHandler keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    BECReceptionistContext *context = [[BECReceptionistContext alloc] initWithObserver:observer changeHandler:changeHandler keyPath:keyPath queue:queue asynchronous:asynchronous];
    [self getContexts:^(NSMutableSet *contexts) {
        [contexts addObject:context];
    }];

    [object addObserver:self forKeyPath:keyPath options:options context:(__bridge void *)context];
}



-(void)unregisterObservationOfObject:(NSObject *)object forObserver:(id)observer changeHandler:(SEL)changeHandler keyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    //Construct a new context and use it to find the context that is registered. 
    BECReceptionistContext *doppelgangerContext = [[BECReceptionistContext alloc] initWithObserver:observer changeHandler:changeHandler keyPath:keyPath queue:queue asynchronous:asynchronous];
    __block BECReceptionistContext *canonicalContext = nil;

    [self getContexts:^(NSMutableSet *contexts) {
        [contexts enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            if (![obj isEqual:doppelgangerContext]) return;
            canonicalContext = obj;
            *stop = YES;
        }];

        //TODO: should this be an assert?
        NSAssert(canonicalContext != nil, @"Attempted to unregister an observation that has not been registered. Ensure that the arguments used to unregister the observation exactly match the arguments used to register it.");
        [contexts removeObject:canonicalContext];
    }];

    [object removeObserver:self forKeyPath:keyPath context:(__bridge void *)canonicalContext];
}

@end



#pragma mark - NSObject KVO Registration
/**
 See header file for documentation for this category.
 */
@implementation NSObject (BECKeyValueObservationRegistration)
#pragma mark start sending
-(void)BEC_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath
{
    [self BEC_startSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath options:0 queue:NULL asynchronous:NO];
}



-(void)BEC_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
{
    [self BEC_startSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath options:options queue:NULL asynchronous:NO];
}



-(void)BEC_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue
{
    [self BEC_startSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath options:options queue:queue asynchronous:YES];
}



-(void)BEC_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    [[BECReceptionist sharedReceptionist] registerObservationOfObject:self forObserver:observer changeHandler:changeHandler keyPath:keyPath options:options queue:queue asynchronous:asynchronous];
}



#pragma mark stop sending
-(void)BEC_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath
{
    [self BEC_stopSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath queue:NULL asynchronous:NO];
}



-(void)BEC_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue
{
    [self BEC_stopSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath queue:queue asynchronous:YES];
}



-(void)BEC_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    [[BECReceptionist sharedReceptionist] unregisterObservationOfObject:self forObserver:observer changeHandler:changeHandler keyPath:keyPath queue:queue asynchronous:asynchronous];
}

@end
