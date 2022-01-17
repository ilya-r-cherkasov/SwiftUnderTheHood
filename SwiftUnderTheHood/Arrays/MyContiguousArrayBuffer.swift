//
//  MyContiguousArrayBuffer.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 16.01.2022.
//

import Foundation

struct MyContiguousArrayBuffer<Element> {
    
    var storage: MyContiguousArrayStorage<Element>
    
    init() {
        self.storage = MyContiguousArrayStorage<Element>()
    }

    init(count: Int) {
        if count == 0 {
            self = MyContiguousArrayBuffer<Element>()
        }
        let pointer = UnsafeMutablePointer<Element>.allocate(capacity: count)
        self.storage = MyContiguousArrayStorage<Element>()
        storage.countAndCapacity = MyArrayBody(count: count)
        storage.pointer = pointer
    }
    
    internal var count: Int {
      get {
          return storage.countAndCapacity?.count ?? 0
      }
    }
    
}
