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
        if elementName == "Children" {
            self.isParsing = true
        }
        if self.isParsing {
            if elementName == "BrowseNode" {
                self.currNode = nil
                self.currNodeName = ""
                self.currNodeID = ""
                self.currElement = nil
            }
            
            if elementName == "BrowseNodeId" || elementName == "Name" {
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
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Children" {
            self.isParsing = false
        }
       
        if self.isParsing {
            if elementName == "BrowseNode" && self.currNodeName != nil && self.currNodeID != nil {
                self.currNode = AmazonSubcategory(name: self.currNodeName!, nodeID: self.currNodeID!)
                self.nodes.append(self.currNode!)
            }
        }
    }
}
