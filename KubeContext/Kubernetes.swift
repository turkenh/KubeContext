//
//  Kubernetes.swift
//  KubeContext
//
//  Created by Turken, Hasan on 07.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import Foundation
import Yams
import os

class Kubernetes {
    var kubeconfigFileUrl:URL?

    init(configFile: URL) {
        kubeconfigFileUrl = configFile
    }
    
    func getConfigFilePath () -> String {
        return (kubeconfigFileUrl?.path)!
    }
    
    private func loadConfig(url: URL) throws -> Config? {
        // TODO: return error as well
        let fileContent = try String(contentsOf: url, encoding: .utf8)
        
        let decoder = YAMLDecoder()
        let config = try decoder.decode(Config.self, from: fileContent)

        return config
    }
    
    func saveConfig(config: Config) throws {
        try saveConfigToFile(config: config, file: kubeconfigFileUrl)
    }
    
    func getConfig() throws -> Config? {
        return try loadConfig(url: kubeconfigFileUrl!)
    }
    
    func mergeKubeconfigIntoConfig(configToImportFileUrl: URL, mainConfig: Config) throws -> Config {
        let newConfig = try loadConfig(url: configToImportFileUrl)
        
        var mergedConfig = mainConfig
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd_HHmmSS"
        let dateString = formatter.string(from: now)
        
        var importIdSuffix = ""
        if uiTesting {
            importIdSuffix = "_imported"
        } else {
            importIdSuffix = "_imported_" + dateString
        }
        
        for var cluster in (newConfig?.Clusters)! {
            cluster.Name += importIdSuffix
            mergedConfig.Clusters.append(cluster)
        }
        for var user in (newConfig?.AuthInfos)! {
            user.Name += importIdSuffix
            mergedConfig.AuthInfos.append(user)
        }
        for var context in (newConfig?.Contexts)! {
            context.Name += importIdSuffix
            context.Context.Cluster += importIdSuffix
            context.Context.AuthInfo += importIdSuffix
            mergedConfig.Contexts.append(context)
        }
        return mergedConfig
    }
        
    func importConfig(configToImportFileUrl: URL) throws {
        let mainConfig = try loadConfig(url: kubeconfigFileUrl!)
        
        let mergedConfig = try mergeKubeconfigIntoConfig(configToImportFileUrl: configToImportFileUrl, mainConfig: mainConfig!)
        
        try saveConfig(config: mergedConfig)
    }
    
    func useContext(name: String) throws {
        var kubeconfig = try loadConfig(url: kubeconfigFileUrl!)
        kubeconfig?.CurrentContext = name
        try saveConfig(config: kubeconfig!)
    }
}
