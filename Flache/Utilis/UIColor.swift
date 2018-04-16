//
//  UIColor.swift
//  Flache
//
//  Created by Patrick Bellot on 4/16/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit

extension UIColor {
	
	static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
		return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
	}
	
	static func mainBlue() -> UIColor {
		return UIColor.rgb(red: 29, green: 29, blue: 144)
	}
}
