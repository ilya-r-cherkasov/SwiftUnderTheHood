//
//  MyContiguousArrayStorage.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 16.01.2022.
//

import Foundation

class MyContiguousArrayStorage<Element> {
        
    var countAndCapacity: MyArrayBody?
    var pointer: UnsafeMutablePointer<Element>?
    
}
