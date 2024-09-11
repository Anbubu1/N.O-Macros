#requires AutoHotkey v2.0
#maxthreadsperhotkey 5

goto defineorderedmap

back:

global VERSION := "v4.2"

$*!p:: {
    exitapp
}

dircreate "N.O Macros V4"

setworkingdir a_workingdir "\N.O Macros V4"
    if fileexist("config.ini") {
        try {
            iniread("config.ini", "version", "version_number") = VERSION ? true : false
        } catch error {
            filedelete "config.ini"
        }
    }

    if !fileexist("config.ini") {
        fileappend "", "config.ini"
    }

; initial declarations
global y_amts_used_map_guis := map()
global valued_guictrls := orderedmap()

if !fileexist("j.ico")
    download "https://files.catbox.moe/8qyoi8.ico", "j.ico"

icon := dllcall("LoadImage", "uint", 0, "str", a_workingdir "\j.ico", "uint", 1, "int", 0, "int", 0, "uint", 0x10)

global main := gui("-maximizebox +lastfound +owndialogs", "N.O Macros " VERSION)

    sendmessage 0x80, 0, icon
    sendmessage 0x80, 1, icon

    sendmode "input"

    main.raw_width  := 600
    main.width      := "w" main.raw_width
    main.raw_height := 420
    main.height     := "h" main.raw_height

    main.backcolor := rgb(25, 34, 45)
    
    caption_color := 35
    setdwmattribute(main.hwnd, caption_color, "0x" rgb(25, 34, 45, true))

    main.setfont("q2", "segoe ui")
    main.setfont("cwhite")
    
    main.onevent("close", main_close)

    main.guictrl_x_offset := 10
    main.guictrl_y_offset := 5
    main.guictrl_y_split  := 6
    
    main.columns          := 2
    main.column_positions := set_columns(main)

    shift_column(main, 2, 25)

    main.rainbow_declaration := 255
    main.rainbow_min := 150

    main.setfont("s12")
        create_checkbox(main, "Always On Top",             always_on_top,  2, ["makes the gui always on top", "s8", "s12", true],,,,,                      "cc0c0c0")
        create_checkbox(main, "Transparent GUI",           transparency,   2, ["makes the gui transparent [0-255] (0 is invisible)", "s8", "s12", true],,,[125, "", 0, 255],, "cc0c0c0")
        create_checkbox(main, "Rainbow Title",             rainbow_title,  2,,,,,, "cc0c0c0")
        create_checkbox(main, "Colorless Mode",            colorless,      2,,,,,, "cc0c0c0")
        global flick_sensitivity := create_text(main, "Flick Sensitivity", 2, ["Set your flick sensitivity here.", "s8", "s12"], [1, "x", 0.01, 100],, "c90ff90")
        create_checkbox(main, "Autoclicker",               single_flick,   1, ["really fast.", "s8", "s12", true],,                                true,,, "cff9fc0")
        create_checkbox(main, "Single Flick Macro",        single_flick,   1, ["does a single flick", "s8", "s12", true],,                         true, [90, "°", -360, 360],, "cff9f9f")
        create_checkbox(main, "Spacebar Macro",            spacebar,       1, ["spams spacebar", "s8", "s12", true],,                              true,,, "cffc09f")
        create_checkbox(main, "Chat Message Macro",        chat_msg,       1, ["pastes a chat message and sends it", "s8", "s12", true],,          true, ["N.O on top", "", -360, 360, true],, "cffff9f")
        create_checkbox(main, "Freeze Macro",              freeze,         1, ["freezes roblox", "s8", "s12", true],,                              true,,, "cc0ff9f")
        create_checkbox(main, "Wall High Jump Macro",      wallhj,         1, ["
                                                                               (
                                                                               makes you high jump next to a wall
                                                                               make sure you're looking at the wall
                                                                               )", "s8", "s12", true],,          true,,, "c9fff9f")
        create_checkbox(main, "Mouse Overlay",             mouse_overlay,  1, ["creates a useful mouse overlay", "s8", "s12", true],,,,,                   "c9fffc0")
        create_checkbox(main, "Always Forward Slide",      forward_slide,  1, ["turns your camera to always forward slide on any slide", "s8", "s12", true],,,,, "c9fffff")
        create_checkbox(main, "W-S Macro",                 w_s,            1, ["you people disgust me.", "s8", "s12", true],, true,,, "c9fc0ff")
        create_text(main, "FUCKING READ THIS!!!",           1, ["
                                                                (
                                                                SET YOUR BLOODY FLICK SENSITIVITY PLEASE! thanks
                                                                )", "s8", "s12",,, 8],,, "cc0c0ff")
        create_text(main, "Credits",           2, ["
                                                   (
                                                   Creator {
                                                       Discord - @anbubu (463321359741616149)
                                                       GitHub  - @Anbubu1
                                                       YouTube - @anbubu
                                                   }
                                                   )", "s8", "s12",, "consolas", 8],,, "cc0c0ff")
        create_text(main, "Info",              2, ["
                                                   (
                                                    ALT + P to force exit script.
                                                   )", "s8", "s12"],,, "cc0c0ff")
        create_text(main, "Values and Hotkeys",2, ["
                                                   (
                                                    BACKSPACE key to reset.
                                                    ENTER key to set.
                                                   )", "s8", "s12"],,, "cc0c0ff")
        create_text(main, "Disclaimer",2,         ["
                                                   (
                                                   Make sure you're allowed to use this macro, cuz
                                                   it basically gives you an advantage 💀
                                                   )", "s8", "s12",,, 10],,, "cc0c0ff")

main.show(main.width " " main.height)

onexit save_config

return

set_columns(gui) {
    try {
        columns := gui.columns
    } catch error {
        msgbox "gui.columns non-existent"
        exitapp
    }

    column_array := []
    column_array.length := columns

    for i, _ in column_array {
        column_array[i] := [((gui.raw_width / columns) * (i - 1)) + 10, 10]
    }

    return column_array
}

shift_column(gui, column, x_offset) {
    for i, v in gui.column_positions {
        if i = 1
            continue

        if v = gui.column_positions[column] {
            v[1] += x_offset
            continue
        }

        v[1] += (x_offset / 2)
    }
}

create_checkbox(
    gui,
    text,
    onevent_function,
    column        := false,
    caption_array := false,
    is_enabled    := false,
    var_hotkey    := false,
    valueselect   := false,
    y_offset      := false,
    color         := false,
    anti_combo    := false
) {
    global y_amts_used_map_guis
    global valued_guictrls

    if !y_amts_used_map_guis.has(gui) {
        y_amts_used_map_guis[gui] := []
        y_amts_used_map_guis[gui].length := gui.columns
    }

    if !y_amts_used_map_guis[gui].has(column)
        y_amts_used_map_guis[gui][column] := 0

    if column {
        column_x_offset := gui.column_positions[column][1]
        column_x_offset_2nd := gui.column_positions.length = column ? gui.raw_width + 10 : gui.column_positions[column + 1][1]
    }

    checkbox := gui.addcheckbox("x" column_x_offset " y" gui.guictrl_y_offset + y_offset, text)

    color ? checkbox.color := color : checkbox.color := "cwhite"
    color ? checkbox.oldcolor := color : checkbox.oldcolor := "cwhite"

    checkbox.value := is_enabled
    checkbox.setfont(is_enabled ? "cc0ffc0" : checkbox.color)

    checkbox.getpos(, &checkbox_y,, &checkbox_h)
    checkbox.move(, checkbox_y + y_amts_used_map_guis[gui][column] + (y_amts_used_map_guis[gui][column] != 0 ? gui.guictrl_y_split : 0))

    old_y_amts_used := y_amts_used_map_guis[gui][column]

    y_amts_used_map_guis[gui][column] += checkbox_h + y_offset + (y_amts_used_map_guis[gui][column] != 0 ? gui.guictrl_y_split : 0)

    if isobject(valueselect) {
        valueselect_value := valueselect[1]
        valueselect_unit  := valueselect[2]
        valueselect_min   := valueselect[3]
        valueselect_max   := valueselect[4]
        valueselect_text  := valueselect.has(5) ? valueselect[5] : false
        valueselect_dropdown := valueselect.has(6) ? valueselect[6] : false

        valueselect_guictrl := gui.addtext("+backgroundtrans +right", "[" valueselect_value  valueselect_unit "]")

        valueselect_guictrl.setfont("cd0d0d0 s10 q2", "consolas")

        checkbox.getpos(, &guictrl_y)
        valueselect_guictrl.move(column_x_offset_2nd - 20, guictrl_y + (var_hotkey ? 18 : 2.5), 160, 16)

        valueselect_guictrl.getpos(&guictrl_x,, &guictrl_w)
        valueselect_guictrl.move(guictrl_x - guictrl_w)

        valueselect_guictrl.array := valueselect

        binded_valueselect_change := valueselect_change.bind(,, checkbox,, valueselect_text, valueselect_dropdown)
        valueselect_guictrl.onevent("click", binded_valueselect_change)

        if fileexist("config.ini") and filegetsize("config.ini") > 0 {
            try {
                cfg_values := strsplit(iniread("config.ini", "main", checkbox.text), "|")
                cfg_value := cfg_values[2]
                if cfg_value = "" {
                    cfg_value := 0
                }
                old_length := strlen(valueselect_guictrl.value)
                valueselect_guictrl.value := "[" cfg_value valueselect_unit "]"
                new_length := strlen(valueselect_guictrl.value)
            } catch error {
    
            }
        }
    } else {
        valueselect_guictrl := false
    }

    if var_hotkey {
        var_hotkey := gui.addtext("+backgroundtrans +right", "[NONE]")
        var_hotkey.setfont("cd0d0d0 s10 q2", "consolas")
        
        checkbox.getpos(, &guictrl_y)
        var_hotkey.move(column_x_offset_2nd - 20, guictrl_y - (isobject(valueselect) ? 0 : -2), 160, 16)

        var_hotkey.getpos(&guictrl_x,, &guictrl_w)
        var_hotkey.move(guictrl_x - guictrl_w)

        binded_hotkey_change := hotkey_change.bind(,, checkbox)

        var_hotkey.onevent("click", binded_hotkey_change)

        if fileexist("config.ini") and filegetsize("config.ini") > 0 {
            try {
                cfg_values := strsplit(iniread("config.ini", "main", checkbox.text), "|")
                cfg_value := strupper(cfg_values[1])
                old_length := strlen(var_hotkey.value)
                var_hotkey.value := "[" cfg_value "]"
            } catch error {
    
            }
        }
    }

    if isobject(caption_array) {
        caption_string     := caption_array[1]
        caption_text_size  := caption_array[2]
        checkbox_text_size := caption_array[3]

        if caption_array.has(4) {
            if caption_array[4] {
                offset_denied := true
            }
        }

        if caption_array.has(5) {
            if caption_array[5] {
                caption_font := caption_array[5]
            } else {
                caption_font := ""
            }
        } else {
            caption_font := ""
        }

        if caption_array.has(6) {
            if caption_array[6] {
                caption_w_offset := caption_array[6]
            } else {
                caption_w_offset := 0
            }
        } else {
            caption_w_offset := 0
        }

        gui.setfont(caption_text_size)

        checkbox.getpos(&guictrl_x, &guictrl_y,, &guictrl_h)

        caption := gui.addtext("+backgroundtrans", caption_string)

        caption.move(guictrl_x, guictrl_y + guictrl_h + (isobject(valueselect) and var_hotkey and (!offset_denied) ? 5 : 0))

        caption.setfont(, caption_font)
        caption.getpos(,,, &guictrl_h)

        y_amts_used_map_guis[gui][column] += guictrl_h + (isobject(valueselect) and var_hotkey and (!offset_denied) ? 5 : 0)

        column_ahead := column = gui.column_positions.length ? gui.raw_width : gui.column_positions[column + 1][1]

        caption.move(,, column_ahead - gui.column_positions[column][1] - 20 + caption_w_offset)
        
        gui.setfont(checkbox_text_size)
    }

    if is_enabled and !var_hotkey
        onevent_function(checkbox, "startup enabled")

    guictrl_port_bind := guictrl_port.bind(,, onevent_function, var_hotkey, valueselect_guictrl)

    checkbox.onevent("click", guictrl_port_bind)

    if is_enabled
        guictrl_port_bind

    checkbox.boundfunc := guictrl_port_bind
    
    if !var_hotkey and !valueselect {
        checkbox.onevent("click", onevent_function)

        if fileexist("config.ini") and filegetsize("config.ini") > 0 {
            try {
                cfg_values := strsplit(iniread("config.ini", "main", checkbox.text), "|")
                cfg_value := cfg_values[3]
                checkbox.value := cfg_value
                is_enabled := cfg_value
            } catch error {
    
            }
        }

        if is_enabled
            onevent_function(checkbox, "asdfghjkl")
    }

    if !var_hotkey and isobject(valueselect) {
        binded_onevent_function := onevent_function.bind(,, valueselect_guictrl)

        checkbox.onevent("click", binded_onevent_function)
    }

    return_info := [checkbox, onevent_function, column, var_hotkey, valueselect_guictrl]

    valued_guictrls[checkbox] := return_info

    return return_info
}

create_text(
    gui,
    text,
    column        := false,
    caption_array := false,
    valueselect   := false,
    y_offset      := false,
    color         := false
) {
    global y_amts_used_map_guis
    global valued_guictrls

    if !y_amts_used_map_guis.has(gui) {
        y_amts_used_map_guis[gui] := []
        y_amts_used_map_guis[gui].length := gui.columns
    }

    if !y_amts_used_map_guis[gui].has(column)
        y_amts_used_map_guis[gui][column] := 0

    if column {
        column_x_offset := gui.column_positions[column][1]
        column_x_offset_2nd := gui.column_positions.length = column ? gui.raw_width + 10 : gui.column_positions[column + 1][1]
    }

    checkbox := gui.addtext("x" column_x_offset " y" gui.guictrl_y_offset + y_offset, text)

    color ? checkbox.color := color : checkbox.color := "cwhite"
    color ? checkbox.oldcolor := color : checkbox.oldcolor := "cwhite"

    checkbox.setfont(checkbox.color)

    checkbox.getpos(, &checkbox_y,, &checkbox_h)
    checkbox.move(, checkbox_y + y_amts_used_map_guis[gui][column] + (y_amts_used_map_guis[gui][column] != 0 ? gui.guictrl_y_split : 0))

    y_amts_used_map_guis[gui][column] += checkbox_h + y_offset + (y_amts_used_map_guis[gui][column] != 0 ? gui.guictrl_y_split : 0)

    if isobject(valueselect) {
        valueselect_value := valueselect[1]
        valueselect_unit  := valueselect[2]
        valueselect_min   := valueselect[3]
        valueselect_max   := valueselect[4]

        valueselect_guictrl := gui.addtext("+backgroundtrans +right", "[" valueselect_value  valueselect_unit "]")

        valueselect_guictrl.setfont("cd0d0d0 s10 q2", "consolas")

        checkbox.getpos(, &guictrl_y)
        valueselect_guictrl.move(column_x_offset_2nd - 20, guictrl_y + 2.75, 160, 16)

        valueselect_guictrl.getpos(&guictrl_x,, &guictrl_w)
        valueselect_guictrl.move(guictrl_x - guictrl_w)

        valueselect_guictrl.array := valueselect

        binded_valueselect_change := valueselect_change.bind(,, checkbox,, true)
        valueselect_guictrl.onevent("click", binded_valueselect_change)

        if fileexist("config.ini") and filegetsize("config.ini") > 0 {
            try {
                cfg_values := strsplit(iniread("config.ini", "main", checkbox.text), "|")
                cfg_value := cfg_values[2]
                if cfg_value = "" {
                    cfg_value := 0
                }
                old_length := strlen(valueselect_guictrl.value)
                valueselect_guictrl.value := "[" cfg_value valueselect_unit "]"
                new_length := strlen(valueselect_guictrl.value)
            } catch error {
    
            }
        }
    } else {
        valueselect_guictrl := false
    }

    if isobject(caption_array) {
        caption_string     := caption_array[1]
        caption_text_size  := caption_array[2]
        checkbox_text_size := caption_array[3]

        if caption_array.has(4) {
            if caption_array[4] {
                offset_denied := true
            }
        }

        if caption_array.has(5) {
            if caption_array[5] {
                caption_font := caption_array[5]
            } else {
                caption_font := ""
            }
        } else {
            caption_font := ""
        }

        if caption_array.has(6) {
            if caption_array[6] {
                caption_w_offset := caption_array[6]
            } else {
                caption_w_offset := 0
            }
        } else {
            caption_w_offset := 0
        }

        gui.setfont(caption_text_size)

        checkbox.getpos(&guictrl_x, &guictrl_y, &guictrl_w, &guictrl_h)

        caption := gui.addtext("+backgroundtrans", caption_string)

        caption.move(guictrl_x, guictrl_y + guictrl_h)

        caption.setfont(, caption_font)
        caption.getpos(,,, &guictrl_h)

        y_amts_used_map_guis[gui][column] += guictrl_h

        column_ahead := column = gui.column_positions.length ? gui.raw_width : gui.column_positions[column + 1][1]

        caption.move(,, column_ahead - gui.column_positions[column][1] - 20 + caption_w_offset)
        
        gui.setfont(checkbox_text_size)
    }

    return_info := [checkbox, false, column, false, valueselect_guictrl]

    valued_guictrls[checkbox] := return_info

    return return_info
}

; i like making up random words
guictrl_port(checkbox,
             href,
             onevent_function,
             var_hotkey := false,
             valueselect := false
) {
    static hotkeys_for_functions := map()

    checkbox.setfont(checkbox.value ? "cc0ffc0" : checkbox.color)

    if var_hotkey {
        hotkey_key := "*$" regexreplace(var_hotkey.value, "[\[\]]")

        if strlower(regexreplace(hotkey_key, "[\*\$]")) = ("none" or "...") {
            return
        }

        if hotkeys_for_functions.has(hotkey_key) {
            if hotkeys_for_functions[hotkey_key] != onevent_function {
                msgbox "please pick another hotkey!`nthis one is being used already",, "T2"

                checkbox.setfont("cwhite")
                checkbox.value := 0

                return
            }
        }

        if valueselect
            onevent_function_bind := onevent_function.bind(, valueselect)
        
        hotkey hotkey_key, valueselect ? onevent_function_bind : onevent_function, checkbox.value ? "on" : "off"

        if checkbox.value {
            hotkeys_for_functions[hotkey_key] := onevent_function
        } else {
            if hotkeys_for_functions.has(hotkey_key)
                hotkeys_for_functions.delete(hotkey_key)
        }
    }
}

spacebar(thishotkey) {
    fixed_hotkey := regexreplace(thishotkey, "\*\$")

    while getkeystate(fixed_hotkey, "P") {
        send "{space}"
        send "{space}"
        send "{space}"
        sleep 1
    }
}

autoclick(thishotkey) {
    fixed_hotkey := regexreplace(thishotkey, "\*\$")

    while getkeystate(fixed_hotkey, "P") {
        click
        click
        click
        sleep 1
    }
}

single_flick(thishotkey, valueselect) {
    unfiltered_flick_value      := valueselect.value
    flick_val_unit              := valueselect.array[2]
    unfiltered_flick_multiplier := flick_sensitivity[5].value
    flick_mult_unit             := flick_sensitivity[5].array[2]


    flick_value := regexreplace(unfiltered_flick_value, "[\[\]" flick_val_unit "]")
    flick_multiplier := regexreplace(unfiltered_flick_multiplier, "[\[\]" flick_mult_unit "]")

    new_mousemove(flick_value * flick_multiplier)
}

chat_msg(thishotkey, valueselect) {
    unfiltered_chat_msg_value := valueselect.value
    unit                      := valueselect.array[2]

    chat_message := regexreplace(unfiltered_chat_msg_value, "[\[\]" unit "]")

    old_clipboard := a_clipboard

    a_clipboard := chat_message

    send "/{backspace}"
    sleep 25
    send "{ctrl down}{v down}"
    sleep 50
    send "{ctrl up}{v up}"
    sleep 25
    send "{enter}"

    a_clipboard := old_clipboard
}

new_mousemove(x := false, y := false) {
    dllcall("mouse_event", "UInt", 0x0001, "Int", x ? x : 0, "Int", y ? y : 0, "UInt", 0, "UInt", 0)
}

freeze(thishotkey) {
    fixed_hotkey := regexreplace(thishotkey, "\*\$")

    process_suspend("RobloxPlayerBeta.exe")
    keywait fixed_hotkey
    process_resume("RobloxPlayerBeta.exe")
}

wallhj(thishotkey) {
    send "{c down}"
    sleep 1
    send "{space down}"
    sleep 50
    send "{c up}{space up}"
    process_suspend("RobloxPlayerBeta.exe")
    sleep 300
    process_resume("RobloxPlayerBeta.exe")
}

process_suspend(PID_or_name) {
    process := instr(PID_or_name,".") ? processexist(PID_or_name) : PID_or_name

    process_openprocess := dllcall("OpenProcess", "uint", 0x1F0FFF, "int", 0, "int", process)

    if !process_openprocess {
        return -1
    }

    dllcall("ntdll.dll\NtSuspendProcess", "int", process_openprocess)
    dllcall("CloseHandle", "int", process_openprocess)
}

process_resume(PID_or_name) {
    process := instr(PID_or_name,".") ? processexist(PID_or_name) : PID_or_name

    process_openprocess := dllcall("OpenProcess", "uint", 0x1F0FFF, "int", 0, "int", process)

    if !process_openprocess {
        return -1
    }

    dllcall("ntdll.dll\NtResumeProcess", "int", process_openprocess)
    dllcall("CloseHandle", "int", process_openprocess)
}

mouse_overlay(checkbox, href) {
    msgbox "this does nothing get fucked"
}

forward_slide(checkbox, href) {
    unfiltered_flick_multiplier := flick_sensitivity[5].value
    flick_mult_unit             := flick_sensitivity[5].array[2]
    flick_multiplier            := regexreplace(unfiltered_flick_multiplier, "[\[\]" flick_mult_unit "]")

    slide_delay := 300

    slide(thishotkey) {
        send regexreplace(thishotkey, "\*\$")

        sleep 5

        if getkeystate("d", "P") {
            new_mousemove(-90 * flick_multiplier)
            sleep slide_delay
            new_mousemove(90 * flick_multiplier)
            return
        }

        if getkeystate("a", "P") {
            new_mousemove(90 * flick_multiplier)
            sleep slide_delay
            new_mousemove(-90 * flick_multiplier)
            return
        }

        if getkeystate("s", "P") {
            new_mousemove(180 * flick_multiplier)
            sleep slide_delay
            new_mousemove(180 * flick_multiplier)
            return
        }
    }

    hotifwinactive "Roblox"
    hotkey "*$c", slide, checkbox.value
    hotifwinactive "Roblox"
}

w_s(thishotkey) {
    fixed_hotkey := regexreplace(thishotkey, "\*\$")

    is_w := false
    
    while getkeystate(fixed_hotkey, "P") {
        if is_w {
            send "{w up}{s down}"
            is_w := false
        } else {
            send "{s up}{w down}"
            is_w := true
        }
        sleep 100
    }
    
    send "{w up}{s up}"
}

always_on_top(checkbox, href) {
    winsetalwaysontop checkbox.value, "Obby Macros v4"
}

transparency(checkbox, href, valueselect) {
    unfiltered_transparency := valueselect.value
    unit                    := valueselect.array[2]

    transparency_val := regexreplace(unfiltered_transparency, "[\[\]" unit "]")

    winsettransparent checkbox.value ? transparency_val : 255
}

colorless(checkbox, href) {
    for _, v in valued_guictrls {
        guictrl := v[1]

        if !checkbox.value {
            guictrl.color := guictrl.oldcolor
            guictrl.setfont(guictrl.color)
            continue
        }

        guictrl.color := "cc0c0c0"
        guictrl.setfont(guictrl.color)
    }

    dco_counter := 1
}

updaterainbow(light, min, rainbow_array, reversed := false) {
    if !isobject(rainbow_array) {
        msgbox "rainbow_array error"
    }

    if light < min {
        msgbox "rainbow error"
        exitapp
    }

    red   := rainbow_array[1]
    green := rainbow_array[2]
    blue  := rainbow_array[3]

    step := 5

    if red = light and green < light and blue = min {
        green += step
        green := clamp(green, min, 255)
    } else if green = light and red > min and blue = min {
        red -= step
        red := clamp(red, min, 255)
    } else if green = light and blue < light and red = min {
        blue += step
        blue := clamp(blue, min, 255)
    } else if blue = light and green > min and red = min {
        green -= step
        green := clamp(green, min, 255)
    } else if blue = light and red < light and green = min {
        red += step
        red := clamp(red, min, 255)
    } else if red = light and blue > min and green = min {
        blue -= step
        blue := clamp(blue, min, 255)
    }

    format_red := format("{:x}", red)
    format_green := format("{:x}", green)
    format_blue := format("{:x}", blue)

    if red < 16 {
        format_red := "0" format_red
    }

    if green < 16 {
        format_green := "0" format_green
    }

    if blue < 16 {
        format_blue := "0" format_blue
    }

    return reversed ? format_blue format_green format_red : format_red format_green format_blue
}

rainbow_title(checkbox, href) {
    window_text := 36

    if !checkbox.value {
        setdwmattribute(checkbox.gui.hwnd, window_text, 0xffffff)
        return
    }

    rainbow_declaration := checkbox.gui.rainbow_declaration
    rainbow_min         := checkbox.gui.rainbow_min

    static red   := rainbow_declaration
    static green := rainbow_min
    static blue  := rainbow_min

    loop_rainbow() {
        if !checkbox.value {
            settimer , 0
            return
        }

        rainbow_step := updaterainbow(rainbow_declaration, rainbow_min, [red, green, blue], true)
        setdwmattribute(checkbox.gui.hwnd, window_text, "0x" rainbow_step)

        red   := hextodec(substr(rainbow_step, 5, 2))
        green := hextodec(substr(rainbow_step, 3, 2))
        blue  := hextodec(substr(rainbow_step, 1, 2))
    }

    settimer loop_rainbow, 25, -2147483648
}

hotkey_change(text, href, checkbox, valueselect := false) {

    inputhook_stop_mousekeys := false

    static exitkeys := "{backspace}{delete}{escape}"

    static mousekeys := [
        "lbutton",
        "mbutton",
        "rbutton",
        "xbutton1",
        "xbutton2",
        "wheeldown",
        "wheelup",
        "wheelleft",
        "wheelright",
        "lalt",
        "ralt",
        "lwin",
        "rwin",
        "lshift",
        "rshift",
        "lcontrol",
        "rcontrol"
    ]

    static inviskeys := [
        "09 TAB",
        "0d ENTER",
        "20 SPACE"
    ]

    text.value := "[...]"

    text.setfont("cyellow")

    checkkeys() {
        for i, v in inviskeys {
            inviskey := strsplit(v, " ")
            if getkeyvk(ih.input) = hextodec(inviskey[1]) {
                global checkkeys_value := inviskey[2]
                return true
            }
        }
        return false
    }

    global ih := inputhook("L1 M B", exitkeys)

    ih.start()

    for _, v in mousekeys {
        hotkey v, inputhookstop, "On"
    }
    
    inputhookstop(thishotkey) {
        ih.stop()
        text.text := "[" strupper(thishotkey) "]"

        for _, v in mousekeys {
            hotkey v, inputhookstop, "Off"
        }

        inputhook_stop_mousekeys := true

        if !checkbox.value {
            return
        }

        checkbox.boundfunc(checkbox)
    }

    ih.wait()

    text.setfont("cd0d0d0")

    if inputhook_stop_mousekeys {
        return
    }

    if strlower(ih.endreason) = "endkey" {
        text.text := "[NONE]"
    } else if checkkeys() {
        text.text := "[" checkkeys_value "]"
    } else {
        text.text := "[" strupper(ih.input) "]"
    }

    for _, v in mousekeys {
        hotkey v, inputhookstop, "Off"
    }

    if !checkbox.value {
        return
    }

    checkbox.boundfunc(checkbox)
}

valueselect_change(text, href, checkbox, valueselect := false, is_text := false, is_dropdown := false) {
    unit := text.array[2]

    oldtext_value := text.value

    text.value := "[..." unit "]"

    text.setfont("cyellow")

    if is_dropdown
        msgbox "yaya"

    checkkeys(inputhook, vk, sc) {
        if (inputhook.input = "." or regexmatch(inputhook.input, "^(?=.*?\..*?\.).*$")) and !is_text {
            inputhook.stop()
            return
        }

        if getkeyname("vk" format("{:X}", vk)) = "Space" {
            text.value := regexreplace(substr(text.value, 1, strlen(text.value) - strlen(unit) - 1) " " unit "]", "(\.\.\.)")
            return
        }

        text.value := regexreplace(substr(text.value, 1, strlen(text.value) - strlen(unit) - 1) getkeyname("vk" format("{:X}", vk)) unit "]", "(\.\.\.)")
    }

    global ih := inputhook((is_text ? "L12" : "L5") " M B", "{enter}")

    ih.keyopt(is_text ? "{all}" : "0123456789.", "+N")

    ih.onkeydown := checkkeys

    ih.start()

    ih.wait()

    text.setfont("cd0d0d0")

    if strlower(ih.endreason) = "stopped" {
        text.value := oldtext_value
        return
    }

    if strlower(ih.endreason) = "max" and text.value = "[..." unit "]" {
        text.value := oldtext_value
        return
    }

    if is_text
        return

    if text.array.has(3)
        text.value := "[" clamp(regexreplace(text.value, "[\[\]" unit "]"), text.array[3]) unit "]"

    if text.array.has(4)
        text.value := "[" clamp(regexreplace(text.value, "[\[\]" unit "]"),, text.array[4]) unit "]"

    text.value := "[" remove_trailing_zeroes(regexreplace(text.value, "[\[\]" unit "]")) unit "]"

    checkbox.boundfunc(checkbox)
}

hextodec(hex) {
    result := 0

    if (substr(hex, 1, 2) == "0x") {
        hex := substr(hex, 3)
    }

    hex_digits := "0123456789ABCDEF"

    loop parse, hex {
        digit := substr(A_LoopField, 1, 1)
        value := instr(hex_digits, digit) - 1
        result := result * 16 + value
    }

    return result
}

rgb(r, g, b, reversed := false) {
    return format("{:X}", reversed ? b : r) format("{:X}", g) format("{:X}", reversed ? r : b)
}

remove_trailing_zeroes(num) {
    regexmatch(num, "(-?([1-9][0-9]*|0(?=\.))(\.[0-9]+(?=[1-9])[1-9])?)", &return_num)

    return return_num[]
}

clamp(num, min := false, max := false) {
    if num < min and min
        return min
    if num > max and max
        return max
    return num
}

setdwmattribute(hwnd, attribute, value) {
    buf := Buffer(4, 0)
    numput("Int", value, buf)
    dllcall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", attribute, "Ptr", buf, "Int", 4)
}

main_close(thisGui) {
    exitapp
}

save_config(exitreason := false, exitcode := false) {
    global VERSION
    iniwrite VERSION, "config.ini", "version", "version_number"
    for i, v in valued_guictrls {
        main_guictrl := v[1].text
        try {
            if v[1].value = (0 or 1) {
                guictrl_enabled := v[1].value
            } else {
                guictrl_enabled := 0
            }
        } catch error {
            guictrl_enabled := 0
        }
        set_hotkey := v[4] ? regexreplace(strlower(v[4].text), "[\[\]]") : v[4]
        set_value := v[5] ? regexreplace(regexreplace(v[5].value, "[\[\]]"), v[5].array[2]) : v[5]
        iniwrite set_hotkey "|" set_value "|" guictrl_enabled, "config.ini", "main", main_guictrl
    }
}

defineorderedmap:

class orderedmap extends map {
    keyarray := []

    __new(kvpairs*) {
        super.__new(kvpairs*)
        for i, key in kvpairs {
            if (mod(i, 2) != 0) {
                this.keyarray.push(kvpairs[i - 1])
            }
        }
    }

    __item[key] {
        set {
            if !this.has(key) {
                this.keyarray.push(key)
            }
            return super[key] := value
        }
    }

    __enum(*) {
        keyenum := this.keyarray.__enum(1)
        keyvalenum(&key := unset, &val := unset) {
            if keyenum(&key) {
                val := this[key]
                return true
            } else {
                return false
            }
        }
        return keyvalenum
    }
}

goto back
