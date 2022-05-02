//
//  TestSwift.swift
//  JDHotFix_Example
//
//  Created by mac on 2022/5/2.
//  Copyright © 2022 zhangjiangdong. All rights reserved.
//

import Foundation

 class TestSwift: NSObject {
    
    @objc func test() {
        print("swift11--->");
        self.test22()
    }
     
     @objc dynamic func test22() {
         print("swift  test22--->");
     }
    
}
