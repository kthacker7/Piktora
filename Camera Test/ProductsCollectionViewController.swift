//
//  ProductsCollectionViewController.swift
//  Camera Test
//
//  Created by Kunal Thacker on 08/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

protocol ProductsCollectionViewDelegate {
    func didFinishPickingImage(image: UIImage)
}

class ProductsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var productsCollectionView: UICollectionView!
    @IBOutlet var doneButton: UIButton!
    var selectedItem : Int?

    var delegate: ProductsCollectionViewDelegate? = nil

    var productImages : [UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productsCollectionView.dataSource = self
        productsCollectionView.delegate = self

        productsCollectionView.layer.borderWidth = 2.0
        productsCollectionView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.automaticallyAdjustsScrollViewInsets = false

        let nib = UINib(nibName: "PhotosCollectionViewCell", bundle: nil)
        productsCollectionView.register(nib, forCellWithReuseIdentifier: "PhotosCollectionViewCell")

        

        self.loadImages()

    }

    func loadImages() {
        let images = [#imageLiteral(resourceName: "Accessories1"), #imageLiteral(resourceName: "Accessories2"), #imageLiteral(resourceName: "Accessories3"), #imageLiteral(resourceName: "Accessories4"), #imageLiteral(resourceName: "Furniture1"), #imageLiteral(resourceName: "Furniture2"), #imageLiteral(resourceName: "Furniture3"), #imageLiteral(resourceName: "Furniture4"), #imageLiteral(resourceName: "Furniture5"), #imageLiteral(resourceName: "Furniture6"), #imageLiteral(resourceName: "Glasses1"), #imageLiteral(resourceName: "Glasses2"), #imageLiteral(resourceName: "Glasses3"), #imageLiteral(resourceName: "Glasses4"), #imageLiteral(resourceName: "Watch1"), #imageLiteral(resourceName: "Watch2"), #imageLiteral(resourceName: "Watch3"), #imageLiteral(resourceName: "Watch4"), #imageLiteral(resourceName: "Watch5"), #imageLiteral(resourceName: "Watch6")]
        var i = 0
        let cameraHelper = CameraHelper()
        while i < 20 {
            let image = images[i]
            let (r,g,b,a,t) = image.getAverageOfCorners()
            if a != 0 {
                productImages.append(cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: images[i], withTolerance: Float(t)))
            } else {
                productImages.append(image)
            }
            i += 1
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (productsCollectionView.frame.size.width)/2 , height: (productsCollectionView.frame.size.height - 40)/2)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15)
        self.productsCollectionView.collectionViewLayout = layout

    }

    // MARK: CollectionView data source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 20
        }
        return 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCollectionViewCell", for: indexPath) as! PhotosCollectionViewCell
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView.image = productImages[indexPath.row]
        cell.layer.borderWidth = 2.0
        if self.selectedItem != nil && indexPath.row == self.selectedItem! {
            cell.layer.borderColor = UIColor(colorLiteralRed: 218.0/255.0, green: 194.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
        } else {
            cell.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        }

        return cell
    }

    // MARK: Collection view delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItem = indexPath.row
        self.doneButton.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 149.0/255.0, blue: 218.0/255.0, alpha: 1.0)
        self.productsCollectionView.reloadData()
    }

    // MARK: Button actions

    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        if self.selectedItem != nil && delegate != nil {
            let image = productImages[self.selectedItem!]
            delegate?.didFinishPickingImage(image: image)
            self.dismiss(animated: true, completion: nil)

        }
    }

    @IBAction func chooseFromGalleryPressed(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Tip", message: "For best results, please select a product with a uniformly colored background, with no alternate objects!", preferredStyle: .alert)
        self.present(alert, animated: false, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            alert.dismiss(animated: false, completion: { 
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            })

        }

    }

    //MARK: ImagePicker delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if (image == nil ) {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        let cameraHelper = CameraHelper()
        let (r, g, b, a, t) = image!.getAverageOfCorners()
        let filteredImage = cameraHelper.replace(UIColor.init(colorLiteralRed: Float(r), green: Float(g), blue: Float(b), alpha: Float(a)), in: image, withTolerance: Float(t))
        if (delegate != nil && filteredImage != nil) {
            delegate?.didFinishPickingImage(image: filteredImage!)
        }
        picker.dismiss(animated: true) { 
            self.dismiss(animated: true, completion: nil)
        }



    }

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
