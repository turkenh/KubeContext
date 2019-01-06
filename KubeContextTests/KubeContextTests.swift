//
//  KubeContextTests.swift
//  KubeContextTests
//
//  Created by Turken, Hasan on 18.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import XCTest
@testable import KubeContext

class KubeContextLoadSingleContextTests: XCTestCase {
    let fileManager = FileManager.default
    
    var k8s: Kubernetes?
    var bundle: Bundle!
    var url: URL!

    override func setUp() {
        bundle = Bundle(for: type(of: self))
        var tempDataUrl: URL?
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            tempDataUrl = documentDirectory.appendingPathComponent("TempData")
            try fileManager.removeItem(at: tempDataUrl!)
            let testDataPath = bundle.resourcePath! + "/TestData"
            try fileManager.copyItem(atPath: testDataPath, toPath: tempDataUrl!.path)
        } catch {
            XCTFail()
        }
        
        url = tempDataUrl!.appendingPathComponent("config-with-one-context.yaml")
        k8s = Kubernetes()
        XCTAssertNoThrow(try k8s?.setKubeconfig(configFile: url))
        XCTAssertNotNil(k8s)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testKubernetesLoadConfig() {
        var config: Config?
        do {
            config = try k8s?.getConfig()
        } catch {
            XCTFail()
        }
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.Contexts.count, 1, "There is one context")
        XCTAssertEqual(config?.Contexts[0].Name, "kubernetes-admin@kubernetes", "Name of the context is correct")
        XCTAssertEqual(config?.Contexts[0].Context.Cluster, "kubernetes", "Cluster of the context is correct")
        XCTAssertEqual(config?.Contexts[0].Context.AuthInfo, "kubernetes-admin", "User of the context is correct")
        XCTAssertNil(config?.Contexts[0].Context.Namespace)
        
        XCTAssertEqual(config?.Clusters.count, 1, "There is one cluster")
        XCTAssertEqual(config?.AuthInfos.count, 1, "There is one user")
        
        XCTAssertEqual(config?.CurrentContext, "kubernetes-admin@kubernetes", "Current context is correct")
        XCTAssertEqual(config?.Clusters[0].Name, "kubernetes", "Server adress is correct")
        XCTAssertEqual(config?.Clusters[0].Cluster.Server, "https://1.2.3.4:5678", "Server adress is correct")
        XCTAssertNotNil(config?.Clusters[0].Cluster.CertificateAuthorityData)
        XCTAssertEqual(config?.Clusters[0].Cluster.CertificateAuthorityData, "W7EomKwXZs1NFqIXk8GMHqJZeBxj8mZKjS26dcdeaX5AZYiqPtsUBe2NKmVXMFZfQY8Ezr1OOrmafuLdw9UUViJS2mFjKbVwdgkWGldoYHlUkn174dNlCHPxCzuXdrN4mJjORoBHKsnnsKFA0uJVr7aQ9TJuJEx8TtC9ORuHRMSurVDX2N2ZxC7tC0tIdHFPwQAsNH7j5t6WjRi2lCjDUnvZPGU7uM1DGXOIsb5593o3P18ylFZcODjpasD2GNGM3e8ztQuyUyHgF56L3kcSTzLs7dm3JjMNt869sveBKsKAZElaXEnfKamspyVBl4jeTDyaG6kgqn6fTEgLQXAJjjQfOVNlRu13Vbt56kK4Y84YfxsmIqW0tTOtObgdKxq1uyFR5oDpEUhHB8hcNEuf4unwCG3xW8qlVMOKSj52TV0WsXterzusUoSgagDCgFkJj3d5biWrJWCuYWG2XeWOu5Dgx6yTCVt3uceON51OaE6rBMmpe6XJgZ9N2AEoNHemFcvfz3jaA5NPGdE2NDzWhR3CM0IUVTmefq2uxG1KIGgkUyR0xRS2msyZiVYgsr7fOE0pO1YuJq2zabhXWb0fPvbCXozFpHOkxVcJLgfmK2lcNWvoYN6qhO9GLzWhc5fM9r2vbJSGteegnIw1Nr5iDUaWZNe6xcBHCojgVl83mhu0L0W4rIMPuVhK7Q9RrdZ7PPL1m7lPxTPWqm1S2G8FRyBkaj6tHsFhAMa7PnfJHhq8mRnDC7FExL5H8KX5lTi1misDpm7iMSF5DXkL4RvXrrZb1ybSWFpHRtCjH8aDQkfCN1WQeG2xva14gwmv8aKrLVGstg2T7mvy5gidW9IE3IaspHmrAlkeIAwRlHEBLWchZ8s9J0pWqvKP6lyIo9iqB4xyUkffgEWNAsmuwcd03QEPyVBCEoK6AmK48SMI43yD4qtXF27jBovN7G3hmhcSFOpIpp5okZePhYaGgVm11BWXjT9VG01FhzalP9Huy9HhWtQsL3pG752dF78dUvGNKc1qlhoFXvxiLp2WEYoHPb1Zc2bHtiBKVh4tDbz1OANPVQRahx9qzZ21sT6rRvoNn3qAFb8jgiY9f546EAHoqxcynlP0PIZhMFvjcATmtT4F2dwz7WdThjKeZZiat3iFfjnRhOnJmnH60EHKzfgPzy4sxUO8JhaGxKL8l2PdFxYkGntq2Js86OuICesq8VS3og8QLUSGnPvQxqMUd0uEKr5FKrvV1eTqmr7NglArkFpr6TZEM3zckFWfNBRJS11jc0yj49ZgSXezOXtiwXwBPhfAz45G2OPdlcgyqWLDNMEcVghJH0Q6tZTs0AklMdy6hdmR16RKXUDatbzv2R4bEzeevBqOn4gVnebJ4bgfQ9pvDE98iO9gTIi3cqXtEjqKO37C2S3c74lRjQTcGSoqVjKVHav5JzKg7ZPKkC20KfYd4SJAmb7EFBEkLaRoCobEIrZago4egHqsZUrW0DG5")
        
