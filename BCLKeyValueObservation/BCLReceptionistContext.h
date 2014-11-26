//
//  BCLReceptionistContext.h
//  BCLKeyValueObservation
//
//  Created by Benedict Cohen on 25/11/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 BCLReceptionistContext is essentially a command object. It stores the details required to invoke a callback on the
 observer. BCLReceptionistContext are considered equal if observer, changeHandler, keyPath and queue are all equal.
 */
@interface BCLReceptionistContext : NSObject

/**
 Intializes a new receptionist context. DEBUG builds will log a warning for if a synchronous, queued context (i.e. queue != NULL and asynchronous = NO) is created. A synchronous queued context can cause deadlocks.

 @param observer      The object to be notified
 @param changeHandler The method selector to invoke on caller
 @param keyPath       The keyPath of the target
 @param queue         The queue to invoke the changeHandler on
 @param asynchronous  YES if the change handler should be invoked asynchronously, NO to be invoked synchronously.

 @return A receptionist context.
 */
-(instancetype)initWithObserver:(id)observer changeHandler:(SEL)changeHandler keyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous;


/// Observer is not retained to avoid creating retain cycles and because KVO should not be concerned with memory management. unsafe_unretained is used instead of weak to because not all OS X classes support weak.
@property(nonatomic, readonly, unsafe_unretained) id observer;

/// The selector to invoke on the observer. See header for the acceptable forms.
@property(nonatomic, readonly) SEL changeHandler;

/// keyPath is needed so that when contexts are unregistered we can find the currently registered context. (It is not need for the invocation because observeValueForKeyPath:ofObject:change:context: provides keyPath when an observation fires.)
@property(nonatomic, readonly) NSString *keyPath;

/// If queue is NULL then the callback will be invoked synchronously on the current thread. If non-NULL then it's invoked asynchronously on queue.
@property(nonatomic, readonly) dispatch_queue_t queue;

/// If YES then the callback is invoked asynchronously on queue. If NO then the callback is invoked synchronously on queue.
@property(nonatomic, readonly) BOOL asynchronous;

/**
 Invokes the changeHandler of the observer using the supplied values.

 @param keyPath The keyPath of the changed value
 @param object  The object that changed
 @param change  The changed values
 */
-(void)invokeWithKeyPath:(NSString *)keyPath object:(id)object change:(NSDictionary *)change;

@end
