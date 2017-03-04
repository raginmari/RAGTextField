//
//  PillView.swift
//  RAGTextField
//
//  Created by Reimar Twelker on 23.02.17.
//  Copyright © 2017 Reimar Twelker. All rights reserved.
//

import UIKit

@IBDesignable class PillView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = floor(0.5 * min(bounds.width, bounds.height))
        layer.cornerRadius = cornerRadius
    }
}