        XCTAssertEqual(config?.AuthInfos[0].Name, "kubernetes-admin", "User name is correct")
        XCTAssertNotNil(config?.AuthInfos[0].User.ClientCertificateData)
        XCTAssertNotNil(config?.AuthInfos[0].User.ClientKeyData)
        XCTAssertEqual(config?.AuthInfos[0].User.ClientCertificateData, "0MoYfMAzvgGMazIj6AuVCektwhXm5Su2AvKGp2iDswrYX9d2LgLj9XsbR07O3eDzTeNrHJWMndwktcXLC1TWfHPtJHo8CaVZDWFceoF0DPkoCnCNororcAOpyp0Z2ymnhHkMvGeWdDnyxSiB3JOiu2BNqVcPWeSoyymwiWzaD2lyquk3au9wC34O3sv1L6sj50KKOnSje8Ja1J55TJNH9bdglFpoFJniFxQE74AkWpe9npq3n9KoGrO35DKEMkkTJrjpSrP2YPO62bgLa3dn7BkoqwE16AGDKEghVqoZluWGhQqajio4LAQqjcqxioqwzI8KhOKNMQf8wsfNF4o0ecJIC1u6KuhlgqUnL43OEzqduCciG7ftKpHw0bBJjo5tyiImv26SrJaJGrMtX774BGTbjUlU2TFAvB6y6FXpKmF7S2uVZWwcjqddzwUUDRbQ8TbSxhiWklyc8wxiGkssipxlcvdQK6TKUKPi7xpgdR5kTB8gKSA3YrAhJwJJpfF1xXrZ5bKvDtmI8bvXHbpzAVVlhmgvxm5hkeFL6amrvK1WqTezibpm3NJ46ECMnLfcwObo1o2gUWw2d7gIzkvaSMqD6A2KuUnESgkdL5zZ2Z3Y38KULKuF5hsEna9ugcrM7MwEznr8zIs7zUgGiDZawzxqILZa4fymi2RSqWbD3jagSGeymcDCNx8P26XITN4ld4WPiGtBzJMIFgQrK8HEOJCeeww7fKfz9XH7DpCiBoKS5CsKqX4GBqjQbAd30Sn7JGX7px2rCWdcoV2ZPs6czIuR5imOfNWN1zi6dzZkxsgwF13xIlWf7lhC2toszRsUziYtihCPqjcsNmAPYgPsX8so5tnHXvoiDqB4WrumwyWjfsYtb5obOWEnv1CySfSrfpAWD7RNuwrKuKaeInGY2Gd1Blt7AzNmon4fwKF1WswTQrSIVDBCzJVdF34gEzurNIkQ7OOjmoENgbcIr8u1QBGxKLpszk2rNaCR4nKGzeEFExXWRG5YGMilVVUBx5wlYKIjk8W7NBO2Q9929afyaJMaQgUOIqF1ibDGxnPlziX5tS3oVIP8glmL1muSeeazh3BYcURiHqdw1BjKgEkver9zlQDrxgOGlY6wLArGo76KQb9HJFw2xHIHqYUls58A7PQR68KCoJqRMx4jNOf3Cz0DKRu6q9DGgGeGBZmtRJcssnOegAJ1KrCLkUAM90gj8orfX6lYFH6LsvRXQoRhCXMXyCrEel8PWdGOfImgiQiFtATCeWpq1YUW6cgmKwykSIicAYH2WuWbuOb5Woq7hewFIRmPSCnNDWReEZslKWsrZFoHXtTmiKRoV0M5JOgDH9lnulJuu4TGugKAmqRge6S7xFeqpmRwfYtuiIe9bQudlUhpkzFzkaT36vZdEkE7fIVo7qEwgnuPBphmJFKjrMl1vn9X1pkc3aWjH6Ra1vVzbdr3TVZeErNHlLb9gfq4qPepJnjMLfc2owYNzoaA")
        XCTAssertEqual(config?.AuthInfos[0].User.ClientKeyData, "dCn9CnH4TyVb0PrLImm3oHJE0651cHyBQIXkFozEKxuueEjRI2yziaxHgoCnTW4Omkif10G6x4NlXap41nevYdrE7DR0ugXIEWhdJAoi64pm0QGLs9qwBFEqV1Vkptlw18JA6sfzy0anDKouwRMrlGrlqSUB9vWryBQc5utrVGBaUsBJWiEUmGmAe7GcfNGZIq7WylRqACRndK2QXDvoyMnZ3NSHfuYUp854iTOQejfebuaUkYIUetABf4Whsx99Jvgymo7o6vyCaTlU8k5Jj8OIYIrPKf1yV0PF9Uhad6Qp3KnvLooeE9weVVb8YlTAi9i6u7o96OxKau5tLMlq28pzEl3EPaKPsafOlfKhLH7P9wkTrazlYMzQki25MxSlxfAFYiuTVSYZ3lKVeyJBj9kAqXz5jBrPaYCX3AnhHkVSap9iZCv5EIaAbcgN9YrB5aI0ColtnhsZL5wi1eX34gLtMQ7TtKZF7DtZRvATGZbLnyEY7R1gdZJqD78AggjXP5FmKsD3SVdBI4NSanYhsGJ6c3QYzzFQFDs6II5B8Jy1taB13JwiLE4XNjomf75ZJUlE4noaQYdtiJR6QC5fBz7qiHCB5janiQgRVAsaOyo39V2aBihCAcZohFKWCMhEuL4nYiWzQdZ9G2TODLzWwysbcPsMcZ4y0yBZgkihXYHdnJovoYimgCPQTHAOIn1386UQ0ITRU3CHpJhPxRKRmgmF0xkWWy4f181bozWPIgbxzsEyw9nrp0dIEtD8hBkssIEHzex0ENu8QYnKF5JGKzcB8SdKvMw4bXOW8ZdE5Ag4e8UTz6zXnS8FiCrGPleqGeGUTaA0JdOr1g0xLPGgLGMR0pO1beSDVKz0LNR4YLP7a7bWtJRQytnjuPFkGq7aNroxCAzwDGdNLT3CU0teFUtYZ8aP0OCjZrI9whgT85CehOXwWcphZMKh9cFpHMdeJYDUecfWPW8IGbizWU10pLvrO9lKhi7gcnmTn6AeC0Ikygh6VtBUCvQ5OrAhiGxUSFEZQ0LFCri4zD08rBSn2ATmusxYv3PhbGJ1ynrLqSyD2UHHOIXw1erzHl3BIQ50lUv5T4zfz7gPOgZ7WyOcwiCSPHhbAf4D1aztHcYkOMiCwF2q09xkrkVkSc5ymVfnPfsmF90wMCsLDqbYfWQzj9yGBQTuSPdWJff59BkRvQV26tJvC3mT1fVAhstxS0UbkSU3ytg9w0iAoV9bM6nf1kMi09uU3IcWUSY5ixVS9SiHhOoEwKqcDb0AzDkw5CMeho50PD5qs4FnNFJFMmaSctdmWtSZTIBtEXX1y21c4bocWzbIqHp29aSBGeDuHF4GadVQaXeG3iWbjQj3dF56gYxz309tAc1FYRscan7omklCaUbZulfM1UlfYxY3PLzeSOD0pvaOUFlKtSJsJ8yYdz8h1rvqPflyKQJ6B4UHzrG9VhI47cOSNDcHgsayvXwsJzhoUj0J5iwnBYdlzm36")
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testKubernetesImportConfig() {
        var config: Config?
        do {
            try k8s?.importConfig(configToImportFileUrl: url)
        } catch {
            XCTFail()
        }
        
        do {
            config = try k8s?.getConfig()
        } catch {
            XCTFail()
        }
        
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.Contexts.count, 2, "There are two contexts")
        
