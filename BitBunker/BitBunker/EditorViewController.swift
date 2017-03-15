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

        richTextView.html = "<h1>My Awesome Editor</h1>Now I am editing in <em>style.</em>"

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

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    // MARK: - Actions

    func keyboardWillShow(notification: Notification) {
        if let info = notification.userInfo,
            let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double {

            containerViewHeightConstraint?.constant = -keyboardFrame.size.height
            UIView.animate(withDuration: animationDuration, animations: { 
                self.view.layoutIfNeeded()
            })
        }
    }

    func keyboardWillHide(notification: Notification) {
        if let info = notification.userInfo,
            let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double {

            containerViewHeightConstraint?.constant = 0
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    // MARK: - Layout

    // default contraints for subviews of containerView
    private func containerViewConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let views = ["rev": richTextView]
        let metrics = ["pad": 15, "top": 35]

        // horizontal
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(pad)-[rev]-(pad)-|", options: [], metrics: metrics, views: views)

        // vertical
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[rev]-(pad)-|", options: [], metrics: metrics, views: views)

        return constraints
    }

}
