//
//  CommandLineHelpers.swift
//
//  (i): Helper methods to CommandLineHandler.swift.
//
//  Created by Kjetil Kr Solberg on 24-09-2024.
//  Copyright © 2024 Kjetil Kr Solberg. All rights reserved.
//
//
// import
//
import Foundation

///
/// Prints information about output devices.
/// 
func PrintAndExecuteOutputDevices() {  
    // print header      
    //print("Audio Output (ao):")
    // print information about ao
    //printAoInfo()    
    // print new line
    print("")
    // print header
    //print("ALSA:")
    // print information about alsa
    //printALSAInfo()        
}
///
/// Prints some info about cmplayer's home directory and its files.
/// 
func PrintAndExecutePlayerHomeDirectory() {
    // print header
    print("Player Home:")
    // set path to applications home directory
    let path = PlayerDirectories.consoleMusicPlayerDirectory
    // if path exists
    if FileManager.default.fileExists(atPath: path.path) {
        // print message we found directory
        print(" > (i): Found at:  \(path.path)")
        // create constant that set path to library file
        let pathLibrary = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerLibrary.filename, isDirectory: false)
        // if pathLibrary exists
        if FileManager.default.fileExists(atPath: pathLibrary.path) {
            // print found message
            print(" > \(PlayerLibrary.filename.convertStringToLengthPaddedString(20, .left, " ")) found")
        }
        // else pathLibrary did not exist
        else {
            // print not found message
            print(" > \(PlayerLibrary.filename.convertStringToLengthPaddedString(20, .left, " ")) NOT found")
        }
        // create constant that set path to log file
        let pathLog = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerLog.filename, isDirectory: false)
        // if pathLog exists
        if FileManager.default.fileExists(atPath: pathLog.path) {
            // print found message
            print(" > \(PlayerLog.filename.convertStringToLengthPaddedString(20, .left, " ")) found")
        }
        // else pathLog did not exist
        else {
            // print not found message
            print(" > \(PlayerLog.filename.convertStringToLengthPaddedString(20, .left, " ")) NOT found")
        }
        // create constant that set path to preferences file
        let pathPref = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerPreferences.filename, isDirectory: false)
        // if pathPref exists
        if FileManager.default.fileExists(atPath: pathPref.path) {
            // print found message
            print(" > \(PlayerPreferences.filename.convertStringToLengthPaddedString(20, .left, " ")) found")
        }
        // else pathPref did not exist
        else {
            // print not found message
            print(" > \(PlayerPreferences.filename.convertStringToLengthPaddedString(20, .left, " ")) NOT found")
        }
        // create constant that set path to history file
        let pathHistory = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerCommandHistory.filename, isDirectory: false)
        // if pathHistory exists
        if FileManager.default.fileExists(atPath: pathHistory.path) {
            // print found message
            print(" > \(PlayerCommandHistory.filename.convertStringToLengthPaddedString(20, .left, " ")) found")
        }
        // else pathHistory did not exist
        else {
            // print not found message
            print(" > \(PlayerCommandHistory.filename.convertStringToLengthPaddedString(20, .left, " ")) NOT found")
        }
        // create constant that set path to history file
        let pathAutoexec = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent("autoexec", isDirectory: false)
        // if pathHistory exists
        if FileManager.default.fileExists(atPath: pathAutoexec.path) {
            // print found message
            print(" > \("autoexec".convertStringToLengthPaddedString(20, .left, " ")) found")
        }
        // else pathHistory did not exist
        else {
            // print not found message
            print(" > \("autoexec".convertStringToLengthPaddedString(20, .left, " ")) NOT found")
        }
    }
    // path did not exists
    else {
        // print error message
        print(" > (e): Did not find player home at: \(path.path)")
    }        
}
///
/// Prints some statistics about player library.
/// 
func PrintAndExecutePlayerLibrary() {
    // print header
    print("Player Library:")    
    do {        
        // create constant set to library file
        let fileUrl: URL = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerLibrary.filename, isDirectory: false)
        // if fileUrl exists
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            // create constant lib set to a new PlayerLibrary()
            let lib: PlayerLibrary = PlayerLibrary()
            // try to load library
            try lib.load()  
            // set g_songs to lib.library
            g_songs = lib.library      
            // rebuild global structures form library so we can get some statistics
            lib.rebuild()
            // print number of entries in library
            print(" > Number of valid entries              \(lib.library.count)")    
            // print number of distinct artist in library
            print(" > Number of distinct artists           \(g_artists.count)") 
            // print number of distinct genres in library
            print(" > Number of distinct genres            \(g_genres.count)")    
            // print number of distinct recording years in library
            print(" > Number of distinct recording years   \(g_recordingYears.count)")                
        }
        // else fileUrl did not exist
        else {
            // print error message
            print(" > (e): Could not find library.")    
        }
    }
    // catch known errors
    catch let error as CmpError {
        // print error message
        print(" > (e): Could not load library. Message: '\(error.message)'")
    }
    // catch unknown errors
    catch {
        // print error message
        print(" > (e): Unknown error. Could not load library. Message: '\(error)'")
    }    
}
///
/// Prints some info on cmplayers preferences if file exists.
/// 
func PrintAndExecutePlayerPreferences()
{
    // print header
    print("Player Preferences:")        
    // create constant set to path of preferences file
    let path: URL = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerPreferences.filename, isDirectory: false)
    // if path exists
    if FileManager.default.fileExists(atPath: path.path) {
        // preferences should have been loaded before this function was called
        // print music root path header
        print(" > musicRootPath:")
        // loop through preferences' music root paths
        for rp in PlayerPreferences.musicRootPath {
            // print the root path
            print("   > \(rp)")
        }
        // print exclusion paths header
        print(" > exclusionPaths:")
        // loop through preferences' exclusion paths
        for ep in PlayerPreferences.exclusionPaths {
            // print the exclusion path
            print("   > \(ep)")
        }
        // print out misc. preferences
        print(" > musicFormats             \(PlayerPreferences.musicFormats)")            
        print(" > autoplayOnStartup        \(PlayerPreferences.autoplayOnStartup)")
        print(" > crossfadeSongs           \(PlayerPreferences.crossfadeSongs)")
        print(" > crossfadeTimeInSeconds   \(PlayerPreferences.crossfadeTimeInSeconds)")
        print(" > viewType                 \(PlayerPreferences.viewType.rawValue)" )
        print(" > colorTheme               \(PlayerPreferences.colorTheme.rawValue)")
        print(" > outputSoundLibrary       \(PlayerPreferences.outputSoundLibrary.rawValue)")
        print(" > logMaxEntries            \(PlayerPreferences.logMaxEntries)")
        print(" > historyMaxEntries        \(PlayerPreferences.historyMaxEntries)")
        print(" > logInformation           \(PlayerPreferences.logInformation)")
        print(" > logWarning               \(PlayerPreferences.logWarning)")
        print(" > logError                 \(PlayerPreferences.logError)")
        print(" > logDebug                 \(PlayerPreferences.logDebug)")
        print(" > logOther                 \(PlayerPreferences.logOther)")            
    }
    // else path did not exist
    else {
        // print error message
        print(" > (e): Could not find preferences.")    
    }
}
///
/// Attempts to find .so library files under /usr.
/// Prints out result.
/// 
func PrintAndExecuteLibraryFiles() {    
    // create constant array of shared object files this application depends on
    let files: [String] = ["libao.so",
                           "libasound.so",
                           "libavcodec.so",
                           "libavformat.so",
                           "libavutil.so",
                           "libmpg123.so"]
    // create a constant array of directories from where to search for files
    let directories: [String] = ["/usr"]
    // print header
    print("Libraries (.so):")
    // loop through all files in files
    for i: Int in 0..<files.count {
        // create constant for current filename
        let fileName = files[i]
        // resultant directory if file is found
        var dir: String = ""
        // create a flag variable, if file is found
        var bFound: Bool = false
        // loop through all directories in directories
        for j: Int in 0..<directories.count {
            // create constant current directory
            let directory: String = directories[j]
            // is directory a directory
            var isDirectory: ObjCBool = false
            // create a constant if directory exists
            let exists = FileManager.default.fileExists(atPath: directory, isDirectory: &isDirectory)
            // if directory exists and it is a directory
            if exists && isDirectory.boolValue {
                // if create constant fileURL a valid url
                if let fileURL: URL = findFile(named: fileName, under: URL(fileURLWithPath: directory)) {
                    // set dir to fileURL path (excluding filename)
                    dir = fileURL.deletingLastPathComponent().path
                    // set bFound flag to true
                    bFound = true
                    // break loop
                    break
                }            
            }
        }
        // if file is found
        if bFound {
            // print found message
            print(" > \(fileName.convertStringToLengthPaddedString(18, .left," ")) found at: \(dir)")
        }
        // else file was not found
        else {
            // print not found message
            print(" > \(fileName.convertStringToLengthPaddedString(18, .left," ")) NOT found!")
        }
    }    
}
/// 
/// finds a file. URL if found, nil otherwise.
/// 
func findFile(named fileName: String, under directory: URL) -> URL? {
    // get default file manager
    let fileManager = FileManager.default
    // create a recursive enumerator to go through all directories and files
    let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil)
    // iterate through the enumerator
    while let fileURL = enumerator?.nextObject() as? URL {
        // if file found is file target
        if fileURL.lastPathComponent == fileName {
            // return file url
            return fileURL
        }
    }
    // file not found
    // return nil
    return nil
}
