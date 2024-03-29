//
//  OutcomeLocationCell.swift
//  UltraCore
//
//  Created by Slam on 7/26/23.
//

import UIKit
import MapKit
import SDWebImage

class OutcomeLocationCell: BaseMessageCell {
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    
    fileprivate lazy var mediaView: UIImageView = .init {
        $0.image = .named("ff_logo_text")
        $0.contentMode = .scaleAspectFill
    }

    override func setupView() {
        super.setupView()
        self.container.addSubview(mediaView)
        self.container.addSubview(statusView)
        self.container.bringSubviewToFront(deliveryDateLabel)
    }

    override func setupConstraints() {
        
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.width.lessThanOrEqualTo(bubbleWidth)
        }

        self.mediaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.constants.maxWidth)
            make.height.equalTo(self.constants.maxHeight)
        }
        
        self.statusView.snp.makeConstraints { make in
            make.centerY.equalTo(deliveryDateLabel.snp.centerY)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(statusView.snp.right).offset((kLowPadding / 2))
            make.right.equalToSuperview().offset(-(kLowPadding / 2))
            make.bottom.equalToSuperview().offset(-(kLowPadding / 2))
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = message.statusImage
        if let mapImage = self.mediaView.imageFromCache(forKey: message.location.locationID) {
            self.mediaView.image = mapImage
        } else {
            let locationCoordinate = CLLocationCoordinate2D(latitude: message.location.lat, longitude: message.location.lon)
            let region = MKCoordinateRegion(center: locationCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            
            let options = MKMapSnapshotter.Options()
            options.region = region
            options.scale = UIScreen.main.scale
            options.size = self.frame.size

            let snapshotter = MKMapSnapshotter(options: options)
            snapshotter.start {[weak self] snapshot, error in
                guard let `self` = self,
                      let snapshot = snapshot, error == nil else {
                    return
                }

                let image = snapshot.image
                let point = snapshot.point(for: locationCoordinate)
                if let pinImage = UIImage.named("conversation_location_pin") {
                    let pinPoint = CGPoint(x: point.x - (pinImage.size.width / 2), y: point.y - (pinImage.size.height / 2))
                    image.draw(at: pinPoint, blendMode: .normal, alpha: 1.0)
                    pinImage.draw(at: pinPoint, blendMode: .normal, alpha: 1.0)
                }
                SDImageCache.shared.store(image, forKey: message.location.locationID, toDisk: true, completion: nil)

                self.mediaView.image = snapshot.image
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.mediaView.image = nil
    }
}

