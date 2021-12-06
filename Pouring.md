# THE POURING PROBLEM

Given several glasses of defined capacities, the purpose of the pouring problem is to obtain a certain volume of water which does not match any of the capacities of the individual glasses. There is a tap from which any quantity of water can be filled, and a sink where glasses can be emptied. Finally, it is possible to pour from one glass into another glass. This playground is inspired by a presentation by Prof. Martin Odersky on Coursera in his “Introduction to Functional Programming in Scala”

This presentation is meant for the curious reader with little or no background at all in OS X, Objective-C or iOS. Swift will be used as a generic language like BASIC or Pascal in the past, used to approach some theorical domain of computer science. The same motivation is driving us today, since a whole domain is returning into the spotlights, unknown even from experienced developers, Functional Programming, although as old as FORTRAN, but being born again with such new representatives as Java 8+, Scala, Clojure, or Swift.

Performances of Xcode and Playground being what they are today, be prepared with patience, the beach ball will be seen often. Just keep cool, after a while the code will stop, show first results and let you browse it.

## Episode 1

To resolve this problem, we will start using several particular features of Swift

* Enums with pattern-matching and value bindings
* Protocols which are like Interfaces in other language
* User defined operators
* Map and reduce
* Usage of (n-)tuples, or more simply of pairs.
* Usage of a nested (private) function 

First let’s model the problem:
* We use arrays to describe the glasses, initially all are empty. The capacities are constants throughout the resolution, hence the “let” keyword.
* The levels of all the glasses together define a state of the resolution. A state is an array of integers.
* We can obtain the initial state by multiplying by zero the capacities to obtain an array of same size filled with zeros. A “mapping” with an anonymous function or “lambda” is used instead of an iteration or an enumeration, to inherit the size.

```swift
typealias State = [Int]

let CAPACITIES = [3, 5, 9]
let initialState = CAPACITIES.map({x in x * 0})
initialState
let glasses = 0..<CAPACITIES.count
```
The state can change when one move is applied. A move will be described with a value in an enum structure:
* Empty glass n
* Fill glass n
* Pour glass n into glass p 

Each move will change the state of the resolution into a new state. That transformation will be described as a “protoocol”, an interface that the enum must implement. For that definition, pattern matching is used, so that values can be bound to the argument of the move.

```swift
import Foundation

typealias State = [Int]

// Prof. Odersky example
let CAPACITIES = [3, 5, 9]
let TARGET = 7
// Die Hard 3: Jugs riddle
// let CAPACITIES = [3, 5]
// let TARGET = 4
print("Capacities: \( CAPACITIES )")
print("Target: \( TARGET )")
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

Move.Fill(0).change(initialState)
Move.Pour(0,2).change(Move.Fill(0).change(initialState))

```
At this point, we can already simplify our life with the definition of a custom operator ~~ the double tilde symbolising the flowing water, it also facilitates the description of moves by allowing extensions to the right

```swift
infix operator ~~: AdditionPrecedence

// Usage: initial_state ~~ move0 ~~ move1 ~~ move2
 func ~~ (left: State, right: Move) -> State {
    return right.change(state: left)
}
initialState ~~ Move.Fill(0) ~~ Move.Pour(0, 2)
```
## Episode 2

