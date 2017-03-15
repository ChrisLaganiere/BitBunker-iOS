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
        gradient.colors = [UIColor.gray.cgColor, UIColor.green.cgColor]
        gradient.locations = [0.0 , 4.0]
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

protocol VaultListFileDelegate {
    func handleEditFile(indexPath: IndexPath)
    func handleDeleteFile(indexPath: IndexPath)
}

class VaultListCollectionViewCell: HFCardCollectionViewCell {

    let containerView = UIView(frame: CGRect.zero)
    let backView = GradientView(frame: CGRect.zero)
    let titleLabel = UILabel(frame: CGRect.zero)
    let editButton = UIButton(type: .roundedRect)
    let deleteButton = UIButton(type: .roundedRect)
    let fileTypeImageView = UIImageView(image: UIImage(named: "fileicon"))

    var indexPath: IndexPath?
    var delegate: VaultListFileDelegate?

    override init(frame: CGRect) {
        super.init(frame:frame)
        contentView.backgroundColor = UIColor.clear

        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        containerView.backgroundColor = UIColor.gray
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 2

        backView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backView)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        editButton.addTarget(self, action: #selector(editFile), for: .touchUpInside)
        editButton.setTitle("Open", for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        editButton.backgroundColor = UIColor.green.withAlphaComponent(0.8)
        editButton.setTitleColor(UIColor.black, for: .normal)
        editButton.layer.cornerRadius = 10
        editButton.layer.borderColor = UIColor.black.cgColor
        editButton.layer.borderWidth = 1.0
        editButton.clipsToBounds = true
        editButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(editButton)

        deleteButton.addTarget(self, action: #selector(deleteFile), for: .touchUpInside)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        deleteButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        deleteButton.setTitleColor(UIColor.black, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.borderColor = UIColor.black.cgColor
        deleteButton.layer.borderWidth = 1.0
        deleteButton.clipsToBounds = true
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(deleteButton)

        fileTypeImageView.tintColor = UIColor.green.withAlphaComponent(0.5)
        fileTypeImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(fileTypeImageView)

        contentView.addConstraints(preferredConstraints())
        containerView.addConstraints(containerViewConstraints())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Styling

    func styleWithFile(file: File, indexPath: IndexPath) {
        titleLabel.text = file.filename
        self.indexPath = indexPath
        cardIsRevealed(false)
    }

    func cardIsRevealed(_ isRevealed: Bool) {
        editButton.isHidden = !isRevealed
        deleteButton.isHidden = !isRevealed
        fileTypeImageView.isHidden = isRevealed
    }

    // MARK: - Actions

    func editFile() {
        if let indexPath = indexPath {
            delegate?.handleEditFile(indexPath: indexPath)
        }
    }

    func deleteFile() {
        if let indexPath = indexPath {
            delegate?.handleDeleteFile(indexPath: indexPath)
        }
    }

    // MARK: - Layout

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
        let views = ["back": backView, "title": titleLabel, "edit": editButton, "delete": deleteButton]
        let metrics = ["pad": 15, "top": 35, "actions": 80, "buttonPadding": 30, "buttonH": 50, "buttonW": 150]

        // back gradient
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[back(100)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[back]|", options: [], metrics: nil, views: views)

        // horizontal
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(pad)-[title]-(pad)-|", options: [], metrics: metrics, views: views)
        constraints.append(NSLayoutConstraint(item: editButton, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: editButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(metrics["buttonW"] ?? 0)))
        constraints.append(NSLayoutConstraint(item: deleteButton, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: deleteButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(metrics["buttonW"] ?? 0)))

        // vertical
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[title(30)]-(actions)-[edit(buttonH)]-(buttonPadding)-[delete(buttonH)]", options: [], metrics: metrics, views: views)

        // file type image view
        constraints.append(NSLayoutConstraint(item: fileTypeImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 140))
        constraints.append(NSLayoutConstraint(item: fileTypeImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 140))
        constraints.append(NSLayoutConstraint(item: fileTypeImageView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: fileTypeImageView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 30.0))

        return constraints
    }
}
