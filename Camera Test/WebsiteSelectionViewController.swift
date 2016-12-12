//
//  WebsiteSelectionViewController.swift
//  Piktora
//
//  Created by Kunal Thacker on 23/10/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

enum PK_Website : String {
    case FlipKart = "FlipKart"
    case Amazon = "Amazon"
    case Gallery = ""
}

class WebsiteSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebsiteTableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    let websites: [PK_Website] = [.FlipKart, .Amazon, .Gallery]
    var flipkartCategoryList : FKM_CategoryList?

    var selectedWebsite: PK_Website?
    var isActivityIndicatorAnimating = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var parentVC: ViewController?
    var delegate: ProductsCollectionViewDelegate? = nil
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var greyView: UIView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNibs()
        self.setupUI()
        self.loadCategories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < websites.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WebsiteTableViewCell", for: indexPath) as! WebsiteTableViewCell
            cell.websiteLogoImageView.image = self.getImage(website: websites[indexPath.row])

            cell.delegate = self
            cell.indexPath =  indexPath
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryRedirectCell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height / CGFloat(websites.count)
    }

    func getImage(website: PK_Website) -> UIImage {
        if website == .FlipKart {
            return #imageLiteral(resourceName: "FlipkartLogo")
        }
        return #imageLiteral(resourceName: "AmazonLogo")
    }

    // MARK: Table View Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let alert = UIAlertController(title: "Tip", message: "For best results, please select a product with a uniformly colored background, with no alternate objects!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                alert.dismiss(animated: false, completion: nil)

                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }))
            self.present(alert, animated: false, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if (image == nil ) {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if (delegate != nil && image != nil) {
            delegate?.didFinishPickingImage(image: image!)
        }
        self.parentVC?.selectedProductInfo = nil
        picker.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }

        
        
    }

    // MARK: WebsiteTableViewDelegate

    func didSelectWebsite(website: PK_Website) {
        self.selectedWebsite = website
        if self.flipkartCategoryList != nil || website == .Amazon {
            self.goToWebsite(website: website)
        } else {
            self.greyView.isHidden = false
            self.activityIndicator.isHidden = false
            self.isActivityIndicatorAnimating = true
        }
    }

    func goToWebsite(website:PK_Website) {
        if website == .FlipKart {
            let storyboard = UIStoryboard(name: "ProductSelection", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CategorySelectionViewController") as! CategorySelectionViewController
            vc.parentVC = self.parentVC
            vc.apiResponse = self.flipkartCategoryList
            vc.website = self.selectedWebsite
            self.navigationController?.pushViewController(vc, animated: true)
        } else if website == .Amazon {
            let storyboard = UIStoryboard(name: "ProductSelection", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AmazonCategorySelectionViewController") as! AmazonCategorySelectionViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: Other methods
    func setupUI() {
        self.navigationItem.title = "Choose products from.."
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(WebsiteSelectionViewController.backButtonTapped))
        self.tableView.backgroundColor = UIColor.black
        self.activityIndicator.isHidden = true
        activityIndicator.center = self.view.center
        self.greyView.isHidden = true
        self.view.addSubview(activityIndicator)
    }
    
    func registerNibs() {
        let nib = UINib(nibName: "WebsiteTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "WebsiteTableViewCell")
    }
    
    func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    func loadCategories() {
        let connector = PiktoraConnector()
        if !self.activityIndicator.isHidden {
            self.activityIndicator.startAnimating()
        }
        connector.getCategoryList(endPoint: "api/iamdonkun.json", success: {categoryList in
            self.flipkartCategoryList = categoryList
            if self.isActivityIndicatorAnimating {
                self.activityIndicator.isHidden = true
                self.isActivityIndicatorAnimating = false
                if self.selectedWebsite != nil {
                    self.goToWebsite(website: self.selectedWebsite!)
                }
                self.activityIndicator.stopAnimating()
            }

        }, failure: { error in
            if self.isActivityIndicatorAnimating {
                self.activityIndicator.isHidden = true
                self.isActivityIndicatorAnimating = false
                self.activityIndicator.stopAnimating()
            }
            let alert = UIAlertController(title: "Oops, something went wrong", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default , handler: { (_) in
                alert.dismiss(animated: false, completion: nil)
                self.activityIndicator.isHidden = false
                self.isActivityIndicatorAnimating = true
                self.loadCategories()

            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                alert.dismiss(animated: false, completion: nil)
            }))

        })
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
