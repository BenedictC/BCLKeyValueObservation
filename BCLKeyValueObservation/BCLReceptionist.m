//
//  BCLReceptionist.m
//  BCLKeyValueObservation
//
//  Created by Benedict Cohen on 25/11/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "BCLReceptionist.h"
#import "BCLReceptionistContext.h"



@implementation BCLReceptionist
{
    @private NSMutableSet *_contexts;
}


#pragma mark singleton
+(BCLReceptionist *)sharedReceptionist
{
    static BCLReceptionist *receptionist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        receptionist = [BCLReceptionist new];
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
    BCLReceptionistContext *context = (__bridge BCLReceptionistContext *)contextPointer;

    [context invokeWithKeyPath:keyPath object:object change:change];
}



#pragma mark observation registration
-(void)registerObservationOfObject:(NSObject *)object forObserver:(id)observer changeHandler:(SEL)changeHandler keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    BCLReceptionistContext *context = [[BCLReceptionistContext alloc] initWithObserver:observer changeHandler:changeHandler keyPath:keyPath queue:queue asynchronous:asynchronous];
    [self getContexts:^(NSMutableSet *contexts) {
        [contexts addObject:context];
    }];

    [object addObserver:self forKeyPath:keyPath options:options context:(__bridge void *)context];
}



-(void)unregisterObservationOfObject:(NSObject *)object forObserver:(id)observer changeHandler:(SEL)changeHandler keyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    //Construct a new context and use it to find the context that is registered.
    BCLReceptionistContext *doppelgangerContext = [[BCLReceptionistContext alloc] initWithObserver:observer changeHandler:changeHandler keyPath:keyPath queue:queue asynchronous:asynchronous];
    __block BCLReceptionistContext *canonicalContext = nil;

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
