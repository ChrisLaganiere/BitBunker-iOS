//
//  EnterViewController.swift
//  BitBunker
//
//  Created by Chris on 3/14/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import UIKit

class EnterViewController: UIViewController {

    let scrollView = UIScrollView(frame: CGRect.zero)
    let containerView = UIView(frame: CGRect.zero)

    let bitbunkerLabel = UILabel(frame: CGRect.zero)
    let responseLabel = UILabel(frame: CGRect.zero)
    let vaultNameTextField = UITextField(frame: CGRect.zero)
    let vaultSecretTextField = UITextField(frame: CGRect.zero)
    let openVaultButton = UIButton(type: .roundedRect)
    let createVaultButton = UIButton(type: .roundedRect)

    var scrollViewHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.gray

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)

        bitbunkerLabel.textAlignment = .center
        bitbunkerLabel.text = "BitBunker"
        bitbunkerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        bitbunkerLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bitbunkerLabel)

        responseLabel.numberOfLines = 0
        responseLabel.textAlignment = .center
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(responseLabel)

        vaultNameTextField.placeholder = "Vault Name"
        vaultNameTextField.autocorrectionType = .no
        vaultNameTextField.autocapitalizationType = .none
        vaultNameTextField.textAlignment = .center
        vaultNameTextField.layer.borderColor = UIColor.black.cgColor
        vaultNameTextField.layer.borderWidth = 1.0
        vaultNameTextField.layer.cornerRadius = 10
        vaultNameTextField.backgroundColor = .darkGray
        vaultNameTextField.clipsToBounds = true
        vaultNameTextField.tintColor = UIColor.green
        vaultNameTextField.textColor = UIColor.white
        vaultNameTextField.font = UIFont.boldSystemFont(ofSize: 18)
        vaultNameTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(vaultNameTextField)

        vaultSecretTextField.placeholder = "Secret Key"
        vaultSecretTextField.autocorrectionType = .no
        vaultSecretTextField.autocapitalizationType = .none
        vaultSecretTextField.textAlignment = .center
        vaultSecretTextField.layer.borderColor = UIColor.black.cgColor
        vaultSecretTextField.layer.borderWidth = 1.0
        vaultSecretTextField.layer.cornerRadius = 10
        vaultSecretTextField.tintColor = UIColor.green
        vaultSecretTextField.textColor = UIColor.white
        vaultSecretTextField.font = UIFont.boldSystemFont(ofSize: 18)
        vaultSecretTextField.backgroundColor = .darkGray
        vaultSecretTextField.clipsToBounds = true
        vaultSecretTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(vaultSecretTextField)

        openVaultButton.addTarget(self, action: #selector(handleOpenVault), for: .touchUpInside)
        openVaultButton.layer.cornerRadius = 10
        openVaultButton.clipsToBounds = true
        openVaultButton.backgroundColor = UIColor.green
        openVaultButton.setTitle("Open Vault", for: .normal)
        openVaultButton.setTitleColor(UIColor.white, for: .normal)
        openVaultButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(openVaultButton)

        createVaultButton.addTarget(self, action: #selector(handleCreateVault), for: .touchUpInside)
        createVaultButton.layer.cornerRadius = 10
        createVaultButton.clipsToBounds = true
        createVaultButton.backgroundColor = UIColor.green
        createVaultButton.setTitle("Create Vault", for: .normal)
        createVaultButton.setTitleColor(UIColor.white, for: .normal)
        createVaultButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(createVaultButton)

        addPreferredConstraints()
        scrollView.addConstraints(scrollViewConstraints())
        containerView.addConstraints(containerConstraints())

        // Gestures

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(tapGesture)

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Notifications

    func keyboardWillShow(notification: Notification) {
        if let info = notification.userInfo,
            let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double {

            scrollViewHeightConstraint?.constant = -keyboardFrame.size.height
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    func keyboardWillHide(notification: Notification) {
        if let info = notification.userInfo,
            let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double {

            scrollViewHeightConstraint?.constant = 0
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    // MARK: - Actions

    func openVault(createNew: Bool) {
        if let vaultName = vaultNameTextField.text,
            let secret = vaultSecretTextField.text,
            vaultName.characters.count > 0,
            secret.characters.count > 0 {

            let success: (NSDictionary)->() = { (response) in
                if let success = response["success"] as? Bool,
                    success {
                    self.pushVaultViewController(vault: vaultName)
                    self.resetFields()
                } else if let reason = response["reason"] as? String {
                    self.responseLabel.text = reason
                } else {
                    self.responseLabel.text = "Failed"
                }
            }

            if createNew {
                BitAPI.createVault(vaultName: vaultName, secret: secret, success: success, failure: { (error) in
                    print(error ?? "")
                })
            } else {
                BitAPI.openVault(vaultName: vaultName, secret: secret, success: success, failure: { (error) in
                    print(error ?? "")
                })
            }
        }
    }

    func handleOpenVault() {
        openVault(createNew: false)
    }

    func handleCreateVault() {
        openVault(createNew: true)
    }

    func resetFields() {
        vaultNameTextField.text = ""
        vaultSecretTextField.text = ""
        endEditing()
    }

    func endEditing() {
        view.endEditing(false)
    }

    func pushVaultViewController(vault: String) {
        let vaultViewController = VaultListViewController(vaultName: vault)
        self.navigationController?.pushViewController(vaultViewController, animated: true)
    }

    // MARK: - Layout

    func addPreferredConstraints() {
        var constraints = [NSLayoutConstraint]()
        let views = ["scroll": scrollView]

        // horizontal
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[scroll]|", options: [], metrics: nil, views: views)

        // vertical
        constraints.append(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        let scrollViewHeightConstraint = NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        constraints.append(scrollViewHeightConstraint)
        self.scrollViewHeightConstraint = scrollViewHeightConstraint

        view.addConstraints(constraints)
    }

    func scrollViewConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
//        let views = ["container": containerView]

        // horizontal
//        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: [], metrics: nil, views: views)
        constraints.append(NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: containerView, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0))

        // vertical
//        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|", options: [], metrics: nil, views: views)

        return constraints
    }

    func containerConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let views = ["bit": bitbunkerLabel, "response": responseLabel, "vault": vaultNameTextField, "secret": vaultSecretTextField, "open": openVaultButton, "create": createVaultButton]

        // horizontal
        constraints.append(NSLayoutConstraint(item: bitbunkerLabel, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: bitbunkerLabel, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: -80))

        constraints.append(NSLayoutConstraint(item: responseLabel, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: responseLabel, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: -100))

        constraints.append(NSLayoutConstraint(item: vaultNameTextField, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: vaultNameTextField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300))

        constraints.append(NSLayoutConstraint(item: vaultSecretTextField, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: vaultSecretTextField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300))

        constraints.append(NSLayoutConstraint(item: openVaultButton, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: openVaultButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300))

        constraints.append(NSLayoutConstraint(item: createVaultButton, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: createVaultButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300))

        // vertical
        constraints.append(NSLayoutConstraint(item: vaultSecretTextField, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[bit]-[response]-(15)-[vault(50)]-(15)-[secret(50)]-(15)-[open(50)]-(15)-[create(50)]", options: [], metrics: nil, views: views)

        return constraints
    }

}
