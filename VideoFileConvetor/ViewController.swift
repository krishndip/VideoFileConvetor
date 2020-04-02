//
//  ViewController.swift
//  VideoFileConvetor
//
//  Created by Karan  on 01/04/20.
//  Copyright © 2020 Karan . All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.perform(#selector(convertVideoProcess), with: nil, afterDelay: 0.5)
    }
    
    @objc func convertVideoProcess()
    {
        let pathVideoFile = Bundle.main.path(forResource: "bird", ofType: "mov")
        VideoConvertorSingleton.sharedConvertor.convertVideo(videoURL: URL(fileURLWithPath: pathVideoFile!), completion: { (success : Bool) in
            
        })
    }

}

