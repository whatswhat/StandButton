//
//  StandButton.swift
//  StandButtonDemo
//
//  Created by Diego on 2019/7/19.
//  Copyright © 2019 whatzwhat. All rights reserved.
//

import UIKit

class StandButton: StandControl {
   
    enum StandModel { case menu, option, none }
    
    enum Direction { case up, donw, left, right }
    
    /// 選單展開狀態
    private(set) final var isOn: Bool = false
    /// 生成方向
    public final var direction: Direction = .up
    /// 按鈕間距
    public final var spacing: CGFloat = 20
    /// 動畫時間
    public final var duration: Double = 0.25
    /// 按鈕樣式
    public final var model: StandModel = .none { didSet { prepareModel() } }
    /// Delegate
    public final var delegate: StandButtonDelegate?
    /// 展開後的背景
    public final lazy var backdropView = UIView()

    /// 背景動畫
    private final lazy var backdropAnimate = UIViewPropertyAnimator(duration: duration / 2, curve: .linear)
    /// 按鈕展開動畫
    private final lazy var actionAnimate = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.5)
    /// 菜單模式動畫
    private final lazy var menuAnimate = UIViewPropertyAnimator(duration: duration / 2, curve: .easeInOut)
    /// 菜單模式使用
    private final lazy var burgerMenu = [UIView(), UIView(), UIView()]
    
    private final func prepareModel() {
        guard delegate != nil else {
            return
        }
        switch model {
        case .menu:
            prepareBurgerMenu()
        case .option:
            prepareBaseImage()
        default:
            return
        }
        addTarget(self, action: #selector(standAction), for: .touchUpInside)
        prepareBackdrop()
    }
    
}



// MARK: - Backdrop View Methods.
extension StandButton: UIGestureRecognizerDelegate {
    
    private final func prepareBackdrop() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickBackdrop))
        tap.delegate = self
        backdropView.addGestureRecognizer(tap)
        backdropView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        backdropView.autoresizingMask = [.flexibleHeight , .flexibleWidth]
        backdropView.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
    }
    
    @objc private final func clickBackdrop() {
        standAction()
    }
    
    private final func backdropTransform(_ isOn: Bool) {
        switch isOn {
        case true:
            backdropView.alpha = 0
            self.superview?.insertSubview(backdropView, belowSubview: self)
            backdropAnimate.addAnimations { self.backdropView.alpha = 1 }
        default:
            backdropAnimate.addAnimations { self.backdropView.alpha = 0 }
            backdropAnimate.addCompletion { _ in self.backdropView.removeFromSuperview() }
        }
        backdropAnimate.startAnimation()
    }
    
    final func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch touch.view {
        case is StandControl:
            return false
        default:
            return true
        }
    }
    
}



// MARK: - Option Model Methods.
extension StandButton {

    private final func prepareBaseImage() {
        guard let delegate = delegate else { return }
        self.setIcon(delegate.standButton(self, iconInCell: 0))
    }

    private final func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.repeatCount = 1
        shake.autoreverses = true
        switch direction {
        case .up, .donw:
            shake.fromValue = NSValue(cgPoint: CGPoint(x: center.x, y: center.y + 3))
            shake.toValue = NSValue(cgPoint: CGPoint(x: center.x, y: center.y - 3))
        case .left, .right:
            shake.fromValue = NSValue(cgPoint: CGPoint(x: center.x + 3, y: center.y))
            shake.toValue = NSValue(cgPoint: CGPoint(x: center.x - 3, y: center.y))
        }
        self.layer.add(shake, forKey: nil)
    }
    
}



// MARK: - Menu Model Methods.
extension StandButton {
    
