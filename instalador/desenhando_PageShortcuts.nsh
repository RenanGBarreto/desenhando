; -----------------------------------------------------------------------------
; Page Shortcut Icons
;
; Export:
;   Macro EIT_MUI_PAGE_SHORTCUTS is used to set the Page.
; -----------------------------------------------------------------------------

!include MUI2.nsh
!include LogicLib.nsh
!include WinMessages.nsh
!include FileFunc.nsh
!include nsDialogs.nsh

; -----------------------------------------------------------------------------
; Places where shortcuts can be created:

!define EIT_MUI_SHORTCUT_FOLDER_DESKTOP      DESKTOP
!define EIT_MUI_SHORTCUT_FOLDER_QUICKLAUNCH  QUICKLAUNCH
!define EIT_MUI_SHORTCUT_FOLDER_STARTMENU    STARTMENU
!define EIT_MUI_SHORTCUT_FOLDER_STARTUP      STARTUP
                                             
!define EIT_MUI_SHORTCUT_STATE_ENABLE        ${BST_CHECKED}

; -----------------------------------------------------------------------------
; Aply the givemn action to all possible shortcut entries
!macro EIT_MUI_SHORTCUTS_ITERATE_ENTRIES  ACTION  ARGUMENTS

  ${${ACTION}} ${EIT_MUI_SHORTCUT_FOLDER_DESKTOP}     ${ARGUMENTS} 
  ${${ACTION}} ${EIT_MUI_SHORTCUT_FOLDER_QUICKLAUNCH} ${ARGUMENTS} 
  ${${ACTION}} ${EIT_MUI_SHORTCUT_FOLDER_STARTMENU}   ${ARGUMENTS} 
  ${${ACTION}} ${EIT_MUI_SHORTCUT_FOLDER_STARTUP}     ${ARGUMENTS} 

!macroend
!define EIT_MUI_SHORTCUTS_IterateEntries '!insertmacro EIT_MUI_SHORTCUTS_ITERATE_ENTRIES'


; -----------------------------------------------------------------------------
; Define variables and mocros for the given shortcut folder
!macro EIT_MUI_SHORTCUTS_DEFINE_ENTRY  ENTRY_NAME  SHORTCUT_FOLDER

  !ifndef EIT_MUI_SHORTCUTS_ENTRY_DEFINED
    !if "${ENTRY_NAME}" == "${SHORTCUT_FOLDER}"
      !define EIT_MUI_SHORTCUTS_ENTRY_DEFINED

      !ifndef EIT_MUI_SHORTCUTS_FOLDER_${ENTRY_NAME}_ENABLED
        !define EIT_MUI_SHORTCUTS_FOLDER_${ENTRY_NAME}_ENABLED

        Var eit.mui.ShortcutsPage.${ENTRY_NAME}
        Var eit.mui.ShortcutsPage.${ENTRY_NAME}.State

        !ifndef EIT_MUI_SHORTCUTS_ENABLED 
          !define EIT_MUI_SHORTCUTS_ENABLED
        !endif

      !endif

    !endif
  !endif

!macroend ; EIT_MUI_SHORTCUTS_DEFINE_ENTRY
!define EIT_MUI_SHORTCUTS_DefineEntry '!insertmacro EIT_MUI_SHORTCUTS_DEFINE_ENTRY'


; -----------------------------------------------------------------------------
; Add on the Page a shortcut folder 
!macro EIT_MUI_PAGE_SHORTCUTS_ADD_FOLDER  SHORTCUT_FOLDER 

  !ifdef EIT_MUI_SHORTCUTS_ENTRY_DEFINED
    !undef EIT_MUI_SHORTCUTS_ENTRY_DEFINED
  !endif

  ${EIT_MUI_SHORTCUTS_IterateEntries}  EIT_MUI_SHORTCUTS_DefineEntry  ${${SHORTCUT_FOLDER}}

  !ifndef EIT_MUI_SHORTCUTS_ENTRY_DEFINED
    !error "Shortcut folder '${SHORTCUT_FOLDER}' is unsupported"
  !else
    !undef EIT_MUI_SHORTCUTS_ENTRY_DEFINED
  !endif

