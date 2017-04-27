//
//  JNDropDownMenu.swift
//  RollbarClient
//
//  Created by Javal Nanda on 4/26/17.
//  Copyright © 2017 Javal Nanda. All rights reserved.
//

import UIKit

struct JNIndexPath {
    var column = 0
    var row = 0
    
    init(column: NSInteger, row: NSInteger) {
        self.column = column
        self.row = row
    }
}

protocol JNDropDownMenuDataSource: class {
    
    func numberOfRows(inColumn: NSInteger, forMenu: JNDropDownMenu) -> Int
    func titleForRow(atIndexPath: JNIndexPath, forMenu: JNDropDownMenu) -> String
    func numberOfColumns(inMenu: JNDropDownMenu) -> NSInteger
}

extension JNDropDownMenuDataSource {
    func numberOfColumns(inMenu: JNDropDownMenu) -> NSInteger {
        return 1
    }
}

protocol JNDropDownMenuDelegate: class {
    func didSelectRow(atIndexPath: JNIndexPath, forMenu: JNDropDownMenu)
}

class JNDropDownMenu: UIView{

    var origin = CGPoint(x: 0, y: 0)
    var currentSelectedMenuIndex = -1
    var show = false
    
    var tableView = UITableView()
    var backGroundView = UIView()
    
    var numOfMenu = 1
    
    //data source
    var array:[String] = [];
    
    //layers array
    var titles:[CATextLayer] = [];
    var indicators:[CAShapeLayer] = [];
    var bgLayers:[CALayer] = [];
    
    var textColor = UIColor.black
    var indicatorColor = UIColor.black
    
    weak var datasource: JNDropDownMenuDataSource? {
        didSet {
            
            //configure view
            
            self.numOfMenu = (datasource?.numberOfColumns(inMenu: self))!
            
            let textLayerInterval = self.frame.size.width / CGFloat(( self.numOfMenu * 2));
            let bgLayerInterval = self.frame.size.width / CGFloat(self.numOfMenu);
            
            var tempTitles:[CATextLayer] = []
            var tempIndicators:[CAShapeLayer] = []
            var tempBgLayers:[CALayer] = []
            
            for i in 0..<self.numOfMenu {
                
                //bgLayer
                let bgLayerPosition = CGPoint(x: (Double(i)+0.5) * Double(bgLayerInterval), y: Double(self.frame.size.height/2));
                let bgLayer = self.createBgLayer(color: UIColor.white, position: bgLayerPosition)
                self.layer.addSublayer(bgLayer)
                tempBgLayers.append(bgLayer)
                
                //title
                let titlePosition = CGPoint(x: Double((i * 2 + 1)) * Double(textLayerInterval), y: Double(self.frame.size.height / 2))
                let titleString = datasource?.titleForRow(atIndexPath: JNIndexPath(column: i, row: 0), forMenu: self)
                let title = self.createTextLayer(string: titleString!, color: self.textColor, point: titlePosition)
                self.layer.addSublayer(title)
                tempTitles.append(title)
                
                //indicator
                let indicator = self.createIndicator(color: self.indicatorColor, point: CGPoint(x: titlePosition.x + title.bounds.size.width / 2 + 8, y: self.frame.size.height / 2))
                self.layer.addSublayer(indicator)
                tempIndicators.append(indicator)
            }
            titles = tempTitles
            indicators = tempIndicators
            bgLayers = tempBgLayers

        }
    }
    
