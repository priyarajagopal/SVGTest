//
//  SVGParserExtn.swift
//  SVGTest
//
//  Created by Priya Rajagopal on 8/26/16.
//  Copyright © 2016 Invicara. All rights reserved.
//

import Foundation
import SVGKit

public class SVGParserExtn:NSObject,SVGKParserExtension {
    @objc public func supportedNamespaces() -> [AnyObject]! {
          print(#function)
        return ["bimpk"]
    }
    
    /*! Array of NSString's, one string for each XML tag (within a supported namespace!) that this parser-extension can parse
     *
     * e.g. the main parser returns "[NSArray arrayWithObjects:@"svg", @"title", @"defs", @"path", @"line", @"circle", ...etc... , nil];"
     */
    @objc public func supportedTags() -> [AnyObject]! {
        return ["path"]
    }
    
    /*!
     Because SVG-DOM uses DOM, custom parsers can return any object they like - so long as its some kind of
     subclass of DOM's Node class
     */
    @objc public func handleStartElement(name: String!, document: SVGKSource!, namePrefix prefix: String!, namespaceURI XMLNSURI: String!, attributes: NSMutableDictionary!, parseResult: SVGKParseResult!, parentNode: Node!) -> Node! {
        print(#function)
        return nil
    }
    
    /**
     Primarily used by the few nodes - <TEXT> and <TSPAN> - that need to post-process their text-content.
     In SVG, almost all data is stored in the attributes instead
     */
    @objc public func handleEndElement(newNode: Node!, document: SVGKSource!, parseResult: SVGKParseResult!) {
          print(#function)
    }
}