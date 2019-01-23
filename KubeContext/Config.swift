//
//  Config.swift
//  KubeContext
//
//  Created by Turken, Hasan on 10.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import Foundation
import Cocoa

struct Config: Codable {
    var APIVersion: String?
    var Clusters: [ClusterElement]
    var Contexts: [ContextElement]
    var CurrentContext: String
    var Extensions: [String:String]?
    var Kind: String?
    var Preferences: Preferences?
    var AuthInfos: [AuthInfoElement]
    
    private enum CodingKeys : String, CodingKey {
        case APIVersion="apiVersion"
        case Clusters="clusters"
        case Contexts="contexts"
        case CurrentContext="current-context"
        case Extensions="extensions"
        case Kind="kind"
        case Preferences="preferences"
        case AuthInfos="users"
    }
    
    init(){
        self.APIVersion = "v1"
        self.Kind = "Config"
        self.Contexts = []
        self.Clusters = []
        self.AuthInfos = []
        self.CurrentContext = ""
    }
}

struct Preferences: Codable {
    var Colors: Bool?
    var Extensions: [String:String]?
    
    private enum CodingKeys : String, CodingKey {
        case Colors="colors"
        case Extensions="extensions"
    }
}

struct ClusterElement: Codable {
    var Cluster: Cluster
    var Name: String
    
    private enum CodingKeys : String, CodingKey {
        case Cluster="cluster"
        case Name="name"
    }
}

struct Cluster: Codable {
    var CertificateAuthority: String?
    var CertificateAuthorityData: String?
    var Extensions: [String:String]?
    var InsecureSkipTLSVerify: Bool?
    var Server: String
    
    private enum CodingKeys : String, CodingKey {
        case CertificateAuthority="certificate-authority"
        case CertificateAuthorityData="certificate-authority-data"
        case Extensions="extensions"
        case InsecureSkipTLSVerify="insecure-skip-tls-verify"
        case Server="server"
    }
}

struct AuthInfoElement: Codable {
    var Name: String
    var User: AuthInfo
    
    private enum CodingKeys : String, CodingKey {
        case Name="name"
        case User="user"
    }
}

struct AuthInfo: Codable {
    var Impersonate: String?
    var ImpersonateGroups: [String]?
    var ImpersonateUserExtra: [String:[String]]?
    var AuthProvider: AuthProviderConfig?
    var ClientCertificate: String?
    var ClientCertificateData: String?
    var ClientKey: String?
    var ClientKeyData: String?
    var Exec: ExecConfig?
    var Extensions: [String:String]?
    var Token: String?
    var TokenFile: String?
    var Password: String?
    var Username: String?
    
    private enum CodingKeys : String, CodingKey {
        case Impersonate="act-as"
        case ImpersonateGroups="act-as-groups"
        case ImpersonateUserExtra="act-as-user-extra"
        case AuthProvider="auth-provider"
        case ClientCertificate="client-certificate"
        case ClientCertificateData="client-certificate-data"
        case ClientKey="client-key"
        case ClientKeyData="client-key-data"
        case Exec="exec"
        case Extensions="extensions"
        case Token="token"
        case TokenFile="tokenFile"
        case Password="password"
        case Username="username"
    }
    
}

struct ContextElement: Codable {
    var Context: Context
    var Name: String
    var IconColor: NSColor?
    
    private enum CodingKeys : String, CodingKey {
        case Context="context"
        case Name="name"
    }
}

struct Context: Codable {
    var Cluster: String
    var Extensions: [String:String]?
    var Namespace: String?
    var AuthInfo: String
    
    private enum CodingKeys : String, CodingKey {
        case Cluster="cluster"
        case Extensions="extensions"
        case Namespace="namespace"
        case AuthInfo="user"
    }
    
}

struct AuthProviderConfig: Codable {
    var Config: [String:String]?
    var Name: String
    
    private enum CodingKeys : String, CodingKey {
        case Config="config"
        case Name="name"
    }
}

struct ExecConfig: Codable {
    var APIVersion: String?
    var Args: [String]?
    var Command: String
    var Env: [ExecEnvVar]?
    
    private enum CodingKeys : String, CodingKey {
        case APIVersion="apiVersion"
        case Args="args"
        case Command="command"
        case Env="env"
    }
}

struct ExecEnvVar: Codable {
    var Name: String
    var Value: String
    
    private enum CodingKeys : String, CodingKey {
        case Name="name"
        case Value="value"
    }
}
