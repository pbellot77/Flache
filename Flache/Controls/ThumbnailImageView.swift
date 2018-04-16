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
	
	func getLastImage(){
		let fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		fetchOptions.fetchLimit = 1
		
		let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
		if fetchResult.count > 0 {
			fetchPhotoAtIndex(0, fetchResult: fetchResult)
		}
	}
	
	func fetchPhotoAtIndex(_ index: Int, fetchResult: PHFetchResult<PHAsset>) {
		let requestOptions = PHImageRequestOptions()
		requestOptions.isSynchronous = true
		
		PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: requestOptions) { (image, _) in
			if let image = image {
				DispatchQueue.main.async {
					self.image = image
					self.getLastImage()
				}
			}
		}
	}
}
