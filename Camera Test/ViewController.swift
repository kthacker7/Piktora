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

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {

        if let pixelData = self.cgImage?.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

            let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

            return UIColor(red: r, green: g, blue: b, alpha: a)
        }

        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
}

extension UIColor {

    func rgb() -> (red:Double, green:Double, blue:Double, alpha:Double)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Double(fRed)
            let iGreen = Double(fGreen)
            let iBlue = Double(fBlue)
            let iAlpha = Double(fAlpha)

            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return (red:0.0, green:0.0, blue:0.0, alpha:1.0)
        }
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, CustomOverlayDelegate, GalleryImageAugmentDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet var chooseOverlayButton: UIButton!
    @IBOutlet var retakeButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var separatorView: UIView!

    @IBOutlet weak var cameraImageView: UIImageView!
    var userImageSet: Bool = false
    var initialBounds: CGRect = CGRect.zero
    var initialBoundsForRotation: CGRect = CGRect.zero
    var lastRotation: CGFloat = 0.0
    let imagePicker = UIImagePickerController.init()
    var overLayView: UIImageView!
    let cameraHelper = CameraHelper.init()
    let overlayPicker = UIImagePickerController.init()

    @IBOutlet var saveToGalleryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.black

        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.delegate = self
        self.cameraImageView.contentMode = UIViewContentMode.scaleAspectFit


        
        // overLayView.backgroundColor = UIColor(patternImage: UIImage(named: "watchImage.jpg")!)
        var image = UIImage(named: "watchImage.jpg")!
        var (r,g,b,a,t) = self.getAverageOfCorners(image: image)
        overLayView = UIImageView(image: cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: UIImage(named: "watchImage.jpg"), withTolerance: Float(t)) )

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
        image = UIImage(named: "watchImage.jpg")!
        (r, g, b, a, t) = getAverageOfCorners(image: image)
        self.cameraImageView.image = cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: image, withTolerance: Float(t))

        self.saveToGalleryButton.isHidden = true
        self.retakeButton.isHidden = true
        self.shareButton.isHidden = true
        self.separatorView.isHidden = true
        // ---- for bannerView Ads
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-8227877258412950/1872033626"
        bannerView.rootViewController = self
        bannerView.load(request)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.overLayView.isHidden && !self.view.subviews.contains(self.overLayView) {
            self.view.addSubview(self.overLayView)
        }
        
    }

    func getAverageOfCorners(image: UIImage) -> (red:Double, green: Double, blue: Double, alpha: Double, tolerance: Double) {

        let height = image.size.height
        let width = image.size.width

        let c1 = image.getPixelColor(pos: CGPoint.init(x: 0.0 , y: 0.0))
        let c2 = image.getPixelColor(pos: CGPoint.init(x: 0.0 , y: height-1.0))
        let c3 = image.getPixelColor(pos: CGPoint.init(x: width-1.0 , y: 0.0))
        let c4 = image.getPixelColor(pos: CGPoint.init(x: width-1.0 , y: height-1.0))

        let (r1, g1, b1, a1) = c1.rgb()!
        let (r2, g2, b2, a2) = c2.rgb()!
        let (r3, g3, b3, a3) = c3.rgb()!
        let (r4, g4, b4, a4) = c4.rgb()!

        let avgR = (r1 + r2 + r3 + r4)/4.0
        let avgG = (g1 + g2 + g3 + g4)/4.0
        let avgB = (b1 + b2 + b3 + b4)/4.0
        let avgA = (a1 + a2 + a3 + a4)/4.0

        let tR = maxDifference(source: avgR, p1: r1, p2: r2, p3: r3, p4: r4)
        let tG = maxDifference(source: avgG, p1: g1, p2: g2, p3: g3, p4: g4)
        let tB = maxDifference(source: avgB, p1: b1, p2: b2, p3: b3, p4: b4)
        let tA = maxDifference(source: avgA, p1: a1, p2: a2, p3: a3, p4: a4)

        let t = max (tR, tG, tB, tA) > 30.0 ? max (tR, tG, tB, tA) : 30.0
        return (avgR, avgG, avgB, avgA, t)
    }

    func maxDifference(source:Double, p1:Double, p2:Double, p3:Double, p4:Double) -> Double {
        let d1 = mod(x: source - p1)
        let d2 = mod(x: source - p2)
        let d3 = mod(x: source - p3)
        let d4 = mod(x: source - p4)

        return max(d1,d2,d3,d4)
    }

    func mod(x: Double) -> Double {
        if (x < 0.0) {
            return x * (-1.0)
        }
        return x
    }


    

    func imageViewTapped(_ sender: UITapGestureRecognizer) {
        overlayPicker.allowsEditing = false
        overlayPicker.sourceType = .photoLibrary
        overlayPicker.delegate = self
        overlayPicker.allowsEditing = true
        self.overLayView.isHidden = false
        self.navigationController?.present(overlayPicker, animated: true, completion:nil)
    }

    @IBAction func redirectToCamera(_ sender: AnyObject) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.overLayView?.isHidden = false
        imagePicker.delegate = self

        let overlayViewController = OverlayViewController(nibName: "OverlayViewController", bundle: nil)
        let customView:CustomOverlayView = overlayViewController.view as! CustomOverlayView
        customView.frame = imagePicker.view.frame
        self.imagePicker.showsCameraControls = false
        overLayView.frame = CGRect(x: self.view.frame.width/2 - 100, y: self.view.frame.height/2 - 100, width: UIScreen.main.bounds.size.width/3, height: UIScreen.main.bounds.size.height/3)

        self.navigationController?.present(imagePicker, animated: true, completion: {
            self.imagePicker.view.addSubview(self.overLayView)
            customView.delegate = self
            customView.frame = self.imagePicker.view.frame
            self.imagePicker.cameraOverlayView = customView
            self.imagePicker.showsCameraControls = false
        })
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
        if picker == self.imagePicker {
            var image = info[UIImagePickerControllerEditedImage] as? UIImage
            if (image == nil ) {
                image = info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            if (picker.sourceType == .camera) {
                var frame = overLayView.frame
                frame.origin.y += self.cameraImageView.frame.origin.y
                overLayView.frame = frame
                if picker.cameraDevice == .front {
                    image = UIImage(cgImage: (image?.cgImage!)!, scale: (image?.scale)!, orientation:.leftMirrored)
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

            self.saveToGalleryButton.isHidden = false
            self.retakeButton.isHidden = false
            overLayView.isHidden = false
            self.shareButton.isHidden = false
            self.separatorView.isHidden = false
            self.saveToGalleryButton.isHidden = false
            self.userImageSet = true
        } else {
            self.retakeButton.isHidden = true
            self.shareButton.isHidden = true
            self.separatorView.isHidden = true
            self.saveToGalleryButton.isHidden = true
            self.userImageSet = false
            var image = info[UIImagePickerControllerEditedImage] as? UIImage
            if (image == nil ) {
                image = info[UIImagePickerControllerOriginalImage] as? UIImage
            }

            let (r, g, b, a, t) = getAverageOfCorners(image: image!)
            overLayView.image = cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: image, withTolerance: Float(t))
            overLayView.contentMode = .scaleAspectFit
            self.cameraImageView.image = overLayView.image
            if !self.userImageSet {
                overLayView.isHidden = true
            } else {
                overLayView.isHidden = false
            }

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
        var rect = overlay.frame
        rect.origin.y += 120
        overlay.frame = rect
        if !self.userImageSet {
            overLayView.isHidden = true
        } else {
            overLayView.isHidden = false
        }
        viewController.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveToGallery(_ sender: AnyObject) {
        var image = self.snapshotImage()
        image = self.cameraHelper.cropImage(image, toFrame: self.cameraImageView.frame, withScale: UIScreen.main.scale, withOrientatio: .up)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil
        )
    }

    func snapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0.0)
        self.view.layer.render(in: (UIGraphicsGetCurrentContext()!))
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultingImage!
    }


    @IBAction func redirectOverlayButton(_ sender: AnyObject) {

        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.overLayView?.isHidden = false
        imagePicker.delegate = self

        let overlayViewController = OverlayViewController(nibName: "OverlayViewController", bundle: nil)
        let customView:CustomOverlayView = overlayViewController.view as! CustomOverlayView
        customView.frame = imagePicker.view.frame
        self.imagePicker.showsCameraControls = false

        self.navigationController?.present(imagePicker, animated: true, completion: {
            self.imagePicker.view.addSubview(self.overLayView)
            customView.delegate = self
            customView.frame = self.imagePicker.view.frame
            self.imagePicker.cameraOverlayView = customView
            self.imagePicker.showsCameraControls = false
        })


    }


    @IBAction func shareButtonTapped(_ sender: AnyObject) {
        var image = self.snapshotImage()
        image = self.cameraHelper.cropImage(image, toFrame: self.cameraImageView.frame, withScale: UIScreen.main.scale, withOrientatio: .up)
        let activityItems = [image]
        let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
        self.navigationController?.present(activityVC, animated: true, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




}

