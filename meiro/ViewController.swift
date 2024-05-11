//
//  ViewController.swift
//  meiro
//
//  Created by まつはる on 2024/05/11.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    private var playerView: UIView!
    private var playerMotionManager = CMMotionManager()
    private var speedX: Double = 0.0
    private var speedY: Double = 0.0
    private let screenSize = UIScreen.main.bounds.size
    private var wallRects: [CGRect] = []
    
    private let maze = [
        [1,0,0,0,1,0],
        [1,0,1,0,1,0],
        [3,0,1,0,1,0],
        [1,1,1,0,0,0],
        [1,0,0,1,1,0],
        [0,0,1,0,0,0],
        [0,1,1,0,1,0],
        [0,0,0,0,1,1],
        [0,1,1,0,0,0],
        [0,0,1,1,1,2],
    ]
    private var startView: UIView!
    private var goalView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMaze()
        setupPlayer()
        setupMotionManager()
    }
    
    private func setupMaze() {
        let cellWidth = screenSize.width / CGFloat(maze[0].count)
        let cellHeight = screenSize.height / CGFloat(maze.count)
        let cellOffsetX = cellWidth / 2
        let cellOffsetY = cellHeight / 2
        
        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
        
        for y in 0..<maze.count {
            for x in 0..<maze[y].count {
                let cellView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                switch maze[y][x] {
                case 1:
                    cellView.backgroundColor = .black
                    wallRects.append(cellView.frame)
                    let wallImageView = UIImageView(image: UIImage(named: "iphone"))
                    wallImageView.frame = cellView.bounds
                    cellView.addSubview(wallImageView)
                case 2:
                    startView = cellView
                    startView.backgroundColor = .green
                case 3:
                    goalView = cellView
                    goalView.backgroundColor = .red
                default:
                    continue
                }
                view.addSubview(cellView)
            }
        }
    }
    
    private func setupPlayer() {
        let cellWidth = screenSize.width / CGFloat(maze[0].count)
        let cellHeight = screenSize.height / CGFloat(maze.count)
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth / 6, height: cellHeight / 6))
        playerView.center = startView.center
        playerView.backgroundColor = .gray
        view.addSubview(playerView)
    }
    
    private func setupMotionManager() {
        playerMotionManager.accelerometerUpdateInterval = 0.02
        startAccelerometer()
    }
    
    private func createView(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> UIView {
        let rect = CGRect(x: offsetX + CGFloat(x) * width - width / 2, y: offsetY + CGFloat(y) * height - height / 2, width: width, height: height)
        return UIView(frame: rect)
    }
    
    private func startAccelerometer() {
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
            guard let self = self, let acceleration = data?.acceleration else { return }
            self.updatePlayerPosition(with: acceleration)
        }
    }
    
    private func updatePlayerPosition(with acceleration: CMAcceleration) {
        speedX += acceleration.x
        speedY += acceleration.y
        
        var newX = playerView.center.x + CGFloat(speedX) / 3
        var newY = playerView.center.y + CGFloat(speedY) / 3
        adjustPlayerPosition(&newX, &newY)
        checkCollision(at: CGPoint(x: newX, y: newY))
    }
    
    private func adjustPlayerPosition(_ newX: inout CGFloat, _ newY: inout CGFloat) {
        let halfWidth = playerView.frame.width / 2
        let halfHeight = playerView.frame.height / 2
        newX = max(halfWidth, min(screenSize.width - halfWidth, newX))
        newY = max(halfHeight, min(screenSize.height - halfHeight, newY))
        playerView.center = CGPoint(x: newX, y: newY)
    }
    
    private func checkCollision(at point: CGPoint) {
        if wallRects.contains(where: {$0.contains(playerView.frame)}) {
            presentGameAlert(result: "GAME OVER", message: "Crashed into a wall!")
        } else if goalView.frame.intersects(playerView.frame) {
            presentGameAlert(result: "CLEAR", message: "You win!")
        }
    }
    
    private func presentGameAlert(result: String, message: String) {
        if playerMotionManager.isAccelerometerActive {
            playerMotionManager.stopAccelerometerUpdates()
        }
        let alert = UIAlertController(title: result, message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.retryGame()
        }
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func retryGame() {
        playerView.center = startView.center
        speedX = 0.0
        speedY = 0.0
        if !playerMotionManager.isAccelerometerActive {
            startAccelerometer()
        }
    }
}