    weak var delegate: JNDropDownMenuDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    init(origin: CGPoint, height: CGFloat) {
    
        let screenSize = UIScreen.main.bounds.size
        super.init(frame: CGRect(origin: CGPoint(x: origin.x,y :origin.y), size: CGSize(width: screenSize.width, height: height)))
        
        self.origin = origin;
        self.currentSelectedMenuIndex = -1;
        self.show = false;
        
        //tableView init
        self.tableView = UITableView.init(frame: CGRect(origin: CGPoint(x: origin.x,y :self.frame.origin.y + self.frame.size.height), size: CGSize(width: self.frame.size.width, height: 0)))
        self.tableView.rowHeight = 38;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        //self tapped
        self.backgroundColor = UIColor.white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.menuTapped(paramSender:)))
        self.addGestureRecognizer(tapGesture)
        
        //background init and tapped
        self.backGroundView = UIView.init(frame: CGRect(origin: CGPoint(x: origin.x,y :origin.y), size: CGSize(width: screenSize.width, height: screenSize.height)))
    
        self.backGroundView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        self.backGroundView.isOpaque = false;
    
        let bgTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(paramSender:)))
        self.backGroundView.addGestureRecognizer(bgTapGesture)
        
        //add bottom shadow
        let bottomShadow = UIView.init(frame: CGRect(origin: CGPoint(x: 0,y :self.frame.size.height-0.5), size: CGSize(width: screenSize.width, height: 0.5)))
        
        bottomShadow.backgroundColor = UIColor.lightGray
        self.addSubview(bottomShadow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createBgLayer(color: UIColor, position: CGPoint) -> CALayer{
        let layer = CALayer()
        layer.position = position
        layer.bounds = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: self.frame.size.width/CGFloat(self.numOfMenu), height: self.frame.size.height-1))
        layer.backgroundColor = color.cgColor;
        return layer
    }
    
    func createIndicator(color: UIColor, point: CGPoint) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: 4, y: 5))
        path.close()
        
        
        layer.path = path.cgPath;
        layer.lineWidth = 1.0;
        layer.fillColor = color.cgColor;
        
        let bound = CGPath(__byStroking: layer.path!, transform: nil, lineWidth: layer.lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: layer.miterLimit)!
        
        layer.bounds = bound.boundingBoxOfPath
        
        layer.position = point;
        
        return layer;
    }
    
    func createTextLayer(string: String, color: UIColor, point: CGPoint) -> CATextLayer {
        
        let size = self.calculateTitleSizeWith(string: string);
        
        let layer = CATextLayer()
        let sizeWidth = (size.width < (self.frame.size.width / CGFloat(self.numOfMenu)) - 25) ? size.width : self.frame.size.width / CGFloat(self.numOfMenu) - 25;
        layer.bounds = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: sizeWidth, height: size.height))
        layer.string = string;
        layer.fontSize = 14.0;
        layer.alignmentMode = kCAAlignmentCenter;
        layer.foregroundColor = color.cgColor;
        layer.contentsScale = UIScreen.main.scale
        layer.position = point;
        
        return layer;
    }
    
    func calculateTitleSizeWith(string: String) -> CGSize {
        let fontSize = 14.0;
        let dict = [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(fontSize))]
        let constraintRect = CGSize(width: 280, height: 0)
        let rect = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: dict, context: nil)
        return rect.size;
    }

}

// Tag gesture
extension JNDropDownMenu {
    
    
    func menuTapped(paramSender: UITapGestureRecognizer) {
        let touchPoint = paramSender.location(in: self)
        
        //calculate index
        let tapIndex = Int(touchPoint.x / (self.frame.size.width / CGFloat(self.numOfMenu)));
        
        for i in 0..<self.numOfMenu {
            if i != tapIndex {
                self.animateIndicator(indicator: indicators[i], forward: false, completion: { _ in
                    self.animateTitle(title: titles[i], show: false, completion: {_ in 
                    })
                })
                
                self.bgLayers[i].backgroundColor = UIColor.white.cgColor
            }
        }
        
        if tapIndex == self.currentSelectedMenuIndex && self.show {
            self.animate(indicator: indicators[self.currentSelectedMenuIndex], background: self.backGroundView, tableView: self.tableView, title: titles[self.currentSelectedMenuIndex], forward: false, completion: { _ in
                self.currentSelectedMenuIndex = tapIndex
                self.show = false
            })
            self.bgLayers[tapIndex].backgroundColor = UIColor.white.cgColor
            
        } else {
            self.currentSelectedMenuIndex = tapIndex;
            self.tableView.reloadData()
            self.animate(indicator: indicators[tapIndex], background: self.backGroundView, tableView: self.tableView, title: titles[tapIndex], forward: true, completion: { _ in
                self.show = true
            })
            self.bgLayers[tapIndex].backgroundColor = UIColor.init(white: 0.9, alpha: 1.0).cgColor
        }

    }
    
    func backgroundTapped(paramSender: UITapGestureRecognizer? = nil) {
        self.animate(indicator: indicators[currentSelectedMenuIndex], background: self.backGroundView, tableView: self.tableView, title: titles[self.currentSelectedMenuIndex], forward: false) { _ in
            self.show = false
        }
        self.bgLayers[self.currentSelectedMenuIndex].backgroundColor = UIColor.white.cgColor
    }
    
}

// Animation
extension JNDropDownMenu {
    
    func animateIndicator(indicator: CAShapeLayer, forward:Bool, completion: ((Bool) -> Swift.Void)) {
        
        let angle = forward ? Double.pi : 0
        let rotate = CGAffineTransform(rotationAngle: CGFloat(angle))
        indicator.transform = CATransform3DMakeAffineTransform(rotate)
        completion(true);
    }
    
