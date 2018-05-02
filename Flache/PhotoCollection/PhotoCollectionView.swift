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
	
	var latestPhotoAssets: PHFetchResult<PHAsset>? = nil
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavBar()
		
		collectionView?.backgroundColor = UIColor.mainBlue()
		collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: cellID)
		
		latestPhotoAssets = self.fetchLatestPhotos(forCount: 24)
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
	
	func fetchLatestPhotos(forCount count: Int?) -> PHFetchResult<PHAsset> {
		let options = PHFetchOptions()
		
		if let count = count { options.fetchLimit = count }
		let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
		options.sortDescriptors = [sortDescriptor]
		
		return PHAsset.fetchAssets(with: .image, options: options)
	}
	
	@objc func handleDismiss() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 2
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 2
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (view.frame.width - 4) / 3
		return CGSize(width: width, height: 200)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return latestPhotoAssets!.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoCell
		let manager = PHImageManager()
		let options = PHImageRequestOptions()
		options.isNetworkAccessAllowed = true
		
		guard let asset = self.latestPhotoAssets?[indexPath.item] else { return cell }
		cell.representedAssetIdentifier = asset.localIdentifier
		manager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: options) { (image, _) in
			if cell.representedAssetIdentifier == asset.localIdentifier {
				cell.photoImageView.image = image
			}
		}
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
		
		let containerView = PreviewPhotoContainerView()
		containerView.previewImageView.image = cell.photoImageView.image
		containerView.previewImageView.contentMode = .scaleAspectFill
		
		UIView.transition(with: containerView, duration: 0.25, options: .transitionCurlDown, animations: {
			self.navigationController?.view.add(containerView)
			containerView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor,
													 paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
			containerView.saveButton.isHidden = true
		}, completion: nil)
	
	}
}
