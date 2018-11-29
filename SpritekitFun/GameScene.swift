//
//  GameScene.swift
//  SpritekitFun
//
//  Created by Chucka, Zachary Tyler on 11/27/18.
//  Copyright © 2018 Chucka, Zachary Tyler. All rights reserved.
//

import SpriteKit
import GameplayKit

// kinda like our view controller
// a SKScene.swift file can have a .sks file which is like the GUI editor componenet for this swift file
// parallel: viewController.swift would connect to a ViewController scene in storyboard which we would edit with Interface builder
// now we have GameScene.swift which connects to a GameScene.sks file which we edit in the Scene Editor
class GameScene: SKScene {
    var background = SKSpriteNode()
    var spike = SKSpriteNode()
    var floor = SKSpriteNode()
    var ceiling = SKSpriteNode()
    var timer = Timer()
    
    override func didMove(to view: SKView) {
        // recall a SKView can show one or more SKScenes
        // this method is like viewDidLoad()
        // its called when the view "moves to" this scene
        // put init code
        //print("Frame width: \(self.frame.width) height: \(self.frame.height)")
        //print("maxX: \(self.frame.maxX) minX: \(self.frame.minX)")
        //print("maxy: \(self.frame.maxY) minY: \(self.frame.minY)")
        //print("midX: \(self.frame.midX) midY: \(self.frame.midY)")
        background = SKSpriteNode(imageNamed: "court")
        background.size = CGSize(width: self.frame.width, height: self.frame.height)
        // we want the background to be "behind" all our other sprites
        background.zPosition = -1
        addChild(background)
        
        // add spike
        spike = SKSpriteNode(imageNamed: "spike")
        spike.size = CGSize(width: 200, height: 200)
        // our scene already has a physics world
        // we just need to add physics bodies to our sprites so that they interact with the physics world
        spike.physicsBody = SKPhysicsBody(circleOfRadius: spike.size.height / 2)
        addChild(spike)
        
        // we need to add a floor for spike
        floor = SKSpriteNode(color: .blue, size: CGSize(width: self.frame.width, height: 50))
        floor.position = CGPoint(x: self.frame.midX, y: self.frame.minY + (floor.size.height / 2))
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: floor.size.height))
        floor.physicsBody?.isDynamic = false
        addChild(floor)
        
        ceiling = SKSpriteNode(color: .blue, size: CGSize(width: self.frame.width, height: 50))
        ceiling.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - (ceiling.size.height / 2))
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: floor.size.height))
        ceiling.physicsBody?.isDynamic = false
        addChild(ceiling)
        
        // now we have to add the flying basketballs
        // task: add a timer that every 3 seconds calls a function addBall
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            self.addBall()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        spike.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func addBall() {
        // 1. create a SKSpriteNode for a ball
        // 2.  add an animation to the ball that moves it from right to left across the screen
        //     when the ball gets off the screen, we remove it
        // 3. ball will rotate (aesthetic)
        // 4. set up contacts and collisions for spike/ the floor/ the ceiling/ basketballs/ footballs
        // 5. add footballs
        
        let ball = SKSpriteNode(imageNamed: "basketball")
        ball.size = CGSize(width: 125, height: 125)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.isDynamic = false
        let randY = CGFloat(0)
        ball.position = CGPoint(x: self.frame.maxX, y: randY)
        addChild(ball)
        
        // step 2 use SKActions define animations
        let moveLeft = SKAction.move(to: CGPoint(x: self.frame.minX, y: randY), duration: 2)
        let removeAction = SKAction.removeFromParent()
        let animation = SKAction.sequence([moveLeft, removeAction])
        ball.run(animation)
    }
}
