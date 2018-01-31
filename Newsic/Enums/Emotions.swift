//
//  EmotionDyad.swift
//  Nusic
//
//  Created by Miguel Alcantara on 03/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

enum EmotionDyad: String {
    case optimism = "Optimism"
    case hope = "Hope"
    case anxiety = "Anxiety"
    case love = "Love"
    case guilt = "Guilt"
    case delight = "Delight"
    case submission = "Submission"
    case curiosity = "Curiosity"
    case sentimentality = "Sentimentality"
    case awe = "Awe"
    case despair = "Despair"
    case shame = "Shame"
    case disapproval = "Disapproval"
    case unbelief = "Unbelief"
    case outrage = "Outrage"
    case remorse = "Remorse"
    case envy = "Envy"
    case pessimism = "Pessimism"
    case contempt = "Contempt"
    case cynicism = "Cynicism"
    case morbidness = "Morbidness"
    case aggressiveness = "Aggressiveness"
    case pride = "Pride"
    case dominance = "Dominance"
    case unknown = "unknown_emotion"
    case none = ""
    
    static let allValues = [love, delight, pride, optimism, hope, curiosity, awe, sentimentality, anxiety, guilt, submission, disapproval, unbelief, shame, contempt, cynicism, remorse, envy, pessimism, despair, outrage, aggressiveness, dominance];
    
    static let allValuesDict = [EmotionCategory.positive:
        [EmotionDyad.awe,EmotionDyad.curiosity,EmotionDyad.delight,EmotionDyad.hope,EmotionDyad.love,EmotionDyad.optimism,EmotionDyad.pride],
                                EmotionCategory.neutral:
        [EmotionDyad.anxiety,EmotionDyad.envy,EmotionDyad.guilt,EmotionDyad.outrage,EmotionDyad.sentimentality,EmotionDyad.unbelief],
                                EmotionCategory.negative:
        [EmotionDyad.aggressiveness,EmotionDyad.contempt,EmotionDyad.cynicism,EmotionDyad.despair,EmotionDyad.disapproval,EmotionDyad.dominance,EmotionDyad.pessimism,EmotionDyad.remorse,EmotionDyad.shame,EmotionDyad.submission]]
}

enum EmotionCategory: String {
    case positive = "Positive"
    case neutral = "Neutral"
    case negative = "Negative"
}
