//
//  RxFeedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxSwift
import Spin_Swift

public struct RxFeedback<State, Event>: Feedback {
    public typealias StreamState = Observable<State>
    public typealias StreamEvent = Observable<Event>
    public typealias Executer = ImmediateSchedulerType

    public let feedbackStream: (StreamState) -> StreamEvent
    public var feedbackExecuter: Executer?

    public init(feedback: @escaping (StreamState) -> StreamEvent, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.feedbackStream = feedback
            return
        }

        self.feedbackStream = { stateStream in
            return feedback(stateStream.observeOn(executer))
        }
    }

    public init<FeedbackType: Feedback>(feedbacks: [FeedbackType])
        where
        FeedbackType.StreamState == StreamState,
        FeedbackType.StreamEvent == StreamEvent {
        let feedback = { (stateStream: FeedbackType.StreamState) -> FeedbackType.StreamEvent in
            let eventStreams = feedbacks.map { $0.feedbackStream(stateStream) }
            return Observable.merge(eventStreams)
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB>(feedbacks feedbackA: FeedbackA, _ feedbackB: FeedbackB)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB, FeedbackC>(feedbacks feedbackA: FeedbackA,
                                                 _ feedbackB: FeedbackB,
                                                 _ feedbackC: FeedbackC)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream),
                                    feedbackC.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(feedbacks feedbackA: FeedbackA,
                                                            _ feedbackB: FeedbackB,
                                                            _ feedbackC: FeedbackC,
                                                            _ feedbackD: FeedbackD)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamEvent == FeedbackD.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream),
                                    feedbackC.feedbackStream(stateStream),
                                    feedbackD.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE>(feedbacks feedbackA: FeedbackA,
                                                                       _ feedbackB: FeedbackB,
                                                                       _ feedbackC: FeedbackC,
                                                                       _ feedbackD: FeedbackD,
                                                                       _ feedbackE: FeedbackE)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackE: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamEvent == FeedbackD.StreamEvent,
        FeedbackD.StreamState == FeedbackE.StreamState,
        FeedbackD.StreamEvent == FeedbackE.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream),
                                    feedbackC.feedbackStream(stateStream),
                                    feedbackD.feedbackStream(stateStream),
                                    feedbackE.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public static func make(from effect: @escaping (StreamState.Value) -> StreamEvent,
                            applying strategy: ExecutionStrategy) -> (StreamState) -> StreamEvent {
        let effectStream = { (state: StreamState.Value) -> StreamEvent in
            return effect(state).catchError { _ in return .empty() }
        }

        let feedbackFromEffectStream: (StreamState) -> StreamEvent = { states in
            switch strategy {
            case .continueOnNewEvent:
                return states.flatMap(effectStream)
            case .cancelOnNewEvent:
                return states.flatMapLatest(effectStream)
            }
        }

        return feedbackFromEffectStream
    }
}
