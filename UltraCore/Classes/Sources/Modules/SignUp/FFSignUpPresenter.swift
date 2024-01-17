//
//  FFSignUpPresenter.swift
//  UltraCore
//
//  Created by Slam on 6/15/23.
//

import RxSwift

final class FFSignUpPresenter {
    
    private unowned let view: SignUpViewInterface
    fileprivate let wireframe: SignUpWireframeInterface
    fileprivate let interactor: SessionInteractorImpl
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle -g
    init(view: SignUpViewInterface,
         wireframe: SignUpWireframeInterface,
         interactor: SessionInteractorImpl) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
    }
}

// MARK: - Extensions -
extension FFSignUpPresenter: SignUpPresenterInterface {
  
    func login(lastName: String, firstname: String, phone number: String) {
        let userDef = UserDefaults.standard
        userDef.set(lastName, forKey: "last_name")
        userDef.set(firstname, forKey: "first_name")
        userDef.set(number, forKey: "phone")
        interactor
            .executeSingle(params: ())
            .subscribe(onSuccess: { [weak self] in
                self?.view.open(view: UltraCoreSettings.entryConversationsViewController())
            })
            .disposed(by: disposeBag)
    }
}


fileprivate extension SignUpPresenter {

}
