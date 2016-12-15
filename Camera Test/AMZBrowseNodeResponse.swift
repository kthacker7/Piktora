//
//  AMZ_BrowseNodeResponse.swift
//  Piktora
//
//  Created by Kunal Thacker on 12/14/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation

class AMZBrowseNodeResponse: NSObject, XMLParserDelegate {
    var nodes: [AmazonSubcategory] = []
    var itemSet: AmazonItemSet = AmazonItemSet(items : [], itemsWithURL : [])
    
    private var currItems : [AmazonItem] = []
    private var currItemsWithURL : [AmazonItemWithUrl] = []
    
    private var currItem : AmazonItem?
    private var currItemName : String?
    private var currItemASIN : String?
    
    private var currItemWithURL: AmazonItemWithUrl?
    
    private var currItemURL : String?
    private var currItemProductGroup : String?
    
    
    private var currNode: AmazonSubcategory?
    private var currNodeName: String?
    private var currNodeID: String?
    private var currElement: String?
    
    var parser = XMLParser()
    var isParsing = false
    
    func initFromXMLResponse(responseObject: Any) {
        if let parser = responseObject as? XMLParser {
            parser.delegate = self
            let _ = parser.parse()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Children" || elementName == "TopSellers" || elementName == "TopItemSet" {
            self.isParsing = true
        }
        if self.isParsing {
            if elementName == "BrowseNode" {
                self.currNode = nil
                self.currNodeName = ""
                self.currNodeID = ""
                self.currElement = nil
            }
            if elementName == "TopSeller" {
                self.currItemName = ""
                self.currItemASIN = ""
            }
            if elementName == "TopItem" {
                self.currItemName = ""
                self.currItemASIN = ""
                self.currItemURL = ""
                self.currItemProductGroup = ""
            }
            
            if elementName == "BrowseNodeId" || elementName == "Name"  || elementName == "ASIN" || elementName == "Title" || elementName == "DetailPageURL" || elementName == "ProductGroup" {
                self.currElement = elementName
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.isParsing {
            if self.currElement == "BrowseNodeId" {
                self.currNodeID?.append(string)
            } else if self.currElement == "Name" {
                self.currNodeName?.append(string)
            } else if self.currElement == "Title" {
                self.currItemName?.append(string)
            } else if self.currElement == "ASIN" {
                self.currItemASIN?.append(string)
            } else if self.currElement == "DetailPageURL" {
                self.currItemURL?.append(string)
            } else if self.currElement == "ProductGroup" {
                self.currItemProductGroup?.append(string)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Children" {
            self.isParsing = false
        }
        if elementName == "TopSellers"{
            self.itemSet.items.append(contentsOf: self.currItems)
            self.isParsing = false
        }
        
        if elementName == "TopItemSet" {
            self.itemSet.itemsWithURL.append(contentsOf: self.currItemsWithURL)
            self.isParsing = false
        }
        if self.isParsing {
            if elementName == "BrowseNode" && self.currNodeName != nil && self.currNodeID != nil {
                self.currNode = AmazonSubcategory(name: self.currNodeName!, nodeID: self.currNodeID!)
                self.nodes.append(self.currNode!)
            }
            if elementName == "TopSeller" && self.currItemASIN != nil && self.currItemName != nil {
                self.currItem = AmazonItem(title: self.currItemName!, ASIN: self.currItemASIN!)
                self.currItems.append(self.currItem!)
            }
            if elementName == "TopItem" && self.currItemASIN != nil && self.currItemName != nil && self.currItemProductGroup != nil && self.currItemURL != nil {
                self.currItemWithURL = AmazonItemWithUrl(title: self.currItemName!, ASIN: self.currItemASIN!, detailPageURL: self.currItemURL!, productGroup: self.currItemProductGroup!)
                self.currItemsWithURL.append(self.currItemWithURL!)
            }
        }
    }
}
