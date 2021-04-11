class ErrorDialog extends DialogBox {
    displaySubmissionForm := true
    errorObj := ""
    notifierObj := ""
    apiEndpoint := ""
    submitError := false
    formShown := false
    formH := 0
    guiH := 0

    __New(app, themeObj, windowKey, errorObj, title, text := "", owner := "", parent := "", btns := "*&Continue|&Reload|&Exit") {
        this.errorObj := errorObj
        this.notifierObj := app.Notifications.notifierObj

        if (app.HasProp("DataSources")) {
            this.apiEndpoint := app.DataSources.GetItem("api")
        }

        this.formShown := this.submitError
        
        super.__New(app, themeObj, windowKey, title, text, owner, parent, btns)
    }

    Controls() {
        super.Controls()
        ctl := this.Add("BasicControl", "vSubmitError", "", this.submitError, "CheckBox", "Submit error to Volantis Development")
        ctl.ctl.OnEvent("Click", "OnSubmitError")

        ctl := this.guiObj.AddText("w" . this.windowSettings["contentWidth"] . " +0x200 +0x100 vDetailsDesc", "Add as much detail as possible about what you were trying to do:")
        ctl := this.AddEdit("ErrorDetails", "", "r4")
        ctl := this.guiObj.AddText("w" . this.windowSettings["contentWidth"] . " +0x200 +0x100 vEmailDesc", "Enter your email address if you would like to be contacted:")
        ctl := this.AddEdit("Email", "", "")
    }

    GetFormHeight() {
        if (!this.guiH) {
            this.guiObj.GetPos(,,, guiH)
            this.guiH := guiH
        }

        if (!this.formH) {
            formH := 0

            this.guiObj["DetailsDesc"].GetPos(,,, ctlH)
            formH += ctlH + this.margin
            this.guiObj["ErrorDetails"].GetPos(,,, ctlH)
            formH += ctlH + this.margin
            this.guiObj["EmailDesc"].GetPos(,,, ctlH)
            formH += ctlH + this.margin
            this.guiObj["Email"].GetPos(,,, ctlH)
            formH += ctlH + this.margin

            this.formH := formH
        }
        
        return this.formH
    }

    ToggleForm(showForm := true, ignoreCurrentState := false) {
        if (this.formShown != showForm || ignoreCurrentState) {
            formH := this.GetFormHeight()

            this.guiObj["DetailsDesc"].Visible := showForm
            this.guiObj["ErrorDetails"].Visible := showForm
            this.guiObj["EmailDesc"].Visible := showForm
            this.guiObj["Email"].Visible := showForm

            if (showForm) {
                this.guiH += formH
            } else {
                this.guiH -= formH
            }

            this.guiObj.Move(,,, this.guiH)
            this.formShown := showForm
        }
    }

    OnShow(windowState := "") {
        super.OnShow(windowState)

        if (!this.formShown) {
            this.ToggleForm(false, true)
        }
    }

    OnSubmitError(ctl, info) {
        this.Submit(false)
        this.ToggleForm(ctl.Value)
    }

    ProcessResult(result, submittedData := "") {
        if (this.guiObj["SubmitError"].Value) {
            this.SendError()
        }

        if (result == "Exit") {
            this.app.ExitApp()
        }

        if (result == "Reload") {
            this.app.RestartApp()
        }

        return super.ProcessResult(result, submittedData)
    }

    SendError() {
        global appVersion

        if (this.apiEndpoint) {
            endpoint := this.apiEndpoint.endpointUrl . "/submit-error"

            body := Map()
            body["message"] := this.errorObj.Message
            body["what"] := this.errorObj.What
            body["file"] := this.errorObj.File
            body["line"] := this.errorObj.Line
            body["extra"] := this.errorObj.HasProp("Extra") ? this.errorObj.Extra : ""
            body["stack"] := this.errorObj.HasProp("Stack") ? this.errorObj.Stack : ""
            body["email"] := this.guiObj["Email"].Text
            body["version"] := appVersion ? appVersion : ""
            body["details"] := this.guiObj["ErrorDetails"].Text

            request := WinHttpReq.new(endpoint)
            response := request.Send("POST", body)
            success := !!(response == -1 && request.GetStatusCode() == 200)

            notification := success ? "Successfully sent error to Volantis Development" : "Failed to send error to Volantis Development"
            this.notifierObj.Notify(notification, "Error Sent", success ? "info" : "error")
        }
    }
}
