// swift-tools-version: 5.10.1
import PackageDescription
    let package = Package(
        name: "CMPlayer",        
        defaultLocalization: "en",        
        products: [
            .executable(name: "cmplayer", targets: ["CMPlayer"])
        ],    
        dependencies: [
            
        ],
        targets: [            
            .executableTarget(
                name: "CMPlayer",
                dependencies: [                        
                    //"Cmpg123",
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
        ]        
    )
