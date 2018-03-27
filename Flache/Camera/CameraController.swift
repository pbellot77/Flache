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
	
	var backCamera: AVCaptureDevice?
	var frontCamera: AVCaptureDevice?
	var captureDevice: AVCaptureDevice?
	
	var toggleCamera = false
	var zoomFactor: CGFloat = 1.0
	var flashMode = AVCaptureDevice.FlashMode.off
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	lazy var captureSession: AVCaptureSession = {
		let capture = AVCaptureSession()
		return capture
	}()
	
	let capturePhotoButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(#imageLiteral(resourceName: "CameraButton"), for: .normal)
		button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
		return button
	}()
	
	let switchCameraButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(#imageLiteral(resourceName: "SwitchCamera"), for: .normal)
		button.addTarget(self, action: #selector(handleCameraToggle), for: .touchUpInside)
		return button
	}()
	
	override func loadView() {
		super.loadView()
		
		setupInputs()
		setupCaptureSession()
		setupHUD()
	}

	// MARK: -- Private Functions
	fileprivate func setupInputs() {
		backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
		frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
		captureDevice = backCamera
	}
	
	fileprivate func setupHUD() {
		view.addSubview(capturePhotoButton)
		capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor,
															right: nil, paddingTop: 0, paddingLeft: 0,
															paddingBottom: 24, paddingRight: 0, width: 100, height: 100)
		capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		
		view.addSubview(switchCameraButton)
		switchCameraButton.anchor(top: nil, left: capturePhotoButton.rightAnchor,
															bottom: view.bottomAnchor, right: nil,
															paddingTop: 0, paddingLeft: 15, paddingBottom: 48,
															paddingRight: 0, width: 50, height: 50)
		
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(pinch:)))
		view.addGestureRecognizer(pinchGesture)
	}
	
	fileprivate func setupCaptureSession() {
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
		
		if captureDevice?.position == .front {
			let mirroredImage = flipImage(image: previewImage!)
			containerView.previewImageView.image = mirroredImage
		} else {
			containerView.previewImageView.image = previewImage
		}
		view.addSubview(containerView)
		containerView.anchor(top: view.topAnchor, left: view.leftAnchor,
												 bottom: view.bottomAnchor, right: view.rightAnchor,
												 paddingTop: 0, paddingLeft: 0, paddingBottom: 0,
												 paddingRight: 0, width: 0, height: 0)
	}
	
	func flipImage(image: UIImage) -> UIImage {
		guard let cgImage = image.cgImage else { return image }
		let flippedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
		return flippedImage
	}
	
	// MARK: -- Selector methods
	@objc func handleCapturePhoto() {
		let settings = AVCapturePhotoSettings()
		guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
		settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
		output.capturePhoto(with: settings, delegate: self)
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
