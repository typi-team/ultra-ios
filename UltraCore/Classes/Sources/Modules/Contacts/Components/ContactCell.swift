//
//  ContactCell.swift
//  UltraCore
//
//  Created by Slam on 4/21/23.
//

import UIKit

class ContactCell: BaseCell {
    
    func setup(contact: ContactDisplayable) {
        self.imageView?.loadImage(by: nil, placeholder: .initial(text: contact.displaName.initails))
        self.textLabel?.text = contact.displaName
    }
}
