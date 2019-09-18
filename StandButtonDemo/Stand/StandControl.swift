//
//  StandControl.swift
//  StandButtonDemo
//
//  Created by Diego on 2019/8/12.
//  Copyright © 2019 whatzwhat. All rights reserved.
//

import UIKit

class StandControl: UIControl {
    
    public final var shadowEnabled: Bool = false {
        didSet { prepareShadow() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    private final func prepareView() {
        rounding(for: self)
        prepareShadow()
    }
    
    @objc private final func changeType() {
        
        
    }
    
    private final func rounding(for view: UIView, radius: CGFloat? = nil) {
        let cornerRadius: CGFloat
        switch radius {
        case .some(let radius):
            cornerRadius = radius
        default:
            cornerRadius = view.bounds.height / 2
        }
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
    }
    
    private final func prepareShadow() {
        guard shadowEnabled else {
            return
        }
        for view in self.subviews {
            rounding(for: view)
        }
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 5.0
    }
    
    public func setIcon(_ named: String) {
        switch UIImage(named: named) {
        case .some(let image):
            let imageView = prepareImageView()
            imageView.image = image
        default:
            let label = prepareLabel()
            label.text = named
            label.textColor = .white
            label.backgroundColor = .black
            label.font = UIFont.systemFont(ofSize: (self.bounds.width * 0.5) / CGFloat(named.count), weight: .bold)
        }
    }
    
}


// MARK: - Surface View Methods.
extension StandControl {
    
    private enum SurfaceView: Int, CaseIterable {
        case imageView = 101
        case label     = 102
    }

    private final func removeSurface(_ surface: SurfaceView) {
        self.viewWithTag(surface.rawValue)?.removeFromSuperview()
    }
    
    private final func prepareSurface(_ surface: SurfaceView) -> UIView? {
        if let view = self.viewWithTag(surface.rawValue) {
            return view
        }
        for surface in SurfaceView.allCases {
            removeSurface(surface)
        }
        return nil
    }
    
    private final func surfaceSettings(_ surface: SurfaceView, for view: UIView) {
        view.frame = CGRect(origin: .zero, size: self.bounds.size)
        view.autoresizingMask = [.flexibleHeight , .flexibleWidth]
        view.tag = surface.rawValue
        if shadowEnabled {
            rounding(for: view)
        }
    }

    private final func prepareImageView() -> UIImageView {
        let surface: SurfaceView = .imageView
        if let view = prepareSurface(surface) as? UIImageView {
            return view
        }
        let imageView = UIImageView()
        surfaceSettings(surface, for: imageView)
        imageView.contentMode = .scaleAspectFill
        self.addSubview(imageView)
        return imageView
    }
    
    private final func prepareLabel() -> UILabel {
        let surface: SurfaceView = .label
        if let view = prepareSurface(surface) as? UILabel {
            return view
        }
        let label = UILabel()
        surfaceSettings(surface, for: label)
        label.numberOfLines = 1
        label.textAlignment = .center
        self.addSubview(label)
        return label
    }

}