//import UIKit
//import CoreMotion
//
//class ViewController: UIViewController {
//    
//    var playerView: UIView!
//    var playerMotionManager: CMMotionManager!
//    var speedX: Double = 0.0
//    var speedY: Double = 0.0
//    
//    let screenSize = UIScreen.main.bounds.size
//    
//    let maze = [
//        [1,0,0,0,1,0],
//        [1,0,1,0,1,0],
//        [3,0,1,0,1,0],
//        [1,1,1,0,0,0],
//        [1,0,0,1,1,0],
//        [0,0,1,0,0,0],
//        [0,1,1,0,1,0],
//        [0,0,0,0,1,1],
//        [0,1,1,0,0,0],
//        [0,0,1,1,1,2],
//    ]
//    var startView: UIView!
//    var goalView: UIView!
//    
//    func createView(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> UIView {
//        let rect = CGRect(x: 0, y: 0, width: width, height: height)
//        let view = UIView(frame: rect)
//        
//        let center = CGPoint(x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
//        
//        view.center = center
//        
//        return view
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let cellWidth = screenSize.width / CGFloat(maze[0].count)
//        let cellHeight = screenSize.height / CGFloat(maze.count)
//        
//        let cellOffsetX = cellWidth / 2
//        let cellOffsetY = cellHeight / 2
//        
//        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
//        
//        for y in 0 ..< maze.count {
//            for x in 0 ..< maze[y].count {
//                switch maze[y][x] {
//                case 1:
//                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
//                    wallView.backgroundColor = UIColor.black
//                    view.addSubview(wallView)
//                case 2:
//                    startView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
//                    startView.backgroundColor = UIColor.green
//                    view.addSubview(startView)
//                case 3:
//                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
//                    goalView.backgroundColor = UIColor.red
//                    view.addSubview(goalView)
//                default:
//                    break
//                }
//            }
//        }
//        
//        // プレイヤーの初期位置を設定
//        playerView = UIView(frame:CGRect(x: 0, y: 0, width: cellWidth / 6, height: cellHeight / 6))
//        playerView.center = startView.center
//        playerView.backgroundColor = UIColor.gray
//        view.addSubview(playerView)
//        
//        // モーションマネージャのセットアップ
//        playerMotionManager = CMMotionManager()
//        playerMotionManager.accelerometerUpdateInterval = 0.02
//        startAccelerometer()
//    }
//    
//    // 加速度センサーの開始
//    func startAccelerometer() {
//        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main) { (CMAccelerometerData, error) in
//            guard let acceleration = CMAccelerometerData?.acceleration else { return }
//            self.speedX += acceleration.x
//            self.speedY += acceleration.y
//            
//            var posX = self.playerView.center.x + (CGFloat(self.speedX) / 3)
//            var posY = self.playerView.center.y + (CGFloat(self.speedY) / 3)
//            
//            // 画面外に出ないように制限する
//            if posX <= self.playerView.frame.width / 2 {
//                self.speedX = 0
//                posX = self.playerView.frame.width / 2
//            }
//            if posY <= self.playerView.frame.height / 2 {
//                self.speedY = 0
//                posY = self.playerView.frame.height / 2
//            }
//            if posX >= self.screenSize.width - (self.playerView.frame.width / 2) {
//                self.speedX = 0
//                posX = self.screenSize.width - (self.playerView.frame.width / 2)
//            }
//            if posY >=  self.screenSize.height - (self.playerView.frame.height / 2) {
//                self.speedY = 0
//                posY = self.screenSize.height - (self.playerView.frame.height / 2)
//            }
//            
//            
//            for wallRect in self.wallRectArray {
//                if wallRect.intersects(self.playerView.frame) {
//                    self.gameCheck(result: "GAMR OVER", message: "CRASH INTO A WALL")
//                    return
//                }
//            }
//            
//            if self.goalView.frame.intersects(self.playerView.frame) {
//                self.gameCheck(result: "CLEAR", message: "YOU WIN!")
//                return
//            }
//            
//            
//            func gameCheck(result: String, message: String) {
//                
//                if playerMotionManager.isAccelerometerActive{
//                    playerMotionManager.stopAccelerometerUpdates()
//                }
//                
//                let gameCheckAlert: UIAlertController = UIAlertController(title: result, message: message, preferredStyle: .alert)
//                
//                let retryAction = UIAlertAction(title: "RETRY", style: .default, handler: {(action: UIAlertAction!)
//                    -> Void in
//                    self.retry()
//            })
//                
//                gameCheckAlert.addAction(retryAction)
//                
//                self.present(gameCheckAlert, animated: true, completion: nil)
//            }
//            
//            func retry() {
//                playerView.center = startView.center
//                if !playerMotionManager.isAccelerometerActive{
//                    startAccelerometer()
//                }
//                
//                speedX = 0.0
//                speedY = 0.0
//            }
//            
//            self.playerView.center = CGPoint(x: posX, y: posY)
//        }
//    }
//}


