//
//  CaptureController.swift
//  Flache
//
//  Created by Patrick Bellot on 3/30/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import AVFoundation


enum CameraPosition {
	case back, front
}

enum FlashMode: Int {
	case off, on, auto
}

enum CameraOutput {
	case photo, video
}

class CaptureController: UIViewController {

	var captureDevice: AVCaptureDevice?
	var frontCamera: AVCaptureDevice?
	var backCamera: AVCaptureDevice?
	var toggleCamera = false
	var zoomFactor: CGFloat = 1.0
	
	lazy var captureSession: AVCaptureSession = {
		let capture = AVCaptureSession()
		return capture
	}()
	
	let captureButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(#imageLiteral(resourceName: "CameraButton"), for: .normal)
		button.addTarget(self, action: #selector(handleCapture), for: .touchUpInside)
		return button
	}()
	
	let switchCameraButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(#imageLiteral(resourceName: "SwitchCamera"), for: .normal)
		button.addTarget(self, action: #selector(handleCameraToggle), for: .touchUpInside)
		return button
	}()
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func loadView() {
		super.loadView()
		
		setupHUD()
		captureDevice = setupCaptureDevice(.back)
	}
	
	fileprivate func setupCaptureDevice(_ cameraPosition: CameraPosition) -> AVCaptureDevice {
		switch cameraPosition {
		case .back:
			backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
		case .front:
			frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
		}
	}
	
	fileprivate func setupHUD() {
		view.add(captureButton)
		captureButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor,
															right: nil, paddingTop: 0, paddingLeft: 0,
															paddingBottom: 24, paddingRight: 0, width: 100, height: 100)
		captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		
		view.add(switchCameraButton)
		switchCameraButton.anchor(top: nil, left: nil,
															bottom: view.bottomAnchor, right: view.rightAnchor,
															paddingTop: 0, paddingLeft: 0, paddingBottom: 48,
															paddingRight: 16, width: 50, height: 50)
		
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(pinch:)))
		view.addGestureRecognizer(pinchGesture)
	}
	
	@objc func handleCapture() {
		
	}
	
	@objc func handleCameraToggle() {
		captureSession.beginConfiguration()
		captureDevice = toggleCamera ? backCamera : frontCamera
		toggleCamera = !toggleCamera
		captureSession.inputs.forEach { captureSession.removeInput($0) }
		do {
			let newInput = try AVCaptureDeviceInput(device: captureDevice!)
			if captureSession.canAddInput(newInput) {
				captureSession.addInput(newInput)
			}
		} catch let err {
			print("Could not toggle camera:", err)
		}
		if captureSession.canAddOutput(output) {
			captureSession.addOutput(output)
		}
		captureSession.commitConfiguration()
	}
	
	@objc func zoom(pinch: UIPinchGestureRecognizer){
		func minMaxZoom(_ factor: CGFloat) -> CGFloat { return min(max(factor, 1.0), (captureDevice?.activeFormat.videoMaxZoomFactor)!) }
		func update(scale factor: CGFloat){
			do {
				try captureDevice?.lockForConfiguration()
				defer { captureDevice?.unlockForConfiguration() }
				captureDevice?.videoZoomFactor = factor
			} catch let err {
				print("Could not setup zoom:", err)
			}
		}
		let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)
		
		switch pinch.state {
		case .began: fallthrough
		case .changed: update(scale: newScaleFactor)
		case .ended:
			zoomFactor = minMaxZoom(newScaleFactor)
			update(scale: zoomFactor)
		default:
			break
		}
	}
}
