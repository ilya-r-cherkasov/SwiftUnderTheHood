//
//  ViewController.swift
//  SwiftUnderTheHood
//
//  Created by Ilya Cherkasov on 15.01.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myArray = MyArray<Int>(1, 3, 5, 7)
        myArray.printAllValues()
    }


}

