//
//  UIButton.swift
//  Flache
//
//  Created by Patrick Bellot on 5/15/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
	
	func pulsate() {
		let pulse = CASpringAnimation(keyPath: "transform.scale")
		pulse.duration = 0.6
		pulse.fromValue = 0.80
		pulse.toValue = 1.0
		pulse.autoreverses = true
		pulse.repeatCount = .infinity
		pulse.initialVelocity = 0.5
		pulse.damping = 1.0
		
		layer.add(pulse, forKey: nil)
	}
}
