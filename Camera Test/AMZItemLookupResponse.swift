//
//  AMZItemLookupResponse.swift
//  Piktora
//
//  Created by Kunal Thacker on 12/24/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import Foundation

class AMZItemLookupResponse : NSObject, XMLParserDelegate {
    var similarItems : [AmazonItem] = []
    var imageURL = ""
    var ASIN = ""
    
    private var currItem : AmazonItem?
    private var currItemName = ""
    private var currItemASIN = ""
    
    private var isImageSet = false
    private var isParsing = false
    private var isParsingSimilarItems = false
    private var currElement  = ""
    
    func initFromXMLResponse(responseObject: Any) {
        if let parser = responseObject as? XMLParser {
            parser.delegate = self
            let _ = parser.parse()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "ImageSets" {
            self.isParsing = false
            self.isImageSet = true
        }
        if elementName == "MediumImage" {
            self.isParsing = true
        }
        if elementName == "SimilarProducts" {
            self.isParsingSimilarItems = true
        }
        if self.isParsing && !self.isImageSet {
            if elementName == "URL" {
                self.imageURL = ""
            }
        }
        if self.isParsingSimilarItems {
            if elementName == "SimilarProduct" {
                self.currItem = nil
                self.currItemName = ""
                self.currItemASIN = ""
            }
        }
        if elementName == "ASIN" || elementName == "Title" {
            self.currElement = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.isParsing && !self.isImageSet {
            self.imageURL += string
        }
        if self.isParsingSimilarItems {
            if self.currElement == "ASIN" {
                self.currItemASIN += string
            } else if self.currElement == "Title" {
                self.currItemName += string
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.isParsing && !self.isImageSet {
            if elementName == "URL" {
                self.isParsing = false
            }
        }
        if elementName == "ImageSets" {
            self.isImageSet = false
        }
        if elementName == "MediumImage" {
            self.isParsing = false
        }
        
        if elementName == "SimilarProduct" {
            self.currItem = AmazonItem(title: self.currItemName, ASIN: self.currItemASIN)
            self.similarItems.append(self.currItem!)
        }
    }
    
}
