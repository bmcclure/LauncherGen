#Warn

appDir := RegExReplace(A_ScriptDir, "\\[^\\]+$")

GenerateIncludeFile(libDir) {
    file := libDir . "\Includes.ahk"

    if (FileExist(file)) {
        FileDelete(file)
    }
    
    FileAppend("; Automatically-generated file, do not edit manually.`n", file)

    Loop Files libDir . "\*.ahk", "R"
    {
        if (A_LoopFileFullPath != file) {
            FileAppend("#Include " . A_LoopFileFullPath . "`n", file)
        }
    }

    FileAppend("; End of auto-generated includes.`n", file)
}

Loop Files appDir . "\Lib\*", "D" {
    GenerateIncludeFile(A_LoopFileFullPath)
}
