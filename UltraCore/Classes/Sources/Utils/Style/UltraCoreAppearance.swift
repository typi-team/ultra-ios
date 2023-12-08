//
//  UltraCoreAppearance.swift
//  UltraCore
//
//  Created by Slam on 12/7/23.
//

import Foundation

public class UltraCoreAppearance {
    public static var imageViewTint: UIColor? {
        didSet {
            UIImageView.appearance().tintColor = imageViewTint
        }
    }
    
    public static var buttonTint: UIColor? {
        didSet {
            UIButton.appearance().tintColor = buttonTint
            UIButton.appearance().imageView?.tintColor = buttonTint
        }
    }
    
    public static var sliderTint: UIColor? {
        didSet {
            UISlider.appearance().tintColor = sliderTint
        }
    }
    
    public static var barButtonTint: UIColor? {
        didSet {
            UIBarButtonItem.appearance().tintColor = barButtonTint
        }
    }
    
    public static var navigationBarTitleTextAttributes: LabelConfig? {
        didSet {
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: navigationBarTitleTextAttributes?.font ?? UIFont.defaultRegularHeadline,
                                                                NSAttributedString.Key.foregroundColor: navigationBarTitleTextAttributes?.color ?? .gray600]
            
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
        }
    }


}
