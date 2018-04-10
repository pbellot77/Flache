//
//  FlashButton.swift
//  Flache
//
//  Created by Patrick Bellot on 4/10/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import AVFoundation

enum FlashMode: Int {
	case off = 0, on, auto
}

class FlashButton: UIButton {
	
	var currentFlashMode: FlashMode = .off
	
	lazy var button: UIButton = {
		let button = UIButton(type: .system)
		button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
	
		setFlashMode(currentFlashMode)
	}
	
	@objc func handleTap() {
		if currentFlashMode == .off {
			currentFlashMode = .on
		} else if currentFlashMode == .on {
			currentFlashMode = .auto
		} else {
			currentFlashMode = .off
		}
	}
	
	fileprivate func setFlashMode(_ flashMode: FlashMode) {
		let settings = AVCapturePhotoSettings()
		switch flashMode {
		case .off:
			settings.flashMode = .off
			self.button.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
		case .on:
			settings.flashMode = .on
			self.button.setImage(#imageLiteral(resourceName: "FlashOn"), for: .normal)
		case .auto:
			settings.flashMode = .auto
			self.button.setImage(#imageLiteral(resourceName: "FlashAuto"), for: .normal)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
