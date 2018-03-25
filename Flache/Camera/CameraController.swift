//
//  CameraController.swift
//  Flache
//
//  Created by Patrick Bellot on 3/23/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {
	
	// MARK: -- Properties
	let output = AVCapturePhotoOutput()
	let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
	
	var zoomFactor: CGFloat = 1.0
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	let capturePhotoButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(#imageLiteral(resourceName: "CameraButton"), for: .normal)
		button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
		return button
	}()
	
	override func loadView() {
		super.loadView()
		
		setupCaptureSession()
		setupHUD()
	}

	// MARK: -- Private Functions
	fileprivate func setupHUD() {
		view.addSubview(capturePhotoButton)
		capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 100, height: 100)
		capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(pinch:)))
		view.addGestureRecognizer(pinchGesture)
	}
	
	fileprivate func setupCaptureSession() {
		let captureSession = AVCaptureSession()
		
		do {
			let input = try AVCaptureDeviceInput(device: captureDevice!)
			if captureSession.canAddInput(input) {
				captureSession.addInput(input)
			}
		} catch let err {
			print("Could not setup camera input:", err)
		}
		
		if captureSession.canAddOutput(output){
			captureSession.addOutput(output)
		}
		
		let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.frame
		view.layer.addSublayer(previewLayer)
		
		captureSession.startRunning()
	}
	
	// MARK: -- Functions
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let imageData = photo.fileDataRepresentation() else { return }
		
		let previewImage = UIImage(data: imageData)
		let containerView = PreviewPhotoContainerView()
		
		containerView.previewImageView.image = previewImage
		view.addSubview(containerView)
		containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
	}
	
	// MARK: -- Selector methods
	@objc func handleCapturePhoto() {
		let settings = AVCapturePhotoSettings()
		
		guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
		settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
		
		output.capturePhoto(with: settings, delegate: self)
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
