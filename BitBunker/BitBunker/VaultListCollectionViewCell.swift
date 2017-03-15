//
//  VaultListCollectionViewCell.swift
//  BitBunker
//
//  Created by Chris on 3/14/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import UIKit
import HFCardCollectionViewLayout

class GradientView: UIView {

    var gradientLayer: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.blue.cgColor, UIColor.green.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)

        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VaultListCollectionViewCell: HFCardCollectionViewCell {

    var containerView = UIView(frame: CGRect.zero)
    var backView = GradientView(frame: CGRect.zero)

    override init(frame: CGRect) {
        super.init(frame:frame)
        contentView.backgroundColor = UIColor.clear

        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 2

        backView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backView)

        contentView.addConstraints(preferredConstraints())
        containerView.addConstraints(containerViewConstraints())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Layout

    func preferredConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let views = ["container": containerView]
        let metrics = ["pad": 10]

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(pad)-[container]-(pad)-|", options: [], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(pad)-[container]-(pad)-|", options: [], metrics: metrics, views: views)

        return constraints
    }

    func containerViewConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let views = ["back": backView]

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[back]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[back]|", options: [], metrics: nil, views: views)

        return constraints
    }
}
