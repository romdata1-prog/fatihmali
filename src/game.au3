#cs
    Aktif Pencereye Waypoint Sistemi
    Orta Tuş: Waypoint ekle
    WASD: Mouse'u hareket ettir
    F7: Kaydı başla
    F8: Kaydı durdur
    P: Makroyu oynat (Playback)
    Esc: Çık
#ce

; Waypointler listesi
Global $waypoints[0][2]  ; Dinamik dizi

; Hareket kaydı
Global $movements[0][4]  ; [Tür, X/Tuş, Y, Zaman]
; Tür: 0=Mouse, 1=Klavye
Global $isRecording = False
Global $recordStart = 0
Global $mouseSpeed = 10
Global $prevKeys[4] = [0, 0, 0, 0]  ; W, A, S, D önceki durumları

; Bilgi göster
MsgBox(0, "Waypoint & Makro Sistemi", "Hazır!~" & @CRLF & @CRLF & _
    "Orta Tuş: Waypoint ekle~" & @CRLF & _
    "WASD: Mouse'u hareket ettir~" & @CRLF & _
    "F7: Kaydı başla~" & @CRLF & _
    "F8: Kaydı durdur~" & @CRLF & _
    "F9: Makroyu oynat~" & @CRLF & _
    "Esc: Çık")

; Ana döngü
While True
    ; Tüm tuşları kontrol et
    If _IsPressed("1B") Then ExitLoop  ; Esc - Çık
    
    ; F7 tuşu - Kaydı başla
    If _IsPressed("76") Then
        If Not $isRecording Then
            _StartRecording()
        EndIf
        Sleep(300)
    EndIf
    
    ; F8 tuşu - Kaydı durdur
    If _IsPressed("77") Then
        If $isRecording Then
            _StopRecording()
        EndIf
        Sleep(300)
    EndIf
    
    ; F9 tuşu - Makroyu oynat
    If _IsPressed("78") Then
        _PlaybackMacro()
        Sleep(300)
    EndIf
    
    ; Orta Tuş - Waypoint ekle
    If _IsPressed("04") Then
        _AddWaypoint()
        Sleep(300)  ; Çift tıklamayı önle
    EndIf
    
    ; WASD - Mouse hareketi
    Local $mousePos = MouseGetPos()
    Local $moved = False
    
    Local $keys[4] = [0, 0, 0, 0]  ; W, A, S, D
    
    If _IsPressed("57") Then  ; W - Yukarı
        MouseMove($mousePos[0], $mousePos[1] - $mouseSpeed, 0)
        $moved = True
        $keys[0] = 1
    EndIf
    If _IsPressed("41") Then  ; A - Sola
        MouseMove($mousePos[0] - $mouseSpeed, $mousePos[1], 0)
        $moved = True
        $keys[1] = 1
    EndIf
    If _IsPressed("53") Then  ; S - Aşağı
        MouseMove($mousePos[0], $mousePos[1] + $mouseSpeed, 0)
        $moved = True
        $keys[2] = 1
    EndIf
    If _IsPressed("44") Then  ; D - Sağa
        MouseMove($mousePos[0] + $mouseSpeed, $mousePos[1], 0)
        $moved = True
        $keys[3] = 1
    EndIf
    
    ; Kaydı yapıyorsa hareketi kaydet
    If $isRecording Then
        ; Mouse hareketini kaydet
        If $moved Then
            _RecordMovement(0, $mousePos[0], $mousePos[1])
        EndIf
        
        ; Klavye tuşlarının durumunu kontrol et (basılma/bırakma)
        Local $keyNames[4] = [87, 65, 83, 68]  ; W, A, S, D ASCII kodları
        For $i = 0 To 3
            If $keys[$i] <> $prevKeys[$i] Then  ; Durum değiştiyse
                _RecordMovement(1, $keyNames[$i], 0)
                $prevKeys[$i] = $keys[$i]
            EndIf
        Next
    EndIf
    
    Sleep(30)
WEnd

MsgBox(0, "Bilgi", "Program sona erdi!~" & @CRLF & @CRLF & _
    "Toplam " & UBound($waypoints) & " waypoint~" & @CRLF & _
    "Toplam " & UBound($movements) & " hareket kaydedildi.")

; Tuş basılı mı kontrol
Func _IsPressed($key)
    Local $keyState = DllCall("user32.dll", "int", "GetAsyncKeyState", "int", "0x" & $key)
    Return BitAND($keyState[0], 0x8000) <> 0
EndFunc