!macroend ; EIT_MUI_PAGE_SHORTCUTS_ADD_FOLDER
!define EIT_MUI_PAGE_SHORTCUTS_AddFolder '!insertmacro EIT_MUI_PAGE_SHORTCUTS_ADD_FOLDER'


; -----------------------------------------------------------------------------
; Page interface settings and variables
!macro EIT_MUI_SHORTCUTSPAGE_INTERFACE

  !ifndef EIT_MUI_SHORTCUTSPAGE_INTERFACE
    !define EIT_MUI_SHORTCUTSPAGE_INTERFACE

    Var eit.mui.ShortcutsPage
    Var eit.mui.ShortcutsPage.Description    
    Var eit.mui.ShortcutsPage.y    

  !endif
  
  !ifndef MUI_${MUI_PAGE_UNINSTALLER_PREFIX}WELCOMEFINISHPAGE_BITMAPS
    !insertmacro MUI_DEFAULT MUI_${MUI_PAGE_UNINSTALLER_PREFIX}WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\win.bmp"  
  !endif

!macroend ; EIT_MUI_SHORTCUTSPAGE_INTERFACE


; -----------------------------------------------------------------------------
; Set initial state for the given file association entry
!macro EIT_MUI_SHORTCUTS_INIT_ENTRY  ENTRY_NAME 

  !ifdef EIT_MUI_SHORTCUTS_FOLDER_${ENTRY_NAME}_ENABLED

    StrCpy $eit.mui.ShortcutsPage.${ENTRY_NAME}.State ${EIT_MUI_SHORTCUT_STATE_ENABLE}

  !endif

!macroend 
!define EIT_MUI_SHORTCUTS_InitEntry '!insertmacro EIT_MUI_SHORTCUTS_INIT_ENTRY'


; -----------------------------------------------------------------------------
; Interface initialization
!macro EIT_MUI_SHORTCUTSPAGE_GUIINIT

  !ifndef EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}SHORTCUTSPAGE_GUINIT
    !define EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}SHORTCUTSPAGE_GUINIT

    Function ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}eit.mui.ShortcutsPage.GUIInit
      
      ${EIT_MUI_SHORTCUTS_IterateEntries} EIT_MUI_SHORTCUTS_InitEntry ""

      !ifdef MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT
        Call "${MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT}"
      !endif   

    FunctionEnd ; eit.mui.ShortcutsPage.GUIInit

    !insertmacro MUI_SET MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT \
                         ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}eit.mui.ShortcutsPage.GUIInit

  !endif    

!macroend ; EIT_MUI_SHORTCUTSPAGE_GUIINIT


; -----------------------------------------------------------------------------
; Page declaration
!macro EIT_MUI_PAGEDECLARATION_SHORTCUTS ${CREATE_SHORTCUT}

  !insertmacro MUI_SET EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}SHORTCUTSPAGE ""
  !insertmacro EIT_MUI_SHORTCUTSPAGE_INTERFACE

  !insertmacro EIT_MUI_SHORTCUTSPAGE_GUIINIT
  !define EIT_MUI_SHORTCUTSPAGE_CREATE_SHORTCUT ${CREATE_SHORTCUT}

  !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUTSPAGE_HEADER      "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_SHORTCUTS_HEADER)"
  !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUTSPAGE_SUBHEADER   "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_SHORTCUTS_SUBHEADER)"
  !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUTSPAGE_DESCRIPTION "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_SHORTCUTS_DESCRIPTION)"
  !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUTSPAGE_DESKTOP     "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_SHORTCUTS_TODESKTOP)"
  !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUTSPAGE_QUICKLAUNCH "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_SHORTCUTS_TOQUICK)"
  !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUTSPAGE_STARTMENU   "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_SHORTCUTS_TOSTARTMENU)"
  !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUTSPAGE_STARTUP     "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_SHORTCUTS_TOSTARTUP)"

  !insertmacro MUI_PAGE_FUNCTION_FULLWINDOW

  PageEx ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}custom

  PageCallbacks ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_ShortcutsPage.Pre_${MUI_UNIQUEID}  \
                ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_ShortcutsPage.Leave_${MUI_UNIQUEID}

  PageExEnd

  !insertmacro EIT_MUI_FUNCTION_SHORTCUTSPAGE ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_ShortcutsPage.Pre_${MUI_UNIQUEID}  \ 
                                              ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_ShortcutsPage.Leave_${MUI_UNIQUEID}

  !insertmacro MUI_UNSET EIT_MUI_SHORTCUTSPAGE_HEADER
  !insertmacro MUI_UNSET EIT_MUI_SHORTCUTSPAGE_SUBHEADER
  !insertmacro MUI_UNSET EIT_MUI_SHORTCUTSPAGE_DESCRIPTION
  !insertmacro MUI_UNSET EIT_MUI_SHORTCUTSPAGE_DESKTOP    
  !insertmacro MUI_UNSET EIT_MUI_SHORTCUTSPAGE_QUICKLAUNCH
  !insertmacro MUI_UNSET EIT_MUI_SHORTCUTSPAGE_STARTMENU  
  !insertmacro MUI_UNSET EIT_MUI_SHORTCUTSPAGE_STARTUP    