//import UIKit
//import CoreMotion
//
//class ViewController: UIViewController {
//     
//    var playerView: UIView!
//    var playerMotionManager: CMMotionManager!
//    var speedX: Double = 0.0
//    var speedY: Double = 0.0
//    
//    let screenSize = UIScreen.main.bounds.size
//    
//    let maze = [
//        [1,0,0,0,1,0],
//        [1,0,1,0,1,0],
//        [3,0,1,0,1,0],
//        [1,1,1,0,0,0],
//        [1,0,0,1,1,0],
//        [0,0,1,0,0,0],
//        [0,1,1,0,1,0],
//        [0,0,0,0,1,1],
//        [0,1,1,0,0,0],
//        [0,0,1,1,1,2],
//    ]
//    var startView: UIView!
//    var goalView: UIView!
//    
//    func createView(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> UIView {
//        let rect = CGRect(x: 0, y: 0, width: width, height: height)
//        let view = UIView(frame: rect)
//        
//        let center = CGPoint(x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
//        
//        view.center = center
//        
//        return view
//    }
//    
//    var wallRectArray = [CGFont]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let cellWidth = screenSize.width / CGFloat(maze[0].count)
//        let cellHeight = screenSize.height / CGFloat(maze.count)
//        
//        let cellOffsetX = cellWidth / 2
//        let cellOffsetY = cellHeight / 2
//        
//        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
//        
//        for y in 0 ..< maze.count {
//            for x in 0 ..< maze[y].count {
//                switch maze[y][x] {
//                case 1:
//                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
//                    wallView.backgroundColor = UIColor.black
//                    view.addSubview(wallView)
//                case 2:
//                    startView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
//                    startView.backgroundColor = UIColor.green
//                    view.addSubview(startView)
//                case 3:
//                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
//                    goalView.backgroundColor = UIColor.red
//                    view.addSubview(goalView)
//                default:
//                    break
//                }
//            }
//        }
//        playerView = UIView(frame:CGRect(x: 0, y: 0, width: cellWidth / 6, height: cellHeight / 6))
//        playerView.center = startView.center
//        playerView.backgroundColor = UIColor.gray
//        view.addSubview(playerView)
//        
//        playerMotionManager = CMMotionManager()
//        playerMotionManager.accelerometerUpdateInterval = 0.02
//        
//        startAccelerometer()
//        
//        func startAccelerometer() {
//            
//            let handler: CMAccelerometerHandler = { (CMAccelerometerData: CMAccelerometerData?, error: Error?)}
//            -> Void; in
//            self.speedX += CMAccelerometerData!.CMAcceleration.x
//            self.speedY += CMAccelerometerData!.CMAcceleration.y
//            
//            
//            var posX = self.playerView.center.x + (CGFloat(self.speedX) / 3)
//            var posY = self.playerView.center.y + (CGFloat(self.speedY) / 3)
//            
//            if posX <= self.playerView.frame.width / 2 {
//                self.speedX = 0
//                posX = self.playerView.frame.width / 2
//            }
//            if posY <= self.playerView.frame.height / 2 {
//                self.speedY = 0
//                posY = self.playerView.frame.height / 2
//            }
//            if posX >= self.screenSize.width - (self.playerView.frame.width / 2) {
//                self.speedX = 0
//                posX = self.screenSize.width - (self.playerView.frame.width / 2)
//            }
//            if posY >=  self.screenSize.height - (self.playerView.frame.height / 2) {
//                self.speedY = 0
//                posY = self.screenSize.height - (self.playerView.frame.height / 2)
//            }
//            
//            
//            self.playerView.center = CGPoint(x: posX, y: posY)
//            
//        }
//        
//        
//        
//        
//        
//    }
//}
//
//




