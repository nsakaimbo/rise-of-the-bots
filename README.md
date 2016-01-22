# Rise of the Bots
## Using Grand Central Dispatch to Become More Human
<p align="center">
<img src="/resources/ex-machina.png"</img>
</p>

###The Problem
It so happens one of my current projects involves a chatbot interface, and an interesting challenge we encountered was that the response times of our bot were too fast. Messages were being sent to and from the server so quickly that our beta testers complained the interaction felt too unnatural! So we had to engineer an artificial delay that felt a little more like talking to a real person.

Our specific problem was that certain responses were received as an array, but had to be staggered one after another and presented to the user sequentially. "What's that?" you say? "Easy-peasy - loop over the array and throw in a little Grand Central Dispatch magic! Piece of cake, right?" Not so fast, cowgirls and cowboys. You'd think the following piece of code would do the trick, right? _Riiiiight?_

```
   public func printLoop() {
        print("\nDISPATCH AFTER\n ")
        for response in responses  {
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue(), { [weak self] in
                self?.showResponse(response)
                })
        }
    }
```
Turns out the above snippet results in only a single initial delay after which our messages are presented to the user simultaneously anyway!

###\#@$&! (a.k.a "What Gives?")

After some digging, [this](http://stackoverflow.com/questions/11465084/dispatch-after-looped-repeated) Stack Overflow post helped clarify some fundamentals of how dispatch_after works, namely:

>The dispatch_after(...) call returns immediately no matter when it is scheduled to run. This means that your loop is not waiting two seconds between dispatching them. Instead you are building an infinite queue of things that will happen two seconds from now, not two seconds between each other. - _David Rönnqvist_

All the dispatch call was doing was queueing up tasks on the given (serial) queue and returning immediately. Therefore, the `DISPATCH_TIME_NOW` for each task changed so little between iterations so as to be imperceptible to the user (and certainly won't register on a standard timestamp interval).

###The Fix

Instead of throwing in the towel and pursuing another approach (such as nesting dispatch_after calls), one of my peers suggested we instead modify our code to use Swift's handy-dandy enumerate function so that each message's dispatch time is based on its position in the array:
```
     public func printLoopEnumerated() {
        for (index,response) in responses.enumerate() {
            let shift   = Double(2.0)
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64((shift + (shift * Double(index))) * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue(), { [weak self] in
                if index == 0 {
                    print("\nDISPATCH AFTER WITH ENUMERATION\n")
                }
                self?.showResponse(response)
                })
        }
    }
```
As you can see by the corresponding timestamps, the dispatch call using an enumerated `dispatch_time` works as we would like it to.

<p align="center">
<img src="/resources/timestamp-screenshot.png"</img>
</p>