!macroend ; EIT_MUI_PAGEDECLARATION_SHORTCUTS


; -----------------------------------------------------------------------------
; Parameter 'CREATE_SHORTCUT' is a macro to be used to create Shortcut for 
; the items whitch are selected by the user.
!macro EIT_MUI_PAGE_SHORTCUTS  CREATE_SHORTCUT

  !ifdef EIT_MUI_SHORTCUTS_ENABLED 
    !verbose push
    !verbose ${MUI_VERBOSE}

    !insertmacro MUI_PAGE_INIT
    !insertmacro EIT_MUI_PAGEDECLARATION_SHORTCUTS ${CREATE_SHORTCUT}

    !verbose pop
  !endif

!macroend ; EIT_MUI_PAGE_SHORTCUTS


; -----------------------------------------------------------------------------
!macro EIT_MUI_SHORTCUTS_CREATE_CHECKBOX  ENTRY_NAME  YPOS

  !ifdef EIT_MUI_SHORTCUTS_FOLDER_${ENTRY_NAME}_ENABLED

    ${NSD_CreateCheckBox} 16u ${YPOS}u 284u 8u "${EIT_MUI_SHORTCUTSPAGE_${ENTRY_NAME}}"
    Pop $eit.mui.ShortcutsPage.${ENTRY_NAME}

    ${NSD_SetState} $eit.mui.ShortcutsPage.${ENTRY_NAME} \
                    $eit.mui.ShortcutsPage.${ENTRY_NAME}.State

    IntOp  ${YPOS} ${YPOS} + 16

  !endif

!macroend ; EIT_MUI_SHORTCUTS_CREATE_CHECKBOX
!define EIT_MUI_SHORTCUTS_CreateCheckbox '!insertmacro EIT_MUI_SHORTCUTS_CREATE_CHECKBOX'


; -----------------------------------------------------------------------------
!macro EIT_MUI_SHORTCUTS_SAVE_CHECKBOX_STATE  ENTRY_NAME

  !ifdef EIT_MUI_SHORTCUTS_FOLDER_${ENTRY_NAME}_ENABLED

    ${NSD_GetState} $eit.mui.ShortcutsPage.${ENTRY_NAME} \
                    $eit.mui.ShortcutsPage.${ENTRY_NAME}.State

  !endif

!macroend ; EIT_MUI_SHORTCUTS_SAVE_CHECKBOX_STATE
!define EIT_MUI_SHORTCUTS_SaveCheckboxState '!insertmacro EIT_MUI_SHORTCUTS_SAVE_CHECKBOX_STATE'


