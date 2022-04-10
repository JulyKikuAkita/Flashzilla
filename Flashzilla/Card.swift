//
//  Card.swift
//  Flashzilla
//
//  Created by Ifang Lee on 4/2/22.
//

import Foundation

struct Card:Codable {
    let promt: String
    let answer: String

    static let example = Card(promt: "Who is the the largest shiba?", answer: "Nanachi")
}
