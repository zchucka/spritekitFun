//
//  GameScene.swift
//  Sprite Kit Fun
//
//  Created by Gina Sprint on 11/27/18.
//  Copyright © 2018 Gina Sprint. All rights reserved.
//

import SpriteKit
import GameplayKit

// kinda like our view controller
// a SKScene .swift file can have a .sks file
// which is the GUI editor component for this swift file
// parallel: ViewController.swift would connect to a ViewController scene in storyboard which we would edit with Interface Builder
// now we have GameScene.swift which connects to a GameScene.sks file which we edit in the Scene Editor
class GameScene: SKScene, SKPhysicsContactDelegate {

    var background = SKSpriteNode()
    var spike = SKSpriteNode()
    var floor = SKSpriteNode()
    var ceiling = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    
    var timer: Timer? = nil
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    enum NodeCategory: UInt32 {
        case spike = 1
        case floorCeiling = 2
        case basketball = 4
        case football = 8
        // unique powers of two because of bitwise and-ing and or-ing
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        // recall a SKView can show one or more SKScenes
        // this method is like viewDidLoad()
        // its called when the view "moves to" this scene
        // put init code
        print("Frame width: \(self.frame.width) height: \(self.frame.height)")
        print("maxX: \(self.frame.maxX) minX: \(self.frame.minX)")
        print("maxY: \(self.frame.maxY) minY: \(self.frame.minY)")
            print("midX: \(self.frame.midX) midY: \(self.frame.midY)")
        
        // add our background to have the court image texture
        background = SKSpriteNode(imageNamed: "court")
        // to add a node to our scene use addChild()
        background.size = CGSize(width: self.frame.width, height: self.frame.height)
        // we want the background to be "behind" all of our other sprites
        background.zPosition = -1 // default 0
        addChild(background)
        
        // add spike
        spike = SKSpriteNode(imageNamed: "spike")
        spike.size = CGSize(width: 225.0, height: 200.0)
        // we want spike to "fall" according to "gravity"
        // our scene already has "physics world"
        // we just need to add physics bodies to our sprites and they will interact with their physics world
        spike.physicsBody = SKPhysicsBody(circleOfRadius: spike.size.height / 2)
        spike.physicsBody?.categoryBitMask = NodeCategory.spike.rawValue
        spike.physicsBody?.contactTestBitMask = NodeCategory.basketball.rawValue | NodeCategory.football.rawValue
        spike.physicsBody?.collisionBitMask = NodeCategory.floorCeiling.rawValue
        // task: set up category bit mask for floor ceiling and basketball
        
        addChild(spike)
        
        // we need to add a floor so spike doesn't fall to oblivion
        floor = SKSpriteNode(color: .blue, size: CGSize(width: self.frame.width, height: 100.0))
        floor.position = CGPoint(x: self.frame.midX, y: self.frame.minY + floor.size.height / 2)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = NodeCategory.floorCeiling.rawValue
        addChild(floor)
        
        ceiling = SKSpriteNode(color: .blue, size: CGSize(width: self.frame.width, height: 100.0))
        ceiling.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - ceiling.size.height / 2)
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.categoryBitMask = NodeCategory.floorCeiling.rawValue
        addChild(ceiling)
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - ceiling.size.height)
        addChild(scoreLabel)
        
        // now we want to add the flying basketballs
        // task: add a timer that every 3 seconds
        // calls a function addBall()
        
        var count = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            if count % 3 == 0
            {
                self.addBall(image: "football")
            } else {
                self.addBall(image: "basketball")
            }
            count += 1
        })
    }
    
    func addBall(image: String) {
        // 1. create a SKSpriteNode for a ball
        let ball = SKSpriteNode(imageNamed: image)
        ball.size = CGSize(width: 125, height: 125)
        // ball position will be
        // x: start off screen to the right
        // y: random y value so that it doesnt overlap
        // with floor or ceiling
        let minRandY = Int(self.frame.minY + floor.size.height + ball.size.height / 2)
        let maxRandY = Int(self.frame.maxY - ceiling.size.height - ball.size.height / 2)
        let randY = CGFloat(Int.random(in: minRandY...maxRandY))
        ball.position = CGPoint(x: self.frame.maxX + ball.size.width / 2, y: randY)
        // add a physics body
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.height / 2)
        ball.physicsBody?.affectedByGravity = false
        
        if image == "basketball" {
            ball.physicsBody?.categoryBitMask = NodeCategory.basketball.rawValue
        } else if image == "football" {
            ball.physicsBody?.categoryBitMask = NodeCategory.football.rawValue
        }
        
        ball.physicsBody?.contactTestBitMask = NodeCategory.spike.rawValue
        ball.physicsBody?.collisionBitMask = 0
        addChild(ball)
        // 2. add an animation to the ball the moves it from right to left across the screen
        // use SKActions to define animations
        let moveLeft = SKAction.move(to: CGPoint(x: self.frame.minX - ball.size.width / 2, y: randY), duration: 2)
        let removeAction = SKAction.removeFromParent()
        let animation = SKAction.sequence([moveLeft, removeAction])
        ball.run(animation)
        // when the ball gets off screen remove it from the scene
        // 3. add an animation so the ball keeps rotating
        // task: for you!
        let rotateBall = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: 1)
        let rotateBallForever = SKAction.repeatForever(rotateBall)
        ball.run(rotateBallForever)
        // task: start the ball offscreen, run it til it is all the way off screen
        // set randY
        // 4. set up contacts and collisions for spike, the floor/ceiling, basketball, footballs
        // 5. add the footballs
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // check if bodyA or bodyB is a basketball
        // no guarantee on order
        if contact.bodyA.categoryBitMask == NodeCategory.basketball.rawValue || contact.bodyB.categoryBitMask == NodeCategory.basketball.rawValue {
            // REMAINING TASKS
            // task 1: remove the basketball from its parent
            if contact.bodyA.categoryBitMask == NodeCategory.basketball.rawValue {
                // we need to remove bodyA
                contact.bodyA.node?.removeFromParent()
            } else {
                // we need to remove bodyB
                contact.bodyB.node?.removeFromParent()
            }
            // task 2: add a score variable and a score label SKLabelNode
            score += 1
            // task 3: add footballs
            // task 4: when spike contacts a football, add game over logic: show the play sprite node, pause the game. when the user taps the screen again add restart game logic: remove the play sprite, reset the score, remove any extra nodes, reposition spike
            // task 5: add sound if time
        } else if contact.bodyA.categoryBitMask == NodeCategory.football.rawValue || contact.bodyB.categoryBitMask == NodeCategory.football.rawValue {
            print("contact with a football")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        spike.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
        // task: add a ceiling so spike can go through the top of the screen
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
