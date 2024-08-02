//
//  GameScene.swift
//  FlipperGame
//
//  Created by Lukas Havlicek on 25.02.2022.
//

import SpriteKit
import GameplayKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  @ObservedObject var gameViewModel: GameViewModel
  
  init(gameViewModel: GameViewModel) {
    self.gameViewModel = gameViewModel
    super.init(size: CGSize.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var mainPlayingfield: SKShapeNode?
  private var rightEdgeWithArc: SKShapeNode?
  private var leftBottomEdge: SKShapeNode?
  private var rightBottomEdge: SKShapeNode?
  private var ballRedirector: SKShapeNode?
  private var ball: SKShapeNode?
  private var startPusherRectangle: SKShapeNode?
  private var endGameDetector: SKSpriteNode?
  private var leftFlipperButton: SKShapeNode?
  private var leftFlipperWing: SKShapeNode?
  private var rightFlipperButton: SKShapeNode?
  private var rightFlipperWing: SKShapeNode?
  private var startBallDetector1: SKShapeNode?
  private var startBallDetector2: SKShapeNode?
  private var leftFreeBallDetector: SKShapeNode?
  private var rightFreeBallDetector: SKShapeNode?
  private var rightPremiumPointsItem: SKShapeNode?
  private var premiumPointsDetector: SKShapeNode?
  private var threePointsDetector: SKShapeNode?
  private var fivePointsDetector: SKShapeNode?
  private var sevenPointsDetector: SKShapeNode?
  
  private let ballTexture = SKTexture(imageNamed: "ball_texture_alpha")
  private let endAngleRadians: CGFloat = 0.25 * .pi
  private let leftArcAngleRadians: CGFloat = 1.2 * .pi
  private let leftArcAngleRadians2: CGFloat = 0.8 * .pi
  private let rightArcAngleRadians: CGFloat = 1.7 * .pi
  private let edgeWidth: CGFloat = 10
  private let ballWidth: CGFloat = 25
  private let pi: CGFloat = .pi
  
  private var radius: CGFloat {
    size.width / 2
  }
  private var innerWidth: CGFloat {
    size.width - ballWidth - edgeWidth
  }
  private var innerRadius: CGFloat {
    innerWidth / 2
  }
  private var yCenterFlipperButton: CGFloat = 0
  private var alphaAngleOfWing: CGFloat {
    let rightBottomWidth = innerWidth / 2 - 15
    let hypotenuse = sqrt(pow(rightBottomWidth, 2) + pow(70, 2))
    return sin(70 / hypotenuse)
  }
  private var pauseContacts = false
  private var freeBallContactTime = Date.timeIntervalSinceReferenceDate
  private var applyImpulsFromRightWing = false
  private var applyImpulsFromLeftWing = false
  
  // MARK: - After loading
  
  override func didMove(to view: SKView) {
    
    physicsWorld.contactDelegate = self
    physicsWorld.gravity = CGVector(dx: 0, dy: -2.5)
    
    backgroundColor = .clear
    
    createMainPlayingfield()
    createRightEdgeWithArc()
    createStartPusherRectangle()
    createLeftBottomEdge()
    createRightBottomEdge()
    createBallRedirector()
    createEndGameDetector()
    createRightFlipperButton()
    createRightFlipperWing()
    createLeftFlipperButton()
    createLeftFlipperWing()
    createStartBallDetectors()
    createFreeBallDetectors()
    createRightPremiumPointsItem()
    createPremiumPointsDetector()
    createVerticalBars()
    createCentralDiamond()
    createPointsDetectors()
    
  }
  
  // MARK: - Create game items functions
  
  private func createCentralDiamond() {
    let centralDiamondPath = CGMutablePath()
    centralDiamondPath.move(to: CGPoint(x: innerWidth / 2, y: findArcCenter().y - radius * abs(sin(leftArcAngleRadians))))
    centralDiamondPath.addLine(to: CGPoint(x: innerWidth * 3/7, y: findArcCenter().y - 1.5 * radius * abs(sin(leftArcAngleRadians))))
    centralDiamondPath.addLine(to: CGPoint(x: innerWidth / 2, y: findArcCenter().y - 2 * radius * abs(sin(leftArcAngleRadians))))
    centralDiamondPath.addLine(to: CGPoint(x: innerWidth * 4/7, y: findArcCenter().y - 1.5 * radius * abs(sin(leftArcAngleRadians))))
    centralDiamondPath.closeSubpath()
    
    let centralDiamond = SKShapeNode(path: centralDiamondPath)
    centralDiamond.fillColor = gameViewModel.mainColor
    centralDiamond.strokeColor = .clear
    centralDiamond.physicsBody = SKPhysicsBody(polygonFrom: centralDiamondPath)
    centralDiamond.physicsBody?.isDynamic = false
    centralDiamond.physicsBody?.restitution = 1
    addChild(centralDiamond)
  }
  
  private func createVerticalBars() {
    
    let leftVerticalBarPath = CGMutablePath()
    leftVerticalBarPath.move(to: CGPoint(x: 35, y: yCenterFlipperButton + 30))
    leftVerticalBarPath.addLine(to: CGPoint(x: 35, y: findArcCenter().y - 1.6 * radius * abs(sin(leftArcAngleRadians))))
    leftVerticalBarPath.addLine(to: CGPoint(x: 45, y: findArcCenter().y - 1.6 * radius * abs(sin(leftArcAngleRadians))))
    leftVerticalBarPath.addLine(to: CGPoint(x: 45, y: yCenterFlipperButton + 30))
    leftVerticalBarPath.closeSubpath()
    
    let leftVerticalBar = SKShapeNode(path: leftVerticalBarPath)
    leftVerticalBar.fillColor = gameViewModel.mainColor
    leftVerticalBar.strokeColor = .clear
    leftVerticalBar.physicsBody = SKPhysicsBody(polygonFrom: leftVerticalBarPath)
    leftVerticalBar.physicsBody?.isDynamic = false
    leftVerticalBar.physicsBody?.restitution = 0.5
    addChild(leftVerticalBar)
    
    let rightVerticalBarPath = CGMutablePath()
    rightVerticalBarPath.move(to: CGPoint(x: innerWidth - 35, y: yCenterFlipperButton + 30))
    rightVerticalBarPath.addLine(to: CGPoint(x: innerWidth - 35, y: findArcCenter().y - 1.6 * radius * abs(sin(leftArcAngleRadians))))
    rightVerticalBarPath.addLine(to: CGPoint(x: innerWidth - 45, y: findArcCenter().y - 1.6 * radius * abs(sin(leftArcAngleRadians))))
    rightVerticalBarPath.addLine(to: CGPoint(x: innerWidth - 45, y: yCenterFlipperButton + 30))
    rightVerticalBarPath.closeSubpath()
    
    let rightVerticalBar = SKShapeNode(path: rightVerticalBarPath)
    rightVerticalBar.fillColor = gameViewModel.mainColor
    rightVerticalBar.strokeColor = .clear
    rightVerticalBar.physicsBody = SKPhysicsBody(polygonFrom: rightVerticalBarPath)
    rightVerticalBar.physicsBody?.isDynamic = false
    rightVerticalBar.physicsBody?.restitution = 0.5
    addChild(rightVerticalBar)
    
  }
  
  private func createLeftFlipperButton() {
    leftFlipperButton = SKShapeNode(circleOfRadius: 20)
    if let leftFlipperButton = leftFlipperButton {
      leftFlipperButton.fillColor = .red
      leftFlipperButton.strokeColor = gameViewModel.mainColor
      leftFlipperButton.lineWidth = 5
      leftFlipperButton.position = CGPoint(x: 45, y: yCenterFlipperButton)
      leftFlipperButton.physicsBody = SKPhysicsBody(circleOfRadius: 20)
      leftFlipperButton.physicsBody?.isDynamic = false
      addChild(leftFlipperButton)
    }
  }
  
  private func createLeftFlipperWing() {
    let leftFlipperWingPath = CGMutablePath()
    
    leftFlipperWingPath.addArc(center: CGPoint(x: 0, y: 0), radius: 20, startAngle: pi / 2 - alphaAngleOfWing, endAngle: pi * 3/2 - alphaAngleOfWing, clockwise: true)
    leftFlipperWingPath.addArc(center: findRightCenterOfLeftWing(), radius: 5, startAngle: pi * 3/2 - alphaAngleOfWing, endAngle: pi / 2 - alphaAngleOfWing, clockwise: false)
    
    leftFlipperWing = SKShapeNode(path: leftFlipperWingPath)
    if let leftFlipperWing = leftFlipperWing {
      leftFlipperWing.fillColor = gameViewModel.mainColor
      leftFlipperWing.strokeColor = .clear
      leftFlipperWing.name = "LeftFlipperWing"
      leftFlipperWing.zPosition = -5
      leftFlipperWing.physicsBody = SKPhysicsBody(polygonFrom: leftFlipperWingPath)
      leftFlipperWing.physicsBody?.isDynamic = false
      leftFlipperWing.physicsBody?.restitution = 0.5
      leftFlipperWing.physicsBody?.categoryBitMask = PhysicsCategory.wingCategory
      leftFlipperWing.physicsBody?.usesPreciseCollisionDetection = true
      leftFlipperButton?.addChild(leftFlipperWing)
    }
  }
  
  private func findRightCenterOfLeftWing() -> CGPoint {
    let leftBottomWidth = innerWidth / 2 - 15
    let c = leftBottomWidth - 35
    let a = c * sin(alphaAngleOfWing) + 14 / cos(alphaAngleOfWing)
    let b = sqrt(pow(c, 2) - pow(a, 2))
    return CGPoint(x: b, y: -a)
  }
  
  private func createRightFlipperButton() {
    let rightBottomWidth = innerWidth / 2 - 15
    let hypotenuse = sqrt(pow(rightBottomWidth, 2) + pow(70, 2))
    let alpha = sin(70 / hypotenuse)
    let beta = .pi / 2 - alpha
    let heightAboveHypotenuse = 45 / sin(beta)
    let lengthFromLeft = rightBottomWidth - 45
    let shorterHypotenuse = hypotenuse * lengthFromLeft / rightBottomWidth
    yCenterFlipperButton = sqrt(pow(shorterHypotenuse, 2) - pow(lengthFromLeft, 2)) + heightAboveHypotenuse + 30
    
    rightFlipperButton = SKShapeNode(circleOfRadius: 20)
    if let rightFlipperButton = rightFlipperButton {
      rightFlipperButton.fillColor = .red
      rightFlipperButton.strokeColor = gameViewModel.mainColor
      rightFlipperButton.lineWidth = 5
      rightFlipperButton.position = CGPoint(x: innerWidth - 45, y: yCenterFlipperButton)
      rightFlipperButton.physicsBody = SKPhysicsBody(circleOfRadius: 20)
      rightFlipperButton.physicsBody?.isDynamic = false
      addChild(rightFlipperButton)
    }
  }
  
  private func createRightFlipperWing() {
    let rightFlipperWingPath = CGMutablePath()
    
    rightFlipperWingPath.addArc(center: CGPoint(x: 0, y: 0), radius: 20, startAngle: pi / 2 + alphaAngleOfWing, endAngle: pi * 3/2 + alphaAngleOfWing, clockwise: false)
    rightFlipperWingPath.addArc(center: findLeftCenterOfRightWing(), radius: 5, startAngle: pi * 3/2 + alphaAngleOfWing, endAngle: pi / 2 + alphaAngleOfWing, clockwise: true)
    
    
    rightFlipperWing = SKShapeNode(path: rightFlipperWingPath)
    if let rightFlipperWing = rightFlipperWing {
      rightFlipperWing.fillColor = gameViewModel.mainColor
      rightFlipperWing.strokeColor = .clear
      rightFlipperWing.name = "RightFlipperWing"
      rightFlipperWing.zPosition = -5
      rightFlipperWing.physicsBody = SKPhysicsBody(polygonFrom: rightFlipperWingPath)
      rightFlipperWing.physicsBody?.isDynamic = false
      rightFlipperWing.physicsBody?.restitution = 0.5
      rightFlipperWing.physicsBody?.categoryBitMask = PhysicsCategory.wingCategory
      rightFlipperWing.physicsBody?.usesPreciseCollisionDetection = true
      rightFlipperButton?.addChild(rightFlipperWing)
    }
  }
  
  private func findLeftCenterOfRightWing() -> CGPoint {
    let rightBottomWidth = innerWidth / 2 - 15
    let c = rightBottomWidth - 35
    let a = c * sin(alphaAngleOfWing) + 14 / cos(alphaAngleOfWing)
    let b = sqrt(pow(c, 2) - pow(a, 2))
    return CGPoint(x: -b, y: -a)
  }
  
  private func createRightPremiumPointsItem() {
    let rightPremiumPointsItemPath = CGMutablePath()
    rightPremiumPointsItemPath.move(to: CGPoint(x: innerWidth, y: findArcCenter().y))
    rightPremiumPointsItemPath.addArc(center: findArcCenter(), radius: radius - ballWidth - edgeWidth, startAngle: 0, endAngle: rightArcAngleRadians, clockwise: true)
    rightPremiumPointsItemPath.addLine(to: findRightPremiumPoint())
    rightPremiumPointsItemPath.closeSubpath()
    
    rightPremiumPointsItem = SKShapeNode(path: rightPremiumPointsItemPath)
    if let rightPremiumPointsItem = rightPremiumPointsItem {
      rightPremiumPointsItem.fillColor = gameViewModel.mainColor
      rightPremiumPointsItem.strokeColor = .clear
      rightPremiumPointsItem.physicsBody = SKPhysicsBody(polygonFrom: rightPremiumPointsItemPath)
      rightPremiumPointsItem.physicsBody?.isDynamic = false
      rightPremiumPointsItem.physicsBody?.restitution = 1
      rightPremiumPointsItem.physicsBody?.usesPreciseCollisionDetection = true
      rightPremiumPointsItem.physicsBody?.categoryBitMask = PhysicsCategory.fieldCategory
      addChild(rightPremiumPointsItem)
    }
  }
  
  private func findRightPremiumPoint() -> CGPoint {
    let heightFromArcCenter = (radius - ballWidth - edgeWidth) * sin(rightArcAngleRadians - alphaAngleOfWing)
    return CGPoint(x: innerWidth, y: findArcCenter().y + heightFromArcCenter)
  }
  
  // MARK: - Create ball detectors
  
  private func createPointsDetectors() {
    
    threePointsDetector = SKShapeNode(circleOfRadius: 20)
    if let threePointsDetector = threePointsDetector {
      threePointsDetector.fillColor = .white
      threePointsDetector.strokeColor = gameViewModel.mainColor
      threePointsDetector.lineWidth = 2
      threePointsDetector.name = "ThreePointsDetector"
      threePointsDetector.position = CGPoint(x: findArcCenter().x + innerRadius * 1/3, y: findArcCenter().y - innerRadius * 1/3)
      threePointsDetector.physicsBody = SKPhysicsBody(circleOfRadius: 20)
      threePointsDetector.physicsBody?.isDynamic = false
      threePointsDetector.physicsBody?.restitution = 1
      threePointsDetector.physicsBody?.categoryBitMask = PhysicsCategory.wingCategory
      threePointsDetector.physicsBody?.collisionBitMask = PhysicsCategory.ballCategory
      threePointsDetector.physicsBody?.contactTestBitMask = PhysicsCategory.ballCategory
      addChild(threePointsDetector)
    }
    let textThree = SKLabelNode(attributedText: NSAttributedString(
      string: "3",
      attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .black)]
    ))
    textThree.position = CGPoint(x: 0, y: -8)
    threePointsDetector?.addChild(textThree)
    
    fivePointsDetector = SKShapeNode(circleOfRadius: 20)
    if let fivePointsDetector = fivePointsDetector {
      fivePointsDetector.fillColor = .white
      fivePointsDetector.strokeColor = gameViewModel.mainColor
      fivePointsDetector.lineWidth = 2
      fivePointsDetector.name = "FivePointsDetector"
      fivePointsDetector.position = CGPoint(x: findArcCenter().x - innerRadius * 1/3, y: findArcCenter().y)
      fivePointsDetector.physicsBody = SKPhysicsBody(circleOfRadius: 20)
      fivePointsDetector.physicsBody?.isDynamic = false
      fivePointsDetector.physicsBody?.restitution = 1
      fivePointsDetector.physicsBody?.categoryBitMask = PhysicsCategory.wingCategory
      fivePointsDetector.physicsBody?.collisionBitMask = PhysicsCategory.ballCategory
      fivePointsDetector.physicsBody?.contactTestBitMask = PhysicsCategory.ballCategory
      addChild(fivePointsDetector)
    }
    let textFive = SKLabelNode(attributedText: NSAttributedString(
      string: "5",
      attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .black)]
    ))
    textFive.position = CGPoint(x: 0, y: -8)
    fivePointsDetector?.addChild(textFive)
    
    sevenPointsDetector = SKShapeNode(circleOfRadius: 20)
    if let sevenPointsDetector = sevenPointsDetector {
      sevenPointsDetector.fillColor = .white
      sevenPointsDetector.strokeColor = gameViewModel.mainColor
      sevenPointsDetector.lineWidth = 2
      sevenPointsDetector.name = "SevenPointsDetector"
      sevenPointsDetector.position = CGPoint(x: findArcCenter().x, y: findArcCenter().y + innerRadius * 2/3)
      sevenPointsDetector.physicsBody = SKPhysicsBody(circleOfRadius: 20)
      sevenPointsDetector.physicsBody?.isDynamic = false
      sevenPointsDetector.physicsBody?.restitution = 1
      sevenPointsDetector.physicsBody?.categoryBitMask = PhysicsCategory.wingCategory
      sevenPointsDetector.physicsBody?.collisionBitMask = PhysicsCategory.ballCategory
      sevenPointsDetector.physicsBody?.contactTestBitMask = PhysicsCategory.ballCategory
      addChild(sevenPointsDetector)
    }
    let textSeven = SKLabelNode(attributedText: NSAttributedString(
      string: "7",
      attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .black)]
    ))
    textSeven.position = CGPoint(x: 0, y: -8)
    sevenPointsDetector?.addChild(textSeven)
    
  }
  
  private func createPremiumPointsDetector() {
    
    let heightFromArcCenter = (radius - ballWidth - edgeWidth) * sin(rightArcAngleRadians - alphaAngleOfWing)
    premiumPointsDetector = SKShapeNode(circleOfRadius: 15)
    if let premiumPointsDetector = premiumPointsDetector {
      premiumPointsDetector.fillColor = .white
      premiumPointsDetector.strokeColor = gameViewModel.mainColor
      premiumPointsDetector.name = "PremiumPointsDetector"
      premiumPointsDetector.position = CGPoint(x: innerWidth - 30, y: findArcCenter().y + heightFromArcCenter + 12)
      premiumPointsDetector.physicsBody = SKPhysicsBody(circleOfRadius: 12)
      premiumPointsDetector.physicsBody?.isDynamic = false
      premiumPointsDetector.physicsBody?.categoryBitMask = PhysicsCategory.startBallCategory
      premiumPointsDetector.physicsBody?.contactTestBitMask = PhysicsCategory.ballCategory
      addChild(premiumPointsDetector)
    }
    
    let textPremium = SKLabelNode(attributedText: NSAttributedString(
      string: "10",
      attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .black)]
    ))
    textPremium.position = CGPoint(x: 0, y: -7)
    premiumPointsDetector?.addChild(textPremium)
  }
  
  private func createEndGameDetector() {
    endGameDetector = SKSpriteNode(color: .clear, size: CGSize(width: 30, height: 2))
    if let endDetector = endGameDetector {
      endDetector.position = CGPoint(x: innerWidth / 2 - 15, y: 0)
      endDetector.anchorPoint = CGPoint(x: 0, y: 0)
      endDetector.name = "Endgame"
      endDetector.zPosition = -5
      endDetector.physicsBody = SKPhysicsBody(rectangleOf: endDetector.size, center: CGPoint(x: endDetector.size.width/2, y: endDetector.size.height/2))
      endDetector.physicsBody?.isDynamic = false
      endDetector.physicsBody?.categoryBitMask = PhysicsCategory.endGameCategory
      addChild(endDetector)
    }
  }
  
  private func createFreeBallDetectors() {
    leftFreeBallDetector = SKShapeNode(circleOfRadius: 5)
    if let leftFreeBallDetector = leftFreeBallDetector {
      leftFreeBallDetector.fillColor = .clear
      leftFreeBallDetector.strokeColor = .clear
      leftFreeBallDetector.name = "FreeBallDetector"
      leftFreeBallDetector.position = CGPoint(x: 20, y: findArcCenter().y - 1.6 * radius * abs(sin(leftArcAngleRadians)) - 20)
      leftFreeBallDetector.physicsBody = SKPhysicsBody(circleOfRadius: 5)
      leftFreeBallDetector.physicsBody?.isDynamic = false
      leftFreeBallDetector.physicsBody?.categoryBitMask = PhysicsCategory.startBallCategory
      leftFreeBallDetector.physicsBody?.contactTestBitMask = PhysicsCategory.ballCategory
      addChild(leftFreeBallDetector)
    }
    
    rightFreeBallDetector = SKShapeNode(circleOfRadius: 5)
    if let rightFreeBallDetector = rightFreeBallDetector {
      rightFreeBallDetector.fillColor = .clear
      rightFreeBallDetector.strokeColor = .clear
      rightFreeBallDetector.name = "FreeBallDetector"
      rightFreeBallDetector.position = CGPoint(x: innerWidth - 20, y: findArcCenter().y - 1.6 * radius * abs(sin(leftArcAngleRadians)) - 20)
      rightFreeBallDetector.physicsBody = SKPhysicsBody(circleOfRadius: 5)
      rightFreeBallDetector.physicsBody?.isDynamic = false
      rightFreeBallDetector.physicsBody?.categoryBitMask = PhysicsCategory.startBallCategory
      rightFreeBallDetector.physicsBody?.contactTestBitMask = PhysicsCategory.ballCategory
      addChild(rightFreeBallDetector)
    }
  }
  
  private func createStartBallDetectors() {
    startBallDetector1 = SKShapeNode(circleOfRadius: 5)
    if let startBallDetector1 = startBallDetector1 {
      startBallDetector1.fillColor = .clear
      startBallDetector1.strokeColor = .clear
      startBallDetector1.name = "StartBallDetector1"
      startBallDetector1.position = CGPoint(x: size.width - 12.5, y: size.height / 2 + 20)
      startBallDetector1.physicsBody = SKPhysicsBody(circleOfRadius: 5)
      startBallDetector1.physicsBody?.isDynamic = false
      startBallDetector1.physicsBody?.categoryBitMask = PhysicsCategory.startBallCategory
      startBallDetector1.physicsBody?.contactTestBitMask = PhysicsCategory.ballCategory
      addChild(startBallDetector1)
    }
    
    startBallDetector2 = SKShapeNode(circleOfRadius: 5)
    if let startBallDetector2 = startBallDetector2 {
      startBallDetector2.fillColor = .clear
      startBallDetector2.strokeColor = .clear
      startBallDetector2.name = "StartBallDetector2"
      startBallDetector2.position = CGPoint(x: size.width - 12.5, y: size.height / 2 - 20)
      startBallDetector2.physicsBody = SKPhysicsBody(circleOfRadius: 5)
      startBallDetector2.physicsBody?.isDynamic = false
      startBallDetector2.physicsBody?.categoryBitMask = PhysicsCategory.startBallCategory
      startBallDetector2.physicsBody?.contactTestBitMask = PhysicsCategory.ballCategory
      addChild(startBallDetector2)
    }
  }
  
  // MARK: - Create edge items functions
  
  private func createMainPlayingfield() {
    let mainPlayingfieldPath = CGMutablePath()
    mainPlayingfieldPath.move(to: CGPoint(x: 0, y: 0))
    mainPlayingfieldPath.addLine(to: CGPoint(x: size.width, y: 0))
    mainPlayingfieldPath.addLine(to: CGPoint(x: size.width, y: findArcCenter().y))
    mainPlayingfieldPath.addArc(center: findArcCenter(), radius: radius, startAngle: CGFloat.zero, endAngle: CGFloat(Double.pi), clockwise: false)
    mainPlayingfieldPath.closeSubpath()
    
    mainPlayingfield = SKShapeNode(path: mainPlayingfieldPath)
    if let mainPlayingfield = mainPlayingfield {
      mainPlayingfield.fillColor = .white
      mainPlayingfield.strokeColor = .clear
      mainPlayingfield.zPosition = -15
      mainPlayingfield.physicsBody = SKPhysicsBody(edgeLoopFrom: mainPlayingfieldPath)
      mainPlayingfield.physicsBody?.isDynamic = false
      mainPlayingfield.physicsBody?.usesPreciseCollisionDetection = true
      mainPlayingfield.physicsBody?.categoryBitMask = PhysicsCategory.fieldCategory
      addChild(mainPlayingfield)
    }
  }
  
  private func createBallRedirector() {
    let ballRedirectorPath = CGMutablePath()
    ballRedirectorPath.move(to: CGPoint(x: 0, y: findArcCenter().y))
    ballRedirectorPath.addArc(center: findArcCenter(), radius: radius, startAngle: pi, endAngle: leftArcAngleRadians, clockwise: false)
    ballRedirectorPath.addArc(center: CGPoint(x: findArcCenter().x, y: findArcCenter().y - 2 * radius * abs(sin(leftArcAngleRadians))), radius: radius, startAngle: leftArcAngleRadians2, endAngle: pi, clockwise: false)
    ballRedirectorPath.closeSubpath()
    
    ballRedirector = SKShapeNode(path: ballRedirectorPath)
    if let ballRedirector = ballRedirector {
      ballRedirector.fillColor = gameViewModel.mainColor
      ballRedirector.strokeColor = .clear
      ballRedirector.zPosition = -10
      ballRedirector.physicsBody = SKPhysicsBody(edgeLoopFrom: ballRedirectorPath)
      ballRedirector.physicsBody?.isDynamic = false
      ballRedirector.physicsBody?.usesPreciseCollisionDetection = true
      ballRedirector.physicsBody?.categoryBitMask = PhysicsCategory.fieldCategory
      addChild(ballRedirector)
    }
  }
  
  private func createRightEdgeWithArc() {
    let rightEdgeWithArcPath = CGMutablePath()
    rightEdgeWithArcPath.move(to: CGPoint(x: size.width - ballWidth, y: 0))
    rightEdgeWithArcPath.addLine(to: CGPoint(x: size.width - ballWidth, y: findArcCenter().y))
    rightEdgeWithArcPath.addArc(center: findArcCenter(), radius: radius - ballWidth, startAngle: 0, endAngle: endAngleRadians, clockwise: false)
    rightEdgeWithArcPath.addCurve(to: CGPoint(x: findArcCenter().x + ((radius - ballWidth - edgeWidth) * cos(endAngleRadians)), y: findArcCenter().y + ((radius - ballWidth - edgeWidth) * sin(endAngleRadians))), control1: CGPoint(x: findArcCenter().x + ((radius - ballWidth) * cos(endAngleRadians + pi * 0.01)), y: findArcCenter().y + ((radius - ballWidth) * sin(endAngleRadians + pi * 0.01))), control2: CGPoint(x: findArcCenter().x + ((radius - ballWidth - edgeWidth) * cos(endAngleRadians + pi * 0.01)), y: findArcCenter().y + ((radius - ballWidth - edgeWidth) * sin(endAngleRadians + pi * 0.01))))
    rightEdgeWithArcPath.addArc(center: findArcCenter(), radius: radius - ballWidth - edgeWidth, startAngle: endAngleRadians, endAngle: 0, clockwise: true)
    rightEdgeWithArcPath.addLine(to: CGPoint(x: size.width - edgeWidth - ballWidth, y: 0))
    rightEdgeWithArcPath.closeSubpath()
    
    rightEdgeWithArc = SKShapeNode(path: rightEdgeWithArcPath)
    if let rightEdgeWithArc = rightEdgeWithArc {
      rightEdgeWithArc.fillColor = gameViewModel.mainColor
      rightEdgeWithArc.strokeColor = .clear
      rightEdgeWithArc.zPosition = -10
      rightEdgeWithArc.physicsBody = SKPhysicsBody(edgeLoopFrom: rightEdgeWithArcPath)
      rightEdgeWithArc.physicsBody?.isDynamic = false
      rightEdgeWithArc.physicsBody?.categoryBitMask = PhysicsCategory.fieldCategory
      addChild(rightEdgeWithArc)
    }
  }
  
  private func createLeftBottomEdge() {
    let leftBottomEdgePath = CGMutablePath()
    leftBottomEdgePath.move(to: CGPoint(x: 0, y: 0))
    leftBottomEdgePath.addLine(to: CGPoint(x: innerWidth / 2 - 15, y: 0))
    leftBottomEdgePath.addLine(to: CGPoint(x: innerWidth / 2 - 15, y: 30))
    leftBottomEdgePath.addLine(to: CGPoint(x: 0, y: 100))
    leftBottomEdgePath.closeSubpath()
    
    leftBottomEdge = SKShapeNode(path: leftBottomEdgePath)
    if let leftBottomEdge = leftBottomEdge {
      leftBottomEdge.fillColor = gameViewModel.mainColor
      leftBottomEdge.strokeColor = .clear
      leftBottomEdge.zPosition = -10
      leftBottomEdge.physicsBody = SKPhysicsBody(edgeLoopFrom: leftBottomEdgePath)
      leftBottomEdge.physicsBody?.isDynamic = false
      leftBottomEdge.physicsBody?.categoryBitMask = PhysicsCategory.fieldCategory
      addChild(leftBottomEdge)
    }
  }
  
  private func createRightBottomEdge() {
    let rightBottomEdgePath = CGMutablePath()
    rightBottomEdgePath.move(to: CGPoint(x: innerWidth / 2 + 15, y: 0))
    rightBottomEdgePath.addLine(to: CGPoint(x: innerWidth / 2 + 15, y: 30))
    rightBottomEdgePath.addLine(to: CGPoint(x: innerWidth, y: 100))
    rightBottomEdgePath.addLine(to: CGPoint(x: innerWidth, y: 0))
    rightBottomEdgePath.closeSubpath()
    
    rightBottomEdge = SKShapeNode(path: rightBottomEdgePath)
    if let rightBottomEdge = rightBottomEdge {
      rightBottomEdge.fillColor = gameViewModel.mainColor
      rightBottomEdge.strokeColor = .clear
      rightBottomEdge.zPosition = -10
      rightBottomEdge.physicsBody = SKPhysicsBody(edgeLoopFrom: rightBottomEdgePath)
      rightBottomEdge.physicsBody?.isDynamic = false
      rightBottomEdge.physicsBody?.categoryBitMask = PhysicsCategory.fieldCategory
      addChild(rightBottomEdge)
    }
  }
  
  private func createStartPusherRectangle() {
    startPusherRectangle = SKShapeNode(rect: CGRect(
      x: size.width - ballWidth - edgeWidth,
      y: 0,
      width: ballWidth + edgeWidth,
      height: size.height / 10)
    )
    if let startPusherRectangle = startPusherRectangle {
      startPusherRectangle.fillColor = gameViewModel.mainColor
      startPusherRectangle.strokeColor = .clear
      startPusherRectangle.zPosition = -10
      startPusherRectangle.physicsBody = SKPhysicsBody(edgeLoopFrom: startPusherRectangle.frame)
      startPusherRectangle.physicsBody?.isDynamic = false
      startPusherRectangle.physicsBody?.categoryBitMask = PhysicsCategory.fieldCategory
      addChild(startPusherRectangle)
    }
  }
  
  private func createBall() {
    ball = SKShapeNode(circleOfRadius: 10)
    if let ball = ball {
      ball.fillColor = .white
      ball.fillTexture = ballTexture
      ball.strokeColor = .clear
      ball.name = "Ball"
      ball.alpha = 0
      ball.position = CGPoint(x: size.width - 12.5, y: size.height / 5)
      ball.physicsBody = SKPhysicsBody(circleOfRadius: 9)
      ball.physicsBody?.isDynamic = true
      ball.physicsBody?.categoryBitMask = PhysicsCategory.ballCategory
      ball.physicsBody?.collisionBitMask = (PhysicsCategory.fieldCategory | PhysicsCategory.wingCategory)
      ball.physicsBody?.contactTestBitMask = (PhysicsCategory.endGameCategory | PhysicsCategory.startBallCategory | PhysicsCategory.wingCategory)
      addChild(ball)
    }
  }
  
  // MARK: - Touches & update functions
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    if contact.bodyA.node?.name == "ThreePointsDetector" || contact.bodyB.node?.name == "ThreePointsDetector" {
      gameViewModel.points += 3
      threePointsDetector?.fillColor = .red
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.threePointsDetector?.fillColor = .white
      }
    }
    if contact.bodyA.node?.name == "FivePointsDetector" || contact.bodyB.node?.name == "FivePointsDetector" {
      gameViewModel.points += 5
      fivePointsDetector?.fillColor = .red
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.fivePointsDetector?.fillColor = .white
      }
    }
    if contact.bodyA.node?.name == "SevenPointsDetector" || contact.bodyB.node?.name == "SevenPointsDetector" {
      gameViewModel.points += 3
      sevenPointsDetector?.fillColor = .red
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.sevenPointsDetector?.fillColor = .white
      }
    }
    
    if contact.bodyA.node?.name == "PremiumPointsDetector" || contact.bodyB.node?.name == "PremiumPointsDetector" {
      gameViewModel.points += 10
      premiumPointsDetector?.fillColor = .red
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.premiumPointsDetector?.fillColor = .white
      }
    }
    
    if applyImpulsFromRightWing {
      if contact.bodyA.node?.name == "RightFlipperWing" || contact.bodyB.node?.name == "RightFlipperWing" {
        guard !pauseContacts else { return }
        if contact.collisionImpulse > 0 && contact.collisionImpulse <= 1 {
          ball?.run(SKAction.applyForce(contact.contactNormal * 30, duration: 0.2))
        }
        guard contact.collisionImpulse > 1 else { return }
        ball?.run(SKAction.applyImpulse(contact.contactNormal * 10, duration: 0.001))
        pauseContacts = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.pauseContacts = false
        }
      }
    }
    
    if applyImpulsFromLeftWing {
      if contact.bodyA.node?.name == "LeftFlipperWing" || contact.bodyB.node?.name == "LeftFlipperWing" {
        guard !pauseContacts else { return }
        if contact.collisionImpulse > 0 && contact.collisionImpulse <= 1 {
          ball?.run(SKAction.applyForce(contact.contactNormal * 30, duration: 0.2))
        }
        guard contact.collisionImpulse > 1 else { return }
        ball?.run(SKAction.applyImpulse(contact.contactNormal * 10, duration: 0.001))
        pauseContacts = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.pauseContacts = false
        }
      }
    }
    
    if contact.bodyA.node?.name == "FreeBallDetector" || contact.bodyB.node?.name == "FreeBallDetector" {
      guard freeBallContactTime + 2 < Date.timeIntervalSinceReferenceDate else { return }
      freeBallContactTime = Date.timeIntervalSinceReferenceDate
      let removeBall = SKAction.fadeOut(withDuration: 1)
      ball?.run(removeBall)
      gameViewModel.showFreeBallAlert = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.ball?.removeFromParent()
        self.createBall()
        self.ball?.alpha = 1
        self.gameViewModel.startButtonActivated = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        self.gameViewModel.showFreeBallAlert = false
      }
    }
    
    if contact.bodyA.node?.name == "Endgame" || contact.bodyB.node?.name == "Endgame" {
      let removeBall = SKAction.fadeOut(withDuration: 0.1)
      ball?.run(removeBall)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.ball?.removeFromParent()
      }
      gameViewModel.loadButtonActivated = true
      gameViewModel.writeHighestScore()
    }
    
    var ball1Detection: Double = 0
    var ball2Detection: Double = 0
    if contact.bodyA.node?.name == "StartBallDetector1" || contact.bodyB.node?.name == "StartBallDetector1" {
      ball1Detection = Date.timeIntervalSinceReferenceDate
    }
    if contact.bodyA.node?.name == "StartBallDetector2" || contact.bodyB.node?.name == "StartBallDetector2" {
      ball2Detection = Date.timeIntervalSinceReferenceDate
    }
    if ball1Detection < ball2Detection {
      gameViewModel.startButtonActivated = true
    } else if ball1Detection > ball2Detection {
      gameViewModel.startButtonActivated = false
    }
    
  }
  
  func touchDown(atPoint pos: CGPoint) {
    if checkButtonPosition(rightFlipperButton?.position, in: pos) {
      applyImpulsFromRightWing = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        self.applyImpulsFromRightWing = false
      }
      let wingRotation = SKAction.rotate(byAngle: -(pi / 2.5), duration: 0.3)
      rightFlipperWing?.run(wingRotation) {
        self.rightFlipperWing?.run(SKAction.rotate(byAngle: self.pi / 2.5, duration: 0.3))
      }
    }
    if checkButtonPosition(leftFlipperButton?.position, in: pos) {
      applyImpulsFromLeftWing = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        self.applyImpulsFromLeftWing = false
      }
      let wingRotation = SKAction.rotate(byAngle: pi / 2.5, duration: 0.3)
      leftFlipperWing?.run(wingRotation) {
        self.leftFlipperWing?.run(SKAction.rotate(byAngle: -(self.pi / 2.5), duration: 0.3))
      }
    }
  }
  
  func touchUp(atPoint pos: CGPoint) {
    if checkButtonPosition(rightFlipperButton?.position, in: pos) {
      
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches { touchDown(atPoint: touch.location(in: self)) }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches { touchUp(atPoint: touch.location(in: self)) }
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    if gameViewModel.colorChange {
      removeAllChildren()
      view?.presentScene(self)
      gameViewModel.colorChange = false
    }
    
    if gameViewModel.loadButton {
      createBall()
      ball?.run(SKAction.fadeIn(withDuration: 0.5))
      gameViewModel.loadButton = false
    }
    
    if gameViewModel.startButton {
      applyForceToBall()
      gameViewModel.startButton = false
    }
    
  }
  
  // MARK: - Other functions
  
  private func checkButtonPosition(_ buttonPosition: CGPoint?, in touch: CGPoint) -> Bool {
    guard let buttonPosition = buttonPosition else { return false }
    if touch.x > buttonPosition.x - 40 && touch.x < buttonPosition.x + 40 && touch.y > buttonPosition.y - 40 && touch.y < buttonPosition.y + 40 {
      return true
    } else {
      return false
    }
  }
  
  private func applyForceToBall() {
    let moveDown = SKAction.move(to: CGPoint(x: 0, y: -30), duration: 0.2)
    let waiting = SKAction.wait(forDuration: 0.3)
    let moveUp = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.1)
    let moveSequence = SKAction.sequence([moveDown, waiting, moveUp])
    startPusherRectangle?.run(moveSequence)
    let force = SKAction.applyImpulse(CGVector(dx: 0, dy: 20), duration: 0.05)
    let waiting2 = SKAction.wait(forDuration: 0.5)
    let moveSequence2 = SKAction.sequence([waiting2, force])
    ball?.run(moveSequence2)
  }
  
  private func findArcCenter() -> CGPoint {
    CGPoint(x: size.width / 2, y: size.height - (size.width / 2))
  }
  
}


struct PhysicsCategory {
  
  static let fieldCategory: UInt32 = 0b0001
  static let ballCategory: UInt32 = 0b0010
  static let endGameCategory: UInt32 = 0b0011
  static let wingCategory: UInt32 = 0b0100
  static let startBallCategory: UInt32 = 0b0000
  
}

/*
label = SKLabelNode(
  attributedText: NSAttributedString(
    string: "Some Text",
    attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]
  )
)
if let label = label {
  label.fontColor = .black
  label.position = CGPoint(x: 0, y: 0)
  label.horizontalAlignmentMode = .left
  label.verticalAlignmentMode = .bottom
  label.zPosition = 10
  addChild(label)
}
*/
