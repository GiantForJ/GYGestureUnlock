//
//  GestureViewController.swift
//  GYGestureUnlock
//
//  Created by zhuguangyang on 16/8/24.
//  Copyright © 2016年 Giant. All rights reserved.
//

import UIKit
import GYGestureUnlock

enum GestureViewControllerType: Int {
    case setting = 1
    case login
}

enum buttonTag: Int {
    case rest = 1
    case manager
    case forget
}

class GestureViewController: UIViewController {
    
    
    /// 控制器的来源类型:设置密码、登录
    var type:GestureViewControllerType?
    
    /// 重置按钮
    private var resetBtn: UIButton?
    
    /// 提示Label
    private var msgLabel: GYLockLabel?
    
    /// 解锁界面
    private  var lockView: GYCircleView?
    
    /// infoView
    private var infoView: GYCircleInfoView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = CircleViewBackgroundColor
        
        //1.界面相同部分生成器
        setupSameUI()
        
        //2.界面不同部分生成器
        setupDifferentUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if self.type == GestureViewControllerType.login {
            navigationController?.isNavigationBarHidden = true
        }
        
        //进来先清空存储的第一个密码
        GYCircleConst.saveGesture(nil, key: gestureOneSaveKey)
    }
    
    
    func setupSameUI(){
        
        //创建导航栏右边按钮
        self.navigationItem.rightBarButtonItem = itemWithTile("重设", target: self, action: #selector(GestureViewController.didClickBtn(_:)), tag: buttonTag.rest.rawValue)
        
        //解锁界面
        let lockView = GYCircleView()
        lockView.delegate = self
        self.lockView = lockView
        view.addSubview(lockView)
        
        let msgLabel = GYLockLabel.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 14))
        msgLabel.center = CGPoint(x: kScreenW/2, y: lockView.frame.minY - 30)
        
        self.msgLabel = msgLabel
        
        view.addSubview(msgLabel)
        
    }
    
    //MARK:- 创建UIBarButtonItem
    
    func itemWithTile(_ title: NSString,target: AnyObject,action: Selector,tag: NSInteger) -> UIBarButtonItem{
        
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle(title as String, for: UIControl.State())
        button.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        button.tag = tag
        button.contentHorizontalAlignment = .right
        button.isHidden = true
        self.resetBtn = button
        
        return UIBarButtonItem(customView: button)
        
        
        
    }
    //    
    //    func didClickBtn(sender: UIButton) {
    //        
    //        
    //        switch sender.tag {
    //        case buttonTag.Rest.rawValue:
    //            
    //            self.resetBtn?.hidden = true
    //            
    //            self.infoViewDeselectedSubviews()
    //            
    //            self.msgLabel?.showNormalMag(gestureTextBeforeSet)
    //            
    //            GYCircleConst.saveGesture(nil, key: gestureOneSaveKey)
    //            
    //            break
    //        case buttonTag.Manager:
    //            print("点击了管理手势密码")
    //            break
    //            
    //        default:
    //            <#code#>
    //        }
    //        
    //    }
    //    
    func setupDifferentUI() {
        
        switch self.type! {
        case GestureViewControllerType.setting:
            setupSubViewsSettingVc()
            break
        case GestureViewControllerType.login:
            setupSubViewsLoginVc()
            break
            
        }
    }
    
    //MARK: -设置手势密码界面
    func setupSubViewsSettingVc() {
        
        self.lockView?.type = CircleViewType.circleViewTypeSetting
        
        title = "设置手势密码"
        
        self.msgLabel?.showNormalMag(gestureTextBeforeSet as NSString)
        
        let infoView = GYCircleInfoView()
        infoView.frame = CGRect(x: 0, y: 0, width: CircleRadius * 2 * 0.6, height: CircleRadius * 2 * 0.6)
        
        infoView.center = CGPoint(x: kScreenW/2, y: self.msgLabel!.frame.minY - infoView.frame.height/2 - 10)
        self.infoView = infoView
        view.addSubview(infoView)
        
        
    }
    
    //MARK: - 登录手势密码
    func setupSubViewsLoginVc() {
        self.lockView?.type = CircleViewType.circleViewTypeLogin
        
        //头像
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
        imageView.center = CGPoint(x: kScreenW/2, y: kScreenH/5)
        imageView.image = UIImage(named: "head")
        view.addSubview(imageView)
        
        //管理手势密码
        let leftBtn = UIButton(type: UIButton.ButtonType.custom)
        
        creatButton(leftBtn, frame: CGRect(x: CircleViewEdgeMargin + 20, y: kScreenH - 60, width: kScreenW/2, height: 20) , titlr: "管理手势密码", alignment: UIControl.ContentHorizontalAlignment.left, tag: buttonTag.manager.rawValue)
        
        //登录其它账户
        let rightBtn = UIButton(type: UIButton.ButtonType.custom)
        
        creatButton(rightBtn, frame: CGRect(x: kScreenW/2 - CircleViewEdgeMargin - 20, y: kScreenH - 60, width: kScreenW/2, height: 20), titlr: "登录其他账户", alignment: UIControl.ContentHorizontalAlignment.right, tag: buttonTag.forget.rawValue)        
        
    }
    
    //MARK: - 创建Button
    func creatButton(_ btn: UIButton,frame: CGRect,titlr: NSString,alignment: UIControl.ContentHorizontalAlignment,tag: NSInteger) {
        btn.frame = frame
        btn.tag = tag
        btn.setTitle(titlr as String, for: UIControl.State())
        btn.setTitleColor(UIColor.white, for: UIControl.State())
        btn.contentHorizontalAlignment = alignment
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(GestureViewController.didClickBtn(_:)), for: UIControl.Event.touchUpInside)
        view.addSubview(btn)
        
    }
    
    @objc func didClickBtn(_ sender:UIButton){
        
        switch sender.tag {
        case buttonTag.rest.rawValue:
            //1.隐藏按钮
            self.resetBtn?.isHidden = true
            
            //2.infoView取消选中
            infoViewDeselectedSubviews()
            
            //3.msgLabel提示文字复位
            self.msgLabel?.showNormalMag(gestureTextBeforeSet as NSString)
            
            //4.清除之前存储的密码
            GYCircleConst.saveGesture(nil, key: gestureOneSaveKey)
            break
        case buttonTag.manager.rawValue:
            print("点击了手势管理密码按钮")
            break
        case buttonTag.forget.rawValue:
            print("点击了登录其他账户按钮")
            break
        default:
            break
        }
        
    }
    
    //MARK: - 让infoView对应按钮取消选中
    func infoViewDeselectedSubviews() {
        
        ((self.infoView?.subviews)! as NSArray).enumerateObjects({ (obj, idx, stop) in
            
            (obj as! GYCircle).state = CircleState.circleStateNormal
        })
        
    }
}

