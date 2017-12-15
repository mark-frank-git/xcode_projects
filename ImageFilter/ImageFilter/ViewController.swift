//
//  ViewController.swift
//  ImageFilter
//
//  Created by Mark Frank on 11/3/17.
//  Copyright © 2017 MarkFrank. All rights reserved.
//

import Cocoa
import CoreImage

class ViewController: NSViewController {
  @IBOutlet var imageView: NSImageView?
  override func viewDidLoad() {
    super.viewDidLoad()
    savedImage    = imageView?.image
    if let cgimg  = savedImage?.CGImage
    {
      let pixelTuple   = pixelValues(fromCGImage: cgimg)
      let imageSize    = CGSize(width:pixelTuple.width, height:pixelTuple.height)
      let cgImage      = image(fromPixelValues: pixelTuple.pixelVals, width: pixelTuple.width, height: pixelTuple.height)
      imageView?.image = NSImage(cgImage:cgImage!, size:imageSize)
    }
    updateImage(centerX:2500, centerY:2500)
  }
  
  func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelVals: [UInt8]?, width: Int, height: Int)
  {
    var width  = 0
    var height = 0
    var pixelVals: [UInt8]?
    if let imageRef = imageRef {
      width  = imageRef.width
      height = imageRef.height
      let bitsPerComponent = imageRef.bitsPerComponent
      let bytesPerRow      = imageRef.bytesPerRow
      let totalBytes       = height * bytesPerRow
      
      let colorSpace = CGColorSpaceCreateDeviceGray()
      var intensities = [UInt8](repeating: 0, count: totalBytes)
      
      let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
      contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
      
      pixelVals = intensities
    }
    return (pixelVals, width, height)
  }
  
  func image(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage?
  {
    var imageRef: CGImage?
    if var pixelValues = pixelValues {
      let bitsPerComponent = 8
      let bytesPerPixel = 1
      let bitsPerPixel = bytesPerPixel * bitsPerComponent
      let bytesPerRow = bytesPerPixel * width
      let totalBytes = height * bytesPerRow
      
      imageRef = withUnsafePointer(to: &pixelValues, {
        ptr -> CGImage? in
        var imageRef: CGImage?
        let colorSpaceRef = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
        let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
        let releaseData: CGDataProviderReleaseDataCallback = {
          (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
        }
        
        if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
          imageRef = CGImage(width: width,
                             height: height,
                             bitsPerComponent: bitsPerComponent,
                             bitsPerPixel: bitsPerPixel,
                             bytesPerRow: bytesPerRow,
                             space: colorSpaceRef,
                             bitmapInfo: bitmapInfo,
                             provider: providerRef,
                             decode: nil,
                             shouldInterpolate: false,
                             intent: CGColorRenderingIntent.defaultIntent)
        }
        
        return imageRef
      })
    }
    
    return imageRef
  }
  func updateImage(centerX:CGFloat, centerY:CGFloat) -> Void
  {
    if savedImage != nil {
      if let cgimg  = savedImage?.CGImage {
      
        let coreImage:CIImage = CIImage(cgImage: cgimg)
      
        let floatArr:Array<CGFloat> = [centerX, centerY]
        let vector = CIVector(values:floatArr, count: floatArr.count)
        let filter = CIFilter(name: "CIBumpDistortion")
        filter?.setValue(vector,    forKey: kCIInputCenterKey)
        filter?.setValue(2000,      forKey: kCIInputRadiusKey)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
      
        if let output = filter?.value(forKey:kCIOutputImageKey) as? CIImage {
          let rep: NSCIImageRep = NSCIImageRep(ciImage: output)
          let filteredImage = NSImage(size:rep.size)
          filteredImage.addRepresentation(rep)
          imageView?.image = filteredImage
        }
      }
    }
    else {
      print("image filtering failed")
    }

  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  var savedImage:NSImage?
  @IBOutlet weak var HorizontalSlider: NSSlider!
  @IBOutlet weak var VerticalSlider: NSSlider!
  
  @IBAction func HorizontalSliderChanged(_ sender: NSSlider) {
    let xCenter = CGFloat(sender.integerValue)
    let yCenter = CGFloat(VerticalSlider.integerValue)
    updateImage(centerX: xCenter, centerY: yCenter)
  }
  
  @IBAction func VerticalSliderChanged(_ sender: NSSlider) {
    let xCenter = CGFloat(HorizontalSlider.integerValue)
    let yCenter = CGFloat(sender.integerValue)
    updateImage(centerX: xCenter, centerY: yCenter)
  }
  
}
extension NSImage {
  var CGImage: CGImage {
    get {
      let context        = NSGraphicsContext.current
      let imageCGRect    = CGRect(x:0, y:0, width:self.size.width, height:self.size.height)
      var imageRect      = NSRectFromCGRect(imageCGRect)
      let imageRef       = cgImage(forProposedRect:&imageRect, context:context, hints:nil)
      return imageRef!
    }
  }
}
