//
//  FLSliderDataSource.swift
//  Flache
//
//  Created by Patrick Bellot on 5/24/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit

public protocol FLSliderDataSource: class {
	func numberOfSlides(_ slider: FLSlider) -> Int
	func slider(_ slider: FLSlider, slideAtIndex index: Int) -> FLSlider
	func startAtIndex(_ slider: FLSlider) -> Int
}

// MARK: - Extension Datasource

extension FLSliderDataSource {
	func numberOfSlides(_ slider: FLSlider) -> Int {
		return 3
	}
	
	func slider(_ slider: FLSlider, slideAtIndex index: Int) -> FLSlider {
		let filter = FLSlider(frame: slider.frame)
		switch index {
		case 0:
			filter.backgroundColor = UIColor.black
			return filter
		case 1:
			filter.backgroundColor = UIColor.green
			return filter
		case 2:
			filter.backgroundColor = UIColor.yellow
			return filter
		default:
			filter.backgroundColor = UIColor.yellow
			return filter
		}
	}
	
	func startAtIndex(_ slider: FLSlider) -> Int {
		return 0
	}
}
