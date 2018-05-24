//
//  FLFilter.swift
//  Flache
//
//  Created by Patrick Bellot on 5/24/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit

open class FLFilter: UIImageView {
	
	open static let filterNameList = ["No Filter", "CIPhotoEffectChrome", "CIPhotoEffectFade",
														  "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir",
															"CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer",
															"CIVignette", "CIVignetteEffect", "CIUnsharpMask",
															"CIComicEffect", "CIDepthOfField", "CIEdges",
															"CISpotLight", ]
	var name: String?
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	public init(frame: CGRect, withImage image: UIImage, withContentMode mode: UIViewContentMode = .scaleAspectFill) {
		super.init(frame: frame)
		self.contentMode = mode
		self.clipsToBounds = true
		self.image = image
		let maskLayer = CAShapeLayer()
		self.layer.mask = maskLayer
		maskLayer.frame = CGRect(origin: .zero, size: self.image!.size)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func mask(_ maskRect: CGRect) {
		let maskLayer = CAShapeLayer()
		let path = CGMutablePath()
		path.addRect(maskRect)
		maskLayer.path = path
		self.layer.mask = maskLayer
	}
	
	func updateMask(_ maskRect: CGRect, newXPosition: CGFloat) {
		let maskLayer = CAShapeLayer()
		let path = CGMutablePath()
		var rect = maskRect
		rect.origin.x = newXPosition
		path.addRect(rect)
		maskLayer.path = path
		self.layer.mask = maskLayer
	}
	
	func updateMask(_ maskRect: CGRect, newYPosition: CGFloat) {
		let maskLayer = CAShapeLayer()
		let path = CGMutablePath()
		var rect = maskRect
		rect.origin.y = newYPosition
		path.addRect(rect)
		maskLayer.path = path
		self.layer.mask = maskLayer
	}
	
	func applyFilter(filterNamed name: String) -> FLFilter {
		let filter: FLFilter = self.copy() as! FLFilter
		filter.name = name
		
		if (FLFilter.filterNameList.contains(name) == false) {
			print("Filter does not exist")
			return filter
		} else if name == "No Filter" {
			return filter
		} else {
			let sourceImage = CIImage(image: filter.image!)
			let myFilter = CIFilter(name: name)
			myFilter?.setDefaults()
			myFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
			let context = CIContext(options: nil)
			let outputCGImage = context.createCGImage(myFilter!.outputImage!, from: myFilter!.outputImage!.extent)
			let filteredImage = UIImage(cgImage: outputCGImage!)
			filter.image = filteredImage
			return filter
		}
	}
	
	static func generateFilters(_ originalImage: FLFilter, filters: [String]) -> [FLFilter] {
		var finalFilters = [FLFilter]()
		_ = DispatchQueue.global(qos: .background)
		let syncQueue = DispatchQueue(label: "com.patrickBellot.Flache", attributes: .concurrent)
		
		DispatchQueue.concurrentPerform(iterations: filters.count) { (iteration) in
			let filterComputed = originalImage.applyFilter(filterNamed: filters[iteration])
			syncQueue.sync {
				finalFilters.append(filterComputed)
				return
			}
		}
		return finalFilters
	}
}

// MARK: - NSCopying protocol

extension FLFilter: NSCopying {
	public func copy(with zone: NSZone?) -> Any {
		guard let image = image else { fatalError("It seems that image is in fact mandatory") }
		let copy = FLFilter(frame: frame, withImage: image, withContentMode: contentMode)
		copy.backgroundColor = self.backgroundColor
		copy.name = name
		return copy
	}
}


