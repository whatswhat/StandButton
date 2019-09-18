//
//  ViewController.swift
//  StandButtonDemo
//
//  Created by Diego on 2019/9/18.
//  Copyright © 2019 whatzwhat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    let icons: [String] = ["icon1", "icon2", "文字"]

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareStandView()
    }
    
    private func prepareStandView() {
        let frame = CGRect(x: self.view.frame.maxX - 80, y: self.view.frame.maxY - 150, width: 50, height: 50)
        let standButton = StandButton(frame: frame)
        standButton.delegate = self
        standButton.shadowEnabled = true
        standButton.direction = .up
        standButton.model = .menu
        standButton.backgroundColor = .red
        standButton.duration = 0.5
        standButton.backdropView.backgroundColor = UIColor(white: 0, alpha: 0.25)
        self.view.addSubview(standButton)
    }
    
}

extension ViewController: StandButtonDelegate {
    
    
    func numberOfCells(in button: StandButton) -> Int {
        return icons.count
    }
    
    func standButton(_ button: StandButton, iconInCell cell: Int) -> String {
        return icons[cell]
    }
    
    func standButton(_ button: StandButton, unfold: Bool) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, animations: {
            if unfold {
                button.alpha = 0.5
            } else {
                button.alpha = 1
            }
        })
    }
    
    func standButton(_ button: StandButton, didSelectCellAt index: Int) {
        
        switch index {
        case 0:
            self.label.text = "我"
        case 1:
            self.label.text = "每天早上"
        case 2:
            self.label.text = "都被自己帥醒"
        default:
            break
        }
        
    }
    
}
