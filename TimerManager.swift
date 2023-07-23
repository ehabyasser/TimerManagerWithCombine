//
//  TimerManager.swift
//  ToolTip
//
//  Created by Ihab yasser on 12/07/2023.
//

import Foundation
import Combine



protocol TimerDelegate {
    func runing(time:Int)
    func finished()
}

class TimerManager:ObservableObject {
    
    private var subscriber:Set<AnyCancellable> = Set<AnyCancellable>()
    private var storage:Int = 0
    private weak var timer:Timer?
    var delegate:TimerDelegate?
    private var isEnded:Bool {
        time == 0
    }
    @Published private var time:Int! {
        didSet{
            if isEnded {
                stop()
            }
        }
    }

    func start(with:Int) {
        initSubscriber()
        setupTimer()
        initTime(time: with)
    }
    
    func stop(){
        timer?.invalidate()
        timer = nil
        self.delegate?.finished()
    }
    
    func restart(){
        start(with: storage)
    }
    
    
    private func setupTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    
    private func initTime(time:Int){
        self.time = time
        self.storage = time
    }
    
    
    private func initSubscriber(){
        $time
            .sink (receiveValue: { second in
                self.delegate?.runing(time: second ?? 0)
            }).store(in: &subscriber)
    }
    
    
    
    @objc private func timerAction(){
        if !isEnded{
            time -= 1
        }
    }
    
}



