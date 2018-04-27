//
//  PhotoController.swift
//  Flache
//
//  Created by Patrick Bellot on 3/23/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class PhotoController: UIViewController, AVCapturePhotoCaptureDelegate {
	
	// MARK: -- Properties
	let photoOutput = AVCapturePhotoOutput()
	
	var backCamera: AVCaptureDevice?
	var frontCamera: AVCaptureDevice?
	var captureDevice: AVCaptureDevice?
	
	var toggleCamera = false
	var zoomFactor: CGFloat = 1.0
	var flashMode: AVCaptureDevice.FlashMode?
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	lazy var captureSession: AVCaptureSession = {
		let capture = AVCaptureSession()
		return capture
	}()
	
	let flashButton: FlashButton = {
		let button = FlashButton(type: .system)
		return button
	}()
	
	let thumbnailImage: ThumbnailImageView = {
		let iv = ThumbnailImageView()
		iv.backgroundColor = .white
		iv.contentMode = .scaleAspectFill
		iv.layer.cornerRadius = 10
		iv.clipsToBounds = true
		iv.isUserInteractionEnabled = true
		iv.fetchPhotos()
		return iv
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
		
		checkPermissions()
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touchPoint = touches.first! as UITouch
		let screenSize = view.bounds.size
		let focusPoint = CGPoint(x: touchPoint.location(in: view).y / screenSize.height, y: 1.0 - touchPoint.location(in: view).x / screenSize.height)
		
		if let device = captureDevice {
			do {
				try device.lockForConfiguration()
				if device.isFocusPointOfInterestSupported && device.isExposurePointOfInterestSupported {
					device.focusPointOfInterest = focusPoint
					device.focusMode = .autoFocus
					device.exposurePointOfInterest = focusPoint
					device.exposureMode = .autoExpose
				}
				device.unlockForConfiguration()
			} catch {
				print("Could not lock configuration")
			}
		}
	}
	
	// MARK: -- Private Functions
	fileprivate func checkPermissions() {
		let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
		switch authStatus {
		case .authorized:
			setupCaptureDevice()
			setupCaptureSession()
			setupHUD()
		case .denied:
			alertPromptToAllowCameraAccess()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { (cameraAccess) in
				print(cameraAccess)
				
				if cameraAccess {
					DispatchQueue.main.async {
						self.setupCaptureDevice()
						self.setupCaptureSession()
						self.setupHUD()
						self.thumbnailImage.fetchPhotos()
					}
				} else {
					DispatchQueue.main.async {
						self.alertPromptToAllowCameraAccess()
					}
				}
			}
		default:
			setupCaptureDevice()
			setupCaptureSession()
			setupHUD()
		}
	}
	
	fileprivate func alertPromptToAllowCameraAccess() {
		let alert = UIAlertController(title: "Error", message: "Camera access is required", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
		alert.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { (alert) in
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
		}))
		present(alert, animated: true, completion: nil)
	}
	
	fileprivate func setupCaptureDevice() {
		let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
																														mediaType: .video, position: .unspecified)
		discoverySession.devices.forEach { (device) in
			if device.position == .back {
				backCamera = device
			} else if device.position == .front {
				frontCamera = device
			}
		}
		captureDevice = backCamera
	}
	
	fileprivate func setupHUD() {
		view.add(capturePhotoButton)
		capturePhotoButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil,
															paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 100, height: 100)
		capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		
		view.add(switchCameraButton)
		switchCameraButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor,
															paddingTop: 0, paddingLeft: 0, paddingBottom: 48, paddingRight: 16, width: 50, height: 50)
		
		view.add(flashButton)
		flashButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor,
											 paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 50, height: 50)
		
		view.add(thumbnailImage)
		thumbnailImage.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil,
													paddingTop: 0, paddingLeft: 16, paddingBottom: 48, paddingRight: 0, width: 50, height: 50)
		
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(pinch:)))
		view.addGestureRecognizer(pinchGesture)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
		thumbnailImage.addGestureRecognizer(tapGesture)
	}
	
	fileprivate func setupCaptureSession() {
		guard let device = captureDevice else { return }
		do {
			let input = try AVCaptureDeviceInput(device: device)
			if captureSession.canAddInput(input) {
				captureSession.addInput(input)
			}
		} catch let err {
			print("Could not setup camera input:", err)
		}
		if captureSession.canAddOutput(photoOutput){
			captureSession.addOutput(photoOutput)
		}
		let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.frame
		view.layer.addSublayer(previewLayer)
		captureSession.startRunning()
	}
	
	// MARK: -- Functions
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let imageData = photo.fileDataRepresentation() else { return }
		guard let previewImage = UIImage(data: imageData) else { return }
		
		let containerView = PreviewPhotoContainerView()
		
		if captureDevice?.position == .front {
			let mirroredImage = flipImage(image: previewImage)
			containerView.previewImageView.image = mirroredImage
		} else {
			containerView.previewImageView.image = previewImage
		}
		view.add(containerView)
		containerView.anchor(top: view.topAnchor, left: view.leftAnchor,
												 bottom: view.bottomAnchor, right: view.rightAnchor,
												 paddingTop: 0, paddingLeft: 0, paddingBottom: 0,
												 paddingRight: 0, width: 0, height: 0)
		containerView.saveDelegate = self
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
		if (captureDevice?.hasFlash)! {
			settings.flashMode = flashButton.currentFlashMode
			print("Flash detected on this device")
		} else {
			print("Flash not available on this device")
		}
		photoOutput.capturePhoto(with: settings, delegate: self)
	}
	
	@objc func handleCameraToggle() {
		captureSession.beginConfiguration()
		captureDevice = toggleCamera ? backCamera : frontCamera
		toggleCamera.toggle()
		captureSession.inputs.forEach { captureSession.removeInput($0) }
		do {
			let newInput = try AVCaptureDeviceInput(device: captureDevice!)
			if captureSession.canAddInput(newInput) {
				self.captureSession.addInput(newInput)
			}
		} catch let err {
			print("Could not toggle camera:", err)
		}
		if captureSession.canAddOutput(photoOutput) {
			captureSession.addOutput(photoOutput)
		}
		captureSession.commitConfiguration()
	}
	
	@objc func handleTap(tap: UITapGestureRecognizer) {
		let layout = UICollectionViewFlowLayout()
		let photoCollectionView = PhotoCollectionView(collectionViewLayout: layout)
		let photoCollectionNavController = UINavigationController(rootViewController: photoCollectionView)
		self.present(photoCollectionNavController, animated: true, completion: nil)
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

extension PhotoController: SaveDelegate {
	
	func didSaveImage(image: UIImage) {
		thumbnailImage.image = image
	}
}
