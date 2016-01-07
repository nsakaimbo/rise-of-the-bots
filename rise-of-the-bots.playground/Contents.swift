import Foundation
import UIKit
import XCPlayground

let myPrinter = Printer()
myPrinter.printLoop()

myPrinter.printLoopEnumerated()
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true