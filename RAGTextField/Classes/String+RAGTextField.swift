//
//  String+RAGTextField.swift
//  Pods-RAGTextField_Example
//
//  Created by Reimar Twelker on 20.01.19.
//

import Foundation

extension String {
    
    func size(using font: UIFont) -> CGSize {
        
        let infinite = CGFloat.greatestFiniteMagnitude
        let infiniteSize = CGSize(width: infinite, height: infinite)
        let boundingRect = self.boundingRect(with: infiniteSize, options: [], attributes: [ .font: font ], context: nil)
        let size = boundingRect.size
        
        return size
    }
}
