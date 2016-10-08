//
//  ViewController.swift
//  KTCustomImagePicker
//
//  Created by Kunal Thacker on 28/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation

class CameraViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var delegate : KTCameraPickerDelegate?

    @IBOutlet var imagesCollectionView: UICollectionView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var previewView: PreviewView!

    @IBOutlet var collectionViewHideButton: UIButton!
    var isCollectionViewHidden = false

    @IBOutlet var imagesCollectionViewHeightConstraint: NSLayoutConstraint!

    // MARK: Constants
    let FETCHLIMIT = 20

    // MARK: Gallery objects

    var augmentedImage: UIImage?

    @IBOutlet var doneGalleryButton: UIButton!
    @IBOutlet var cancelGalleryButton: UIButton!
    @IBOutlet var doneAndCancelView: UIView!
    let cachingImageManager = PHCachingImageManager()
    let options = PHImageRequestOptions()
    var assets: [PHAsset] = [] {
        willSet {
            cachingImageManager.stopCachingImagesForAllAssets()
        }

        didSet {
            cachingImageManager.startCachingImages(for: self.assets,
                                                   targetSize: self.imageView.frame.size,
                                                   contentMode: .default,
                                                   options: nil)
            cachingImageManager.startCachingImages(for: self.assets, targetSize: CGSize(width: 70, height: 70), contentMode: .default, options: self.options)
        }
    }

    var fetchResults : PHFetchResult<PHAsset>!

    var userSelectedImages: [UIImage] = []

    // MARK: Camera Objects

    let session = AVCaptureSession()
    var authorizationStatus: AVAuthorizationStatus = .notDetermined
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    var videoDeviceInput: AVCaptureDeviceInput!
    var photoOutput : AVCaptureOutput!
    var captureConnection : AVCaptureConnection?
    var flashMode : AVCaptureFlashMode = AVCaptureFlashMode.auto
    var devicePosition : AVCaptureDevicePosition = AVCaptureDevicePosition.back
    @IBOutlet var flashView: UIView!
    var imageCaptured = false
    
    // MARK: Image Picker

    let imagePicker = UIImagePickerController()

    // MARK: Overlay Objects

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var flashButton: UIButton!
    @IBOutlet var flashOptionsView: UIView!
    @IBOutlet var flashOptionsViewHeightConstraint: NSLayoutConstraint!
    var flashViewHidden = true
    var torchOn = false
    @IBOutlet var torchButton: UIButton!
    var overlayImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let nib = UINib(nibName: "PhotosCollectionViewCell", bundle: nil)
        self.imagesCollectionView.register(nib, forCellWithReuseIdentifier: "PhotosCollectionViewCell")
        
        previewView.session = self.session
        self.imageView.isHidden = true
        self.setupOverlay()
        self.setupDoneAndCancelView()

        if overlayImageView != nil {
            self.overlayImageView?.isHidden = false
            self.view.insertSubview(self.overlayImageView!, aboveSubview: self.previewView)

        }

        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.scrollDirection = .horizontal
        self.imagesCollectionView.collectionViewLayout = layout

        self.options.isSynchronous = false
        self.options.deliveryMode = .highQualityFormat
        self.options.isNetworkAccessAllowed = true
        self.imageView.contentMode = .scaleAspectFit
        self.flashView.layer.opacity = 0.0
        self.doneAndCancelView.isHidden = true


        if #available(iOS 10.0, *) {
            photoOutput = AVCapturePhotoOutput()
        } else {
            // Fallback on earlier versions
            photoOutput = AVCaptureStillImageOutput()
        }

        PHPhotoLibrary.shared().register(self)
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self


        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.fetchLimit = FETCHLIMIT


        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions) as PHFetchResult<PHAsset>
        var assetResult: [PHAsset] = []
        results.enumerateObjects ({ (object, _, _) in
            assetResult.append(object)

        })
        self.fetchResults = results
        self.assets = assetResult

        self.checkCameraPermissions()

    }

    override func viewDidAppear(_ animated: Bool) {
        switch self.authorizationStatus {
        case .authorized:
            self.session.startRunning()


        case .denied:
            DispatchQueue.main.async { [unowned self] in
                let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { action in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }
                }))

                self.present(alertController, animated: true, completion: nil)
            }

        default:
            DispatchQueue.main.async { [unowned self] in
                let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))

                self.present(alertController, animated: true, completion: nil)
            }
        }
    }


    func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            self.authorizationStatus = .authorized
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (success) in
                if (success) {
                    self.authorizationStatus = .notDetermined
                }
            })
        case .denied:
            self.authorizationStatus = .denied
        default:
            self.authorizationStatus = .denied
        }

        sessionQueue.async {
            self.setupSession()
        }



    }

    func setupSession() {

        if (self.authorizationStatus != .authorized) {
            return
        }
        self.session.beginConfiguration()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        do {
            var defaultVideoDevice: AVCaptureDevice?


            if let cameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
                defaultVideoDevice = cameraDevice
                self.devicePosition = cameraDevice.position
            }



            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)


            if self.session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            }
            else {
                self.authorizationStatus = .notDetermined
                self.session.commitConfiguration()
                return
            }

            self.captureConnection = AVCaptureConnection.init(inputPorts: self.videoDeviceInput.ports, output: self.photoOutput)

            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
        }
        catch {
            self.authorizationStatus = .notDetermined
            self.session.commitConfiguration()
            return
        }
        self.session.commitConfiguration()



    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCollectionViewCell", for: indexPath) as! PhotosCollectionViewCell
        if (indexPath.row == 0) {
            cell.imageView.image = #imageLiteral(resourceName: "CameraIcon")
            cell.imageView.contentMode = .scaleAspectFit
            return cell
        }
        var count = self.assets.count + self.userSelectedImages.count
        if count > FETCHLIMIT {
            count = FETCHLIMIT
        }
        if (indexPath.row == count + 1) {
            cell.imageView.image = #imageLiteral(resourceName: "GalleryIcon")
            return cell
        }

        if (indexPath.row == 1 && self.imageCaptured) {
            self.previewView.isHidden = true
            self.doneAndCancelView.isHidden = false
            cachingImageManager.requestImage(for: assets[indexPath.row - 1], targetSize: self.imageView.frame.size, contentMode: .default, options: self.options, resultHandler: { (image, info) in

                UIView.transition(with: self.imageView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    self.imageView.isHidden = false
                    self.imageView.image = image
                    }, completion: nil)
            })
            self.imageCaptured = false
        }

        cell.imageView.contentMode = .scaleAspectFit

        if (indexPath.row <= count && indexPath.row > count - self.userSelectedImages.count) {
            let index = indexPath.row - (count - self.userSelectedImages.count) - 1
            cell.imageView.image = self.userSelectedImages[index]
            return cell
        }


        cachingImageManager.requestImage(for: assets[indexPath.row - 1], targetSize: CGSize(width: 70, height: 70), contentMode: .default, options: self.options, resultHandler: { (image, info) in
            cell.imageView.image = image
        })

        return cell

    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = self.assets.count + self.userSelectedImages.count
        if count > FETCHLIMIT {
            count = FETCHLIMIT
        }
        return count + 2
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var count = self.assets.count + self.userSelectedImages.count
        if count > FETCHLIMIT {
            count = FETCHLIMIT
        }
        if indexPath.row == 0 {
            self.imageView.isHidden = true
            UIView.transition(with: self.previewView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                self.previewView.isHidden = false
                self.doneAndCancelView.isHidden = true
                }, completion: { (success) in
                    

            })

        } else if (indexPath.row == count + 1) {
            self.present(self.imagePicker, animated: true, completion: nil)
        } else {
            self.previewView.isHidden = true
            self.doneAndCancelView.isHidden = false
            if (indexPath.row <= count && indexPath.row > count - self.userSelectedImages.count) {
                let index = indexPath.row - (count - self.userSelectedImages.count) - 1
                UIView.transition(with: self.imageView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    self.imageView.isHidden = false
                    self.imageView.image = self.userSelectedImages[index]
                    }, completion: nil)

            } else {
                cachingImageManager.requestImage(for: assets[indexPath.row - 1], targetSize: self.imageView.frame.size, contentMode: .default, options: self.options, resultHandler: { (image, info) in

                    UIView.transition(with: self.imageView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                        self.imageView.isHidden = false
                        self.imageView.image = image
                        }, completion: nil)
                })
            }
        }

    }

    // MARK: Camera Overlay logic

    @IBAction func capturePhoto(_ sender: AnyObject) {
        self.imageCaptured = true
        if #available(iOS 10.0, *) {
            let photoSettings = AVCapturePhotoSettings()
            if !self.flashButton.isHidden {
                photoSettings.flashMode = self.flashMode
            }
            photoSettings.isHighResolutionPhotoEnabled = true

            if photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
            }
            if let output = self.photoOutput as? AVCapturePhotoOutput {
                output.isHighResolutionCaptureEnabled = true
                output.capturePhoto(with: photoSettings, delegate: self)
            }

        } else {
            if let output = self.photoOutput as? AVCaptureStillImageOutput {
                output.captureStillImageAsynchronously(from: self.captureConnection!, completionHandler: { (sampleBuffer, error) in
                    DispatchQueue.main.async {
                        if (self.flashButton.isHidden) {
                            self.flashView.backgroundColor = UIColor.black
                        } else {
                            if self.flashMode == .on {
                                self.flashView.backgroundColor = UIColor.white
                            } else {
                                self.flashView.backgroundColor = UIColor.black
                            }
                        }
                        self.flashView.layer.opacity = 1.0
                        UIView.animate(withDuration: 0.25, animations: {
                            self.flashView.layer.opacity = 0.0
                        })
                    }
                    if error != nil {
                        if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) {
                            if let image = UIImage(data: imageData) {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }
                        }
                    }
                })
            }
        }


    }

    @IBAction func hideCollectionView(_ sender: AnyObject) {
        if !self.isCollectionViewHidden {
            self.collectionViewHideButton.setImage(#imageLiteral(resourceName: "UpArrow"), for: .normal)
            self.view.layoutIfNeeded()
            self.imagesCollectionViewHeightConstraint.constant = 0
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (_) in
                    self.isCollectionViewHidden = true
            })
        } else {
            self.collectionViewHideButton.setImage(#imageLiteral(resourceName: "DownArrow"), for: .normal)

            self.view.layoutIfNeeded()
            self.imagesCollectionViewHeightConstraint.constant = 70
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (_) in
                    self.isCollectionViewHidden = false
            })
        }
    }



    func setupOverlay() {
        self.cancelButton.layer.cornerRadius = 15.0
        self.cancelButton.layer.borderWidth = 1.0
        self.cancelButton.layer.borderColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        self.cancelButton.backgroundColor = self.cancelButton.backgroundColor?.withAlphaComponent(0.25)


        self.flashOptionsView.layer.cornerRadius = 10.0
        self.flashOptionsView.layer.borderWidth = 1.0
        self.flashOptionsView.layer.borderColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        let color = self.flashOptionsView.backgroundColor
        self.flashOptionsView.backgroundColor = color?.withAlphaComponent(0.5)

        self.flashOptionsViewHeightConstraint.constant = 0.0
        self.flashOptionsView.layoutIfNeeded()


    }

    func setupDoneAndCancelView() {
        self.cancelGalleryButton.layer.cornerRadius = 15.0
        self.cancelGalleryButton.layer.borderWidth = 1.0
        self.cancelGalleryButton.layer.borderColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        self.cancelGalleryButton.backgroundColor = self.cancelGalleryButton.backgroundColor?.withAlphaComponent(0.25)

        self.doneGalleryButton.layer.cornerRadius = 15.0
        self.doneGalleryButton.layer.borderWidth = 1.0
        self.doneGalleryButton.layer.borderColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        self.doneGalleryButton.backgroundColor = self.doneGalleryButton.backgroundColor?.withAlphaComponent(0.25)

        let color = self.doneAndCancelView.backgroundColor
        self.doneAndCancelView.backgroundColor = color?.withAlphaComponent(0.5)


    }

    @IBAction func flashButtonTapped(_ sender: AnyObject) {
        self.view.layoutIfNeeded()
        if self.flashViewHidden {
            self.flashOptionsViewHeightConstraint.constant = 90
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (_) in
                    self.flashViewHidden = false
                    self.view.bringSubview(toFront: self.flashOptionsView)
            })
        } else {
            self.flashOptionsViewHeightConstraint.constant = 0.0
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (_) in
                    self.flashViewHidden = true
            })
        }
    }

    @IBAction func flashOnTapped(_ sender: AnyObject) {
        if (self.videoDeviceInput.device.hasTorch) {
            self.flashMode = .on
            do {
                try self.videoDeviceInput.device.lockForConfiguration()
                self.videoDeviceInput.device.flashMode = .on
                self.videoDeviceInput.device.unlockForConfiguration()
            } catch {
                self.videoDeviceInput.device.unlockForConfiguration()
            }
        }
        self.view.layoutIfNeeded()
        self.flashButton.setImage(#imageLiteral(resourceName: "FlashOn"), for: .normal)
        self.flashOptionsViewHeightConstraint.constant = 0.0
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.flashViewHidden = true
        })
    }


    @IBAction func flashOffTapped(_ sender: AnyObject) {
        if (self.videoDeviceInput.device.hasFlash) {
            self.flashMode = .off
            do {
                try self.videoDeviceInput.device.lockForConfiguration()
                self.videoDeviceInput.device.flashMode = .off
                self.videoDeviceInput.device.unlockForConfiguration()
            } catch {
                self.videoDeviceInput.device.unlockForConfiguration()
            }
        }
        self.view.layoutIfNeeded()
        self.flashButton.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
        self.flashOptionsViewHeightConstraint.constant = 0.0
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.flashViewHidden = true
        })
    }


    @IBAction func flashAutoTapped(_ sender: AnyObject) {
        if self.videoDeviceInput.device.hasFlash {
            self.flashMode = .auto
            do {
                try self.videoDeviceInput.device.lockForConfiguration()
                self.videoDeviceInput.device.flashMode = .off
                self.videoDeviceInput.device.unlockForConfiguration()
            } catch {
                self.videoDeviceInput.device.unlockForConfiguration()
            }
        }
        self.view.layoutIfNeeded()
        self.flashButton.setImage(#imageLiteral(resourceName: "FlashOn"), for: .normal)
        self.flashOptionsViewHeightConstraint.constant = 0.0
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.flashViewHidden = true
        })
    }

    
    @IBAction func switchCamera(_ sender: AnyObject) {
        if !self.flashViewHidden {
            self.flashOptionsViewHeightConstraint.constant = 0.0
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (_) in
                    self.flashViewHidden = true
            })
        }

        self.session.beginConfiguration()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        do {
            var defaultVideoDevice: AVCaptureDevice?

            if let availableDevices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
                for device in availableDevices {
                    if device.position != self.videoDeviceInput.device.position {
                        defaultVideoDevice = device
                        if (device.hasFlash) {
                            self.flashButton.isHidden = false
                        } else {
                            self.flashButton.isHidden = true
                        }
                        if (device.hasTorch) {
                            self.torchButton.isHidden = false
                        } else {
                            self.torchButton.isHidden = true
                        }
                        break
                    }
                }
            }

            self.session.removeInput(self.videoDeviceInput)



            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)

            if self.session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput


            }
            else {
                self.authorizationStatus = .notDetermined
                self.session.commitConfiguration()
                return
            }

            self.captureConnection = AVCaptureConnection.init(inputPorts: self.videoDeviceInput.ports, output: self.photoOutput)

            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
        }
        catch {
            self.authorizationStatus = .notDetermined
            self.session.commitConfiguration()
            return
        }
        self.session.commitConfiguration()


    }

    @IBAction func switchTorch(_ sender: AnyObject) {
        if self.torchOn {
            if self.videoDeviceInput.device.hasTorch {
                self.torchButton.setImage(#imageLiteral(resourceName: "TorchOff"), for: .normal)
                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                    self.videoDeviceInput.device.torchMode = .off
                    self.videoDeviceInput.device.unlockForConfiguration()
                    self.torchOn = false

                } catch {
                    self.videoDeviceInput.device.unlockForConfiguration()
                }
            }
        } else {
            if self.videoDeviceInput.device.hasTorch {
                self.torchButton.setImage(#imageLiteral(resourceName: "TorchOn"), for: .normal)
                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                    self.videoDeviceInput.device.torchMode = .on
                    self.videoDeviceInput.device.unlockForConfiguration()
                    self.torchOn = true
                } catch {
                    self.videoDeviceInput.device.unlockForConfiguration()
                }
            }
        }
    }

    // MARK: Delegate calls

    @IBAction func cameraCancelTapped(_ sender: AnyObject) {
        delegate?.cameraCancelTapped(VC: self)

    }

    @IBAction func galleryCancelTapped(_ sender: AnyObject) {
        delegate?.galleryCancelTapped(VC: self)
    }


    @IBAction func galleryDoneTapped(_ sender: AnyObject) {
        self.overlayImageView?.isHidden = false
        self.doneAndCancelView.isHidden = true
        self.collectionViewHideButton.isHidden = true
        self.imagesCollectionView.isHidden = true
        self.augmentedImage = snapshotImage()
        delegate?.galleryDoneTapped(VC: self)

    }

    func snapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0.0)
        self.view.layer.render(in: (UIGraphicsGetCurrentContext()!))
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultingImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    @available(iOS 10.0, *)
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }

        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            if let image = UIImage(data: dataImage) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }

    @available(iOS 10.0, *)
    func capture(_ captureOutput: AVCapturePhotoOutput, willCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        DispatchQueue.main.async {
            if (self.flashButton.isHidden) {
                self.flashView.backgroundColor = UIColor.black
            } else {
                if self.flashMode == .on {
                    self.flashView.backgroundColor = UIColor.white
                } else {
                    self.flashView.backgroundColor = UIColor.black
                }
            }
            self.flashView.layer.opacity = 1.0
            UIView.animate(withDuration: 0.25, animations: {
                self.flashView.layer.opacity = 0.0
            })
        }
    }

}

