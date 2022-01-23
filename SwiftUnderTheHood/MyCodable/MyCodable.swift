//
//  MyCodable.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 22.01.2022.
//

import Foundation


class Test {
    
    let value1: Int = 10
    let value2: String = "Hi"
    let value3: Double = 1.0
    let value4: Float = 2.0

}

class SimpleClass {
    
    let simpleValue: Int
    
    init(simpleValue: Int) {
        self.simpleValue = simpleValue
    }
    
    deinit {
        print("SimpleClass deinit")
    }
}
