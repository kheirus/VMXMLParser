//
//  VMXMLParser.swift
//  XMLParserTest
//
//  Created by Jimmy Jose on 22/08/14.
//  Copyright (c) 2014 Varshyl Mobile Pvt. Ltd. All rights reserved.
//

import Foundation


class VMXMLParser: NSObject,NSXMLParserDelegate{
    
    private let kParserError = "Parser Error"
    private var activeElement = ""
    private var previousElement = "-1"
    private var previousElementValue = ""
    private var arrayFinalXML = NSMutableArray()
    private var dictFinalXML  = NSMutableDictionary()
    private var completionHandler:((tags:NSArray?, error:String?)->Void)?
    
    
    class func parseXMLForURL(url:NSURL,completionHandler:((tags:NSArray?, error:String?)->Void)? = nil){
        
        VMXMLParser().initWithURL(url, completionHandler: completionHandler)
        
    }
    
    class func parseXMLForURLString(urlString:NSString,completionHandler:((tags:NSArray?, error:String?)->Void)? = nil){
        
        VMXMLParser().initWithURLString(urlString, completionHandler: completionHandler)
    }
    
    
    class func parseXMLForData(data:NSData,completionHandler:((tags:NSArray?, error:String?)->Void)? = nil){
        
        VMXMLParser().initWithContentsOfData(data, completionHandler:completionHandler)
        
    }
    
    
    private func initWithURL(url:NSURL,completionHandler:((tags:NSArray?, error:String?)->Void)? = nil) -> AnyObject {
        
        parseXMLForUrl(url :url, completionHandler: completionHandler)
        
        return self
        
    }
    
    
    
    private func initWithURLString(urlString :NSString,completionHandler:((tags:NSArray?, error:String?)->Void)? = nil) -> AnyObject {
        
        let url = NSURL.URLWithString(urlString)
        parseXMLForUrl(url :url, completionHandler: completionHandler)
        
        return self
    }
    
    private func initWithContentsOfData(data:NSData,completionHandler:((tags:NSArray?, error:String?)->Void)? = nil) -> AnyObject {
        
        initParserWith(data: data)
        
        return self
        
    }
    
    private func parseXMLForUrl(#url:NSURL,completionHandler:((tags:NSArray?, error:String?)->Void)? = nil){
        
        self.completionHandler = completionHandler
        
        beginParsingXMLForUrl(url)
        
    }
    
    private func beginParsingXMLForUrl(url:NSURL){
        
        let request:NSURLRequest = NSURLRequest(URL:url)
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request,queue:queue,completionHandler:{response,data,error in
            
            if(error){
                if(self.completionHandler != nil){
                    self.completionHandler?(tags:nil,error:error.localizedDescription)
                }
                
            }else{
                
                self.initParserWith(data: data)
                
            }})
    }
    
    
    private func initParserWith(#data:NSData){
        
        var parser = NSXMLParser(data: data)
        parser.delegate = self
        
        var success:Bool = parser.parse()
        
        if success {
            
            if(self.arrayFinalXML != nil){
                if(self.completionHandler != nil){
                    self.completionHandler?(tags:self.arrayFinalXML,error:nil)
                }
            }
            
        } else {
            
            if(self.completionHandler != nil){
                self.completionHandler?(tags:nil,error:kParserError)
            }
        }
        
    }
    
    
    internal func parser(parser: NSXMLParser!,didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
        
        activeElement = elementName;
    }
    
    
    internal func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
        if(dictFinalXML.objectForKey(activeElement)){
            
            arrayFinalXML.addObject(dictFinalXML)
            dictFinalXML = NSMutableDictionary()
            
        }else{
            
            dictFinalXML.setValue(previousElementValue, forKey: activeElement)
        }
        
        previousElement = "-1"
        previousElementValue = ""
        
    }
    
    
    internal func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        
        var str = string as NSString
        
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if((previousElement as NSString).isEqualToString("-1")){
            
            previousElement = activeElement
            previousElementValue = str
            
        }else{
            
            if((previousElement as NSString).isEqualToString(activeElement)){
                
                previousElementValue = previousElementValue + str
                
            }else{
                
                previousElement = activeElement
                previousElementValue = str
            }
        }
        
    }
    
    
    internal func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        if(self.completionHandler != nil){
            self.completionHandler?(tags:nil,error:parseError.localizedDescription)
        }
    }
    
}