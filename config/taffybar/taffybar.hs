import System.Taffybar
import System.Taffybar.SimpleClock
import System.Taffybar.Systray
import System.Taffybar.XMonadLog

main = do
    let log   = xmonadLogNew
        tray  = systrayNew
        clock = textClockNew Nothing "<span color='white'>%l:%M %p</span>  " 1

    defaultTaffybar defaultTaffybarConfig
        { startWidgets = [ log ]
        , endWidgets   = [ clock, tray ] }
