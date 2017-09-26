import Foundation

typealias State = [Int]

let CAPACITIES = [3, 5, 9]
print("Capacities: \( CAPACITIES )")
let initialState = CAPACITIES.map({x in x * 0})
print("Initial state: \( initialState)")
let glasses = 0..<CAPACITIES.count

protocol StateChanger {
    func change(state: State) -> State
}

enum Move: StateChanger {
    
    case Empty(Int)
    case Fill(Int)
    case Pour(Int, Int)
    
    func change(state: State) -> State {
        var changed = state
        switch self {
        case .Empty(let glass):
            changed[glass] = 0
            return changed
        case .Fill(let glass):
            changed[glass] = CAPACITIES[glass]
            return changed
        case let .Pour(from, to):
            let availQty = state[from]
            let availCap = CAPACITIES[to] - state[to]
            if availQty >= availCap {
                changed[from] = availQty - availCap
                changed[to] = CAPACITIES[to]
            } else {
                changed[from] = 0
                changed[to] += availQty
            }
            return changed
        }
    }
}
// print(Move.Pour(0,2).change(state: Move.Fill(0).change(state: initialState)))

infix operator ~~

// Usage: initial_state ~~ move0 ~~ move1 ~~ move2
 func ~~ (left: State, right: Move) -> State {
    return right.change(state: left)
}
// print(initialState ~~ Move.Fill(0) ~~ Move.Pour(0, 2))

let TARGET = 7

protocol Enumerable {
    static var values:[Move] {get}
}
extension Move: Enumerable {
    static var values:[Move] {
        var moves = [Move]()
        for g in glasses {
            moves.append(Move.Empty(g))
        }
        for g in glasses {
            moves.append(Move.Fill(g))
        }
        for g in glasses {
            for h in glasses.filter({x in x != g}) {
                moves.append(Move.Pour(g,h))
            }
        }
        return moves
    }
}
// print(Move.values)

protocol TextRepresentable {
    func asText() -> String
}
extension Move: TextRepresentable {
    func asText() -> String {
        switch self {
        case .Empty(let glass): return "Empty(\(glass))"
        case .Fill(let glass): return "Fill(\(glass))"
        case let .Pour(from, to): return "Pour(\(from), \(to))"
        }
    }
}
// print (Move.values.map({m in m.asText()}))

typealias Path = [Move]

func partition<T>(ar: [T], predicate: @escaping (T)->Bool) -> ([T],[T]) {
    func antiPredicate(value: T) -> Bool {
        return !(predicate(value))
    }
    return(ar.filter(predicate), ar.filter(antiPredicate))
}

extension Move: Equatable {
}
func == (left: Move, right: Move) -> Bool {
    return left.asText() == right.asText()
}

func != (left: Move, right: Move) -> Bool {
    return !(right == left)
}

func extend(from: [Path]) -> [Path] {
    var result = [Path]()
    for fromPath in from {
        let lastMove = fromPath.last
        if lastMove == nil {
            result = [[Move.Fill(0)], [Move.Fill(1)], [Move.Fill(2)]]
        } else {
            for move in Move.values.filter( {x in x != lastMove!}) {
                var path = fromPath
                path.append(move)
                result.append(path)
            }
        }
    }
    return result
}

func resolve(paths: [Path], target: Int) {
    func isSolution(path: Path) -> Bool {
        return path.reduce(initialState, ~~).contains(target)
    }
    let (solutions, others) = partition(ar: paths, predicate: isSolution)
    if (solutions.count > 0) {
        let _ = solutions.map({s in print("Solution: \(s.map({m in m.asText()})) -> \(s.reduce(initialState, ~~))")})
    } else {
        resolve(paths: extend(from: others), target: target)
    }
}

resolve(paths: [[]], target: TARGET)


