//
//  HomeUseCase.swift
//  PopPool
//
//  Created by Porori on 8/21/24.
//

import Foundation
import RxSwift

protocol FetchHomeUseCase {
    
    var repository: HomeRepository { get set }
    
    func execute(
        userId: String
    ) -> Observable<GetHomeInfoResponse>
}
