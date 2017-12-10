//
//  ViewController.swift
//  AR Drawing
//
//  Created by Hyeongjin Um on 9/23/17.
//  Copyright © 2017 Hyeongjin Um. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let drawButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
        
        drawButton.translatesAutoresizingMaskIntoConstraints = false
        drawButton.backgroundColor = UIColor.white
        drawButton.layer.cornerRadius = 30
        drawButton.clipsToBounds = true
        drawButton.setTitle("Draw", for: .normal)
        drawButton.setTitleColor(UIColor.blue, for: .normal)
        sceneView.addSubview(drawButton)
        
        drawButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        drawButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        drawButton.centerYAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -50).isActive = true
        drawButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor).isActive = true
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }


    //delegate
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        //orientation is reversed. so make it negative
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPositionOfCamera = orientation + location
        
        
        DispatchQueue.main.async {
            // if drawbutton is tapped( hightlighted ) - button is pressed.
            //cool!
            if self.drawButton.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = currentPositionOfCamera
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
            } else {
                // give pointer to better UX
                //box also look like sphere!
//                let pointer = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01/2))
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                pointer.position = currentPositionOfCamera
                
                
                // delete every single other point before we add a new pointer to the scene
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    
                    //we need distinguish pointers
//                    if node.geometry is SCNBox {
//                        node.removeFromParentNode()
//                    }
                    
                    //better way to distuingues -> give pointer a name
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                })
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                
            }
        }
        
       
    }
    
//    var isTouched = false
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isTouched = true
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isTouched = false
//    }

}



func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