    private final class StandMenuView: UIStackView {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            return nil
        }
    }
    
    private final func prepareBurgerMenu() {
        let viewWidth = bounds.width * 0.45
        let viewHeight = viewWidth * 0.15
        let stack = StandMenuView(arrangedSubviews: burgerMenu)
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = viewHeight * 1.5
        for view in burgerMenu {
            view.backgroundColor = .white
            view.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
            view.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
            view.layer.cornerRadius = viewHeight / 3
            view.clipsToBounds = true
        }
        self.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private final func menuTransform(_ isOn: Bool) {
        switch isOn {
        case true:
            menuAnimate.addAnimations {
                let moveDown = self.burgerMenu[2].center.y - self.burgerMenu[1].center.y
                let moveUp = self.burgerMenu[0].center.y - self.burgerMenu[1].center.y
                let angle = CGFloat.pi / 180 * 135
                let transforms = [
                    CGAffineTransform(translationX: 0, y: moveDown).rotated(by: angle),
                    CGAffineTransform(scaleX: 0.01, y: 0.01),
                    CGAffineTransform(translationX: 0, y: moveUp).rotated(by: -angle)
                ]
                for index in stride(from: 0, to: self.burgerMenu.count, by: 1) {
                    self.burgerMenu[index].transform = transforms[index]
                }
            }
        default:
            menuAnimate.addAnimations {
                let identity = CGAffineTransform.identity
                for view in self.burgerMenu {
                    view.transform = identity
                }
            }
        }
        menuAnimate.startAnimation()
    }
    
}



// MARK: - Show Buttons Methods.
extension StandButton {

    @objc private final func standAction() {
        guard isUserInteractionEnabled else {
            return
        }
        isUserInteractionEnabled = false
        isOn = !isOn
        
        switch model {
        case .menu: menuTransform(isOn)
        default: break
        }
        foldTransform(isOn)
        backdropTransform(isOn)
        delegate?.standButton(self, unfold: isOn)
    }
    
    private final func foldTransform(_ isOn: Bool) {
        switch isOn {
        case true:
            unfold()
        default:
            enfold()
        }
    }
    
    private final func unfold() {
        guard let delegate = delegate else {
            return
        }
        let space = spacing + self.bounds.height
        let total = delegate.numberOfCells(in: self)
        var current: CGFloat = 0
        for index in stride(from: 0, to: total, by: 1) {
            let stand = StandCell(frame: self.frame, index: index, delegate: self)
            stand.setIcon(delegate.standButton(self, iconInCell: index))
            stand.alpha = 0
            backdropView.addSubview(stand)
            current += space
            switch direction {
            case .up:
                actionAnimate.addAnimations { stand.center.y -= current }
            case .donw:
                actionAnimate.addAnimations { stand.center.y += current }
            case .left:
                actionAnimate.addAnimations { stand.center.x -= current }
            case .right:
                actionAnimate.addAnimations { stand.center.x += current }
            }
            actionAnimate.addAnimations {
                stand.alpha = 1
            }
            if index == (total - 1){
                actionAnimate.addCompletion { _ in
                    self.isUserInteractionEnabled = true
                }
            }
            actionAnimate.startAnimation()
        }
    }
    
    private final func enfold() {
        let space = spacing + self.bounds.height
        var current: CGFloat = 0
        for view in backdropView.subviews {
            if view is StandCell {
                view.isUserInteractionEnabled = false
                current += space
                switch self.direction {
                case .up:
                    actionAnimate.addAnimations { view.center.y += current }
                case .donw:
                    actionAnimate.addAnimations { view.center.y -= current }
                case .left:
                    actionAnimate.addAnimations { view.center.x += current }
                case .right:
                    actionAnimate.addAnimations { view.center.x -= current }
                }
                actionAnimate.addAnimations {
                    view.alpha = 0
                }
                actionAnimate.addCompletion { _ in
                    view.removeFromSuperview()
                }
                actionAnimate.startAnimation()
            }
        }
        isUserInteractionEnabled = true
    }
    
}



// MARK: - Select Method.
extension StandButton: StandCellDelegate {
    
    func didSelectCellAt(index: Int) {
        guard isUserInteractionEnabled else { return }
        switch model {
        case .option:
            guard let delegate = delegate else { return }
            setIcon(delegate.standButton(self, iconInCell: index))
            shake()
        default:
            break
        }
        delegate?.standButton(self, didSelectCellAt: index)
        standAction()
    }
    
}

