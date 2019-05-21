//
//  main.swift
//  EonilFSEventsDemoCLI
//
//  Created by Henry on 2018/12/27.
//

import Foundation
import EonilFSEvents

let k = NSObject()
try EonilFSEvents.startWatching(
    paths: [NSHomeDirectory()],
    for: ObjectIdentifier(k),
    with: { e in print(e) })

RunLoop.main.run()
