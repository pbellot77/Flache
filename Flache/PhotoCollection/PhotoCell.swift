//
//  PhotoCell.swift
//  Flache
//
//  Created by Patrick Bellot on 4/17/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
	
	var representedAssetIdentifier: String?
	
	let photoImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		return iv
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		add(photoImageView)
		photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
													paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
