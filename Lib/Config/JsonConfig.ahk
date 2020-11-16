class JsonConfig extends FileConfig {
    config := {}
    primaryConfigKey := "Config"

    __New(app, configPath := "", autoLoad := true) {
        base.__New(app, configPath, ".json", autoLoad)
    }

    LoadConfig() {
        if (this.ConfigPath == "") {
            MsgBox, Config file path not provided.
            return this
        }

        FileRead, jsonString, % this.ConfigPath

        if (jsonString != "") {
            this.config := JSON.Load(jsonString)
        } else {
            this.config := {}
        }

        return this
    }

    SaveConfig() {
        if (this.ConfigPath == "") {
            this.AskForPath()
        }

        if (this.ConfigPath == "") {
            MsgBox, Config file path not provided.
            return this
        }

        FileDelete, % this.ConfigPath
        jsonString := JSON.Dump(this.config, "", 4)
        FileAppend, %jsonString%, % this.ConfigPath

        return this
    }
}