; -----------------------------------------------------------------------------
; Page functions
!macro EIT_MUI_FUNCTION_SHORTCUTSPAGE  PRE  LEAVE

  ; ---------------------------------------------------------------------------
  Function "${PRE}"

    !ifndef EIT_MUI_SHORTCUTS_ENABLED 
      Abort
    !endif

    !insertmacro MUI_PAGE_FUNCTION_CUSTOM PRE
    !insertmacro MUI_HEADER_TEXT_PAGE ${EIT_MUI_SHORTCUTSPAGE_HEADER} \
                                      ${EIT_MUI_SHORTCUTSPAGE_SUBHEADER}

    nsDialogs::Create /NOUNLOAD 1018
    Pop $eit.mui.ShortcutsPage

    ${if} $eit.mui.ShortcutsPage == error
      Abort
    ${endif}

    ; Description text
    ${NSD_CreateLabel} 0u 0u 300u 8u "${EIT_MUI_SHORTCUTSPAGE_DESCRIPTION}"
    Pop $eit.mui.ShortcutsPage.Description

    ; CheckBoxes
    StrCpy $eit.mui.ShortcutsPage.y  20
    ${EIT_MUI_SHORTCUTS_IterateEntries} EIT_MUI_SHORTCUTS_CreateCheckbox \
                                        $eit.mui.ShortcutsPage.y

    nsDialogs::Show

  FunctionEnd ; PRE


  ; ---------------------------------------------------------------------------
  Function "${LEAVE}"

    ${EIT_MUI_SHORTCUTS_IterateEntries} EIT_MUI_SHORTCUTS_SaveCheckboxState ""

    !insertmacro MUI_PAGE_FUNCTION_CUSTOM LEAVE

  FunctionEnd ; LEAVE

!macroend ; EIT_MUI_FUNCTION_SHORTCUTSPAGE


; -----------------------------------------------------------------------------
!macro EIT_MUI_SHORTCUTS_PROCESS_SHORTCUT  ENTRY_NAME SHORTCUT_FOLDER

  !if "${ENTRY_NAME}" == "${SHORTCUT_FOLDER}"

    ${if} "$eit.mui.ShortcutsPage.${ENTRY_NAME}.State" == "${EIT_MUI_SHORTCUT_STATE_ENABLE}"

      ${${EIT_MUI_SHORTCUTSPAGE_CREATE_SHORTCUT}}      \
          "${EIT_MUI_SHORTCUT_FOLDER_LOCATION_${ENTRY_NAME}}\${EIT_MUI_SHORTCUTS_LNK_FILE}" \
          "${EIT_MUI_SHORTCUTS_TARGET_FILE}"   \
         '"${EIT_MUI_SHORTCUTS_PARAMETERS}"'   \
          "${EIT_MUI_SHORTCUTS_WORKING_DIR}"
      
    ${endif}

  !endif

!macroend ; EIT_MUI_SHORTCUTS_PROCESS_SHORTCUT
!define EIT_MUI_SHORTCUTS_ProcessShortcut '!insertmacro EIT_MUI_SHORTCUTS_PROCESS_SHORTCUT'


; -----------------------------------------------------------------------------
; Create selected shortcuts.
!macro EIT_MUI_PAGE_SHORTCUTS_CREATE_SHORTCUT  SHORTCUT_FOLDER  \
                                               LNK_FILE TARGET_FILE PARAMETERS WORKING_DIR 

  !ifdef EIT_MUI_SHORTCUTS_ENABLED 

    !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUT_FOLDER_LOCATION_DESKTOP     $DESKTOP
    !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUT_FOLDER_LOCATION_QUICKLAUNCH $QUICKLAUNCH
    !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUT_FOLDER_LOCATION_STARTMENU   $STARTMENU
    !insertmacro MUI_DEFAULT EIT_MUI_SHORTCUT_FOLDER_LOCATION_STARTUP     $SMSTARTUP

    !insertmacro MUI_SET EIT_MUI_SHORTCUTS_LNK_FILE    "${LNK_FILE}" 
    !insertmacro MUI_SET EIT_MUI_SHORTCUTS_TARGET_FILE "${TARGET_FILE}"
    !insertmacro MUI_SET EIT_MUI_SHORTCUTS_PARAMETERS  '"${PARAMETERS}"'
    !insertmacro MUI_SET EIT_MUI_SHORTCUTS_WORKING_DIR "${WORKING_DIR}"

    ${EIT_MUI_SHORTCUTS_IterateEntries}  EIT_MUI_SHORTCUTS_ProcessShortcut  ${${SHORTCUT_FOLDER}}

    !insertmacro MUI_UNSET EIT_MUI_SHORTCUTS_LNK_FILE
    !insertmacro MUI_UNSET EIT_MUI_SHORTCUTS_TARGET_FILE
    !insertmacro MUI_UNSET EIT_MUI_SHORTCUTS_PARAMETERS
    !insertmacro MUI_UNSET EIT_MUI_SHORTCUTS_WORKING_DIR

    !insertmacro MUI_UNSET EIT_MUI_SHORTCUT_FOLDER_LOCATION_DESKTOP    
    !insertmacro MUI_UNSET EIT_MUI_SHORTCUT_FOLDER_LOCATION_QUICKLAUNCH
    !insertmacro MUI_UNSET EIT_MUI_SHORTCUT_FOLDER_LOCATION_STARTMENU  
    !insertmacro MUI_UNSET EIT_MUI_SHORTCUT_FOLDER_LOCATION_STARTUP    

  !endif

