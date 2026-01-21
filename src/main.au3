#cs
    Merhaba AutoIT Projesi
    Temel bir AutoIT script örneği
#ce

; Program başlamıyor mesajı
MsgBox(0, "Hoş Geldiniz", "AutoIT Projesi başarıyla başladı!")

; Basit bir döngü örneği
For $i = 1 To 3
    MsgBox(0, "Bilgi", "Merhaba! Bu " & $i & ". mesajdır.")
Next

; Program sonu
MsgBox(0, "Sonlandırma", "Program bitti!")
Exit
