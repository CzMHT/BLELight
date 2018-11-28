//
//  Common.swift
//  BLELight
//
//  Created by YuanGu on 2018/8/8.
//  Copyright © 2018年 YuanGu. All rights reserved.
//

import UIKit

let Screen_Height = UIScreen.main.bounds.size.height
let Screen_Width  = UIScreen.main.bounds.size.width

// 判断 iPhone5
let iPhone5 = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? CGSize(width: 960, height: 1336).equalTo((UIScreen.main.currentMode?.size)!) : false
// 判断 iPhone6
let iPhone6 = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? CGSize(width: 750, height: 1334).equalTo((UIScreen.main.currentMode?.size)!) : false
// 判断 iPhone6p
let iPhone6p = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? CGSize(width: 1242, height: 2208).equalTo((UIScreen.main.currentMode?.size)!) : false
// 判断 iPhone6p 大屏幕
let iPhone6pBigMode = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? CGSize(width: 1125, height: 2001).equalTo((UIScreen.main.currentMode?.size)!) : false
// 判断iPhoneX
let iPhoneX = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? CGSize(width: 1125, height: 2436).equalTo((UIScreen.main.currentMode?.size)!) : false
//适配参数
let suitParm: CGFloat = (iPhone6p ? 1.12 : (iPhone6 ? 1.0 : (iPhone6pBigMode ? 1.01 : (iPhoneX ? 1.0 : 0.85))))

// 状态栏高度
let STATUS_BAR_HEIGHT: CGFloat = (iPhoneX ? 44.0 : 20.0)
// 导航栏高度
let NAVIGATION_BAR_HEIGHT: CGFloat = (iPhoneX ? 88.0 : 64.0)
// tabBar高度
let TAB_BAR_HEIGHT: CGFloat = (iPhoneX ? (49.0+34.0) : 49.0)
// home indicator
let HOME_INDICATOR_HEIGHT: CGFloat = (iPhoneX ? 34.0 : 0.0)


func isIphoneX() -> Bool {
    guard UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone else {
        return false
    }
    if #available(iOS 11.0 ,* ) {
        if ((UIApplication.shared.delegate?.window)!)!.safeAreaInsets.bottom > 0.0 {
            return true
        }
    }
    return false
}

func Log<T>(_ message : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    
    #if DEBUG
    
    let fileName = (file as NSString).lastPathComponent
    
    print("\(fileName)-(\(lineNum)) : \(message)")
    
    #endif
}

// MARK:- 自定义打印
func TimeLog<T>(_ message : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    
    #if DEBUG
    
    let timeFormatter = DateFormatter()
    
    timeFormatter.dateFormat = "HH:mm:ss.SSS"
    
    let strNowTime = timeFormatter.string(from: NSDate() as Date) as String
    
    let fileName = (file as NSString).lastPathComponent
    
    print("\(strNowTime)-\(fileName)-(\(lineNum)): \(message)")
    
    #endif
}


// MARK: - 全局提示框
func alert(_ message: String, _ duration: NSInteger = NSInteger.max) {
    
    let alert = UIAlertController(title: "Warn", message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Sure", style: .cancel, handler: nil))
    
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: {
    })
    
    if duration != NSInteger.max {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(integerLiteral: duration)) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

extension DispatchTime: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = DispatchTime.now() + .seconds(value)
    }
}
extension DispatchTime: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = DispatchTime.now() + .milliseconds(Int(value * 1000))
    }
}

/// 随机字符串生成
extension String{
    static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static func randomStr(len: Int) -> String{
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}

func DispatchTimers(timeInterval: Double, handler:@escaping (DispatchSourceTimer?)->()) {
    
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
    timer.schedule(deadline: .now(), repeating: timeInterval)
    timer.setEventHandler {
        DispatchQueue.main.async {
            handler(timer)
        }
    }
    timer.resume()
}
