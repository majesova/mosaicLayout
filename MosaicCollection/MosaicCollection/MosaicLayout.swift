//
//  MosaicLayout.swift
//  MosaicCollection
//
//  Created by Plenumsoft on 28/04/17.
//  Copyright © 2017 Majesova. All rights reserved.
//

import UIKit


class MyElementProvider{
    
    var data : [MyElement]?
    
    var maxIndex = 0
    
    init(maxIndex:Int){
        self.maxIndex = maxIndex
    }
    
    func getData(screenWidth:CGFloat, padding: CGFloat) -> [MyElement]{
        
        
        //jump indica si el siguiente elemento debe brincar
        
        var cosas = [MyElement]()
        
        let element = MyElement()
        element.column = 0
        element.widthRatio = 0.5
        element.heightPx = 95
        element.jump = false
        cosas.append(element)
        
        let element1 = MyElement()
        element1.column = 1
        element1.widthRatio = 0.5
        element1.heightPx = 95
        element1.jump = true
        cosas.append(element1)
        
        let element2 = MyElement()
        element2.column = 0
        element2.widthRatio = 1
        element2.heightPx = 100
        element2.jump = true
        cosas.append(element2)
        
        let element3 = MyElement()
        element3.column = 0
        element3.widthRatio = 1
        element3.heightPx = 150
        element3.jump = true
        cosas.append(element3)
        
        let element4 = MyElement()
        element4.column = 0
        element4.widthRatio = 0.5
        element4.heightPx = 87
        element4.jump = false
        cosas.append(element4)
        
        let element5 = MyElement()
        element5.column = 1
        element5.widthRatio = 0.5
        element5.heightPx = 87
        element5.jump = true
        cosas.append(element5)
        
        var row = 0
        for cosa in cosas {
            
            cosa.widthPx = (screenWidth - padding * 2) * cosa.widthRatio
            if cosa.widthRatio == 1 {
                //Si es fullwidth se le suma el padding de en medio
                cosa.widthPx = (screenWidth - padding * 3) * cosa.widthRatio
            }
            if cosa.column == 0{
                
                cosa.xOffset = 10;
                
            }else{
                //Se corre el ancho
                cosa.xOffset = (screenWidth) * cosa.widthRatio
            }
            cosa.row = row
            row += 1
        }
        data = cosas
        return cosas
    }
    
    func getDataByPos(pos: Int) -> MyElement{
        
        if pos <= self.maxIndex {
            return data![pos]
        }
        
        var index = 0
        var residuo = pos % (maxIndex + 1)
        
        /*if residuo > 0 {
            index = residuo - 1;
        }*/
       index = residuo
        print("pos \(pos) % maxIndex \(maxIndex) = \(residuo) -> \(index)")
        
        let item = data![index]
        
        return item
    }
    
    func getPrevious(fromIndex: Int) -> MyElement {
        let item = getDataByPos(pos: fromIndex - 1)
        return item
    }

}


class MyElement {

    var widthRatio:CGFloat = 0 //ancho en porcentaje
    var heightPx: CGFloat = 0 //fijo
    var column: Int?
    var xOffset : CGFloat = 0
    var yOffset : CGFloat = 0
    var widthPx : CGFloat = 0
    var jump: Bool = false
    var row : Int = 0
}


protocol MosaicLayoutDelegate {

    func collectionView(_ collectionView:UICollectionView, heightForCellAtIndexPath:IndexPath, withWidth:CGFloat)

}


class MosaicLayoutAttributes: UICollectionViewLayoutAttributes{

    var height : CGFloat = 0.0
    var width : CGFloat = 0.0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! MosaicLayoutAttributes
        copy.width = width
        copy.height = height
        return copy
    }
    
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attrs = object as? MosaicLayoutAttributes {
            if attrs.height == height && attrs.width == width{
                return super.isEqual(object)
            }
        }
        return false
    }
    
}

class MosaicLayout: UICollectionViewLayout , UICollectionViewDelegateFlowLayout{

    var numItems = 0
    
    var delegate: MosaicLayoutDelegate!
    
    var cellPadding : CGFloat = 6.0
    
    fileprivate var cache = [MosaicLayoutAttributes]()
    
    fileprivate var contentHeight:CGFloat  = 0.0
    
    fileprivate var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    var yOffset : CGFloat = 0
    
    
    override func prepare() {
        
        let elementProvider = MyElementProvider(maxIndex: 5)
        let items = elementProvider.getData(screenWidth: contentWidth, padding:cellPadding)
        
        for item in 0 ..< numItems {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let item = elementProvider.getDataByPos(pos: item)
            
            //método para pintar la celda, crear el frame etc
            let height = cellPadding +  item.heightPx + cellPadding
            
            let frame = CGRect(x: item.xOffset, y: yOffset, width: item.widthPx, height: height)
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = MosaicLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            if item.jump == true {
                yOffset += item.heightPx + cellPadding
            }
            
            contentHeight = max(contentHeight, frame.maxY)
        }
        
        
    }
    
    override var collectionViewContentSize: CGSize{
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes  in cache {
            if attributes.frame.intersects(rect ) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    
}
