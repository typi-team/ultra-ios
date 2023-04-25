//
//  ContactCell.swift
//  UltraCore
//
//  Created by Slam on 4/21/23.
//

import UIKit

class ContactCell: BaseCell {
    
    func setup(contact: ContactDisplayable) {
        
        if (self.imageView?.borderColor != .green500) {
            self.imageView?.borderWidth = 2
            self.imageView?.cornerRadius = 32
            self.imageView?.borderColor = .green500
            self.imageView?.contentMode = .scaleAspectFit
        }
        
        self.imageView?.loadImage(by: nil,
                                  placeholder: .initial(text: contact.displaName.initails))
        self.textLabel?.text = contact.displaName
    }
}