We`ve already achieved a lot, we have a kind of manual calculator that can evaluate what a sequence of moves will provide as a final state.

What if we want to automate that calculator:

* Here’s an initial state
* Here’s an array of moves

What will that array produce ?

Let’s step back a bit, this is a well-known problem:

* Instead of the ~~ operator, let’s consider the + operator
* Instead of an array of moves, let’s consider an array of integers
* Let’s use 0 as the initial state
Using addition, the numbers, and zero in the same way, the outcome of these operations is the sum of all integers. A more academic name for this is the reduction of an array of integer by the addition operator. It already exists in the standard library.

```swift
let nums = [0, 1, 2, 3, 4, 5]
nums.reduce(0, +)
```

So what about this:

```swift
let simulation = [Move.Fill(0), Move.Pour(0,2)]
simulation.reduce(initialState, ~~)
```
Now, here's a less obvious usage of the reduce operation, and although we won't use it as is, since a standard library function exists, let's detail how it could be implemented: 

How to tell if the nums array contains 2?
A classic solution is to map a predicate which will return an array of boolean:
```swift
let isThisTwo = nums.map({n in n == 2})
isThisTwo
```
To verify if the array contains at least one 'true' value, let's reduce it with the logical OR operator |, with false as the inital value

```swift
isThisTwo.reduce(false, |)
```

But more simply, we'll use the standard library:

```swift
contains(nums, 2)
```


## Episode 3

Wow, we've accomplished a lot already. We know how to evaluate if a sequence of moves will provide a state that may or not contain the target level of water  of this problem. 

```swift
let TARGET = 7
let isSolution = contains(simulation.reduce(initialState, ~~), TARGET)
```
OK. Let's shift gears, and let the computer generate the simulation and evaluate it by itself. This is what is called Artificial Intelligence!

Are there that many choices?
* How many Empty(n) are there, with n chosen in set _glasses_ ? 3: Empty(0), Empty(1), Empty(2).
* How many Fill(n) are there, with n chosen in set _glasses_ ? 3: Fill(0), Fill(1), Fill(2).
* How many Pour(n,p) are there, with n and p chosen in set _glasses_ ? Up to 3x3, but Pour(0,0), Pour(1,1) and Pour(2,2) are not valid, all the n = p are invalid, so only 6 of them are valid.

With our setup there are only 3 + 3 + 6 = 12 different choices for a move.
Given our initial state, will all empty glasses, only 3 first moves are relevant, any of the Fill(n). Let _Move_ provide these _values_.

Let's also shift gears about our model of the problem, let's call the sequence of moves 'Path'

```swift
protocol Enumerable {
    class var values:[Move] {get}
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
            for h in filter(glasses, {x in x != g}) {
                moves.append(Move.Pour(g,h))
            }
        }
        return moves
    }
}
Move.values
```
It's time to get a prettier display of Move values
```swift

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

Move.values.map({m in m.asText()})
```
## Episode 4 and End

To resolve the problem, we will start from 3 possible initial moves:
* Fill(0)
* Fill(1)
* Fill(2)

For each of these iniital moves, we will add another move, and build arrays of Move we will define as Paths

The number of Paths grows as more steps are added since several choices are available for each new step.

Then we will partition out solutions from the rest of Paths, the latter will get extended each with a new Move, and the same evaluation is performed again.

As we need to compare moves to avoid repetition it needs to implement the equatable protocol.

Finally, we decide to stop after the first batch of solutions.

```swift
typealias Path = [Move]

func partition<T>(ar: [T], predicate: @escaping (T)->Bool) -> ([T],[T]) {
    func antiPredicate(value: T) -> Bool {
        return !(predicate(value))
    }
    return(ar.filter(predicate), ar.filter(antiPredicate))
}
```
Example of usage of _partition_ with _nums_
```swift
let (a,b) = partition(nums, {n in n > 2})
a
b
```
More operators to compare two instances of _Move_
```swift
extension Move: Equatable {
}
func == (left: Move, right: Move) -> Bool {
    return left.asText() == right.asText()
}

func != (left: Move, right: Move) -> Bool {
    return !(right == left)
}
```
How the solution is researched: By extending the collections of _Move_ ie the _Path_ 
```swift
func extend(from: [Path]) -> [Path] {
    var result = [Path]()
    for fromPath in from {
        let lastMove = fromPath.last
        if lastMove == nil {
	    for g in glasses {
		result.append([Move.Fill(g)])
	    }
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
```
Finally, how to resolve this problem:
- Staring from the initial state, generate and evaluate all the possible next move.
- Separate the results, those that contain the target values, and those that don't.
```swift
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

```
 
## Closing note

Look at how many (mutable) variables were needed. In all cases, they are local values, being iteratively built.

The function isSolution will run 8786 times before the first results are available. It'll take a long, long time. To see them, make sure your View setup will show the Assistant Editor in the right panel.

You'll get much faster results by running the standalone code in a Terminal with the following command line:

```shell
$ xcrun swift pouring.swift
```
