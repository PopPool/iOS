//
//  Date+.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/30/24.
//

import Foundation

extension Optional where Wrapped == Date {
    /// `yyyy. MM. dd` 형식으로 날짜를 문자열로 변환합니다.
    /// - Parameter defaultString: 날짜가 nil일 경우 반환할 기본 문자열 (기본값: 빈 문자열 "")
    /// - Returns: 형식화된 날짜 문자열 또는 기본 문자열
    func toPPDateString(defaultString: String = "") -> String {
        guard let date = self else {
            return defaultString
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter.string(from: date)
    }

    func toPPDateMonthString(defaultString: String = "") -> String {
        guard let date = self else {
            return defaultString
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일"
        return formatter.string(from: date)
    }

    func toPPTimeeString(defaultString: String = "") -> String {
        guard let date = self else {
            return defaultString
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
