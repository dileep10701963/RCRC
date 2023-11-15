//
//  Observable.swift
//  RCRC
//
//  Created by Errol on 14/07/20.
//

import Foundation

class Observable<T, U> {

    var value: T {
        didSet { listener?(value, error) }
    }

    var error: U {
        didSet { listener?(value, error)}
    }

    private var listener: ((T, U) -> Void)?

    init(_ value: T, _ error: U) {
        self.value = value
        self.error = error
    }

    func bind(_ closure: @escaping (T, U) -> Void) {
        closure(value, error)
        listener = closure
    }
}

class ValueObservable<T> {

    var value: T {
        didSet { listener?(value) }
    }

    private var listener: ((T) -> Void)?

    init(_ value: T) {
        self.value = value
    }

    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
}

class TextFieldObservable<T, U> {

    var message: T {
        didSet { listener?(message, fieldType) }
    }

    var fieldType: U {
        didSet { listener?(message, fieldType)}
    }

    private var listener: ((T, U) -> Void)?

    init(_ message: T, _ fieldType: U) {
        self.message = message
        self.fieldType = fieldType
    }

    func bind(_ closure: @escaping (T, U) -> Void) {
        closure(message, fieldType)
        listener = closure
    }
}
