//
//  PreviewPhotoContainerView.swift
//  Flache
//
//  Created by Patrick Bellot on 3/23/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import Photos

protocol SaveDelegate {
	func didSaveImage(image: UIImage)
}

class PreviewPhotoContainerView: UIView {
	
	var saveDelegate: SaveDelegate!
	
	// MARK: -- Properties
	let previewImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		return iv
	}()
	
	let cancelButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(#imageLiteral(resourceName: "OvalCancel"), for: .normal)
		button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
		return button
	}()
	
	let shareButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(#imageLiteral(resourceName: "Share"), for: .normal)
		button.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
		return button
	}()
	
	let saveButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(#imageLiteral(resourceName: "Save"), for: .normal)
		button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
		return button
	}()
	
	// MARK: -- Selector functions
	@objc func handleCancel() {
		self.removeFromSuperview()
	}
	
	@objc func handleShare() {
		guard let image = previewImageView.image else { return print("No image found") }
		let imageToShare = [image]
		let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = PreviewPhotoContainerView()
		
		var topVC = UIApplication.shared.keyWindow?.rootViewController
		while topVC?.presentedViewController != nil {
			topVC = topVC?.presentedViewController
		}
		topVC?.present(activityViewController, animated: true, completion: nil)
	}
	
	@objc func handleSave() {
		guard let previewImage = previewImageView.image else { return }
		let library = PHPhotoLibrary.shared()
		
		library.performChanges({
			PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
		}) { (success, err) in
			if let err = err {
				print("Failed to save image to library:", err)
			}
			print("Successfully saved image to library")
			
			DispatchQueue.main.async {
				let savedLabel = UILabel()
				savedLabel.text = "Saved Successfully"
				savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
				savedLabel.textColor = .white
				savedLabel.numberOfLines = 0
				savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
				savedLabel.textAlignment = .center
				savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
				savedLabel.center = self.center
				self.add(savedLabel)
				
				savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
				
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
					savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
				}, completion: { (completed) in
					
					UIView.animate(withDuration: 0.5, delay: 0.70, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
						savedLabel.layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
					}, completion: { (_) in
						savedLabel.removeFromSuperview()
							self.removeFromSuperview()
					})
				})
			}
		}
		saveDelegate.didSaveImage(image: previewImage)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		add(previewImageView)
		previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
		
		setupUI()
	}
	
	fileprivate func setupUI() {
		let stackView = UIStackView(arrangedSubviews: [saveButton, cancelButton, shareButton])
		stackView.distribution = .fillEqually
		
		self.add(stackView)
		stackView.anchor(top: nil, left: self.safeAreaLayoutGuide.leftAnchor, bottom: self.safeAreaLayoutGuide.bottomAnchor, right: self.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 45, paddingRight: 0, width: 0, height: 0)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
