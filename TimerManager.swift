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

class TimerManager:NSObject {
    
    private var counter = PassthroughSubject<Int , Error>()
    private var subscriber:AnyCancellable!
    private var storage:Int = 0
    private weak var timer:Timer?
    var delegate:TimerDelegate?
    private var isEnded:Bool {
        time < 0
    }
    private var time:Int! {
        didSet{
            if isEnded {
                stop()
            }else{
                counter.send(time)
            }
        }
    }
    

    func start(seconds:Int) {
        initSubscriber()
        setupTimer()
        initTime(time: seconds)
    }
    
    func stop(){
        delegate?.finished()
        timer?.invalidate()
        timer = nil
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
        subscriber = counter.sink { completion in
            switch completion {
            case .finished:
                print("finished")
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        } receiveValue: { second in
            self.delegate?.runing(time: second)
        }
    }
    
    
    
    @objc private func timerAction(){
        if !isEnded{
            time -= 1
        }
    }
    
    deinit{
        counter.send(completion: .finished)
        stop()
    }
    
}



