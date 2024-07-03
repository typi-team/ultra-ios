//
//  FilesControllerConfig.swift
//  UltraCore
//
//  Created by Slam on 12/8/23.
//

import Foundation

public protocol FilesControllerConfig {
    var backgroundColor: TwiceColor { get set }
    var takePhotoImage: TwiceImage { get set }
    var fromGalleryImage: TwiceImage { get set }
    var documentImage: TwiceImage { get set }
    var contactImage: TwiceImage { get set }
    var locationImage: TwiceImage { get set }
}
