//
//  UIViewController.swift
//  Flache
//
//  Created by Patrick Bellot on 5/21/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit

extension UIViewController {
	
	func presentAlertForCameraOrPhotoAccess(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (alert) in
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
		}))
		present(alert, animated: true, completion: nil)
	}
}
