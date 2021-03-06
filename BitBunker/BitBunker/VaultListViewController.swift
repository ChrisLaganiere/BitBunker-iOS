//
//  VaultListViewController.swift
//  BitBunker
//
//  Created by Chris on 3/14/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import UIKit
import HFCardCollectionViewLayout

protocol VaultListModelDelegate {
    func didUpdateFiles()
    func failedToUpdateFiles()
}

class VaultListModel {
    let vaultName: String
    private(set) var files = [File]()

    var delegate: VaultListModelDelegate?

    init(vaultName: String) {
        self.vaultName = vaultName
    }

    func updateFileList() {
        BitAPI.listVault(vaultName: vaultName, success: { (response) in
            if let success = response["success"] as? Bool,
                success {
//                print(response)
                if let rawFiles = response["files"],
                    let files = File.filesFromJSON(rawJSON: rawFiles) {
                    self.files = files
                    self.delegate?.didUpdateFiles()
                }
            }
        }) { (error) in
            print(error ?? "")
        }
    }

    func updateFile(updated: File, original: File?) {
        BitAPI.replaceFile(updated: updated, original: original, success: { (response) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateFileList()
            }
        }) { (error) in
            print(error ?? "")
        }
    }

    func deleteFile(original: File) {
        BitAPI.deleteFile(filename: original.filename, vaultName: original.vaultName, success: { (response) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateFileList()
            }
        }) { (error) in
            print(error ?? "")
        }
    }
}

class VaultListViewController: UIViewController, UICollectionViewDataSource, HFCardCollectionViewLayoutDelegate, VaultListModelDelegate, VaultListFileDelegate, EditorViewDelegate {

    var collectionView: UICollectionView?
    var model: VaultListModel

    var cardCollectionViewLayout = HFCardCollectionViewLayout()

    private let listCellReuseID = "VaultListCell"

    required init(vaultName: String) {
        model = VaultListModel(vaultName: vaultName)
        super.init(nibName: nil, bundle: nil)

        model.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        model.updateFileList()

        title = model.vaultName

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: cardCollectionViewLayout)
        let collectionViewTap = UITapGestureRecognizer(target: self, action: #selector(unrevealCard))
        collectionView.addGestureRecognizer(collectionViewTap)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VaultListCollectionViewCell.self, forCellWithReuseIdentifier: listCellReuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        self.collectionView = collectionView

        view.addConstraints(preferredConstraints())

        cardCollectionViewLayout.cardHeadHeight = 100
        cardCollectionViewLayout.cardShouldExpandHeadHeight = false
        cardCollectionViewLayout.cardShouldStretchAtScrollTop = true
        cardCollectionViewLayout.cardMaximumHeight = 400
        cardCollectionViewLayout.bottomNumberOfStackedCards = 4
        cardCollectionViewLayout.spaceAtBottom = 40
        cardCollectionViewLayout.spaceAtTopForBackgroundView = 44

        let createFileBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createFile))
        let refreshListBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshList))
        self.navigationItem.setRightBarButtonItems([refreshListBarButtonItem, createFileBarButtonItem], animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.black

        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (traitCollection.horizontalSizeClass == .regular) {
            collectionView?.contentInset.left = 100
            collectionView?.contentInset.right = 100
        } else {
            collectionView?.contentInset.left = 0
            collectionView?.contentInset.right = 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.files.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: listCellReuseID, for: indexPath)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 320, height: 320);
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item < model.files.count,
            let fileCell = cell as? VaultListCollectionViewCell {
            let file = model.files[indexPath.item]
            fileCell.styleWithFile(file: file, indexPath: indexPath)
            fileCell.delegate = self
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardCollectionViewLayout.revealCardAt(index: indexPath.item)
    }

    // MARK: - Card collection view layout

    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willRevealCardAtIndex index: Int) {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? VaultListCollectionViewCell {
            cell.cardIsRevealed(true)
        }
    }

    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnrevealCardAtIndex index: Int) {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? VaultListCollectionViewCell {
            cell.cardIsRevealed(false)
        }
    }

    // MARK: - Actions

    func createFile() {
        presentFileEditor(file: nil)
    }

    func refreshList() {
        model.updateFileList()
    }

    func unrevealCard() {
        cardCollectionViewLayout.unrevealCard()
    }

    func back() {
        BitAPI.closeVault(vaultName: model.vaultName, success: { (response) in
            if let success = response["success"] as? Bool,
                success {
//                print("closed vault")
            } else {
                print(response)
            }
        }) { (error) in
            print(error ?? "")
        }
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - VaultListModelDelegate

    func didUpdateFiles() {
        unrevealCard()
//        print(model.files)
        collectionView?.reloadData()
//        collectionView?.collectionViewLayout.invalidateLayout()
//        collectionView?.reloadSections([0])
//        cardCollectionViewLayout.invalidateLayout()
//        collectionView?.reloadItems(at: collectionView?.indexPathsForVisibleItems ?? [])

    }

    func failedToUpdateFiles() {

    }

    // MARK: - VaultListFileDelegate

    func handleEditFile(indexPath: IndexPath) {
        if indexPath.item < model.files.count {
            let file = model.files[indexPath.item]
            presentFileEditor(file: file)
        }
    }

    func handleDeleteFile(indexPath: IndexPath) {
        if indexPath.item < model.files.count {
            let file = model.files[indexPath.item]
            cardCollectionViewLayout.unrevealCard()
            model.deleteFile(original: file)
        }
    }

    // MARK: - EditorViewDelegate

    func cancelEdit() {
        self.dismiss(animated: true, completion: nil)
    }

    func saveEdit(updated: File, original: File?) {
        self.dismiss(animated: true) {
            self.model.updateFile(updated: updated, original: original)
        }
    }

    // MARK: - Layout

    func presentFileEditor(file: File?) {
        unrevealCard()
        let editorViewController = EditorViewController(file: file, vault: model.vaultName)
        editorViewController.delegate = self
        editorViewController.modalPresentationStyle = .fullScreen
        self.present(editorViewController, animated: true, completion: nil)
    }

    func preferredConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let views = ["vault": collectionView]

        // horizontal
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[vault]|", options: [], metrics: nil, views: views)

        // vertical
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[vault]|", options: [], metrics: nil, views: views)

        return constraints
    }

}
