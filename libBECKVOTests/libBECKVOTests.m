//
//  libBECKVOTests.m
//  libBECKVOTests
//
//  Created by Benedict Cohen on 29/05/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+BECKeyValueObservation.h"
#import <OCMock/OCMock.h>



@interface BECProclaimer : NSObject
@property(nonatomic) id value;
@end

@implementation BECProclaimer
@end



@protocol BECObserver <NSObject>
-(void)observeProclaimer;
-(void)observeProclaimer:(id)proclaimer;
-(void)observeProclaimer:(id)proclaimer change:(NSDictionary *)change;
-(void)observeProclaimer:(id)proclaimer change:(NSDictionary *)change keyPath:(NSString *)keyPath;
@end



#pragma mark - TODO Replace BECObserver with a mock object
@interface BECObserver : NSObject
@property(nonatomic) id observedObject;
@property(nonatomic) NSDictionary *observedChanges;
@property(nonatomic) NSString *observedKeyPath;
@end

@implementation BECObserver
-(void)observeProclaimer
{
    self.observedObject = nil;
    self.observedChanges = nil;
    self.observedKeyPath = nil;
}



-(void)observeProclaimer:(id)proclaimer
{
    self.observedObject = proclaimer;
    self.observedChanges = nil;
    self.observedKeyPath = nil;
}



-(void)observeProclaimer:(id)proclaimer change:(NSDictionary *)change
{
    self.observedObject = proclaimer;
    self.observedChanges = change;
    self.observedKeyPath = nil;
}



-(void)observeProclaimer:(id)proclaimer change:(NSDictionary *)change keyPath:(NSString *)keyPath
{
    self.observedObject = proclaimer;
    self.observedChanges = change;
    self.observedKeyPath = keyPath;
}

@end



@interface libBECKVOTests : XCTestCase

@property(nonatomic) BECProclaimer *proclaimer;
@property(nonatomic) id value;
@end



@implementation libBECKVOTests

- (void)setUp
{
    [super setUp];
    self.proclaimer = [BECProclaimer new];
}



- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.proclaimer = nil;
}



-(void)fireKVO
{
    self.value = @(arc4random());
    self.proclaimer.value = self.value;
}



#pragma mark - tests callbacks of each selector form receive correct values
- (void)testZeroArgumentCallback
{
    BECObserver *observer = [BECObserver new];

    [self.proclaimer BEC_startSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer) forKeyPath:KEY_PATH(value) options:0];
    [self fireKVO];
    XCTAssertEqualObjects(nil, observer.observedObject, @"???");
    XCTAssertEqualObjects(nil, observer.observedChanges, @"???");
    XCTAssertEqualObjects(nil, observer.observedKeyPath, @"???");
    [self.proclaimer BEC_stopSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer) forKeyPath:KEY_PATH(value)];

    //Test that unregistration has worked.
    id anotherValue = @"This should be nil";
    observer.observedObject = anotherValue;
    [self fireKVO];
    XCTAssertEqualObjects(anotherValue, observer.observedObject, @"???");
}



- (void)testOneArgumentCallback
{
    BECObserver *observer = [BECObserver new];
    [self.proclaimer BEC_startSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer:) forKeyPath:KEY_PATH(value) options:0];
    [self fireKVO];
    XCTAssertEqualObjects(self.proclaimer, observer.observedObject, @"???");
    XCTAssertEqualObjects(nil, observer.observedChanges, @"???");
    XCTAssertEqualObjects(nil, observer.observedKeyPath, @"???");
    [self.proclaimer BEC_stopSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer:) forKeyPath:KEY_PATH(value)];

    //Test that unregistration has worked.
    id anotherValue = @"This should be nil";
    observer.observedObject = anotherValue;
    [self fireKVO];
    XCTAssertEqualObjects(anotherValue, observer.observedObject, @"???");
}



- (void)testTwoArgumentCallback
{
    BECObserver *observer = [BECObserver new];
    [self.proclaimer BEC_startSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer:change:) forKeyPath:KEY_PATH(value) options:NSKeyValueObservingOptionInitial];
    [self fireKVO];
    XCTAssertEqualObjects(self.proclaimer, observer.observedObject, @"???");
    XCTAssertTrue([observer.observedChanges isKindOfClass:[NSDictionary class]], @"???"); //Hmmm. I'm not sure how to do this.
    XCTAssertEqualObjects(nil, observer.observedKeyPath, @"???");
    [self.proclaimer BEC_stopSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer:change:) forKeyPath:KEY_PATH(value)];

    //Test that unregistration has worked.
    id anotherValue = @"This should be nil";
    observer.observedObject = anotherValue;
    [self fireKVO];
    XCTAssertEqualObjects(anotherValue, observer.observedObject, @"???");
}



- (void)testThreeArgumentCallback
{
    BECObserver *observer = [BECObserver new];
    [self.proclaimer BEC_startSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer:change:keyPath:) forKeyPath:KEY_PATH(value) options:NSKeyValueObservingOptionInitial];
    [self fireKVO];
    XCTAssertEqualObjects(self.proclaimer, observer.observedObject, @"???");
    XCTAssertTrue([observer.observedChanges isKindOfClass:[NSDictionary class]], @"???"); //Hmmm. I'm not sure how to do this.
    XCTAssertEqualObjects(KEY_PATH(value), observer.observedKeyPath, @"???");
    [self.proclaimer BEC_stopSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer:change:keyPath:) forKeyPath:KEY_PATH(value)];

    //Test that unregistration has worked.
    id anotherValue = @"This should be nil";
    observer.observedObject = anotherValue;
    [self fireKVO];
    XCTAssertEqualObjects(anotherValue, observer.observedObject, @"???");
}



#pragma mark - concurrency
//-(void)testDeadlock
//{
//    BECObserver *observer = [BECObserver new];
//    [self.proclaimer BEC_startSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer:change:keyPath:) forKeyPath:KEY_PATH(value) options:NSKeyValueObservingOptionInitial queue:dispatch_get_main_queue() asynchronous:NO];
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [self fireKVO];
//    });
//
//    XCTAssertEqualObjects(self.proclaimer, observer.observedObject, @"???");
//    XCTAssertTrue([observer.observedChanges isKindOfClass:[NSDictionary class]], @"???"); //Hmmm. I'm not sure how to do this.
//    XCTAssertEqualObjects(KEY_PATH(value), observer.observedKeyPath, @"???");
//    [self.proclaimer BEC_stopSendingObservationsToObserver:observer changeHandler:@selector(observeProclaimer:change:keyPath:) forKeyPath:KEY_PATH(value) queue:dispatch_get_main_queue() asynchronous:NO];
//
//    //Test that unregistration has worked.
//    id anotherValue = @"This should be nil";
//    observer.observedObject = anotherValue;
//    [self fireKVO];
//    XCTAssertEqualObjects(anotherValue, observer.observedObject, @"???");
//}



/*
 Positive tests:

 - Adding multiple simaultanious callbacks

 Negative tests:

 - Invalid callbacks
 - Incorrect unregistration details
 - Unregistration race condition

 */


@end
