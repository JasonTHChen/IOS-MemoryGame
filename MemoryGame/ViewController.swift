//
//  ViewController.swift
//  MemoryGame
//
//  Created by Jason Chen on 2018-04-14.
//  Copyright © 2018 Jason Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var tileWidth: CGFloat!
    
    // to store both tiles and centers
    var tilesArr: NSMutableArray = []
    var centersArr: NSMutableArray = []
    
    var curTime: Int = 0
    var gameTimer: Timer?
    
    var matched: Int = 0
    var turns: Int = 0
    
    var compareState: Bool = false
    var firstTile: MyLabel!
    var secondTile: MyLabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        resetButton.layer.cornerRadius = 15
        gameTimer = Timer()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.resetAction(Any.self)
    }
    
    func randomizeAction()
    {
        // go through the blocks in order and give them a random center
        for tile in tilesArr
        {
            let randIndex: Int = Int(arc4random()) % centersArr.count
            let randCenter: CGPoint = centersArr[randIndex] as! CGPoint
            
            (tile as! MyLabel).center = randCenter
            centersArr.removeObject(at: randIndex)
        }
    }
    
    func blockMarkerAction()
    {
        tileWidth = gameView.frame.size.width / 4
        
        var xCen: CGFloat = tileWidth / 2
        var yCen: CGFloat = tileWidth / 2
        
        let tileFrame:CGRect = CGRect(x: 0, y: 0, width: tileWidth - 4, height: tileWidth - 4)
        
        var counter: Int = 1
        
        for _ in 0..<4
        {
            for _ in 0..<4
            {
                let tile: MyLabel = MyLabel(frame: tileFrame)
                
                if counter > 8
                {
                    counter = 1
                }
                
                tile.text = String(counter)
                tile.tagNumber = counter
                tile.textAlignment = NSTextAlignment.center
                tile.font = UIFont.boldSystemFont(ofSize: 20)
                let cen: CGPoint = CGPoint(x: xCen, y: yCen)
                
                tile.isUserInteractionEnabled = true
                
                tile.center = cen
                tile.backgroundColor = UIColor(red: 255/255, green: 153/255, blue: 159/255, alpha: 1.0) /* #ff999f */
                gameView.addSubview(tile)
                
                tilesArr.add(tile)
                centersArr.add(cen)
                
                xCen = xCen + tileWidth
                counter += 1
            }
            yCen = yCen + tileWidth
            xCen = tileWidth / 2
        }
    }
    
    @IBAction func resetAction(_ sender: Any)
    {
        self.turns = 0
        self.matched = 0
        turnLabel.text = String(self.turns)
        for anyView in gameView.subviews
        {
            anyView.removeFromSuperview()
        }
        
        tilesArr = []
        centersArr = []
        
        blockMarkerAction()
        randomizeAction()
        
        for anyTile in tilesArr
        {
            (anyTile as! MyLabel).text = "?"
            (anyTile as! MyLabel).matched = false
            (anyTile as! MyLabel).flipped = false
        }
        
        curTime = 0
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(timerFunc),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    @objc func timerFunc()
    {
        curTime += 1
        
        let timeMins: Int = curTime / 60 // (110 / 60) = 1
        let timeSecs: Int = curTime % 60 // (110 % 60) = 50
        let timeStr: String = NSString(format: "%02d\' : %02d\"", timeMins, timeSecs) as String
        
        timeLabel.text = timeStr
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let myTouch: UITouch = touches.first!
        
        if (tilesArr.contains(myTouch.view as Any))
        {
            let thisTile: MyLabel = myTouch.view as! MyLabel
            
            if !thisTile.matched && !thisTile.flipped
            {
                UIView.transition(with: thisTile,
                                  duration: 0.75,
                                  options: UIViewAnimationOptions.transitionFlipFromRight,
                                  animations: {
                                    thisTile.text = String(thisTile.tagNumber)
                                    thisTile.backgroundColor = UIColor(displayP3Red: 183.0/255, green: 234.0/255, blue: 249.0/255, alpha: 1.0)
                }, completion: {(true) in
                    if self.compareState
                    {
                        // let's compare
                        self.compareState = false
                        self.secondTile = thisTile
                        self.compareAction()
                        // comparison
                        
                    }
                    else
                    {
                        // only flip
                        thisTile.flipped = true
                        self.firstTile = thisTile
                        self.compareState = true
                    }
                })
            }
        }
    }
    
    func flipThemBack(anyInp: Array<Any>)
    {
        for anyObj in anyInp
        {
            let thisTile = anyObj as! MyLabel
            thisTile.matched = true;
            UIView.transition(with: thisTile,
                              duration: 0.75,
                              options: UIViewAnimationOptions.transitionFlipFromRight,
                              animations: {
                                thisTile.text = "👻"
                                thisTile.backgroundColor = UIColor(red: 83/255, green: 204/255, blue: 42/255, alpha: 1.0) /* #53cc2a */
            }, completion: nil)
        }
    }
    
    func compareAction()
    {
        self.turns += 1
        turnLabel.text = String(self.turns)
        
        print("We have items: \(firstTile.tagNumber) and \(secondTile.tagNumber)")
        if firstTile.tagNumber == secondTile.tagNumber
        {
            matched += 1
            
            if matched == 8
            {
                let timeMins: Int = curTime / 60 // (110 / 60) = 1
                let timeSecs: Int = curTime % 60 // (110 % 60) = 50
                let timeStr: String = NSString(format: "%02d\' : %02d\"", timeMins, timeSecs) as String
                
                let alert = UIAlertController(title: "You Won",
                                              message: "It took you \(timeStr) and \(self.turns) turns",
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Play Again",
                                             style: UIAlertActionStyle.default,
                                             handler: {action in
                                                switch action.style {
                                                case .default:
                                                    self.resetAction(Any.self)
                                                case .cancel: break
                                                case .destructive: break
                                                }
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                if gameTimer != nil
                {
                    gameTimer?.invalidate()
                    gameTimer = nil
                }
            }
            
            self.flipThemBack(anyInp: [firstTile, secondTile])
        }
        else
        {
            // they are different
            firstTile.flipped = false
            UIView.transition(with: self.view,
                              duration: 0.75,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {
                                self.firstTile.text = "?"
                                self.secondTile.text = "?"
                                self.firstTile.backgroundColor = UIColor(red: 255/255, green: 153/255, blue: 159/255, alpha: 1.0) /* #ff999f */
                                self.secondTile.backgroundColor = UIColor(red: 255/255, green: 153/255, blue: 159/255, alpha: 1.0) /* #ff999f */
            },
                              completion: nil)
        }
    }
}


class MyLabel: UILabel
{
    var tagNumber: Int!
    var matched: Bool = false
    var flipped: Bool = false
}
