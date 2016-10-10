//
//  ViewController.swift
//  Camera Test
//
//  Created by Kunal Thacker on 06/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit
import CoreGraphics
import GoogleMobileAds


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, CustomOverlayDelegate, GalleryImageAugmentDelegate,GADBannerViewDelegate, KTCameraPickerDelegate, ProductsCollectionViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet var menuViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var hideMenuFullHeightConstraint: NSLayoutConstraint!
    @IBOutlet var hideMenuQuarterHeightConstraint: NSLayoutConstraint!

    @IBOutlet var shareMenuTopConstraint: NSLayoutConstraint!
    @IBOutlet var changeProductTopConstraint: NSLayoutConstraint!
    @IBOutlet var augmentRealityTopConstraint: NSLayoutConstraint!




    @IBOutlet var menuView: UIView!

    @IBOutlet weak var cameraImageView: UIImageView!
    var userImageSet: Bool = false
    var initialBounds: CGRect = CGRect.zero
    var initialBoundsForRotation: CGRect = CGRect.zero
    var lastRotation: CGFloat = 0.0
    let imagePicker = UIImagePickerController.init()
    var overLayView: UIImageView!
    let cameraHelper = CameraHelper.init()
    let overlayPicker = UIImagePickerController.init()
    var galleryImage: UIImage? = nil

    var menuExpanded = false

    @IBOutlet var hideMenuLabel: UILabel!

    @IBOutlet var hideMenuView: UIView!
    @IBOutlet var shareMenuView: UIView!
    @IBOutlet var changeProductMenuView: UIView!
    @IBOutlet var augmentRealityMenuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupGestureRecognizers()
        self.collapse()
        self.view.backgroundColor = UIColor.black

        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.delegate = self
        self.cameraImageView.contentMode = UIViewContentMode.scaleAspectFit


        
        // overLayView.backgroundColor = UIColor(patternImage: UIImage(named: "watchImage.jpg")!)
        var image = #imageLiteral(resourceName: "Watch1")
        var (r,g,b,a,t) = image.getAverageOfCorners()
        overLayView = UIImageView(image: cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: image, withTolerance: Float(t)) )

        overLayView.frame = CGRect(x: self.view.frame.width/2 - 100, y: self.view.frame.height/2 - 100, width: UIScreen.main.bounds.size.width/3, height: UIScreen.main.bounds.size.height/3)
        overLayView.contentMode = UIViewContentMode.scaleAspectFill
        overLayView.clipsToBounds = true


        overLayView.isUserInteractionEnabled = true
        overLayView.isMultipleTouchEnabled = true
        imagePicker.view.isUserInteractionEnabled = true