!macroend ; EIT_MUI_PAGE_SHORTCUTS_CREATE_SHORTCUTS
!define EIT_MUI_PAGE_SHORTCUTS_CreateShortcut '!insertmacro EIT_MUI_PAGE_SHORTCUTS_CREATE_SHORTCUT'


; -----------------------------------------------------------------------------
!macro EIT_MUI_SHORTCUTS_GET_SHORTCUT_INFO  ENTRY_NAME OUT_INFO

  ${if} "$eit.mui.ShortcutsPage.${ENTRY_NAME}.State" == "${EIT_MUI_SHORTCUT_STATE_ENABLE}"

    StrCpy ${OUT_INFO}  "${OUT_INFO}${EIT_MUI_MSG_INFO_SHORTCUTS_${ENTRY_NAME}}"
  
  ${endif}

!macroend ; EIT_MUI_SHORTCUTS_GET_SHORTCUT_INFO
!define EIT_MUI_SHORTCUTS_GetShortcutInfo '!insertmacro EIT_MUI_SHORTCUTS_GET_SHORTCUT_INFO'


; -----------------------------------------------------------------------------
; Out: $R0 = Return information of selected shortcuts.
!macro EIT_MUI_PAGE_SHORTCUTS_GET_INSTALLINFO

  StrCpy $R0 ""
  !ifdef EIT_MUI_SHORTCUTS_ENABLED 

    !insertmacro MUI_DEFAULT EIT_MUI_MSG_INFO_SHORTCUTS_DESKTOP     "$(${MUI_PAGE_UNINSTALLER_PREFIX}MSG_INFO_SHORTCUTS_DESKTOP)"
    !insertmacro MUI_DEFAULT EIT_MUI_MSG_INFO_SHORTCUTS_QUICKLAUNCH "$(${MUI_PAGE_UNINSTALLER_PREFIX}MSG_INFO_SHORTCUTS_QUICKLAUNCH)"
    !insertmacro MUI_DEFAULT EIT_MUI_MSG_INFO_SHORTCUTS_STARTMENU   "$(${MUI_PAGE_UNINSTALLER_PREFIX}MSG_INFO_SHORTCUTS_STARTMENU)"
    !insertmacro MUI_DEFAULT EIT_MUI_MSG_INFO_SHORTCUTS_STARTUP     "$(${MUI_PAGE_UNINSTALLER_PREFIX}MSG_INFO_SHORTCUTS_STARTUP)"
    
    ${EIT_MUI_SHORTCUTS_IterateEntries}  EIT_MUI_SHORTCUTS_GetShortcutInfo  $R0

    !insertmacro MUI_UNSET EIT_MUI_MSG_INFO_SHORTCUTS_DESKTOP    
    !insertmacro MUI_UNSET EIT_MUI_MSG_INFO_SHORTCUTS_QUICKLAUNCH
    !insertmacro MUI_UNSET EIT_MUI_MSG_INFO_SHORTCUTS_STARTMENU  
    !insertmacro MUI_UNSET EIT_MUI_MSG_INFO_SHORTCUTS_STARTUP    

  !endif
  
!macroend ; EIT_MUI_PAGE_SHORTCUTS_GET_INSTALLINFO
!define EIT_MUI_PAGE_SHORTCUTS_GetInstallInfo '!insertmacro EIT_MUI_PAGE_SHORTCUTS_GET_INSTALLINFO'
