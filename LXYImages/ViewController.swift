//
//  ViewController.swift
//  LXYImages
//
//  Created by 李 欣耘 on 16/3/25.
//  Copyright © 2016年 lixinyun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var _image : UIImage = UIImage.init()
        
        _image = LXYNetImage.lxy_imageWithURL("xxxx.xxx", placeholderImage: "xx") { (image, respones, error) in
            if image != nil {
                _image = image!
            }else {
                
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