//import UIKit
//
//class ViewController: UIViewController {
//    
//    let screenSize = UIScreen.main.bounds.size
//    
//    let maze = [
//        [1,0,0,0,1,0],
//        [1,0,1,0,1,0],
//        [3,0,1,0,1,0],
//        [1,1,1,0,0,0],
//        [1,0,0,1,1,0],
//        [0,0,1,0,0,0],
//        [0,1,1,0,1,0],
//        [0,0,0,0,1,1],
//        [0,1,1,0,0,0],
//        [0,0,1,1,1,2],
//    ]
//    var startView: UIView!
//    var goalView: UIView!
//    
//    func createView(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) ->
//    UIView {
//        let rect = CGRect(x: 0, y: 0, width: width, height: height)
//        let view = UIView(frame: rect)
//        
//        let center = CGPoint(x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
//        
//        view.center = center
//        
//        return view
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        
//        let cellWidth = screenSize.width / CGFloat(maze[0].count)
//        let cellHeight = screenSize.height / CGFloat(maze[0].count)
//        
//        let cellOffsetX = cellWidth / 2
//        let cellOfsetY = cellHeight / 2
//        
//        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
//        
//        for y in 0 ..< maze.count {
//            for x in 0 ..< maze[y].count {
//                switch maze[y][x] {
//                    
//                case 1:
//                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOfsetY)
//                    wallView.backgroundColor = UIColor.black // 例えば壁は黒色とする
//                    view.addSubview(wallView) // 壁のビューをビュー階層に追加する
//
//
////                case 1:
////                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOfsetY)
////                    
////                    let wallImageView = UIImageView(image: UIImage (named: "wall"))
////                    wallImageView.frame = wallView.frame
////                    view.addSubview(wallImageView)
////                 
//                    
//                case 2:
//                    startView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOfsetY)
//                    startView.backgroundColor = UIColor.yellow
//                    view.addSubview(startView) // startView をビュー階層に追加する
//
//                    
//                case 3:
//                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOfsetY)
//                    goalView.backgroundColor = UIColor.red
//                    view.addSubview(goalView) // goalView をビュー階層に追加する
//
//                    
////                case 2:
////                    startView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOfsetY)
////                    startView.backgroundColor = UIColor.green
////                    view.addSubview(startView)
////                    
////                case 3:
////                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOfsetY)
////                    goalView.backgroundColor = UIColor.red
////                    view.addSubview(goalView)
//                default:
//                    break
//                }
//            }
//            
//            
//            
//        }
//        
//        
//    }
//}
