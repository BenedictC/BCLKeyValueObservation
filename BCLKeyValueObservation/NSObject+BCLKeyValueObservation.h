//
//  BCLKeyValueObservation.h
//  BCLKeyValueObservation
//
//  Created by Benedict Cohen on 25/05/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 A changeHandler must take one of the following four forms:

 -(void)aChangeHandlerWithZeroArguments;
 -(void)aChangeHandlerWithChangedObject:(id)changedObject;
 -(void)aChangeHandlerWithChangedObject:(id)changedObject change:(NSDictionary *)change;
 -(void)aChangeHandlerWithChangedObject:(id)changedObject change:(NSDictionary *)change keyPath:(NSString *)keyPath;

 */



#pragma mark - KVO Registration
@interface NSObject (BCLKeyValueObservation)

-(void)BCL_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous;
-(void)BCL_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue;
-(void)BCL_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;
-(void)BCL_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath;

-(void)BCL_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous;
-(void)BCL_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue;
-(void)BCL_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath;

@end



/**
 KEY_PATH adds a small degree of compile-time safety by check that a selector exists before converting to a string to use as a key path.
 */
#ifndef BCL_KEY
#ifdef DEBUG
#define BCL_KEY(PROPERTY) NSStringFromSelector(@selector(PROPERTY))
#else
#define BCL_KEY(PROPERTY) @#PROPERTY
#endif
#endif
