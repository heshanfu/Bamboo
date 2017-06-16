//
//  ConstraintChain.swift
//  Bamboo
//
//  Copyright (c) 2017 Javier Zhang (https://wordlessj.github.io/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public protocol ConstraintsContainer {
    var constraints: [NSLayoutConstraint] { get }
}

extension ConstraintsContainer {
    func merge<Container: ConstraintsContainer>(_ containers: [Container]) -> [NSLayoutConstraint] {
        return constraints + containers.flatMap { $0.constraints.dropFirst(constraints.count) }
    }
}

public protocol ConstraintChainBase: ConstraintsContainer {
    associatedtype Item: ConstraintItem
    var item: Item { get }
}

public protocol ConstraintChain: ConstraintChainBase {
    associatedtype NextChain: ConstraintChainBase
    func nextChain(_ c: NSLayoutConstraint) -> NextChain
}

extension ConstraintChain {
    func merge<Container: ConstraintsContainer>(_ containers: [Container]) -> MultipleChain<Item> {
        return MultipleChain(item: item, constraints: merge(containers))
    }
}

public struct InitialChain<Item: ConstraintItem>: ConstraintChain {
    public var item: Item
    public var constraints: [NSLayoutConstraint]

    init(item: Item) {
        self.item = item
        constraints = []
    }

    public func nextChain(_ c: NSLayoutConstraint) -> SingleChain<Item> {
        return SingleChain(item: item, constraint: c)
    }
}

public struct SingleChain<Item: ConstraintItem>: ConstraintChain {
    public var item: Item
    public var constraint: NSLayoutConstraint

    public var constraints: [NSLayoutConstraint] { return [constraint] }

    public func nextChain(_ c: NSLayoutConstraint) -> MultipleChain<Item> {
        return MultipleChain(item: item, constraints: [constraint, c])
    }
}

public struct MultipleChain<Item: ConstraintItem>: ConstraintChain {
    public var item: Item
    public var constraints: [NSLayoutConstraint]

    public func nextChain(_ c: NSLayoutConstraint) -> MultipleChain<Item> {
        return MultipleChain(item: item, constraints: constraints + [c])
    }
}
