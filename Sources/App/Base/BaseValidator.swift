//
//  BaseValidator.swift
//  IMServer
//
//  Created by Yiqiang Zeng on 2019/2/26.
//

import SwiftValidators

protocol BaseValidatorProtocol {
    
    func validate(_ input: String) -> Bool
}

enum BaseValidator {
    
    case password
}

extension BaseValidator {
    
    //MARK: - 工厂
    func instance() -> BaseValidatorProtocol {
        switch self {
        case .password:
            return ValidatorPassword.instance
        }
    }
    
    //MARK: - 验证
    func validate(_ input: String) -> Bool {
        switch self {
        case .password:
            return ValidatorPassword.instance.validate(input)
        }
    }
}

struct ValidatorPassword: BaseValidatorProtocol {
    
    //MARK: - 单例
    static let instance = ValidatorPassword()
    private init() { }
    
    //MARK: - 验证
    func validate(_ input: String) -> Bool {
        return v_ascii.apply(input) && v_length_min.apply(input) && v_length_min.apply(input)
    }
    
    //MARK: - 私有成员
    fileprivate let v_ascii         = Validator.isASCII()
    fileprivate let v_length_min    = Validator.minLength(6)
    fileprivate let v_length_max    = Validator.maxLength(16)
}


