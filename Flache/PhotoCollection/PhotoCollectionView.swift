//
//  PhotoCollectionView.swift
//  Flache
//
//  Created by Patrick Bellot on 4/16/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionView: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	let cellID = "cellID"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupNavBar()
		
		collectionView?.backgroundColor = UIColor.mainBlue()
		collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
	}
	
	func setupNavBar() {
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = "Last 24 Photos"
		navigationController?.navigationBar.barTintColor = .white
		let attributes = [NSAttributedStringKey.foregroundColor: UIColor.mainBlue()]
		navigationController?.navigationBar.largeTitleTextAttributes = attributes
		addBackbutton()
	}
	
	func addBackbutton() {
		let backButton = UIButton(type: .custom)
		backButton.tintColor = UIColor.mainBlue()
		backButton.setTitle("Back", for: .normal)
		backButton.setTitleColor(UIColor.mainBlue(), for: .normal)
		backButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
	}
	
	@objc func handleDismiss() {
		self.dismiss(animated: true, completion: nil)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
		
		return cell
	}
	
}