    func animateBackGroundView(view: UIView, show:Bool, completion: @escaping ((Bool) -> Swift.Void)) {
        if show {
            self.superview?.addSubview(view)
            view.superview?.addSubview(self)
            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.3)
                completion(true);
            })
        }
        else {
            UIView.animate(withDuration: 0.2, animations: {
                view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
            }, completion: { finished in
                view.removeFromSuperview()
                completion(true);
            })
        }
    }
    
    func animateTableView(tableView: UITableView, show: Bool, completion: @escaping ((Bool) -> Swift.Void)) {
        if show {
            tableView.frame = CGRect(origin: CGPoint(x: self.origin.x, y: self.frame.origin.y + self.frame.size.height), size: CGSize(
            width: self.frame.size.width, height: 0))
            
            self.superview?.addSubview(tableView)
            
            let tableViewHeight = (tableView.numberOfRows(inSection: 0) > 5) ? (5 * tableView.rowHeight) : (CGFloat(tableView.numberOfRows(inSection: 0)) * tableView.rowHeight)
            
            UIView.animate(withDuration: 0.2, animations: { 
                self.tableView.frame = CGRect(origin: CGPoint(x: self.origin.x, y: self.frame.origin.y + self.frame.size.height), size: CGSize(
                    width: self.frame.size.width, height: tableViewHeight))
                completion(true);
            })
            
        }
        else {
            UIView.animate(withDuration: 0.2, animations: { 
                self.tableView.frame = CGRect(origin: CGPoint(x: self.origin.x, y: self.frame.origin.y + self.frame.size.height), size: CGSize(
                    width: self.frame.size.width, height: 0))
            }, completion: { (finished) in
                tableView.removeFromSuperview()
                completion(true);
            })
            
        }
    }
    
    func animateTitle(title: CATextLayer, show: Bool, completion: ((Bool) -> Swift.Void)) {
        let size = self.calculateTitleSizeWith(string: title.string as! String)
        let sizeWidth = (size.width < (self.frame.size.width / CGFloat(self.numOfMenu)) - 25) ? size.width : self.frame.size.width / CGFloat(self.numOfMenu) - 25;
        title.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: sizeWidth, height: size.height))
        
        completion(true);
    }
    
    func animate(indicator: CAShapeLayer, background:UIView, tableView:UITableView, title:CATextLayer, forward:Bool, completion: @escaping ((Bool) -> Swift.Void)) {
        
        animateIndicator(indicator: indicator, forward: forward, completion: {_ in
            animateTitle(title: title, show: forward, completion: {_ in 
                animateBackGroundView(view: background, show: forward, completion: {_ in
                    self.animateTableView(tableView: tableView, show: forward, completion: {_ in
                            completion(true);
                    })
                })
            })
        })
    }

}

// TableView DataSource - Delegate
extension JNDropDownMenu: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(self.datasource != nil, "menu's dataSource shouldn't be nil");
        
        return (self.datasource?.numberOfRows(inColumn: self.currentSelectedMenuIndex, forMenu: self))!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DropDownMenuCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        assert(self.datasource != nil, "menu's datasource shouldn't be nil")
        
        cell?.textLabel?.text = self.datasource?.titleForRow(atIndexPath: JNIndexPath(column: self.currentSelectedMenuIndex, row: indexPath.row), forMenu: self)
        
        cell?.backgroundColor = UIColor.white
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightLight)
        
        cell?.separatorInset = UIEdgeInsets.zero;
        
        if (cell?.textLabel?.text)! == self.titles[self.currentSelectedMenuIndex].string as! String {
            cell?.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
        }
        
        return cell!;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.confiMenuWith(row: indexPath.row)
        self.delegate?.didSelectRow(atIndexPath: JNIndexPath(column: self.currentSelectedMenuIndex, row: indexPath.row), forMenu: self)
    }
    
    func confiMenuWith(row: NSInteger) {
        let title = self.titles[self.currentSelectedMenuIndex];
        title.string = self.datasource?.titleForRow(atIndexPath: JNIndexPath(column: self.currentSelectedMenuIndex, row: row), forMenu: self)
        
        self.animate(indicator: indicators[self.currentSelectedMenuIndex], background: self.backGroundView, tableView: self.tableView, title: titles[self.currentSelectedMenuIndex], forward: false) { _ in
            self.show = false
        }
        
        self.bgLayers[self.currentSelectedMenuIndex].backgroundColor = UIColor.white.cgColor
        
        
        let indicator = self.indicators[self.currentSelectedMenuIndex]
        indicator.position = CGPoint(x: title.position.x + title.frame.size.width / 2 + 8, y: indicator.position.y)
    }
    
    func dismiss() {
        self.backgroundTapped(paramSender: nil)
    }
    
    func selectRow(row: NSInteger, in component:NSInteger) {
        self.currentSelectedMenuIndex = component;
        self.confiMenuWith(row: row)
    }
}
