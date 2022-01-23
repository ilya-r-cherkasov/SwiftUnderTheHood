//
//  MyCodableViewController.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 22.01.2022.
//

import UIKit

final class MyCodableViewController: UIViewController {
    
    var testClass = Test()
    var simpleClass: SimpleClass!
    var secondSimpleClass: SimpleClass!
    
    var testClassPointer: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(testClass).toOpaque()
    }
    
    var simpleClassPointer: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(simpleClass).toOpaque()
    }
    
    // Указатель на метаданные
    var metaPointer: UnsafeMutableRawPointer {
        let address = testClassPointer.load(as: Int.self)
        return swiftIntToPointer(Int64(address))!
        //или unsafeBitCast(Test.self, to: UnsafeMutableRawPointer.self)
    }
    
    var simpleClassMetaPointer: UnsafeMutableRawPointer {
        unsafeBitCast(SimpleClass.self, to: UnsafeMutableRawPointer.self)
    }
    
    //Счетчик ссылок
    var referenceCounter: Int {
        let ptr = testClassPointer + 8
        return ptr.load(as: Int.self)
    }
    
    var simpleClassReferenceCounter: Int {
        let ptr = simpleClassPointer + 8
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
        
        simpleClass = manualInitialization()
        secondSimpleClass = simpleClass
        
        let simplePtr = MyClassMetadata(ptr: simpleClassMetaPointer)
        simplePtr.descriptor.fieldDescriptor.records.forEach { field in
            print(field.name)
        }
        print("Битовое поле счетчика ссылок: \(simpleClassReferenceCounter)")
        print(simpleClass.simpleValue)
        print(simpleClass.secondValue)
        print(simpleClass.add())
        
//        secondSimpleClass = simpleClass
//        print("Битовое поле счетчика ссылок: \(simpleClassReferenceCounter)")
        simpleClass = SimpleClass(simpleValue: 8, secondValue: 13)
        secondSimpleClass = simpleClass
        print(simpleClass.add())
    }
    
    func adress(of object: UnsafeRawPointer) {
        print(String(format: "%p", Int(bitPattern: object)))
    }
    
    func manualInitialization() -> SimpleClass {
        
        // Сначала передаем в simpleClass ссылку
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: 32, alignment: 0)
        let ptrAddress = getRawAdressVoid(ptr)
        ptr.initializeMemory(as: Int64.self, repeating: ptrAddress, count: 1)
        (ptr + 8).initializeMemory(as: Int64.self, repeating: 0, count: 1) //обязательно тут
        (ptr + 16).initializeMemory(as: Int64.self, repeating: 15, count: 1) //обязательно тут
        (ptr + 24).initializeMemory(as: Int64.self, repeating: 40, count: 1) //обязательно тут
        
        //получаем ссылку на класс
        let ref = ptr.load(as: SimpleClass.self)
        
        //готовим ссылку на метаданные
        let metaPtr = unsafeBitCast(SimpleClass.self, to: UnsafeMutablePointer<Int64>.self) //
        let address = getRawAdress(metaPtr)
        
        // вставляем ссылку на метаданные (heap object)
        ptr.initializeMemory(as: Int64.self, repeating: address, count: 1)
        
        (ptr + 8).initializeMemory(as: Int64.self, repeating: 3, count: 1) //костыль
        print("Ручная иницилизация класса")
        
        return ref
    }
    
}

