//
//  ViewController.swift
//  StoryboardWatchApp
//
//  Created by Benoit Briatte on 21/09/2022.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    
    var game : [[Int]] = Array(repeating: Array(repeating: 0, count: 15), count: 11)
    var charPos : [Int] = [0, 0]
    var walls : [[Int]] = []
    var nonWalls : [[Int]] = []
    var viewWidth : CGFloat!
    var viewHeight : CGFloat!
    var enemies : [[Int]] = []
    var bombs: [[Int]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        WCSession.default.delegate = self
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        let screenSize: CGRect = UIScreen.main.bounds
        self.viewWidth = screenSize.width
        self.viewHeight = screenSize.height
        self.walls = self.initObjects(limit: 5)
        self.enemies = self.initObjects(limit: 6)
        self.nonWalls = self.initObjects(limit: 3)
        
        print(enemies.count)
        print(walls.count)
        print(nonWalls.count)
        self.redraw()
        
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    func initObjects(limit: Int) -> [[Int]] {
        var objectPos : [[Int]] = []
        var i = limit
        for _ in 0...i {
            let x = Int.random(in: 1..<14)
            let y = Int.random(in: 1..<11)
            
            if !objectPos.contains([x, y]) && self.isCellEmpty(x: x, y: y) {
                objectPos.append([x, y])
            }else {
                i += 1;
            }
        }
        return objectPos
    }
    
    func isCellEmpty(x: Int, y: Int) -> Bool {
        if self.walls.contains([x, y]) || self.nonWalls.contains([x, y]) || self.enemies.contains([x, y]) {
            return false
        }
        return true
    }
    
    func removeFromCell(x: Int, y: Int) {
        if self.isCellEmpty(x: x, y: y){
            return
        }
        if self.enemies.contains([x, y]) {
            var i = 0
            for enemy in self.enemies {
                
                if (enemy == [x,y]) {
                    self.enemies.remove(at: i)
                }
                i += i
            }
        }
        if self.walls.contains([x, y]) {
            var i = 0
            for wall in self.walls{
                
                if (wall == [x,y]) {
                    self.walls.remove(at: i)
                }
                i += 1
            }
        }
    }
    

    func redraw() {
        for j in 0...10 {
            for i in 0...14 {
                let view = UIView()
                view.frame = CGRect(x: (self.viewWidth/15)*CGFloat(i), y: CGFloat(j)*(self.viewHeight/11), width: (self.viewWidth/15), height: (self.viewHeight/11))
                
                view.backgroundColor = UIColor(patternImage: UIImage(named: "road.png")!)
                
                if j == self.charPos[0] && i == self.charPos[1] {
                    view.backgroundColor = UIColor(patternImage: UIImage(named: "Hobbit.png")!)
                }
                
                if self.walls.contains([i, j]){
                    view.backgroundColor = UIColor(patternImage: UIImage(named: "wall.png")!)
                }
                
                if self.nonWalls.contains([i, j]) {
                    view.backgroundColor = UIColor(patternImage: UIImage(named: "durable-wall.png")!)
                }
                
                if self.enemies.contains([i, j]) {
                    view.backgroundColor = UIColor(patternImage: UIImage(named: "skeleton.png")!)
                }
                
                if self.bombs.contains([i, j]){
                    view.backgroundColor = UIColor(patternImage: UIImage(named: "bomb.png")!)
                }
                
                self.view.addSubview(view)
            }
        }
    }

}



extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("coucou")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
                
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("VC : \(message)")
        switch message["Move"] as? String {
        case "UP":
            if self.isCellEmpty(x: self.charPos[1], y: self.charPos[0] - 1) {
                self.charPos[0] -= 1
            }
        case "DOWN":
            if self.isCellEmpty(x:self.charPos[1]  , y:  self.charPos[0] + 1){
                self.charPos[0] += 1
            }
        case "LEFT":
            if self.isCellEmpty(x:self.charPos[1] - 1 , y:  self.charPos[0]){
                self.charPos[1] -= 1
            }
        case "RIGHT":
            if self.isCellEmpty(x:self.charPos[1] + 1 , y:  self.charPos[0]){
                self.charPos[1] += 1
            }
        case "BOMB":
            var array : [Int] = [0, 0]
            array[0] = self.charPos[1]
            array[1] = self.charPos[0]
            self.bombs.append(array)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.drawWithBomb(x : array[0], y: array[1])
            }
        default:
            self.charPos[0] += 0
        }
        print(self.charPos)
        DispatchQueue.main.async {
            self.redraw()
        }
    }
    
    func drawWithBomb(x: Int, y: Int){
        self.bombs.removeAll()
        
        let explosionArray = [[x-2, y], [x-1, y],[x+2, y], [x+1, y], [x, y], [x, y+1], [x, y+2], [x, y-1], [x, y-2]]
        for j in 0...10 {
            for i in 0...14 {
                let view = UIView()
                view.frame = CGRect(x: (self.viewWidth/15)*CGFloat(i), y: CGFloat(j)*(self.viewHeight/11), width: (self.viewWidth/15), height: (self.viewHeight/11))
                
                view.backgroundColor = UIColor(patternImage: UIImage(named: "road.png")!)
                
                if j == self.charPos[0] && i == self.charPos[1] {
                    view.backgroundColor = UIColor(patternImage: UIImage(named: "Hobbit.png")!)
                }
                
                if explosionArray.contains([i, j]) {
                    view.backgroundColor = UIColor(patternImage: UIImage(named: "boum.png")!)
                    self.removeFromCell(x: i, y: j)
                } else {
                    if self.walls.contains([i, j]){
                        view.backgroundColor = UIColor(patternImage: UIImage(named: "wall.png")!)
                    }
                    
                    if self.enemies.contains([i, j]) {
                        view.backgroundColor = UIColor(patternImage: UIImage(named: "skeleton.png")!)
                    }
                    
                    if explosionArray.contains([i, j]) {
                        view.backgroundColor = UIColor(patternImage: UIImage(named: "boum.png")!)
                    }
                    
                    if self.nonWalls.contains([i, j]) {
                        view.backgroundColor = UIColor(patternImage: UIImage(named: "durable-wall.png")!)
                    }
                }
                
                
                
                
                
                
                
                
                self.view.addSubview(view)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.redraw()
                }
            }
        }
    }
    
    
}
