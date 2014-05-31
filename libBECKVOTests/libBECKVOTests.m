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
@property(nonatomic) id observedValue;
@end

@implementation BECObserver
@end



@interface libBECKVOTests : XCTestCase

@property(nonatomic) BECProclaimer *proclaimer;
@property(nonatomic) BECObserver *observer;

@end



@implementation libBECKVOTests

- (void)setUp
{
    [super setUp];
    self.proclaimer = [BECProclaimer new];
    self.observer = [BECObserver new];

    [self.proclaimer addObserver:self.observer forKeyPath:KEY_PATH(value) options:0 context:NULL];
}



- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.proclaimer removeObserver:self.observer forKeyPath:KEY_PATH(value)];
}



- (void)testExample
{
    id value = @(arc4random());
    self.proclaimer.value = value;
    XCTAssertEqualObjects(value, self.observer.observedValue, @"value not setting");

    /*
     Positive tests:

     - Add a callback for each selector style
     - Adding multiple simaultanious callbacks
     - Asynchronous callbacks
     
     Negative tests:     
     
     - Invalid callbacks
     - Incorrect unregistration details
     - Unregistration race condition

    */
}

@end
