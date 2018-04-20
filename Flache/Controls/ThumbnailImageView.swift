//
//  ThumbnailImageView.swift
//  Flache
//
//  Created by Patrick Bellot on 4/15/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import Photos

class ThumbnailImageView: UIImageView {
	
	func fetchPhotos () {
		let fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
		fetchOptions.fetchLimit = 1
	
		let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
		if fetchResult.count > 0 {
			fetchPhotoAtIndex(0, fetchResult)
		}
	}
	
	func fetchPhotoAtIndex(_ index: Int, _ fetchResult: PHFetchResult<PHAsset>) {
		let requestOptions = PHImageRequestOptions()
		requestOptions.isSynchronous = true
		
		let manager = PHImageManager()
		manager.requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: CGSize(width: 50, height: 50), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
			if let image = image {
					self.image = image
			}
		})
	}
}

