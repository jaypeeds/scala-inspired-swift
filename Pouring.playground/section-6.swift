infix operator ~~ { associativity left precedence 160 }

// Usage: initial_state ~~ move0 ~~ move1 ~~ move2
func ~~ (left: State, right: Move) -> State {
    return right.change(left)
}
initialState ~~ Move.Fill(0) ~~ Move.Pour(0, 2)
