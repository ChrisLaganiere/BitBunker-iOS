//
//  EditorViewController.swift
//  BitBunker
//
//  Created by Chris on 2/9/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import UIKit
import RichEditorView

protocol EditorViewDelegate {
    func cancelEdit()
    func saveEdit(updated: File, original: File?)
}

class EditorViewController: UIViewController, RichEditorToolbarDelegate {

    let containerView = UIView(frame: CGRect.zero)
    let richTextView = RichEditorView(frame: CGRect.zero)
    let cancelButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    let titleTextField = UITextField(frame: CGRect.zero)

    var containerViewHeightConstraint: NSLayoutConstraint?

    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()

    let originalFile: File?
    let vault: String
    var delegate: EditorViewDelegate?

    required init(file: File?, vault: String) {
        originalFile = file
        self.vault = vault
        super.init(nibName: nil, bundle: nil)

        if let file = file {
            titleTextField.text = file.filename
            richTextView.html = file.content ?? ""
        } else {
            richTextView.html = "<i>bunk</i> this"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        // Editor + Keyboard

        richTextView.inputAccessoryView = toolbar

        toolbar.delegate = self
        toolbar.editor = richTextView

        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }

        var options = toolbar.options
        options.append(item)
        toolbar.options = options

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

        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setContentHuggingPriority(751, for: .horizontal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cancelButton)

        titleTextField.addTarget(self, action: #selector(titleTextFieldChanged), for: .editingChanged)
        titleTextField.placeholder = "Title"
        titleTextField.textAlignment = .center
        titleTextField.layer.cornerRadius = 10.0
        titleTextField.clipsToBounds = true
        titleTextField.layer.borderColor = UIColor.gray.cgColor
        titleTextField.layer.borderWidth = 1.0
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleTextField)

        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setContentHuggingPriority(751, for: .horizontal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(saveButton)

        richTextView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(richTextView)

        containerView.addConstraints(containerViewConstraints())

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextFieldChanged()
    }

    // MARK: - Actions

    func handleCancel() {
        delegate?.cancelEdit()
    }

    func handleSave() {
        let filename = titleTextField.text ?? ""
        let content = richTextView.html
        if filename.characters.count > 0 {
            let updated = File(filename: filename, vaultName: vault, content: content)
            delegate?.saveEdit(updated: updated, original: originalFile)
        }
    }

    func titleTextFieldChanged() {
        saveButton.isEnabled = titleTextField.text?.characters.count ?? 0 > 0
    }

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
        let views = ["rev": richTextView, "save": saveButton, "cancel": cancelButton, "title": titleTextField]
        let metrics = ["pad": 15, "mid": 25, "top": 35]

        // horizontal
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(pad)-[rev]-(pad)-|", options: [], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(pad)-[cancel]-(pad)-[title]-(pad)-[save]-(pad)-|", options: [], metrics: metrics, views: views)

        // vertical
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[title(30)]-(mid)-[rev]-(pad)-|", options: [], metrics: metrics, views: views)
        constraints.append(NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: titleTextField, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: saveButton, attribute: .centerY, relatedBy: .equal, toItem: titleTextField, attribute: .centerY, multiplier: 1.0, constant: 0.0))

        return constraints
    }

}