//        imagePicker.cameraOverlayView = overLayView
        overLayView.isMultipleTouchEnabled = true

        let pinchRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch))
        pinchRecognizer.delegate = self
        overLayView.addGestureRecognizer(pinchRecognizer)

        let rotationRecognizer = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate))
        rotationRecognizer.delegate = self
        overLayView.addGestureRecognizer(rotationRecognizer)

        let translationRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        translationRecognizer.delegate = self
        overLayView.addGestureRecognizer(translationRecognizer)
        imagePicker.view.addSubview(overLayView)

        self.overLayView?.isHidden = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageViewTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.cameraImageView.isUserInteractionEnabled = true
        self.cameraImageView.addGestureRecognizer(tapGestureRecognizer)
        (r, g, b, a, t) = image.getAverageOfCorners()
        self.cameraImageView.image = cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: image, withTolerance: Float(t))


        // ---- for bannerView Ads
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-8227877258412950/1872033626"
        bannerView.rootViewController = self
        bannerView.load(request)
        
    }

    func setupGestureRecognizers() {
        let hideMenuGesture = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.expandOrCollapse(sender:)))
        self.hideMenuView.addGestureRecognizer(hideMenuGesture)

        let shareMenuGesture = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.sharePicture(sender:)))
        self.shareMenuView.addGestureRecognizer(shareMenuGesture)

        let changeProductGesture = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.changeProduct(sender:)))
        self.changeProductMenuView.addGestureRecognizer(changeProductGesture)

        let augmentRealityGesture = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.augmentReality(sender:)))
        self.augmentRealityMenuView.addGestureRecognizer(augmentRealityGesture)


    }

    func expandOrCollapse(sender: UITapGestureRecognizer) {
        if (self.menuExpanded) {
            self.collapse()
        } else {
            if (self.userImageSet){
                self.bannerView.isHidden = true
                var image = self.snapshotImage()
                image = self.cameraHelper.cropImage(image, toFrame: self.cameraImageView.frame, withScale: UIScreen.main.scale, withOrientatio: .up)
                self.galleryImage = image
                self.bannerView.isHidden = false
            }
            self.expand()
        }
        
    }

    func collapse() {
        self.view.layoutIfNeeded()
        self.hideMenuLabel.text = "Menu"
        self.menuView.layoutIfNeeded()
        self.hideMenuQuarterHeightConstraint.isActive = false
        self.hideMenuFullHeightConstraint.isActive = true

        self.menuViewBottomConstraint.constant = (self.view.frame.size.height * 3)/4
        
        self.menuView.bringSubview(toFront: self.hideMenuView)
        self.shareMenuTopConstraint.constant = -self.shareMenuView.frame.size.height
        self.changeProductTopConstraint.constant = self.changeProductMenuView.frame.size.height
        self.augmentRealityTopConstraint.constant = self.augmentRealityMenuView.frame.height
        if self.overLayView != nil && self.userImageSet {
            self.overLayView.isHidden = false
        }

        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: [], animations: {
            self.view.layoutIfNeeded()
            self.menuView.layoutIfNeeded()
        }) { (completion: Bool) in
            self.menuExpanded = false
        }
    }

    func expand() {
        self.view.layoutIfNeeded()
        self.hideMenuLabel.text = "Hide Menu"
        if self.overLayView != nil {
            self.overLayView.isHidden = true
        }
        self.menuView.layoutIfNeeded()
        self.hideMenuFullHeightConstraint.isActive = false
        self.hideMenuQuarterHeightConstraint.isActive = true

        self.menuViewBottomConstraint.constant = 0

        self.menuView.bringSubview(toFront: self.hideMenuView)
        self.shareMenuTopConstraint.constant = 0
        self.changeProductTopConstraint.constant = 0
        self.augmentRealityTopConstraint.constant = 0


        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: [], animations: {
            self.view.layoutIfNeeded()
            self.menuView.layoutIfNeeded()
        }) { (completion: Bool) in
            self.menuExpanded = true
        }
    }

    func sharePicture(sender: UITapGestureRecognizer) {
        if let image = self.galleryImage {
            let activityItems = [image]
            let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
            self.navigationController?.present(activityVC, animated: true, completion:nil)
        } else {
            let vc = UIAlertController.init(title: "Oops!", message: "You haven't clicked or selected an image. You don't want to share a blank image do you? :)", preferredStyle: .alert)
            vc.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in

            }))
            self.present(vc, animated: true, completion: nil)
        }
    }

    func changeProduct(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductsCollectionViewController") as! ProductsCollectionViewController
        vc.delegate = self
        self.navigationController?.present(vc, animated: true, completion: nil)

//        overlayPicker.allowsEditing = false
//        overlayPicker.sourceType = .photoLibrary
//        overlayPicker.delegate = self
//        overlayPicker.allowsEditing = true
//        self.navigationController?.present(overlayPicker, animated: true, completion:nil)
    }

    func augmentReality(sender: UITapGestureRecognizer) {
//        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//        self.overLayView?.isHidden = false
//        imagePicker.delegate = self
//
//        let overlayViewController = OverlayViewController(nibName: "OverlayViewController", bundle: nil)
//        let customView:CustomOverlayView = overlayViewController.view as! CustomOverlayView
//        customView.frame = imagePicker.view.frame
//        self.imagePicker.showsCameraControls = false
//        let image = overLayView?.image
//        overLayView?.center = self.view.center
//        overLayView?.image = image
//
//        self.navigationController?.present(imagePicker, animated: true, completion: {
//            self.imagePicker.view.addSubview(self.overLayView)
//            customView.delegate = self
//            customView.frame = self.imagePicker.view.frame
//            self.imagePicker.cameraOverlayView = customView
//            self.imagePicker.showsCameraControls = false
//        })
        let cameraStoryboard = UIStoryboard.init(name: "Camera", bundle: nil)
        let vc = cameraStoryboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        vc.delegate = self
        let image = overLayView?.image
        overLayView?.center = self.view.center
        overLayView?.image = image
        overLayView.isHidden = false
        vc.overlayImageView = overLayView


        self.navigationController?.present(vc, animated: true, completion: nil)

    }



    func mod(x: Double) -> Double {
        if (x < 0.0) {
            return x * (-1.0)
        }
        return x
    }


    

    func imageViewTapped(_ sender: UITapGestureRecognizer) {

    }


    func handlePinch(_ sender: UIGestureRecognizer) {

        let overlayView = sender.view
        if (sender.state == UIGestureRecognizerState.began) {
            self.initialBounds = (overlayView?.bounds)!
        }
        if let pinchRecognizer = sender as? UIPinchGestureRecognizer {
            let factor = pinchRecognizer.scale
            let zt = CGAffineTransform.identity.scaledBy(x: factor, y: factor)
            let centerPoint = overlayView?.center
            let originPoint = overlayView?.frame.origin
            let xDist = (centerPoint?.x)! - (originPoint?.x)!
            let yDist = (centerPoint?.y)! - (originPoint?.y)!
            let distance = sqrt((xDist * xDist) + (yDist * yDist));

            let boundingRect = CGRect(x: (centerPoint?.x)! - distance, y: (centerPoint?.y)! - distance, width: distance * 2.0 , height: distance * 2.0)
            if (self.view.bounds.contains(centerPoint!) && factor <= 3.0) {
                    overlayView?.bounds = self.initialBounds.applying(zt)
            } else if factor < 1.0 {
                overlayView?.bounds = self.initialBounds.applying(zt)
            }
            let boundingView = UIView(frame: boundingRect)
            boundingView.layer.borderColor = UIColor.blue.cgColor
            boundingView.layer.borderWidth = 5.0
            
            //overlayView?.bringSubview(toFront: boundingView)



            /*
            if (((overlayView?.frame.origin.x)! < CGFloat(0.0)) || ((overlayView?.frame.origin.y)! < CGFloat(0.0)
                ) || (((overlayView?.frame.origin.y)! + (overlayView?.frame.size.height)!) > UIScreen.main.bounds.size.height) || ((overlayView?.frame.origin.x)! + (overlayView?.frame.size.width)!) > UIScreen.main.bounds.size.width) {
                overlayView?.frame = oldFrame!
            }
            */
        }
    }

    func handleRotate(_ sender: UIRotationGestureRecognizer) {
//        let rotation = self.lastRotation * sender.rotation
        let overlayView = sender.view
        if (sender.state == UIGestureRecognizerState.began) {
            self.initialBoundsForRotation = (overlayView?.bounds)!
        }

        let centerPoint = overlayView?.center
        let originPoint = overlayView?.frame.origin
        let xDist = (centerPoint?.x)! - (originPoint?.x)!
        let yDist = (centerPoint?.y)! - (originPoint?.y)!
        let distance = sqrt((xDist * xDist) + (yDist * yDist));

        let boundingRect = CGRect(x: (centerPoint?.x)! - distance, y: (centerPoint?.y)! - distance, width: distance * 2.0 , height: distance * 2.0)
        if (self.view.bounds.contains(centerPoint!)) {
            overlayView?.transform = CGAffineTransform(rotationAngle: sender.rotation)
        }
        let boundingView = UIView(frame: boundingRect)
        boundingView.layer.borderColor = UIColor.blue.cgColor
        boundingView.layer.borderWidth = 5.0
        
        //overlayView?.bringSubview(toFront: boundingView)


        /*
        if (((overlayView?.frame.origin.x)! < CGFloat(0.0)) || ((overlayView?.frame.origin.y)! < CGFloat(0.0)
            ) || (((overlayView?.frame.origin.y)! + (overlayView?.frame.size.height)!) > UIScreen.main.bounds.size.height) || ((overlayView?.frame.origin.x)! + (overlayView?.frame.size.width)!) > UIScreen.main.bounds.size.width) {
            overlayView?.frame = oldFrame!
        }
        */



    }

    func handlePan(_ sender: UIPanGestureRecognizer) {
        let overlayView = sender.view
        var centerPoint = overlayView?.center
        let originPoint = overlayView?.frame.origin
        let xDist = (centerPoint?.x)! - (originPoint?.x)!
        let yDist = (centerPoint?.y)! - (originPoint?.y)!
        let distance = sqrt((xDist * xDist) + (yDist * yDist));

        centerPoint = sender.location(in: self.view)

        let boundingRect = CGRect(x: (centerPoint?.x)! - distance, y: (centerPoint?.y)! - distance, width: distance * 2.0 , height: distance * 2.0)
        if (self.view.bounds.contains(centerPoint!)) {
            overlayView?.center =  sender.location(in: self.view)
        }

        let boundingView = UIView(frame: boundingRect)
        boundingView.layer.borderColor = UIColor.blue.cgColor
        boundingView.layer.borderWidth = 5.0
        
        //overlayView?.bringSubview(toFront: boundingView)

    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if (self.menuExpanded) {
            self.collapse()
        }
        if picker == self.imagePicker {
            var image = info[UIImagePickerControllerEditedImage] as? UIImage
            if (image == nil ) {
                image = info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            if (picker.sourceType == .camera) {
                let image2 = overLayView.image
                overLayView.center.y += self.cameraImageView.frame.origin.y
                overLayView.image = image2

                if picker.cameraDevice == .front {
                    image = cameraHelper.flip(image)
                }
                UIImageWriteToSavedPhotosAlbum(image!, self,nil, nil) //save to the photo library
            } else {
                self.overLayView.isHidden = false
                picker.dismiss(animated: true, completion: {
                    let galleryViewController = GalleryImageAugmentViewController(nibName: "GalleryImageAugmentViewController", bundle: nil)
                    galleryViewController.selectedImage = image
                    galleryViewController.overLayView = self.overLayView

                    galleryViewController.delegate = self
                    self.navigationController?.present(galleryViewController, animated: true, completion: nil)
                })
            }

            self.cameraImageView.image = image
            self.cameraImageView.contentMode = UIViewContentMode.scaleAspectFit
            self.view.addSubview(overLayView)
            overLayView.isHidden = false
            self.userImageSet = true
        } else {


        }
        picker.dismiss(animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if !self.userImageSet {
            overLayView.isHidden = true
        } else {
            overLayView.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)

    }

    func didShoot(overlayView: CustomOverlayView) {
        self.imagePicker.takePicture()
    }

    func didCancel(overlayView: CustomOverlayView) {
        if !self.userImageSet {
            overLayView.isHidden = true
        } else {
            overLayView.isHidden = false
        }
        self.imagePicker.dismiss(animated: true,
                                             completion: nil)
    }

    func didChangeToGallery(overlayView: CustomOverlayView) {
        self.overLayView?.isHidden = true
        self.imagePicker.showsCameraControls = true
        self.imagePicker.sourceType = .photoLibrary
    }

    func switchCamera(overlayView: CustomOverlayView) {
        if self.imagePicker.cameraDevice == .front {
            self.imagePicker.cameraDevice = .rear
        } else {
            self.imagePicker.cameraDevice = .front
        }
    }

    func switchFlashMode(overlayView: CustomOverlayView) {
        if self.imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashMode.auto {
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
            overlayView.flashTextLabel.text = "Off"
            return
        }
        if self.imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashMode.off {
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.on
            overlayView.flashTextLabel.text = "On"
            return
        }

            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.auto
            overlayView.flashTextLabel.text = "Auto"

    }

    func didCancel(viewController: GalleryImageAugmentViewController) {
        if !self.userImageSet {
            overLayView.isHidden = true
        } else {
            overLayView.isHidden = false
        }
        viewController.dismiss(animated: true, completion: nil)
    }

    func didChoose(viewController: GalleryImageAugmentViewController) {
        self.cameraImageView.image = viewController.selectedImage
        self.cameraImageView.contentMode = UIViewContentMode.scaleAspectFit
        let overlay = viewController.overLayView!
        overlay.contentScaleFactor = self.cameraImageView.contentScaleFactor
        self.view.addSubview(overlay)
//        var rect = overlay.frame
//        rect.origin.y += 120
//        overlay.frame = rect

        let currentSize = cameraHelper.imageSize(afterAspectFit: self.cameraImageView)
        let oldSize = cameraHelper.imageSize(afterAspectFit: viewController.selectedImageView)

        let difference = mod(x: Double(currentSize.height - oldSize.height)/2.0)

        let image = overLayView?.image
        overlay.center.y += CGFloat(120.0 - difference)
        overlay.image = image

        if !self.userImageSet {
            overLayView.isHidden = true
        } else {
            overLayView.isHidden = false
        }
        viewController.dismiss(animated: true, completion: nil)
    }

    func snapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0.0)
        self.view.layer.render(in: (UIGraphicsGetCurrentContext()!))
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultingImage!
    }

    // MARK: KTCameraPickerDelegate methods

    func cameraCancelTapped(VC: CameraViewController) {
        overLayView.isHidden = true
        VC.dismiss(animated: true, completion: nil)
    }

    func galleryDoneTapped(VC: CameraViewController) {
        self.cameraImageView.image = VC.augmentedImage
        VC.doneAndCancelView.isHidden = false
        VC.collectionViewHideButton.isHidden = false
        VC.imagesCollectionView.isHidden = false
        self.userImageSet = true
        if self.menuExpanded {
            self.collapse()
        }
        VC.dismiss(animated: true, completion: nil)
    }

    func galleryCancelTapped(VC: CameraViewController) {
        overLayView.isHidden = true
        VC.dismiss(animated: true, completion: nil)
    }

    //MARK: Products collection view delegate

    func didFinishPickingImage(image: UIImage) {
        self.userImageSet = false
        if self.menuExpanded {
            self.collapse()
        }
        self.overLayView.contentMode = .scaleAspectFit
        self.overLayView.image = image
        self.cameraImageView.image = image

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




}

