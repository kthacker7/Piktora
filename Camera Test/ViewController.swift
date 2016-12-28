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
import SDWebImage


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, CustomOverlayDelegate, GalleryImageAugmentDelegate,GADBannerViewDelegate, KTCameraPickerDelegate, ProductsCollectionViewDelegate, PiktoraTutorialDelegate {

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


    @IBOutlet var shopAndShareButton: UIButton!
    @IBOutlet var productScreenButton: UIButton!
    @IBOutlet var changeProductButton: UIButton!
    @IBOutlet var pikItButton: UIButton!

    var menuExpanded = false

    var tutorialPageViewController: UIPageViewController?
    let tutorialImages = [#imageLiteral(resourceName: "TutorialPage1"), #imageLiteral(resourceName: "TutorialPage2"), #imageLiteral(resourceName: "TutorialPage3")]

    var selectedProductInfo : FKM_ProductInfo?
    var selectedAmazonProduct : AmazonItemWithDetails?
    
    var selectedWebsite : PK_Website?

    // Buy and share objects
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var buyAndShareButtonView: UIView!
    @IBOutlet var buyAndShareViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet var buyButtonHeightConstraint: NSLayoutConstraint!

    var buyAndShareExpanded = false



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if UserDefaults.standard.value(forKey: "FirstLaunch") == nil {
            self.setupAndShowTutorialController()
            UserDefaults.standard.set(false, forKey: "FirstLaunch")
        }


//        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.delegate = self
        self.cameraImageView.contentMode = UIViewContentMode.scaleAspectFit

        // overLayView.backgroundColor = UIColor(patternImage: UIImage(named: "watchImage.jpg")!)
        let image = #imageLiteral(resourceName: "PlaceHolderProduct")
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

        (r, g, b, a, t) = image.getAverageOfCorners()
        self.cameraImageView.image = image

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.augmentReality(sender:)))
        pikItButton.addGestureRecognizer(tapGestureRecognizer)
        // ---- for bannerView Ads
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]

        self.setupButtons()
        self.setupBuyAndShareUI()
        self.collapse()
        UserDefaults.standard.set(nil, forKey: "ProductImageURL")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)

        if self.selectedWebsite == PK_Website.FlipKart {
            if let url = UserDefaults.standard.url(forKey: "ProductImageURL") {
                SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions.highPriority, progress: { (_, _) in
                    
                }, completed: { (image, error, _, finished, _) in
                    DispatchQueue.main.async {
                        if finished && error == nil && image != nil {
                            let (r, g, b, a, t) = image!.getAverageOfCorners()
                            self.cameraImageView.image = image
                            self.userImageSet = false
                            self.overLayView.contentMode = .scaleAspectFit
                            self.overLayView.image = self.cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: image, withTolerance: Float(t))
                        }
                    }
                })
            }
        } else if self.selectedWebsite == PK_Website.Amazon {
            if let urlString = self.selectedAmazonProduct?.imageURL {
                if let url = URL(string: urlString) {
                    SDWebImageManager.shared().downloadImage(with: url, options: .highPriority, progress: { (_, _) in
                    }, completed: { (image, error, _, finished, _) in
                        if finished && error == nil && image != nil {
                            let (r, g, b, a, t) = image!.getAverageOfCorners()
                            self.cameraImageView.image = image
                            self.userImageSet = false
                            self.overLayView.contentMode = .scaleAspectFit
                            self.overLayView.image = self.cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: image, withTolerance: Float(t))
                        }
                    })
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
        if self.buyAndShareExpanded {
            self.buyAndShareExpanded = false
            self.collapse()
        }
        UserDefaults.standard.set(nil, forKey: "ProductImageURL")
    }

    @IBAction func changeProductTapped(_ sender: Any) {
        self.showProductSelectionTableView()
    }

    @IBAction func chooseProductTapped(_ sender: Any) {
        self.showProductSelectionTableView()
    }
    func showProductSelectionTableView() {
        let storyboard = UIStoryboard(name: "ProductSelection", bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "WebsiteSelectionViewController") as! WebsiteSelectionViewController
        vc.modalPresentationStyle = .pageSheet
        vc.parentVC = self
        vc.delegate = self
        let navC = UINavigationController(rootViewController: vc)
        self.navigationController?.present(navC, animated: true, completion: nil)
    }

    func expandOrCollapse(sender: UITapGestureRecognizer) {
        if (self.menuExpanded) {

        } else {
            if (self.userImageSet){
                self.galleryImage = self.cameraImageView.image
            }
        }
        
    }


    func sharePicture(sender: UITapGestureRecognizer) {
        if let image = self.galleryImage {
            let activityItems = [image]
            let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
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
        let cameraStoryboard = UIStoryboard.init(name: "Camera", bundle: nil)
        let vc = cameraStoryboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        vc.selectedProdInfo = self.selectedProductInfo
        vc.selectedWebsite = self.selectedWebsite
        vc.selectedAmazonInfo = self.selectedAmazonProduct
        vc.delegate = self
        vc.parentVC = self
        let image = overLayView?.image
        overLayView?.center = self.view.center
        overLayView?.image = image
        overLayView.isHidden = false
        vc.overlayImageView = overLayView


        self.navigationController?.pushViewController(vc, animated: true)

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
    }

    func galleryDoneTapped(VC: CameraViewController) {
        self.cameraImageView.image = VC.augmentedImage
        VC.doneAndCancelView.isHidden = false
        VC.collectionViewHideButton.isHidden = false
        VC.imagesCollectionView.isHidden = false
        self.userImageSet = true
    }

    func galleryCancelTapped(VC: CameraViewController) {
        overLayView.isHidden = true
    }

    //MARK: Products collection view delegate

    func didFinishPickingImage(image: UIImage) {
        self.userImageSet = false
        self.overLayView.contentMode = .scaleAspectFit
        self.cameraImageView.image = image
        let (r,g,b,a,t) = image.getAverageOfCorners()
        let filteredImage = cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: image, withTolerance: Float(t))
        self.overLayView.image = filteredImage
    }

    // MARK: UISetup

    func setupButtons() {
        self.changeProductButton.layer.cornerRadius = 15.0
        self.changeProductButton.layer.borderWidth = 1.0
        self.changeProductButton.layer.borderColor = UIColor(colorLiteralRed: 21.0/255.0, green: 67.0/205.0, blue: 94.0/255.0, alpha: 1.0).cgColor
    }

    func setupAndShowTutorialController() {
        tutorialPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        tutorialPageViewController?.dataSource = self
        tutorialPageViewController?.view.bounds = self.view.bounds
        let vc = TutorialViewController(nibName: "TutorialViewController", bundle: nil)
        vc.delegate = self
        vc.index = 0
        vc.tutorialImage = self.tutorialImages[vc.index]
        tutorialPageViewController?.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        self.view.addSubview((tutorialPageViewController?.view)!)

        tutorialPageViewController?.didMove(toParentViewController: self)
    }

    // MARK: Buy and share handlers and ui setup
    func setupBuyAndShareUI() {
        self.buyAndShareButtonView.layer.cornerRadius = 10.0
        self.buyAndShareButtonView.layer.borderWidth = 1.0
        self.buyAndShareButtonView.layer.borderColor = UIColor.init(colorLiteralRed: 100.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0).cgColor

        self.buyButton.layer.borderWidth = 1.0
        self.buyButton.layer.borderColor = UIColor.init(colorLiteralRed: 100.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0).cgColor

        self.shareButton.layer.borderWidth = 1.0
        self.shareButton.layer.borderColor = UIColor.init(colorLiteralRed: 100.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0).cgColor


    }

    func expand() {
        self.buyAndShareButtonView.layoutIfNeeded()
        if (self.selectedProductInfo != nil || self.selectedAmazonProduct != nil) && self.selectedWebsite != PK_Website.Gallery {
            self.buyButtonHeightConstraint.constant = 45
        } else {
            self.buyButtonHeightConstraint.constant = 0
        }
        self.buyAndShareViewHeightConstraint.constant = self.buyButtonHeightConstraint.constant + 45.0
        UIView.animate(withDuration: 0.1, animations: {
            self.buyAndShareButtonView.layoutIfNeeded()
        })
    }

    func collapse() {
        self.buyAndShareButtonView.layoutIfNeeded()
        self.buyButtonHeightConstraint.constant = 0
        self.buyAndShareViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.1, animations: {
            self.buyAndShareButtonView.layoutIfNeeded()
        })
    }

    func expandOrCollapse() {
        if self.buyAndShareExpanded {
            self.buyAndShareExpanded = !self.buyAndShareExpanded
            self.collapse()
        } else {
            self.buyAndShareExpanded = !self.buyAndShareExpanded
            self.expand()
        }

    }

    @IBAction func buyButtonTapped(_ sender: Any) {
        if self.selectedWebsite == PK_Website.FlipKart {
            if let prodInfo = self.selectedProductInfo {
                if let prodUrl = prodInfo.productBaseInfoV1?.productURL {
                    UIApplication.shared.openURL(URL(string: prodUrl)!)
                }
            }
        } else if self.selectedWebsite == PK_Website.Amazon{
            if let prodInfo = self.selectedAmazonProduct {
                if let prodURL = URL(string: prodInfo.detailURL) {
                    UIApplication.shared.openURL(prodURL)
                }
            }
        }
    }

    @IBAction func shareButtonTapped(_ sender: Any) {

            if let image = self.cameraImageView.image {
                let activityItems = [image]
                let activityVC = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.navigationController?.present(activityVC, animated: true, completion:nil)
            } else {
                let vc = UIAlertController.init(title: "Oops!", message: "You haven't clicked or selected an image. You don't want to share a blank image do you? :)", preferredStyle: .alert)
                vc.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in

                }))
                self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func buyAndShareButtonTapped(_ sender: Any) {
        self.expandOrCollapse()
    }

    // MARK: Tutorial Delegate
    func hideTutorialTapped() {
        (tutorialPageViewController?.view)!.removeFromSuperview()
        if let tutorialView = tutorialPageViewController?.view {
            tutorialView.isHidden = true
        }
    }

    @IBAction func showTutorialTapped(_ sender: Any) {
        self.setupAndShowTutorialController()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? TutorialViewController {
            if vc.index >= 2 {
                return nil
            }
            let nextVC = TutorialViewController(nibName: "TutorialViewController", bundle: nil)
            nextVC.delegate = self
            nextVC.index = (vc.index + 1)
            nextVC.tutorialImage = self.tutorialImages[nextVC.index]
            return nextVC
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? TutorialViewController {
            if vc.index <= 0 {
                return nil
            }
            let nextVC = TutorialViewController(nibName: "TutorialViewController", bundle: nil)
            nextVC.delegate = self
            nextVC.index = (vc.index - 1)
            nextVC.tutorialImage = self.tutorialImages[nextVC.index]
            return nextVC
        }
        return nil

    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 3
    }
}