extension GestureViewController: GYCircleViewDelegate {
    
    func circleViewConnectCirclesLessThanNeedWithGesture(_ view: GYCircleView, type: CircleViewType, gesture: String) {
        
        //swift 很奇葩
        guard GYCircleConst.getGestureWithKey(gestureOneSaveKey) != nil else {
            
            self.msgLabel?.showWarnMsgAndShake("最少连接\(CircleSetCountLeast)点,请重新输入")
            return
        }
        
        let gestureOne = GYCircleConst.getGestureWithKey(gestureOneSaveKey)! as NSString
        
        //看是否存在第一个密码
        if gestureOne.length > 0 {
            self.resetBtn?.isHidden = false
            self.msgLabel?.showWarnMsgAndShake(gestureTextDrawAgainError)
        } else {
            print("密码长度不合格\(gestureOne.length)")
            self.msgLabel?.showWarnMsgAndShake(gestureTextConnectLess as String)
        }
        
        
    }
    
    func circleViewdidCompleteSetFirstGesture(_ view: GYCircleView, type: CircleViewType, gesture: String) {
        
        print("获取第一个手势密码\(gesture)")
        
        self.msgLabel?.showWarnMsgAndShake(gestureTextDrawAgain)
        
        //infoView展示对应选中的圆
        infoViewSelectedSubviewsSameAsCircleView(view)
        
        
        
    }
    
    
    
    func circleViewdidCompleteSetSecondGesture(_ view: GYCircleView, type: CircleViewType, gesture: String, result: Bool) {
        
        print("获得第二个手势密码\(gesture)")
        
        if result {
            print("两次手势匹配！可以进行本地化保存了")
            
            self.msgLabel?.showWarnMsg(gestureTextSetSuccess)
            GYCircleConst.saveGesture(gesture, key: gestureFinalSaveKey)
            navigationController?.popToRootViewController(animated: true)
        } else {
            print("两次手势不匹配")
            self.msgLabel?.showWarnMsgAndShake(gestureTextDrawAgainError)
            self.resetBtn?.isHidden = false
        }
        
    }
    
    func circleViewdidCompleteLoginGesture(_ view: GYCircleView, type: CircleViewType, gesture: String, result: Bool) {
        
        
        //此时的type有两种情况 Login or verify
        if type == CircleViewType.circleViewTypeLogin {
            if result {
                print("登录成功!")
                navigationController?.popViewController(animated: true)
            } else {
                print("密码错误")
                self.msgLabel?.showWarnMsgAndShake(gestureTextGestureVerifyError)
            }
        } else  if type == CircleViewType.circleViewTypeVerify {
            if result {
                print("验证成功，跳转到设置手势界面")
            } else {
                print("原手势密码输入错误!")
            }
            
        }
    }
    
    
    //MARK: - 相关方法
    
    func infoViewSelectedSubviewsSameAsCircleView(_ circleView: GYCircleView){
        for circle: GYCircle in circleView.subviews as! [GYCircle] {
            
            if circle.state == CircleState.circleStateSelected || circle.state == CircleState.circleStateLastOneSelected {
                for infoCircle:GYCircle in self.infoView?.subviews as! [GYCircle]{
                    if infoCircle.tag == circle.tag {
                        infoCircle.state = CircleState.circleStateSelected
                    }
                }
            }
            
        }
    }
    
}
