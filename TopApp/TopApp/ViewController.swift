//
//  ViewController.swift
//  TopApp
//
//  Created by Appspia on 3/9/24.
//

import UIKit
import Combine

class ViewController: UIViewController {

    var cancellables =  Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        API.free.request.sink { error in
            print(error)
        } receiveValue: { (item: TopAppsItem.TopApps) in
            print(item)
        }.store(in: &cancellables)

    }


}

