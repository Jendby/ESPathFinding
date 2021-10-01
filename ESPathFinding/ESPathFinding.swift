//
//  ESPathFinding.swift
//  testPathF
//
//  Created by Evgeniy Smolyakov on 27.08.2021.
//

import GameplayKit

public struct GraphItem:Codable {
    public var id: Int
    public var connections: [Int]
    public var position: SIMD3<Float>
}

public class NamedGraphNode3D: GKGraphNode3D {
    public let id: Int
    
    public required init(id: Int, position: SIMD3<Float>) {
        self.id = id
        super.init(point: vector_float3(position))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ESPathFinding {
    public init() {}
    public struct Path {
        public var positions: [SIMD3<Float>]
        public var cost: Float
    }
    public func findPath(from start:NamedGraphNode3D, to finish:NamedGraphNode3D) -> Path? {
        let path = start.findPath(to: finish)
        var nodes = [SIMD3<Float>]()
        for item in path {
            if let item = item as? NamedGraphNode3D {
                nodes.append(item.position)
            }
        }
        if nodes.isEmpty {
            return nil
        }
        let cost = getCost(for: nodes)
        return Path(positions: nodes, cost: cost)
    }
    
    public func findPath(graph: [Int:NamedGraphNode3D],
                         from start:SIMD3<Float>,
                         to finish:NamedGraphNode3D,
                         maxDistanceToFind:Float = .infinity) -> Path? {
        let nearest = findNearest(graph: graph,
                                  from: start,
                                  maxDistanceToFind: maxDistanceToFind)
        guard let st = nearest.startElement,
              var mainPath = findPath(from: st, to: finish) else {
                  return nil
              }
        let addCost = distance(start, mainPath.positions[0])
        mainPath.positions.insert(start, at: 0)
        mainPath.cost += addCost
        
        return mainPath
    }
    
    public func findPath(graph: [Int:NamedGraphNode3D],
                         from start:SIMD3<Float>,
                         to finish:SIMD3<Float>,
                         maxDistanceToFind:Float = .infinity) -> Path? {
        let nearest = findNearest(graph: graph,
                                  from: start,
                                  to: finish,
                                  maxDistanceToFind: maxDistanceToFind)
        guard let st = nearest.startElement,
              let fn = nearest.finishElement,
              var mainPath = findPath(from: st, to: fn) else {
                  return nil
              }
        if st === fn {
            let positions = [start,st.position,finish]
            let cost = getCost(for: positions)
            return Path(positions: positions, cost: cost)
        } else {
            let addStartCost = distance(start, mainPath.positions[0])
            let addFinishCost = distance(finish, mainPath.positions.last!)
            mainPath.positions.insert(start, at: 0)
            mainPath.positions.append(finish)
            mainPath.cost += addStartCost + addFinishCost
            return mainPath
        }
    }
    
    private func findNearest(graph: [Int:NamedGraphNode3D],
                             from start:SIMD3<Float>,
                             to finish:SIMD3<Float>? = nil,
                             maxDistanceToFind:Float) -> (startElement:NamedGraphNode3D?, finishElement:NamedGraphNode3D?) {
        var startElement:(value:NamedGraphNode3D?, distance: Float) = (nil, .infinity)
        var finishElement:(value:NamedGraphNode3D?, distance: Float) = (nil, .infinity)
        
        for (_, value) in graph {
            let distStart = distance(start, value.position)
            if distStart < startElement.distance && distStart <= maxDistanceToFind {
                startElement = (value, distStart)
            }
            if let fn = finish {
                let distFinish = distance(fn, value.position)
                if distFinish < finishElement.distance  && distFinish <= maxDistanceToFind {
                    finishElement = (value, distFinish)
                }
            }
        }
        return (startElement.value, finishElement.value)
    }
    
    public func getCost(for path: [NamedGraphNode3D]) -> Float {
        var total: Float = 0
        if path.isEmpty { return 0 }
        for i in 0..<(path.count-1) {
            total += path[i].cost(to: path[i+1])
        }
        return total
    }
    
    public func getCost(for positions: [SIMD3<Float>]) -> Float {
        var total: Float = 0
        if positions.isEmpty { return 0 }
        for i in 0..<(positions.count-1) {
            total += distance(positions[i], positions[i+1])
        }
        return total
    }
}

public class ESPathFindingGraph {
    public var nodes = [Int:NamedGraphNode3D]()
    
    public func setupFrom(url:URL) -> Bool {
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([GraphItem].self, from: data) {
            return setupedNodes(graphItems: decoded)
        }
        return false
    }
    
    public func setupedNodes(graphItems: [GraphItem]) -> Bool {
        if graphItems.isEmpty {
            return false
        }
        nodes.removeAll()
        for item in graphItems {
            let node3d = NamedGraphNode3D(id: item.id,
                                          position: item.position)
            nodes[node3d.id] = node3d
        }
        
        for item in graphItems {
            guard let node = nodes[item.id] else { continue }
            for connect in item.connections {
                if let target = nodes[connect] {
                    node.addConnections(to: [target], bidirectional: true)
                }
            }
        }
        return true
    }
    
    public init() {}
}
