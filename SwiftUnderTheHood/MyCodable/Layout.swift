//
//  Layout.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 23.01.2022.
//

import Foundation

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
