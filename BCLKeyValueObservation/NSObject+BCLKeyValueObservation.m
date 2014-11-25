//
//  BCLKeyValueObservation.m
//  BCLKeyValueObservation
//
//  Created by Benedict Cohen on 25/05/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "NSObject+BCLKeyValueObservation.h"

#import "BCLReceptionist.h"
#import "BCLReceptionistContext.h"



#pragma mark - NSObject KVO Registration
/**
 See header file for documentation for this category.
 */
@implementation NSObject (BCLKeyValueObservation)
#pragma mark start sending
-(void)BCL_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath
{
    [self BCL_startSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath options:0 queue:NULL asynchronous:NO];
}



-(void)BCL_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
{
    [self BCL_startSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath options:options queue:NULL asynchronous:NO];
}



-(void)BCL_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue
{
    [self BCL_startSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath options:options queue:queue asynchronous:YES];
}



-(void)BCL_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    [[BCLReceptionist sharedReceptionist] registerObservationOfObject:self forObserver:observer changeHandler:changeHandler keyPath:keyPath options:options queue:queue asynchronous:asynchronous];
}



#pragma mark stop sending
-(void)BCL_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath
{
    [self BCL_stopSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath queue:NULL asynchronous:NO];
}



-(void)BCL_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue
{
    [self BCL_stopSendingObservationsToObserver:observer changeHandler:changeHandler forKeyPath:keyPath queue:queue asynchronous:YES];
}



-(void)BCL_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous
{
    [[BCLReceptionist sharedReceptionist] unregisterObservationOfObject:self forObserver:observer changeHandler:changeHandler keyPath:keyPath queue:queue asynchronous:asynchronous];
}

@end
