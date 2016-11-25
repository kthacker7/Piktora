//
//  AmazonCategorySelectionViewController.swift
//  Piktora
//
//  Created by Kunal Thacker on 19/11/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

class AmazonCategorySelectionViewController: UIViewController {

    let supportedCategoryNames = ["Automotive", "Clothing & Accessories", "Home & Kitchen", "Jewellery", "Luggage & Bags", "Shoes & Handbags", "Sports, Fitness & Outdoors", "Watches"]
    let supportedCategoryBrowseNodes = ["4772061031", "1571272031", "2454176031", "1951049031", "2454170031", "1571284031", "1984444031", "1350388031"]
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hitApi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func hitApi() {
        let connector = PiktoraConnector()
        connector.browseNodeLookupForNodeID(nodeID: "1350388031", success: {
            
        }, failure: { error in

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
