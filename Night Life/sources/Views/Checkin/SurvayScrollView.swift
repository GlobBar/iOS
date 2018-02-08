//
//  SurvayScrollView.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class SurvayScrollView : UIScrollView {
   
    @IBOutlet var partyStatusContainer: UIView!
    @IBOutlet var fullnessContainer: UIView!
    @IBOutlet var musicContainer: UIView!
    @IBOutlet var genderRatioContainer: UIView!
    @IBOutlet var coverChargeContainer: UIView!
    @IBOutlet var queueLengthContainer: UIView!
    
    fileprivate let partyStatusView : RadioButtonGroup<PartyStatus> = RadioButtonGroup()
    fileprivate let fulnessView : DiscreetStepper<Fullness> = DiscreetStepper()
    fileprivate let musicView : RadioButtonGroup<Music> = RadioButtonGroup()
    fileprivate let genderRatioView : DiscreetStepper<GenderRatio> = DiscreetStepper()
    fileprivate let coverChargeView : RadioButtonGroup<CoverCharge> = RadioButtonGroup()
    fileprivate let queueView : RadioButtonGroup<QueueLine> = RadioButtonGroup()
    
    @IBOutlet var continueSurvayButton: UIButton!
    @IBOutlet var completeSurvayButton: UIButton!
    @IBOutlet var submitSurvayButton: UIButton!
    
    var viewModel : CreateReportViewModel!
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ///party staus
        
        partyStatusContainer.embbedViewAsContainer(partyStatusView)
        
        partyStatusView.addOptions([
            .yes,
            .no
            ])
        
        ///fulness
        
        fullnessContainer.embbedViewAsContainer(fulnessView)
        
        fulnessView.minimumColor = UIColor.orange
        fulnessView.maximumColor = UIColor.white
        fulnessView.addOptions([Fullness.empty, Fullness.low, Fullness.crowded, Fullness.packed])
        
        ///music
        musicContainer.embbedViewAsContainer(musicView)
        
        musicView.addOptions([
                .noMusic,
                .dj_EDM_House,
                .dj_disco,
                .dj_hip,
                .pop,
                .liveBand,
                .karaoke,
                .other,
            ])
        
        ///gender ratio
        
        genderRatioContainer.embbedViewAsContainer(genderRatioView)
        genderRatioView.minimumColor = UIColor(red: 255, green: 182, blue: 193)
        genderRatioView.maximumColor = UIColor(red: 34, green: 123, blue: 151)
        genderRatioView.addOptions([
            .mostlyGuys,
            .moreGuys,
            .balanced,
            .moreLadies,
            .mostlyLadies
            ])
        
        ///cover charge
        coverChargeContainer.embbedViewAsContainer(coverChargeView)
        
        coverChargeView.addOptions([
            .free,
            .small,
            .moderete,
            .big
            ])
        
        ///queue
        queueLengthContainer.embbedViewAsContainer(queueView)
        
        queueView.addOptions([
            .noQueue,
            .short,
            .long,
            .enormous
            ])
        
        ///validation closure
        let validationClosure = { (ar: [CustomStringConvertible?]) -> Bool in
            return ar.filter{ $0 != nil }.count == ar.count
        }

        ///complete survay after 3 questions actions
        let completeSurvayObservable = completeSurvayButton
            .rx.tap
            .filter { [unowned self] _ in
                let isValid = validationClosure([
                    self.partyStatusView.selectedOption,
                    self.queueView.selectedOption,
                    self.coverChargeView.selectedOption
                    ])
                
                if !isValid {
                    self.viewModel.errorMessage.value = "Please answer the questions before completing survey"
                }
                
                return isValid
            }
            .map { [unowned self] _ -> Report in
                let partyStatus = self.partyStatusView.selectedOption
                let coverCharge = self.coverChargeView.selectedOption
                let queue = self.queueView.selectedOption
                
                return Report(partyOnStatus: partyStatus,
                    fullness: nil,
                    musicType: nil,
                    genderRatio:  nil,
                    coverCharge: coverCharge,
                    queue:  queue)
            }
        
        ///complete survay after 6 questions actions
        let submitSurvayObservable = submitSurvayButton
            .rx.tap
            .filter { [unowned self] _ in
                let isValid = validationClosure([
                    self.partyStatusView.selectedOption,
                    self.queueView.selectedOption,
                    self.coverChargeView.selectedOption,
                    self.genderRatioView.selectedOption,
                    self.fulnessView.selectedOption,
                    self.musicView.selectedOption
                    ])
                
                if !isValid {
                    self.viewModel.errorMessage.value = "Please answer the questions before completing survey"
                }
                
                return isValid
            }.map { [unowned self] _ -> Report in
                
                let partyStatus = self.partyStatusView.selectedOption
                let fullness = self.fulnessView.selectedOption
                let music = self.musicView.selectedOption
                let genderRatio = self.genderRatioView.selectedOption
                let coverCharge = self.coverChargeView.selectedOption
                let queue = self.queueView.selectedOption
                
                return Report(partyOnStatus: partyStatus, fullness: fullness, musicType: music, genderRatio:  genderRatio, coverCharge: coverCharge, queue:  queue)
            }

        
        Observable.of(
            submitSurvayObservable,
            completeSurvayObservable
            ).merge().subscribe(onNext: { [unowned self] report in
                
                self.viewModel.submitReport(report)
                
            }
            )
.disposed(by: disposeBag)

        
        ///continue survay button actions
        continueSurvayButton.rx.tap
            .filter { [unowned self] _ in
                let isValid = validationClosure([
                    self.partyStatusView.selectedOption,
                    self.queueView.selectedOption,
                    self.coverChargeView.selectedOption
                    ])
                
                if !isValid {
                    self.viewModel.errorMessage.value = "Please answer the questions before proceeding"
                }
                
                return isValid
            }
            .subscribe(onNext:{ [unowned self] _ in
                UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    self.contentOffset.y += self.frame.size.height
                    }) { _ in
                        self.viewModel.moveToNextQuestionPage()
                    }
            }
            )
.disposed(by: disposeBag)
    }

    func configureUI() {
        ///CONTINUE SURVAY
        continueSurvayButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), at: 0)
        
        ///COMPLETE SURVEY
        completeSurvayButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), at: 0)
        
        ///SUBMIT SURVEY
        submitSurvayButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), at: 0)
        
    }
    
    func layoutSubLayers() {
        continueSurvayButton.layer.sublayers?.forEach{ [weak s = continueSurvayButton] l in
            l.frame = s!.bounds
        }
        
        completeSurvayButton.layer.sublayers?.forEach{ [weak s = completeSurvayButton] l in
            l.frame = s!.bounds
        }
        
        submitSurvayButton.layer.sublayers?.forEach{ [weak s = submitSurvayButton] l in
            l.frame = s!.bounds
        }
    }
    
}

extension UIView {
    
    func embbedViewAsContainer(_ view: UIView) {
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint1 = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let constraint2 = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let constraint3 = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let constraint4 = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.addConstraints([constraint1,constraint2,constraint3,constraint4])
    }
    
}
