# BCLKeyValueObservation

## What is BCLKeyValueObservation?

BCLKeyValueObservation is a thin abstraction on top of Apple's KVO system. The goals of BCLKeyValueObservation are:
- Less boiler plate code
- Improve clarity of functionality
- **Not** an excuse to have fun with the runtime

BCLKeyValueObservation achieves these by:
- Encapsulating the receptionist pattern used by KVO and using a target-action inspired pattern
- Providing methods with stronger verb usage
- Respecting the original design goals of KVO and intentionally not addressing tangential concerns, specifically memory management



## Err, what's the receptionist pattern?

> The Receptionist design pattern addresses the general problem of redirecting an event occurring in one execution context of an application to another execution context for handling. 

Concepts in Objective-C Programming: Receptionist Pattern[https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/ReceptionistPattern/ReceptionistPattern.html#//apple_ref/doc/uid/TP40010810-CH13-SW107]

In KVO the receptionist pattern is manifested as `observeValueForKeyPath:ofObject:change:context:`. In the value-add of `observeValueForKeyPath:ofObject:change:context:` over calling invoking callbacks directly is that concurrency preconditions of the receiver can be addressed in a centralized place instead of being repeated in each callback method. While there is utility in the functionality provided by `observeValueForKeyPath:ofObject:change:context:` it comes at a significant cost. Implementing `observeValueForKeyPath:ofObject:change:context:`  requires much boiler plate code which is rip for errors. 

BCLKeyValueObservation encapsulates the receptionist pattern and instead provides a target-action style pattern. BCLKeyValueObservation provides the same functionality that a typical implementation of `observeValueForKeyPath:ofObject:change:context:` would provide. It ensure that concurrency requirements are meet and then invokes a specific method to handle the observed change.

## Why target-action style pattern and not blocks?

Blocks are a powerful tool but they are not the right solution to every problem. Blocks are best suited to handling transient, on-off 
events such as enumerating a collection or asynchronous task completion. Blocks are not well suited for open-ended communication between objects. The reasons for this is because of the memory management behaviour of blocks. By default blocks retain all objects that are within the blocks scope. This is unlikely to cause memory management issues if the block remains exclusively on the stack (in a conceptual sense) but as soon as a block is attached to the object graph (by being stored in a `@property`) the possibility of retain cycles becomes much greater.

KVO is intended for open-ended communication. Using blocks as a callback mechanism for KVO would inherently add the error-prone burden of memory management to the methods calling a block-based API. Of course there are techniques for dealing with this burden but a better approach is to avoid the quagmire and use a more suitable pattern in the first place.

The target-action pattern, like KVO, has no implications on memory management.  Both target-action and KVO assume that memory management is being handled else where. This is fine assumption. If an object is being observed then the observer is interested in the object and should thus own it by retaining it. In other words, if you observer an object then you are clearly interested in it and should be retaining it anyway.



## Why call it a 'target-action *style* pattern'?

The target-action pattern is intend for UI controls (views) to communicate with a controller (think target-`IBAction`). The target action pattern takes advantage of the responder chain to allow actions to be the most relevant receiver depending on the state of the UI. This flexibility is not implemented (or required) in the case of model-controller communications. To avoid ambiguity and confusion BCLKeyValueObservation uses the terms `observer` and `changeHandler` instead of `target` and `action`.



## How do I use it?

```
@implementation BECController 

#pragma mark - properties
-(void)setModelObject:(BECModelObject *)modelObject
{
//Unregister the existing object
    [_modelObject BCL_stopSendingObservationsToObserver:self changeHandler:@selector(modelObject:didChange:keyPath:) forKeyPath:@"value"];
    [_modelObject BCL_stopSendingObservationsToObserver:self changeHandler:@selector(modelObject:didChange:keyPath:) forKeyPath:@"anotherValue"];        
    
    _modelObject = modelObject;
    
    //start observing the new object
    [_modelObject BCL_startSendingObservationsToObserver:self changeHandler:@selector(modelObject:didChange:keyPath:) forKeyPath:@"value"];
    [_modelObject BCL_startSendingObservationsToObserver:self changeHandler:@selector(modelObject:didChange:keyPath:) forKeyPath:@"anotherValue"];    
    
    //ensure the view correctly represents the new object.
}



#pragma mark - KVO handling
-(void)modelObject:(BECModelObject *) didChange:(NSDictionary *)changes keyPath:(NSString *)keyPath
{
    [self refreshView];
}

@end

```