//
//  ViewController.swift
//  InternationalDemo
//
//  Created by FancyLou on 2021/1/4.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var helloLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapChangeLabel(_ sender: UIButton) {
        self.helloLabel.text = L10n.First.helloChange
    }
    
}