; Waypoint ekle
Func _AddWaypoint()
    Local $mousePos = MouseGetPos()
    Local $newSize = UBound($waypoints) + 1
    
    ReDim $waypoints[$newSize][2]
    $waypoints[$newSize - 1][0] = $mousePos[0]
    $waypoints[$newSize - 1][1] = $mousePos[1]
    
    Local $count = UBound($waypoints)
    ToolTip("Waypoint #" & $count & " eklendi: [" & $mousePos[0] & ", " & $mousePos[1] & "]", $mousePos[0], $mousePos[1] - 30)
    Sleep(1000)
    ToolTip("")
    
    ConsoleWrite("Waypoint #" & $count & ": X=" & $mousePos[0] & " Y=" & $mousePos[1] & @CRLF)
EndFunc

; Kaydı başla
Func _StartRecording()
    $isRecording = True
    $recordStart = TimerInit()
    Local $size = UBound($movements)
    ReDim $movements[$size + 1][4]
    
    ToolTip("KAYIT BAŞLADI!", 10, 10)
    Sleep(500)
    ToolTip("")
    
    ConsoleWrite("=== KAYIT BAŞLADI ===" & @CRLF)
EndFunc

; Kaydı durdur
Func _StopRecording()
    $isRecording = False
    
    ToolTip("KAYIT DURDURULDU! (" & UBound($movements) & " hareket kaydedildi)", 10, 10)
    Sleep(1000)
    ToolTip("")
    
    ConsoleWrite("=== KAYIT DURDURULDU ===" & @CRLF & "Toplam hareket: " & UBound($movements) & @CRLF)
EndFunc

; Hareketi kaydet
Func _RecordMovement($type, $x, $y = 0)
    Local $currentTime = TimerDiff($recordStart)
    Local $size = UBound($movements)
    
    ; Son hareketinden sonra 50ms geçtiyse kaydet (çoğaltmayı önle)
    If $size > 0 Then
        Local $lastTime = $movements[$size - 1][3]
        If $currentTime - $lastTime < 50 Then Return
    EndIf
    
    ReDim $movements[$size + 1][4]
    $movements[$size][0] = $type     ; 0=Mouse, 1=Klavye
    $movements[$size][1] = $x        ; X pozisyonu veya Tuş kodu
    $movements[$size][2] = $y        ; Y pozisyonu
    $movements[$size][3] = $currentTime  ; Zaman
EndFunc

; Makroyu oynat
Func _PlaybackMacro()
    If UBound($movements) == 0 Then
        ToolTip("Kaydedilmiş hareket yok!", 10, 10)
        Sleep(1000)
        ToolTip("")
        Return
    EndIf
    
    ToolTip("MAKRO OYNATILIYOR...", 10, 10)
    Sleep(500)
    
    Local $startTime = TimerInit()
    Local $moveIndex = 0
    Local $totalMoves = UBound($movements)
    Local $keyStates[4] = [0, 0, 0, 0]  ; W, A, S, D basılı mı
    Local $keyNames[4] = [87, 65, 83, 68]  ; W, A, S, D
    
    While $moveIndex < $totalMoves
        Local $elapsedTime = TimerDiff($startTime)
        Local $targetTime = $movements[$moveIndex][3]
        
        ; Zaman aşımı kontrol et
        If $elapsedTime >= $targetTime Then
            Local $type = $movements[$moveIndex][0]
            
            If $type = 0 Then  ; Mouse hareketi
                Local $x = $movements[$moveIndex][1]
                Local $y = $movements[$moveIndex][2]
                MouseMove($x, $y, 0)
            ElseIf $type = 1 Then  ; Klavye hareketi
                Local $keyCode = $movements[$moveIndex][1]
                
                ; Tuş basılı mı bırakıldı mı kontrol et
                Local $keyIndex = -1
                For $i = 0 To 3
                    If $keyNames[$i] = $keyCode Then
                        $keyIndex = $i
                        ExitLoop
                    EndIf
                Next
                
                If $keyIndex >= 0 Then
                    ; Tuş durumunu değiştir
                    $keyStates[$keyIndex] = 1 - $keyStates[$keyIndex]
                    
                    ; Gerçek tuşu gönder
                    Local $keyChar = Chr($keyCode)
                    If $keyStates[$keyIndex] = 1 Then
                        ; Tuş basıldı - KeyDown
                        Send("{" & $keyChar & " down}")
                    Else
                        ; Tuş bırakıldı - KeyUp
                        Send("{" & $keyChar & " up}")
                    EndIf
                EndIf
            EndIf
            
            $moveIndex += 1
        EndIf
        
        ; ESC tuşu basılmışsa dur
        If _IsPressed("1B") Then
            ToolTip("MAKRO İPTAL EDİLDİ!", 10, 10)
            Sleep(500)
            ToolTip("")
            Return
        EndIf
        
        Sleep(10)
    WEnd
    
    ToolTip("MAKRO TAMAMLANDI! (" & $totalMoves & " hareket oynatıldı)", 10, 10)
    Sleep(1000)
    ToolTip("")
    
    ConsoleWrite("=== MAKRO TAMAMLANDI ===" & @CRLF)
EndFunc

