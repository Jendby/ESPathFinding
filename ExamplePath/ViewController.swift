//
//  ViewController.swift
//  ExamplePath
//
//  Created by Evgeniy Smolyakov on 01.10.2021.
//

import UIKit
import ESPathFinding

class ViewController: UIViewController {

    let pathFinder = ESPathFinding()
    let graphNode = ESPathFindingGraph()
//
    override func viewDidLoad() {
        super.viewDidLoad()
        print("asd")
        let testBundle = Bundle(for: type(of: self))
        let url = testBundle.path(forResource: "Directions", ofType: "json")!
        if graphNode.setupFrom(url: URL(fileURLWithPath: url)) {
            for (_, value) in graphNode.nodes {
                print(value.position)
            }
        } else {
            fatalError()
        }


        if let p = pathFinder.findPath(graph: graphNode.nodes,
                                       from: SIMD3<Float>(7.3,21.5,-15),
                                       to: graphNode.nodes[9]!) {
            print("--",p.positions)
        } else {
            fatalError()
        }
    }
}

