// swift-tools-version: 5.10.1
import PackageDescription
    let package = Package(
        name: "CMPlayer",        
        defaultLocalization: "en",        
        products: [
            .executable(name: "cmplayer", targets: ["CMPlayer"]),
            .executable(name: "cmpshim", targets: ["CMPShim"])
        ],    
        dependencies: [
            
        ],
        targets: [            
            .executableTarget(
                name: "CMPlayer",
                dependencies: [                        
                    
                ],
                cSettings: [
                    .define("CMP_PLATFORM_ARM64"),
                    .define("CMP_TARGET_MACOS_V27")
                ],
                swiftSettings: [
                    .define("CMP_PLATFORM_ARM64"),
                    .define("CMP_TARGET_MACOS_V27")
                ]
            ),
            .executableTarget(
                name: "CMPShim",
                dependencies: [                        
                
                ],
                cSettings: [
                    
                ],
                swiftSettings: [
                    
                ]
            ),
        ]        
    )
