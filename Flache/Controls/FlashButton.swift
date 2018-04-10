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
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupFlash(tapCount)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		tapCount += 1
		if tapCount > 2 {
			tapCount = 0
		}
		print(tapCount)
		setupFlash(tapCount)
	}
	
	fileprivate func setupFlash(_ count: Int) {
		let settings = AVCapturePhotoSettings()
		if tapCount == 0 {
			settings.flashMode = .off
			self.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
		}
		if tapCount == 1 {
			settings.flashMode = .on
			self.setImage(#imageLiteral(resourceName: "FlashOn"), for: .normal)
		}
		if tapCount == 2 {
			settings.flashMode = .auto
			self.setImage(#imageLiteral(resourceName: "FlashAuto"), for: .normal)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
