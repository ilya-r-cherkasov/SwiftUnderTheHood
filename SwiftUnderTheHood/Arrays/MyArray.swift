//
//  MyArray.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 15.01.2022.
//

import Foundation

struct MyArray<Element> {
    
    var buffer: MyContiguousArrayBuffer<Element>
    
    init(_ elements: Element...) { // Sequence
        self.buffer = MyContiguousArrayBuffer<Element>(count: elements.count)
        if var pointer = buffer.storage.pointer {
            elements.forEach { element in
                pointer.initialize(to: element)
                pointer += 1
            }
        }
    }
    
    private init() {
        self.buffer = MyContiguousArrayBuffer<Element>()
    }
    
}

extension MyArray {
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        get {
            return _getCount()
        }
    }
    
    func printAllValues() {
        guard var pointer = buffer.storage.pointer else {
            return
        }
        for _ in 0..<buffer.count {
            print(pointer.pointee)
            pointer += 1
        }
    }
    
}

extension MyArray {
    
    func _getCount() -> Int {
        buffer.count
    }
    
}
