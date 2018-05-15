//
//  FlashButton.swift
//  Flache
//
//  Created by Patrick Bellot on 4/10/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import AVFoundation

class FlashButton: UIButton {

	var tapCount = 0
	var currentFlashMode: AVCaptureDevice.FlashMode = .off
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupFlashIcon(tapCount)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		tapCount += 1
		if tapCount > 2 {
			tapCount = 0
		}
		setupFlashIcon(tapCount)
		updateFlash(tapCount: tapCount)
	}
	
	func updateFlash(tapCount: Int){
		if tapCount == 0 {
			currentFlashMode = .off
			print("The flashMode is:" ,currentFlashMode)
		} else if tapCount == 1 {
			currentFlashMode = .on
			print("The flashMode is:" ,currentFlashMode)
		} else if tapCount == 2 {
			currentFlashMode = .auto
			print("The flashMode is:" ,currentFlashMode)
		}
	}
	
	fileprivate func setupFlashIcon(_ count: Int){
		if tapCount == 0 {
			self.setImage(#imageLiteral(resourceName: "flashOff2"), for: .normal)
		}
		if tapCount == 1 {
			self.setImage(#imageLiteral(resourceName: "flashOn2"), for: .normal)
		}
		if tapCount == 2 {
			self.setImage(#imageLiteral(resourceName: "flashAuto2"), for: .normal)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
