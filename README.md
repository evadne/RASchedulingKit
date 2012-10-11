# RASchedulingKit

Callback-based NSOperation subclasses.  Asynchronous programming made easy.  Spliced from [IRFoundations](http://github.com/iridia/IRFoundations).


## Using RASchedulingKit

The Scheduling Kit gives you an **Async Operation**, a **Suspension-Counted** Operation Queue, and a **RAScheduling Category** on `NSObject`.

### Async Operation

The Async operation is the crux of the kit.  You can easily wrap a long-running piece of code in an `NSBlockOperation` and queue it, passing the value out of the scope later on.  However, this does not work for things that already provide asynchronous callbacks.  You would have to wait for the callbacks to come in.  Or you can react to the callbacks.

In which case, use `+[RAAsyncBarrierOperation operationWithWorker:callback:]`:

	RAAsyncBarrierOperation *operation = [RAAsyncBarrierOperation operationWithWorker:^(RAAsyncOperationCallback callback) {
	
		[AFSomething doSomethingWithCompletion:^(BOOL didFinish, id results, NSError *error){
		
			if (didFinish) {
			
				callback(results);
			
			} else {

				callback(error);
			
			}
		
		}];
		
	} callback: ^ (id results) {
	
		//	Process the results
		
	}];

The operation will keep itself on the queue and wait until the callback block is called to mark itself finished.  Dependencies still work.

In cases you want to do work on different threads, use `+operationWithWorker:trampoline:callback:trampoline:`.  The worker and callback trampolines allow, and trust you to invoke the block elsewhere on their behalf.

### Suspension-Counted Operation Queue

There is a `RAOperationQueue` which provides `-beginSuspendingOperations` and `-endSuspendingOperations`.  It does not allow calls into `-setSuspended:` directly but manages the suspension state for you.

This is usually not useful until you have operations that would trigger UI updates, for example a table view reload or animated update, that should really not happen in the middle of an user interaction.

### RAScheduling Category on `NSObject`

`NSObject+RAScheduling.h` introduces these methods on `NSObject`:

*	`-ra_performBlock:`, which enqueues a block wrapped in an async operation, with block trampolines to the main queue. 
*	`-ra_cancelBlocks`, which cancels every update.
