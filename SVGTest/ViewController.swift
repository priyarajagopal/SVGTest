//
//  ViewController.swift
//  SVGTest
//
//  Created by Priya Rajagopal on 7/27/16.
//  Copyright © 2016 Invicara. All rights reserved.
//

import UIKit
import SVGKit




class ViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    #if SINGLELAYER
    // render as a single layer . ELement selecxtion can be more expensive
    var singleLayerContentView:SVGKFastImageView?
    #else
    // Render as a series of layers- every path component is a separate layer
    var contentView: SVGKImageView?
    #endif
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.scrollView.delegate = self
        if let localFile = SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("drawing1") {
            loadSVGFromFile(localFile)
        }
        else {
            print ("Couldnt load file")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension ViewController :UIScrollViewDelegate{
    func loadSVGFromFile(source:SVGKSource) {
        if let source = source as? SVGKSourceLocalFile {
       
            SVGKImage.imageWithSource(source, onCompletion: { (loadedImage, parseResult) in
                dispatch_async(dispatch_get_main_queue(), {
                    #if SINGLELAYER
                    if let singleLayerContentView:SVGKFastImageView = self.internalLoadedResource(source, parserOutput: parseResult, createImageViewFromDocument: loadedImage) {
                       
                            self.singleLayerContentView = singleLayerContentView
                            
                            self.scrollView.addSubview(singleLayerContentView)
                            self.addTapGestureRecognizerToContentView()
                            self.scrollView.contentSize = singleLayerContentView.frame.size
                            let screenToDocumentSizeRatio = self.scrollView.frame.size.width / singleLayerContentView.frame.size.width;
                            
                            self.scrollView.minimumZoomScale = 0.25
                            self.scrollView.maximumZoomScale = 5

                        }
                    #else
                    if let contentView:SVGKImageView = self.internalLoadedResource(source, parserOutput: parseResult, createImageViewFromDocument: loadedImage) {
                        
                        self.contentView = contentView
                        
                        self.scrollView.addSubview(contentView)
                        self.addTapGestureRecognizerToContentView()
                        self.scrollView.contentSize = contentView.frame.size
                        let screenToDocumentSizeRatio = self.scrollView.frame.size.width / contentView.frame.size.width;
                        
                        self.scrollView.minimumZoomScale = 0.25
                        self.scrollView.maximumZoomScale = 5
                        
                    
                        }
                #endif

                })
            })
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?  {
        #if SINGLELAYER
        return self.singleLayerContentView;
        #else
        return self.contentView
        #endif
    }
    
   
    private func internalLoadedResource<T>(source:SVGKSource, parserOutput parseResult:SVGKParseResult?, createImageViewFromDocument document:SVGKImage?)->T? {
     
        var newContentView:T?
   
       // self.printParsedDocument(parseResult?.parsedDocument)
        if let document = document {
            if let _ = document.parseErrorsAndWarnings.rootOfSVGTree {
                print (document.size)
            #if SINGLELAYER
                newContentView = SVGKFastImageView.init(SVGKImage: document) as? T
            #else
                 newContentView = SVGKLayeredImageView.init(SVGKImage: document) as? T
            #endif
                
            }
            
            if let parseResult = parseResult where parseResult.errorsFatal.count > 0 {
                print ("fatal error when parsing SVG \(parseResult)")
                
            }
        }
        else {
            if let parseResult = parseResult {
                print ("Error in parsing SVG with error \(parseResult)")
            }
            else {
                print ("Unknown error when parsing SVG doc")
            }
        }
        return newContentView
        
    }
    
    private func printParsedDocument(domDocument:SVGDocument?) {
        let element = domDocument?.getElementById("face")
        print (element)
        
    }
    
    // MARK- Gesture Recognizers
    private func addTapGestureRecognizerToContentView() {
        let sel = "handleTapGesture:"
        let gesture = UITapGestureRecognizer(target: self, action: Selector(sel))
        #if SINGLELAYER
        self.singleLayerContentView?.addGestureRecognizer(gesture)
        #else
        self.contentView?.addGestureRecognizer(gesture)
        #endif
    }
    
    func handleTapGesture(gesture:UITapGestureRecognizer) {
    
        print(#function)
        let point:CGPoint = gesture.locationInView(self.contentView)
        #if SINGLELAYER
        let layerForHitTesting = self.singleLayerContentView?.image.CALayerTree
        #else
        let layerForHitTesting = self.contentView?.layer
        #endif
        /*
        Returns the farthest descendant of the layer containing point 'p'.
         * Siblings are searched in top-to-bottom order. 'p' is defined to be
        * in the coordinate space of the receiver's nearest ancestor that
        * isn't a CATransformLayer (transform layers don't have a 2D
        * coordinate space in which the point could be specified).
        */
        
        if let hitTestDescendent = layerForHitTesting?.hitTest(point) {
            
            
            if let shapeLayer = hitTestDescendent as? CAShapeLayer {
    //            shapeLayer?.borderColor = UIColor.redColor().CGColor
    //            shapeLayer?.borderWidth = 2.0
                
                // Highlight the selected shape
                shapeLayer.fillColor = UIColor(red: 0.904, green: 0.941, blue: 0.247, alpha: 8.0).CGColor
                
                // Fetch details corresponding to selected element in selected layer. This could be used in future for fetching selected element properties
                if let name = shapeLayer.name, element = self.contentView?.image.DOMDocument?.getElementById(name) as? SVGElement {
                    
                     print ("Id of selected element is \(element.identifier)")
                    let text = textLabelViewWithText(name,atPosition:point)
                    self.contentView?.addSubview(text)
                    
                }
                else {
                    print("Element Identifier  not found")
                }
                
            
            
           
            }
            else {
                // WOuld happen if selectable area
                // recursively traverse the sub layers from the root to get to the right layer ...but cant identify the shape
                if let shapeLayers =  hitTestDescendent.sublayers {
                    print("Selected layer is \(hitTestDescendent)")
                  //  self.changeFillColorRecursively(shapeLayers, color:  UIColor(red: 0.904, green: 0.941, blue: 0.247, alpha: 8.0))
                   
                }
            
            }
        
            
            #if SINGLELAYER
                 if let name = hitTestDescendent.name {
                    
                    if let element = self.singleLayerContentView?.image.DOMDocument?.getElementById(name) as? SVGElement {
                        print (element)
                    }
                    
                    
                    if let  absoluteLayer = self.singleLayerContentView!.image.newCopyPositionedAbsoluteLayerWithIdentifier(name) {
                        absoluteLayer.backgroundColor = UIColor.blueColor().CGColor
                        self.singleLayerContentView?.layer.addSublayer(absoluteLayer)
                    }
                    print (name)
                }
                
            #endif

       
        }
    }
    
    private func textLayerWithText(textStr:String, atPosition:CGPoint)->CATextLayer {
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        textLayer.string = textStr
        textLayer.alignmentMode = "left"
        textLayer.font = UIFont.systemFontOfSize(12.0)
        
     
        let size = textStr.boundingRectWithSize( CGSizeMake(200, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:[NSFontAttributeName:textLayer.font!], context:nil).size
        
        textLayer.frame = CGRectMake(atPosition.x, atPosition.y, size.width,size.height )
        
        textLayer.foregroundColor = UIColor.darkGrayColor().CGColor
        return textLayer
    }
    
    private func textLabelViewWithText(textStr:String, atPosition:CGPoint)-> UILabel {
        
        let font =  UIFont.systemFontOfSize(15.0)
        let size = textStr.boundingRectWithSize( CGSizeMake(200, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:[NSFontAttributeName:font], context:nil).size
        
       
        let textLabel = UILabel(frame: CGRectMake(atPosition.x, atPosition.y, size.width,size.height ))
        textLabel.numberOfLines = 0
        textLabel.text = textStr
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.font = font
        textLabel.backgroundColor = UIColor.orangeColor()
        
        return textLabel
    }
    
    // https://github.com/SVGKit/SVGKit/issues/98
    private func changeFillColorRecursively(sublayers: [AnyObject], color: UIColor){
       // guard let sublayers = sublayers else {return nil }
        
        for layer in sublayers {
            
            if let l = layer as? CAShapeLayer {
                l.fillColor = color.CGColor
    
            }
            if let l = layer as? CALayer, sub = l.sublayers {
                changeFillColorRecursively(sub, color: color)
            }
        }
 
    
   
    }

}
