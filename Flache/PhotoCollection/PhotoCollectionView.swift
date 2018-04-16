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
		
		collectionView?.backgroundColor = UIColor.mainBlue()
		collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
		
		return cell
	}
	
}
