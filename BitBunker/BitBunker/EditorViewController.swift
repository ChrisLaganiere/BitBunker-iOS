//
//  EditorViewController.swift
//  BitBunker
//
//  Created by Chris on 2/9/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import UIKit
import RichEditorView

class EditorViewController: UIViewController {

    var containerView = UIView(frame: CGRect.zero)
    var richTextView = RichEditorView(frame: CGRect.zero)

    var containerViewHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Container View

        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: [], metrics: nil, views: ["container": containerView]))
        view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))

        // control height of containerView to adjust for keyboard
        let containerViewHeightConstraint = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        view.addConstraint(containerViewHeightConstraint)
        self.containerViewHeightConstraint = containerViewHeightConstraint

        // Subviews

        richTextView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(richTextView)

        containerView.addConstraints(containerViewConstraints())
    }

    // default contraints for subviews of containerView
    private func containerViewConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let views = ["rev": richTextView]

        // horizontal
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[rev]|", options: [], metrics: nil, views: views)

        // vertical
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[rev]|", options: [], metrics: nil, views: views)

        return constraints
    }

}

