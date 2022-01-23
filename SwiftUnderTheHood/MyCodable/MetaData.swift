//
//  MetaData.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 23.01.2022.
//

import Foundation

struct MyClassMetadata {
    
    typealias Layout = _ClassMetadata
    
    /// Backing class metadata pointer.
    let ptr: UnsafeMutableRawPointer
    
    var layout: Layout {
        ptr.load(as: Layout.self)
    }
    
    /// The class context descriptor that describes this class.
    var descriptor: MyClassDescriptor {
        return layout._descriptor
    }
    
}

struct MyClassDescriptor {
    
    typealias Layout = _ClassDescriptor
    
    /// Backing context descriptor pointer.
    let ptr: UnsafeMutableRawPointer
    
    var layout: Layout {
        ptr.load(as: Layout.self)
    }
    
    var _typeDescriptor: _TypeDescriptor {
        ptr.load(as: _TypeDescriptor.self)
    }
    
    public var fieldDescriptor: MyFieldDescriptor {
        let offset = ptr + MemoryLayout<Int32>.size * 4
        let ptr = offset + Int(_typeDescriptor._fields.offset)
        return MyFieldDescriptor(ptr: ptr)
    }
    
    /// The number of properties this class declares (not including superclass)
    /// properties).
    var numFields: Int {
        Int(layout._numFields)
    }
    
}

struct MyFieldDescriptor {
    
    typealias Layout = _FieldDescriptor
    
    let ptr: UnsafeMutableRawPointer
    
    var layout: Layout {
        ptr.load(as: Layout.self)
    }
    
    var numFields: Int {
        Int(layout._numFields)
    }
    
    public var records: [MyFieldRecord] {
        var result = [MyFieldRecord]()
        
        for i in 0 ..< numFields {
            let address = trailing + MemoryLayout<_FieldRecord>.size * i
            result.append(MyFieldRecord(ptr: address))
        }
        
        return result
    }
    
    var trailing: UnsafeMutableRawPointer {
        ptr + MemoryLayout<Layout>.size
    }
    
}

struct MyFieldRecord {
    
    typealias Layout = _FieldRecord
    
    let ptr: UnsafeMutableRawPointer
    
    var layout: Layout {
        ptr.load(as: Layout.self)
    }
    
    var mangledTypeName: String {
        let offset = ptr + MemoryLayout<Int32>.size
        let ptr = offset + Int(layout._mangledTypeName.offset)
        let cStrPtr = ptr.assumingMemoryBound(to: CChar.self)
        return String(cString: cStrPtr)
    }
    
    var name: String {
        let offset = ptr + MemoryLayout<Int32>.size * 2
        let ptr = offset + Int(layout._fieldName.offset)
        let cStrPtr = ptr.assumingMemoryBound(to: CChar.self)
        return String(cString: cStrPtr)
    }
    
}
