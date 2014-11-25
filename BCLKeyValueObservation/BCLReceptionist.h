//
//  BCLReceptionist.h
//  BCLKeyValueObservation
//
//  Created by Benedict Cohen on 25/11/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface BCLReceptionist : NSObject

+(BCLReceptionist *)sharedReceptionist;
-(void)registerObservationOfObject:(NSObject *)object forObserver:(id)observer changeHandler:(SEL)changeHandler keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous;
-(void)unregisterObservationOfObject:(NSObject *)object forObserver:(id)observer changeHandler:(SEL)changeHandler keyPath:(NSString *)keyPath queue:(dispatch_queue_t)queue asynchronous:(BOOL)asynchronous;

@end
