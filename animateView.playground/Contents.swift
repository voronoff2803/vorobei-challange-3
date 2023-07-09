//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    let slider = UISlider()
    let size: CGFloat = 100
    let animationDuration: CGFloat = 1.0
    let animatedView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.cornerRadius = 8
        return view
    }()
    var displayLink: CADisplayLink?
    var startTime: CFTimeInterval = 0
    var startOffset: CFTimeInterval = 0
    var endOffset: CFTimeInterval = 0
    
    lazy var firstConstraints = [
        animatedView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
    ]
    
    lazy var secondConstraint = [
        animatedView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -size / 4)
    ]
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpOutside)
        
        [slider, animatedView].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            slider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            slider.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            animatedView.heightAnchor.constraint(equalToConstant: size),
            animatedView.heightAnchor.constraint(equalTo: animatedView.widthAnchor),
            animatedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: size)
        ])
        
        
        addAnimation()
    }
    
    func addAnimation() {
        NSLayoutConstraint.activate(self.firstConstraints)
        NSLayoutConstraint.deactivate(self.secondConstraint)
        
        DispatchQueue.main.async {
            self.animatedView.layer.speed = 0
            UIView.animate(withDuration: self.animationDuration) {
                self.animatedView.transform = .init(rotationAngle: .pi / 2).scaledBy(x: 1.5, y: 1.5)
                NSLayoutConstraint.deactivate(self.firstConstraints)
                NSLayoutConstraint.activate(self.secondConstraint)
                
                self.view.layoutSubviews()
            }
        }
    }
    
    var startAnimationProgress: CGFloat = 0.0
    
    func startAnimation() -> CGFloat {
        startOffset = animatedView.layer.timeOffset
        startTime = CACurrentMediaTime()
        endOffset = CFTimeInterval(animationDuration)
        
        startAnimationProgress = animatedView.layer.timeOffset
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .default)
        
        return animationDuration - (animationDuration * startAnimationProgress)
    }
    
    @objc func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        let duration = animationDuration - (animationDuration * startAnimationProgress)
        
        let animationProgress = elapsedTime / duration
        let currentOffset = startOffset + (endOffset - startOffset) * animationProgress
        
        animatedView.layer.timeOffset = currentOffset
        if animationProgress >= 1 {
            stopAnimation()
        }
    }
    
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func action() {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        self.present(vc, animated: true)
    }
    
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        self.animatedView.layer.speed = 0
        animatedView.layer.timeOffset = CFTimeInterval(sender.value)
    }
    
    @IBAction func sliderTouchUp(_ sender: UISlider) {
        guard sender.value < 1.0 else { return }
        
        let duaration = self.startAnimation()
        
        UIView.animate(withDuration: duaration, delay: 0.0, options: [.curveLinear]) {
            self.slider.setValue(1.0, animated: true)
        }
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
