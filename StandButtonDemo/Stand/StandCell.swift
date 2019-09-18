//
//  StandCell.swift
//  StandButtonDemo
//
//  Created by Diego on 2019/8/8.
//  Copyright © 2019 whatzwhat. All rights reserved.
//

import UIKit

class StandCell: StandControl {
    
    private final let index: Int
    
    private final let delegate: StandCellDelegate

    init(frame: CGRect, index: Int, delegate: StandCellDelegate) {
        self.index = index
        self.delegate = delegate
        super.init(frame: frame)
        self.addTarget(self, action: #selector(selected), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private final func selected() {
        delegate.didSelectCellAt(index: index)
    }

}


