-- Author: Zach Kelling
-- Source: https://github.com/zeekay/dot-files || https://bitbucket.org/zeekay/dot-files

import System.IO
import System.Exit
import XMonad
import XMonad.Config.Gnome
import XMonad.Util.Replace
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Layout.BoringWindows
import XMonad.Layout.BorderResize
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.DraggingVisualizer
import XMonad.Layout.Maximize
import XMonad.Layout.Minimize
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PositionStoreFloat
import qualified XMonad.Actions.FlexibleResize as Flex
import XMonad.Actions.GridSelect
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "terminator"
myBorderWidth   = 1
myModMask       = mod4Mask
myNumlockMask   = mod2Mask
myWorkspaces    = map show [1..9]
myFocusFollowsMouse = True
myNormalBorderColor  = "#7c7c7c"
myFocusedBorderColor = "#ffb6b0"

-- keybindings
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- launch a terminal
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- lock screen
    , ((modMask .|. controlMask, xK_l     ), spawn "xscreensaver-command -lock")

    -- launch dmenu
    , ((modMask,               xK_r     ), spawn "exec dmenu_run")

    -- GridSelect
    , ((modMask, xK_g), goToSelected defaultGSConfig)

    -- close focused window
    , ((modMask .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modMask,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modMask,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modMask,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modMask,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modMask,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modMask,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modMask,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Expand/Shrink the master area
    , ((modMask,               xK_h     ), sendMessage Shrink)
    , ((modMask,               xK_l     ), sendMessage Expand)

    -- Expand/Shrink a slave area
    , ((modMask,               xK_u     ), sendMessage ShrinkSlave)
    , ((modMask,               xK_i     ), sendMessage ExpandSlave)

    -- Push window back into tiling
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))

    -- Quit xmonad
    , ((modMask .|. shiftMask, xK_q     ), spawn "gnome-session-quit")

    -- Restart xmonad
    , ((modMask              , xK_q     ), restart "xmonad" True)
    ]
    ++

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip myWorkspaces [xK_1 .. xK_9]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++

    -- mod-{F1-F3}, Switch to physical/Xinerama screens 1..3
    -- mod-shift-{F1-F3}, Move client to screen 1..3
   [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
       | (key, sc) <- zip [xK_F1..xK_F3] [0..]
       , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- mouse bindings
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)) -- set the window to floating mode and move by dragging
    , ((modMask, button2), (\w -> focus w >> windows W.shiftMaster)) -- raise the window to the top of the stack
    , ((modMask, button3), (\w -> focus w >> Flex.mouseResizeWindow w)) -- set the window to floating mode and resize by dragging
    ]

-- layout
myLayout = avoidStruts $ boringWindows $ (
            named "vert" tiled |||
            named "horiz" tiled2 |||
            named "full" full
            )
  where
     tiled   = smartBorders $ mouseResizableTile { draggerType = FixedDragger { gapWidth = 0, draggerWidth = 4 }}
     tiled2  = smartBorders $ mouseResizableTile { isMirrored = True, draggerType = FixedDragger { gapWidth = 0, draggerWidth = 4 }}
     full    = noBorders Full

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

-- hooks
myManageHook = composeAll
    [ className =? "Gimp"           --> doFloat
    , resource  =? "compose"        --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

main = do
    xmobar <- spawnPipe "xmobar"
    xmonad $ gnomeConfig {
          terminal           = myTerminal
        , focusFollowsMouse  = myFocusFollowsMouse
        , borderWidth        = myBorderWidth
        , modMask            = myModMask
        , workspaces         = myWorkspaces
        , keys               = myKeys
        , mouseBindings      = myMouseBindings
        , layoutHook         = smartBorders $ myLayout
        , manageHook         = manageHook $ gnomeConfig
        , logHook            = dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn xmobar
            , ppTitle = xmobarColor "#FFB6B0" "" . shorten 100
            , ppCurrent = xmobarColor "#CEFFAC" ""
            , ppSep = "   "
        }
        , startupHook        = do
            setWMName "LG3D"
    }
