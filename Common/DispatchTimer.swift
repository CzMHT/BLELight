//
//  DispatchTimer.swift
//  BLELight
//
//  Created by YuanGu on 2018/8/8.
//  Copyright © 2018年 YuanGu. All rights reserved.
//

import UIKit

enum ActionOption {
    case AbandonPreviousAction //废除之前的任务
    case MergePreviousAction
}

class DispatchTimer {

    static let Single = DispatchTimer()
    
    lazy var timerContainer:NSMutableDictionary = { return NSMutableDictionary() }()
    lazy var actionBlockCache: NSMutableDictionary = { return NSMutableDictionary() }()
    
    
    // MARK:- Private Method
    
    private func cacheAction(action: @escaping(()->Void) ,timerName: String) -> () {
        
        let array = actionBlockCache.object(forKey: timerName)
        
        if let actionArray:NSMutableArray = array as? NSMutableArray {
            
            actionArray.add(action)
        }else{
            
            let actionArray:NSMutableArray = [action]
            
            actionBlockCache.setValue(actionArray, forKey: timerName)
        }
    }
    
    private func removeActionCacheForTimer(timerName:String) -> () {
        
        let object = actionBlockCache.object(forKey: timerName)
        
        if object != nil {
            
            actionBlockCache.removeObject(forKey: timerName)
        }
    }
    
    
    // MARK:- Public
    
    public func cancelAllTimer(){
        
        for (key , value) in timerContainer {
            
            if let name:String = key as? String {
                
                if let timer:DispatchSourceTimer = value as? DispatchSourceTimer {
                    
                    self.timerContainer.removeObject(forKey: name)
                    
                    timer.cancel()
                }
            }
        }
    }
    
    public func cancelTimerWithName(timerName:String) {
        
        let value = self.timerContainer.object(forKey: timerName)
        
        if let timer:DispatchSourceTimer = value as? DispatchSourceTimer {
            
            timer.cancel()
            
            timerContainer.removeObject(forKey: timerName)
            actionBlockCache.removeObject(forKey: timerName)
        }
    }
    
    public func scheduledDispatchTimer(timerName:String ,Interval:Int ,repeats:Bool ,option:ActionOption ,action:@escaping ()->Void){
        
        let value = timerContainer.object(forKey: timerName)
        
        var timer:DispatchSourceTimer
        
        if value != nil{
            
            timer = (value as? DispatchSourceTimer)!
            
            timer.cancel()
        }
        
        timer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())
        timerContainer.setValue(timer, forKey: timerName)
        
        weak var weakSelf = self
        
        switch option {
        case .AbandonPreviousAction:
            
            weakSelf?.removeActionCacheForTimer(timerName: timerName)
            
            timer.setEventHandler(handler: {
                action()
            })
            
            break
        case .MergePreviousAction:
            weakSelf?.cacheAction(action: action, timerName: timerName)
            
            timer.setEventHandler(handler: {
                
                let actionArray = self.actionBlockCache.object(forKey: timerName)
                
                if let array:NSMutableArray = actionArray as? NSMutableArray{
                    
                    for object in array {
                        
                        if let actions:()->Void = object as? () -> Void{
                            
                            actions()
                        }
                    }
                }
            })
            
            weakSelf?.removeActionCacheForTimer(timerName: timerName)
            
            break
        }
        
        timer.schedule(deadline: .now(), repeating: .seconds(Interval))
        
        timer.resume()
        
        if repeats == false {
            weakSelf?.cancelTimerWithName(timerName: timerName)
        }
    }
}
