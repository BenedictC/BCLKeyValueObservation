//
//  libBECKVOTests.m
//  libBECKVOTests
//
//  Created by Benedict Cohen on 29/05/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+BECKeyValueObservation.h"



@interface BECProclaimer : NSObject
@property(nonatomic) id value;
@end

@implementation BECProclaimer
@end



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
@property(nonatomic) BECObserver *observer;
@property(nonatomic) id value;
@end



@implementation libBECKVOTests

- (void)setUp
{
    [super setUp];
    self.proclaimer = [BECProclaimer new];
    self.observer = [BECObserver new];
}



- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.proclaimer = nil;
    self.observer = nil;
}



-(void)fireKVO
{
    self.value = @(arc4random());
    self.proclaimer.value = self.value;
}



#pragma mark - tests
- (void)testZeroArgumentCallback
{
    [self.proclaimer BEC_startSendingObservationsToObserver:self.observer changeHandler:@selector(observeProclaimer) forKeyPath:KEY_PATH(value) options:0];
    [self fireKVO];
    XCTAssertEqualObjects(nil, self.observer.observedObject, @"???");
    XCTAssertEqualObjects(nil, self.observer.observedChanges, @"???");
    XCTAssertEqualObjects(nil, self.observer.observedKeyPath, @"???");
    [self.proclaimer BEC_stopSendingObservationsToObserver:self.observer changeHandler:@selector(observeProclaimer) forKeyPath:KEY_PATH(value)];
}



- (void)testOneArgumentCallback
{
    [self.proclaimer BEC_startSendingObservationsToObserver:self.observer changeHandler:@selector(observeProclaimer:) forKeyPath:KEY_PATH(value) options:0];
    [self fireKVO];
    XCTAssertEqualObjects(self.proclaimer, self.observer.observedObject, @"???");
    XCTAssertEqualObjects(nil, self.observer.observedChanges, @"???");
    XCTAssertEqualObjects(nil, self.observer.observedKeyPath, @"???");
    [self.proclaimer BEC_stopSendingObservationsToObserver:self.observer changeHandler:@selector(observeProclaimer:) forKeyPath:KEY_PATH(value)];
}



- (void)testTwoArgumentCallback
{
    [self.proclaimer BEC_startSendingObservationsToObserver:self.observer changeHandler:@selector(observeProclaimer:change:) forKeyPath:KEY_PATH(value) options:NSKeyValueObservingOptionInitial];
    [self fireKVO];
    XCTAssertEqualObjects(self.proclaimer, self.observer.observedObject, @"???");
    XCTAssertTrue([self.observer.observedChanges isKindOfClass:[NSDictionary class]], @"???"); //Hmmm. I'm not sure how to do this.
    XCTAssertEqualObjects(nil, self.observer.observedKeyPath, @"???");
    [self.proclaimer BEC_stopSendingObservationsToObserver:self.observer changeHandler:@selector(observeProclaimer:change:) forKeyPath:KEY_PATH(value)];
}



- (void)testThreeArgumentCallback
{
    [self.proclaimer BEC_startSendingObservationsToObserver:self.observer changeHandler:@selector(observeProclaimer:change:keyPath:) forKeyPath:KEY_PATH(value) options:NSKeyValueObservingOptionInitial];
    [self fireKVO];
    XCTAssertEqualObjects(self.proclaimer, self.observer.observedObject, @"???");
    XCTAssertTrue([self.observer.observedChanges isKindOfClass:[NSDictionary class]], @"???"); //Hmmm. I'm not sure how to do this.
    XCTAssertEqualObjects(KEY_PATH(value), self.observer.observedKeyPath, @"???");
    [self.proclaimer BEC_stopSendingObservationsToObserver:self.observer changeHandler:@selector(observeProclaimer:change:keyPath:) forKeyPath:KEY_PATH(value)];
}

/*
 Positive tests:

 - Add a callback for each selector style
 - Adding multiple simaultanious callbacks
 - concurrency

 Negative tests:

 - Invalid callbacks
 - Incorrect unregistration details
 - Unregistration race condition

 */


@end
