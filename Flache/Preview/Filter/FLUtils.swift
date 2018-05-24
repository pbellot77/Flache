//
//  FLUtils.swift
//  Flache
//
//  Created by Patrick Bellot on 5/24/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit

open class FLUtils {
	
	open static let screenSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
	
	// Allow you to take a screenshot of screen
	open static func screenShot(_ view: UIView?) -> UIImage? {
		guard let imageView = view else { return nil }
		
		UIGraphicsBeginImageContextWithOptions(imageView.frame.size, true, 0.0)
		imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}
