import Foundation
import UIKit

public class Printer: NSObject {
    
    let formatter: NSDateFormatter = {
        let _formatter = NSDateFormatter()
        _formatter.dateStyle = .NoStyle
        _formatter.timeStyle = .MediumStyle
        return _formatter
    }()
    
    let responses = ["hello", "darkness", "my", "old", "friend"]
    
    func showResponse(response:String) {
        print(response + ", " + formatter.stringFromDate(NSDate()))
    }
    
    public func printLoop() {
        print("\nDISPATCH AFTER\n ")
        for response in responses  {
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue(), { [weak self] in
                self?.showResponse(response)
                })
        }
    }
    
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
}