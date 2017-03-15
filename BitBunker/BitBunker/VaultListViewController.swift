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
    private(set) var files = [String: String]()

    var delegate: VaultListModelDelegate?

    init(vaultName: String) {
        self.vaultName = vaultName
    }

    func updateFiles() {
        print("to do")
        files.updateValue(String(repeating: "a", count: files.count+1), forKey: String(repeating: "a", count: files.count+1))
        delegate?.didUpdateFiles()
    }

    func updateFile(filename: String, content: String) {
        files.updateValue(content, forKey: filename)
        delegate?.didUpdateFiles()
    }
}

class VaultListViewController: UIViewController, UICollectionViewDataSource, HFCardCollectionViewLayoutDelegate {

    var collectionView: UICollectionView?
    var model: VaultListModel

    var cardCollectionViewLayout = HFCardCollectionViewLayout()

    private let listCellReuseID = "VaultListCell"

    required init(vaultName: String) {
        model = VaultListModel(vaultName: vaultName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = model.vaultName

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: cardCollectionViewLayout)

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

//        cardCollectionViewLayout?.firstMovableIndex = cardLayoutOptions.firstMovableIndex
//        self.cardCollectionViewLayout?.bottomStackedCardsShouldScale = cardLayoutOptions.bottomStackedCardsShouldScale
//        self.cardCollectionViewLayout?.bottomCardLookoutMargin = cardLayoutOptions.bottomCardLookoutMargin
//        self.cardCollectionViewLayout?.spaceAtTopShouldSnap = cardLayoutOptions.spaceAtTopShouldSnap
//        self.cardCollectionViewLayout?.scrollAreaTop = cardLayoutOptions.scrollAreaTop
//        self.cardCollectionViewLayout?.scrollAreaBottom = cardLayoutOptions.scrollAreaBottom
//        self.cardCollectionViewLayout?.scrollShouldSnapCardHead = cardLayoutOptions.scrollShouldSnapCardHead
//        self.cardCollectionViewLayout?.scrollStopCardsAtTop = cardLayoutOptions.scrollStopCardsAtTop
//        self.cardCollectionViewLayout?.bottomStackedCardsMinimumScale = cardLayoutOptions.bottomStackedCardsMinimumScale
//        self.cardCollectionViewLayout?.bottomStackedCardsMaximumScale = cardLayoutOptions.bottomStackedCardsMaximumScale
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        model.updateFiles()

        if (traitCollection.horizontalSizeClass == .regular) {
            collectionView?.contentInset.left = 100
            collectionView?.contentInset.right = 100
        } else {
            collectionView?.contentInset.left = 0
            collectionView?.contentInset.right = 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15//model.files.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: listCellReuseID, for: indexPath)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 320, height: 320);
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardCollectionViewLayout.revealCardAt(index: indexPath.item)
    }

    //MARK: - Layout

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
