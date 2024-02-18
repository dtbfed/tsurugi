#Include %A_LineFile%\..\JSON.ahk

#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
#HotKeyInterval 1
#MaxHotkeysPerInterval 127
SetKeyDelay, -1, -1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay, -1
SendMode, InputThenPlay
SetBatchLines, -1
ListLines, Off
CoordMode, Pixel, screen
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High
DllCall("QueryPerformanceFrequency", "Int64*", Update)
AimbotKey := config.Tsurugi.Binds.Keybind

; aimbot

;SoundPlay, C:\Users\blynq\Downloads\loooolwtf.mp3
MsgBox, Tsurugi - Authorized & Loaded


yes := true

if (yes)
{

    configuration := A_LineFile . "\..\settings.json"
    if (FileExist(configuration)) {
        File := FileOpen(configuration, "r")
        configData := File.Read()
        File.Close()
        config := JSON.Load(configData)
    } else {
        MsgBox, Tsurugi - Failed to locate configuration file, Make sure settings.json is placed in the same directory, Exiting.
        ExitApp
    }


    KANKAN := "https://www.youtube.com/watch?v=8c6AJMIm310"

    if (config.Tsurugi.Misc.KANKAN)
    {
        ;Run, %KANKAN%
    }

    
    AimbotKey := config.Tsurugi.Binds.Keybind
    PauseKey := config.Tsurugi.Binds.Pause
    Saturation := config.Tsurugi.Color.Saturation ; 15-30 for hood games
    LinearCurveX := config.Tsurugi.Bezier.LinearCurveX
    LinearCurveY := config.Tsurugi.Bezier.LinearCurveY
    CameraToGunFOV := config.Tsurugi.Misc.CameraToGunFOV
    AimbotUpdateTick := config.Tsurugi.Misc.AimbotUpdateTick
    SmoothnessX := config.Tsurugi.Easing.SmoothnessX / LinearCurveX
    SmoothnessY := config.Tsurugi.Easing.SmoothnessY / LinearCurveY
    SmoothingReplicatorX := config.Tsurugi.Easing.SmoothingReplicatorX
    SmoothingReplicatorY := config.Tsurugi.Easing.SmoothingReplicatorY
    SmoothingDividerX := config.Tsurugi.Easing.SmoothingDividerX
    SmoothingDividerY := config.Tsurugi.Easing.SmoothingDividerY
    FOVOffsetX := config.Tsurugi.FOV.FOVOffsetX
    FOVOffsetY := config.Tsurugi.FOV.FOVOffsetY
    FlickTime := config.Tsurugi.Misc.FlickTime    
    AimbotMS := config.Tsurugi.Misc.AimbotUpdateMS
    Prediction := config.Tsurugi.Easing.Prediction.Enabled
    PredictionMode := config.Tsurugi.Easing.Prediction.Mode
    PredictionX := config.Tsurugi.Easing.Prediction.PredictionX
    PredictionY := config.Tsurugi.Easing.Prediction.PredictionY
    Random, PredictionX, -500, 500
    Random, PredictionY, -500, 500    
    FallbackPixelX := 0
    FallbackPixelY := 0
    ModelPixels := [0xFDFDFC]
    CameraPositionX := A_ScreenWidth
    CameraPositionY := A_ScreenHeight
    WorldToScreenDivider := 2
    ScreenSizeX := Floor(CameraPositionX // WorldToScreenDivider) - FallbackPixelX
    ScreenSizeY := Floor(CameraPositionY // WorldToScreenDivider) - FallbackPixelY
    FOVOffsetX := fallback(FOVOffsetX, CameraToGunFOV, CameraPositionX, CameraPositionY)
    FOVOffsetY := fallback(FOVOffsetY, CameraToGunFOV, CameraPositionX, CameraPositionY)
    CameraPositionA := ScreenSizeX - FOVOffsetX
    CameraPositionB := ScreenSizeY - FOVOffsetY
    CameraPositionC := ScreenSizeX + FOVOffsetX
    CameraPositionD := ScreenSizeY + FOVOffsetY
    Paused := false
    LastPosition := [0, 0]

    Loop {
        KeyWait, %AimbotKey%, D
        Position := ModelSearch(CameraPositionA, CameraPositionB, CameraPositionC, CameraPositionD, ModelPixels, Saturation)
        
        if (!ErrorLevel) {
            Start := Position[1]
            End := Position[5]
            PredictionX := 0.12
            PredictionY := 0.12
            LookAtX := Position[1] - ScreenSizeX
            LookAtY := Position[5] - ScreenSizeY
            EndpointX :=
            EndpointY :=

            if (Prediction)
            {
                if (PredictionMode == "Ideal")
                {
                    EndpointX := Floor(coordinatemode(LookAtX + PredictionX, CameraToGunFOV, A_ScreenWidth, A_ScreenHeight) * (SmoothnessX/SmoothingDividerX) * SmoothingReplicatorX)
                    EndpointY := Floor(coordinatemode(LookAtY + PredictionY, CameraToGunFOV, A_ScreenWidth, A_ScreenHeight) * (SmoothnessY/SmoothingDividerY) * SmoothingReplicatorY)
                }

                if (PredictionMode == "Multiplication")
                {
                    EndpointX := Floor(coordinatemode((LookAtX * PredictionX), CameraToGunFOV, A_ScreenWidth, A_ScreenHeight) * (SmoothnessX/SmoothingDividerX) * SmoothingReplicatorX)
                    EndpointY := Floor(coordinatemode((LookAtY * PredictionY), CameraToGunFOV, A_ScreenWidth, A_ScreenHeight) * (SmoothnessY/SmoothingDividerY) * SmoothingReplicatorY)
                }
            }
            else
            {
                EndpointX := Floor(coordinatemode( LookAtX, CameraToGunFOV, A_ScreenWidth, A_ScreenHeight ) * ( SmoothnessX/SmoothingDividerX ) * SmoothingReplicatorX )
                EndpointY := Floor(coordinatemode( LookAtY, CameraToGunFOV, A_ScreenWidth, A_ScreenHeight ) * ( SmoothnessY/SmoothingDividerY ) * SmoothingReplicatorY )
            }


            DllCall("QueryPerformanceCounter", "Int64*", DeltaTime)
    
            if ((DeltaTime - FlickTime) / Update * AimbotMS >= 1000 / AimbotUpdateTick) {
                DllCall("QueryPerformanceCounter", "Int64*", FlickTime)
                DllCall("mouse_event", "uint", 0x0001, "uint", EndpointX, "uint", EndpointY, "uint", 0, "int", 0)
            }
        }
    }
    
    ModelSearch(X1, Y1, X2, Y2, ColorIDs, Variation) {
        PixelSearch, OutputVarX, OutputVarY, X1, Y1, X2, Y2, ColorIDs, Variation, Fast RGB
        Return [OutputVarX, OutputVarY]
    }

    degreetoradians(degrees) {
        return degrees * ((4 * ATan(1)) / 180)
    }

    radianstodegrees(radians) {
        return radians * (180 / (4 * ATan(1)))
    }

    coordinatemode(delta, fov, winWidth, winHeight) {
        return radianstodegrees(atan(((delta << 1) / winWidth) * tan(degreetoradians(fov * 0.5))))
    }

    fallback(delta, fov, winWidth, winHeight) {
        return winWidth * 0.5 / tan(degreetoradians(fov * 0.5)) * tan(degreetoradians(delta))
    }

    screenEncryption(fov, winWidth, winHeight) {
        aspectRatio := (winWidth / winHeight) / (4 / 3)
        return 2 * radianstodegrees(atan(tan(degreetoradians(fov * 0.5)) * aspectRatio))
    }
}

Alt::
Pause
Paused := !Paused
if (!Paused) {
    Msgbox, Tsurugi - Paused (Alt)
}
Return