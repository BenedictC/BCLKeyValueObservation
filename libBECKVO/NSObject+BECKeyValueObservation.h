//
//  NSObject+BECKeyValueObservation.h
//  BECKeyValueObservation
//
//  Created by Benedict Cohen on 25/05/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 changeHandler are selectors that follow the same form as action selectors. A changeHandler must take one of the 
 following four forms:

 -(void)aChangeHandlerWithZeroArguments;
 -(void)aChangeHandlerWithChangedObject:(id)changedObject;
 -(void)aChangeHandlerWithChangedObject:(id)changedObject change:(NSDictionary *)change;
 -(void)aChangeHandlerWithChangedObject:(id)changedObject change:(NSDictionary *)change keyPath:(NSString *)keyPath;

 */



#pragma mark - KVO Registration
@interface NSObject (BECKeyValueObservationRegistration)

-(void)BEC_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous;
-(void)BEC_startSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;

-(void)BEC_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous;
-(void)BEC_stopSendingObservationsToObserver:(id)observer changeHandler:(SEL)changeHandler forKeyPath:(NSString *)keyPath;

@end



/**
 The KEY_PATH macro adds a small degree of compile-time safety by check that a selector exists before converting to a
 string to use as a key path.
 */
#ifndef KEY_PATH
#ifdef DEBUG
#define KEY_PATH(KP) NSStringFromSelector(@selector(KP))
#else
#define KEY_PATH(KP) @#KP
#endif
#endif