extension CameraViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {

        guard let changes = changeInstance.changeDetails(for: fetchResults)
            else { return }

        DispatchQueue.main.sync {
            fetchResults = changes.fetchResultAfterChanges
            var assetResult: [PHAsset] = []
            fetchResults.enumerateObjects ({ (object, _, _) in
                assetResult.append(object)

            })
            self.assets = assetResult
            if changes.hasIncrementalChanges {
                guard let collectionView = self.imagesCollectionView else { fatalError() }
                collectionView.performBatchUpdates({

                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0 + 1, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0 + 1, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0 + 1, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex + 1, section: 0),
                                                to: IndexPath(item: toIndex + 1, section: 0))
                    }
                })
                if (imageCaptured) {
                    self.imagesCollectionView.reloadData()
                }
            } else {
                self.imagesCollectionView.reloadData()
            }
            self.cachingImageManager.stopCachingImagesForAllAssets()
        }
    }
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if (image == nil ) {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        self.userSelectedImages.append(image!)
        if self.userSelectedImages.count > FETCHLIMIT / 2 {
            self.userSelectedImages.remove(at: 0)
        }
        picker.dismiss(animated: true, completion: {
            self.previewView.isHidden = true
            self.doneAndCancelView.isHidden = false
            UIView.transition(with: self.imageView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                self.imageView.isHidden = false
                self.imageView.image = image
                self.imagesCollectionView.reloadData()
                }, completion: nil)

        })

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