        XCTAssertNil(config?.Contexts[0].Context.Namespace)
        
        XCTAssertEqual(config?.Clusters.count, 2, "There are two clusters")
        XCTAssertEqual(config?.AuthInfos.count, 2, "There is two users")
        
        XCTAssertEqual(config?.CurrentContext, "kubernetes-admin@kubernetes", "Current context is correct")
    }
}

class KubeContextLoadTwoContextTests: XCTestCase {
    let fileManager = FileManager.default
    
    var k8s: Kubernetes?
    var bundle: Bundle!
    var url: URL!
    
    override func setUp() {
        bundle = Bundle(for: type(of: self))
        var tempDataUrl: URL?
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            tempDataUrl = documentDirectory.appendingPathComponent("TempData")
            try fileManager.removeItem(at: tempDataUrl!)
            let testDataPath = bundle.resourcePath! + "/TestData"
            try fileManager.copyItem(atPath: testDataPath, toPath: tempDataUrl!.path)
        } catch {
            XCTFail()
        }
        
        url = tempDataUrl!.appendingPathComponent("config-with-two-contexts.yaml")
        k8s = Kubernetes()
        XCTAssertNoThrow(try k8s?.setKubeconfig(configFile: url))
        XCTAssertNotNil(k8s)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testKubernetesLoadConfig() {
        var config: Config?
        do {
            config = try k8s?.getConfig()
        } catch {
            XCTFail()
        }
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.Contexts.count, 2, "There is two contexts")
        XCTAssertEqual(config?.Contexts[0].Name, "kubernetes-admin@kubernetes", "Name of the context is correct")
        XCTAssertEqual(config?.Contexts[0].Context.Cluster, "kubernetes", "Cluster of the context is correct")
        XCTAssertEqual(config?.Contexts[0].Context.AuthInfo, "kubernetes-admin", "User of the context is correct")
        XCTAssertNil(config?.Contexts[0].Context.Namespace)
        
        XCTAssertEqual(config?.Clusters.count, 2, "There are two clusters")
        XCTAssertEqual(config?.AuthInfos.count, 2, "There are two users")
    }
    
    func testKubernetesChangeUsedContext() {
        do {
            try k8s?.useContext(name: "other-context")
        } catch {
            XCTFail()
        }
        var config: Config?
        do {
            config = try k8s?.getConfig()
        } catch {
            XCTFail()
        }
        XCTAssertEqual(config?.CurrentContext, "other-context", "Current context is correct")
        
    }
}
