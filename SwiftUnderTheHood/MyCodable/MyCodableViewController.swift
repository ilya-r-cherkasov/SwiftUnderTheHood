//
//  MyCodableViewController.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 22.01.2022.
//

import UIKit

final class MyCodableViewController: UIViewController {
    
    var testClass = Test()
    
    var testClassPointer: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(testClass).toOpaque()
    }
    
    // Указатель на метаданные
    var metaPointer: UnsafeMutableRawPointer {
        let address = testClassPointer.load(as: Int.self)
        let ptr = swiftIntToPointer(Int64(address))!
        print(ptr)
        print(unsafeBitCast(Test.self, to: UnsafeRawPointer.self))
        return ptr
    }
    
    //Счетчик ссылок
    var referenceCounter: Int {
        let ptr = testClassPointer + 8
        return ptr.load(as: Int.self)
    }
    
    //
    
    var firstValue: Int {
        let ptr = testClassPointer + 16
        return ptr.load(as: Int.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ptr = testClassPointer + 16
        let metaClass = MyClassMetadata(ptr: metaPointer)
        metaClass.descriptor.fieldDescriptor.records.forEach { field in
            switch field.mangledTypeName {
            case "Si":
                typealias T = Int
                print("\(field.name): \(Int.self) = \(ptr.load(as: Int.self))")
            case "SS":
                print("\(field.name): \(String.self) = \(ptr.load(as: String.self))")
                ptr += 8
            case "Sd":
                print("\(field.name): \(Double.self) = \(ptr.load(as: Double.self))")
            case "Sf":
                print("\(field.name): \(Float.self) = \(ptr.load(as: Float.self))")
            default:
                break
            }
            ptr += 8
        }
        
        print("Битовое поле счетчика ссылок: \(referenceCounter)")
        
    }
    
    func adress(of object: UnsafeRawPointer) {
        print(String(format: "%p", Int(bitPattern: object)))
    }
    
}

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

struct _ClassMetadata {
    let _kind: Int
    let _superclass: Any.Type?
    let _reserved: (Int, Int)
    let _rodata: Int
    let _flags: UInt32
    let _instanceAddressPoint: UInt32
    let _instanceSize: UInt32
    let _instanceAlignMask: UInt16
    let _runtimeReserved: UInt16
    let _classSize: UInt32
    let _classAddressPoint: UInt32
    let _descriptor: MyClassDescriptor
    let _ivarDestroyer: UnsafeRawPointer
}

struct _ClassDescriptor {
    let _base: _TypeDescriptor
    let _superclass: RelativeDirectPointer<CChar>
    
    // This is either a uint32 for negative size, or a relative direct pointer
    // to class metadata bounds if the superclass is resilient.
    let _negativeSizeOrResilientBounds: UInt32
    
    // This is either a uint32 for positive size, or extra class flags
    // if the superclass is resilient.
    let _positiveSizeOrExtraFlags: UInt32
    
    let _numImmediateMembers: UInt32
    let _numFields: UInt32
    let _fieldOffsetVectorOffset: UInt32
}

struct _TypeDescriptor {
    let _base: _ContextDescriptor
    let _name: RelativeDirectPointer<CChar>
    let _accessor: RelativeDirectPointer<UnsafeRawPointer>
    let _fields: RelativeDirectPointer<_FieldDescriptor>
}

struct _ContextDescriptor {
    let _flags: UInt32
    let _parent: RelativeIndirectablePointer<_ContextDescriptor>
}

struct RelativeDirectPointer<Pointee> {
    let offset: Int32
}

struct RelativeIndirectablePointer<Pointee> {
    let offset: Int32
}

struct _FieldDescriptor {
    let _mangledTypeName: RelativeDirectPointer<CChar>
    let _superclass: RelativeDirectPointer<CChar>
    let _kind: UInt16
    let _recordSize: UInt16
    let _numFields: UInt32
}

struct _FieldRecord {
    let _flags: UInt32
    let _mangledTypeName: RelativeDirectPointer<CChar>
    let _fieldName: RelativeDirectPointer<CChar>
}
