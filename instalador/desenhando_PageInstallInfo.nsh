; -----------------------------------------------------------------------------
; Page Start Installation
;
; Export:
;   Macro EIT_MUI_PAGE_INSTALLINFO is used to set the Page.
; -----------------------------------------------------------------------------

!include MUI2.nsh
!include LogicLib.nsh
!include WinMessages.nsh
!include FileFunc.nsh
!include nsDialogs.nsh



; -----------------------------------------------------------------------------
; Page interface settings and variables
!macro EIT_MUI_INSTALLINFOPAGE_INTERFACE

  !ifndef EIT_MUI_INSTALLINFOPAGE_INTERFACE
    !define EIT_MUI_INSTALLINFOPAGE_INTERFACE

    Var eit.mui.InstallInfoPage
    Var eit.mui.InstallInfoPage.Description    
    Var eit.mui.InstallInfoPage.Label    
    Var eit.mui.InstallInfoPage.EditText    

  !endif
  
  !ifndef MUI_${MUI_PAGE_UNINSTALLER_PREFIX}WELCOMEFINISHPAGE_BITMAPS
    !insertmacro MUI_DEFAULT MUI_${MUI_PAGE_UNINSTALLER_PREFIX}WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\win.bmp"  
  !endif

!macroend ; EIT_MUI_INSTALLINFOPAGE_INTERFACE


; -----------------------------------------------------------------------------
; Interface initialization
!macro EIT_MUI_INSTALLINFOPAGE_GUIINIT

  !ifndef EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}INSTALLINFOPAGE_GUINIT
    !define EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}INSTALLINFOPAGE_GUINIT

    Function ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}eit.mui.InstallInfoPage.GUIInit
      
      !ifdef MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT
        Call "${MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT}"
      !endif   

    FunctionEnd ; eit.mui.InstallTypePage.GUIInit

    !insertmacro MUI_SET MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT \
                         ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}eit.mui.InstallInfoPage.GUIInit

  !endif    

!macroend ; EIT_MUI_INSTALLINFOPAGE_GUIINIT


; -----------------------------------------------------------------------------
; Page declaration
!macro EIT_MUI_PAGEDECLARATION_INSTALLINFO  ${START_MENU_FOLDER} ${GET_SHORTCUT_INFO}

  !insertmacro MUI_SET EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}INSTALLINFOPAGE ""
  !insertmacro EIT_MUI_INSTALLINFOPAGE_INTERFACE

  !insertmacro EIT_MUI_INSTALLINFOPAGE_GUIINIT
  !define EIT_MUI_INSTALLINFOPAGE_START_MENU_FOLDER ${START_MENU_FOLDER}
  !define EIT_MUI_INSTALLINFOPAGE_GET_SHORTCUT_INFO ${GET_SHORTCUT_INFO}

  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLINFOPAGE_HEADER      "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INFO_HEADER)"
  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLINFOPAGE_SUBHEADER   "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INFO_SUBHEADER)"
  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLINFOPAGE_DESCRIPTION "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INFO_DESCRIPTION)"
  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLINFOPAGE_LABEL       "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INFO_DESCLABEL)"

  !insertmacro MUI_DEFAULT EIT_MUI_MSG_DESTINATION_DIRECTORY   "$(${MUI_PAGE_UNINSTALLER_PREFIX}MSG_INFO_DESTINATION_DIRECTORY)"
  !insertmacro MUI_DEFAULT EIT_MUI_MSG_INFO_PROGRAM_FOLDER     "$(${MUI_PAGE_UNINSTALLER_PREFIX}MSG_INFO_PROGRAM_FOLDER)"

  !insertmacro MUI_PAGE_FUNCTION_FULLWINDOW

  PageEx ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}custom

  PageCallbacks ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_InstallInfoPage.Pre_${MUI_UNIQUEID}  \
                ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_InstallInfoPage.Leave_${MUI_UNIQUEID}

  PageExEnd

  !insertmacro EIT_MUI_FUNCTION_INSTALLINFOPAGE ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_InstallInfoPage.Pre_${MUI_UNIQUEID}  \ 
                                                ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_InstallInfoPage.Leave_${MUI_UNIQUEID}

  !insertmacro MUI_UNSET EIT_MUI_INSTALLINFOPAGE_HEADER
  !insertmacro MUI_UNSET EIT_MUI_INSTALLINFOPAGE_SUBHEADER
  !insertmacro MUI_UNSET EIT_MUI_INSTALLINFOPAGE_DESCRIPTION

  !insertmacro MUI_UNSET EIT_MUI_MSG_DESTINATION_DIRECTORY
  !insertmacro MUI_UNSET EIT_MUI_MSG_INFO_PROGRAM_FOLDER

!macroend ; EIT_MUI_PAGEDECLARATION_INSTALLINFO


; -----------------------------------------------------------------------------
!macro EIT_MUI_PAGE_INSTALLINFO  START_MENU_FOLDER  GET_SHORTCUT_INFO

  !verbose push
  !verbose ${MUI_VERBOSE}

  !insertmacro MUI_PAGE_INIT
  !insertmacro EIT_MUI_PAGEDECLARATION_INSTALLINFO ${START_MENU_FOLDER} \
                                                   ${GET_SHORTCUT_INFO}

  !verbose pop

!macroend ; EIT_MUI_PAGE_INSTALLINFO


; -----------------------------------------------------------------------------
; Page functions
!macro EIT_MUI_FUNCTION_INSTALLINFOPAGE  PRE  LEAVE

  ; ---------------------------------------------------------------------------
  Function "${PRE}"

    !insertmacro MUI_PAGE_FUNCTION_CUSTOM PRE
    !insertmacro MUI_HEADER_TEXT_PAGE ${EIT_MUI_INSTALLINFOPAGE_HEADER} \
                                      ${EIT_MUI_INSTALLINFOPAGE_SUBHEADER}

    nsDialogs::Create /NOUNLOAD 1018
    Pop $eit.mui.InstallInfoPage

    ${if} $eit.mui.InstallInfoPage == error
      Abort
    ${endif}

    ; Description text
    StrCpy $0 "$(^Name)"
    ${NSD_CreateLabel} 0u 0u 300u 24u "${EIT_MUI_INSTALLINFOPAGE_DESCRIPTION}"
    Pop $eit.mui.InstallInfoPage.Description

    ; Label text
    ${NSD_CreateLabel} 0u 28u 300u 8u "${EIT_MUI_INSTALLINFOPAGE_LABEL}"
    Pop $eit.mui.InstallInfoPage.Label

    ; Info text
    nsDialogs::CreateControl /NOUNLOAD ${__NSD_Text_CLASS} \
        ${DEFAULT_STYLES}|${ES_MULTILINE}|${WS_VSCROLL}|${ES_READONLY}|${WS_GROUP}|{SS_BLACKFRAME} \
        ${WS_EX_STATICEDGE} \
        0u 40u 300u 98u  ""
    Pop $eit.mui.InstallInfoPage.EditText

    StrCpy $0  "$INSTDIR"
    StrCpy $R1 "${EIT_MUI_MSG_DESTINATION_DIRECTORY}"

    StrCpy $0  "${EIT_MUI_INSTALLINFOPAGE_START_MENU_FOLDER}"
    StrCpy $R1 "$R1${EIT_MUI_MSG_INFO_PROGRAM_FOLDER}"

    ${${EIT_MUI_INSTALLINFOPAGE_GET_SHORTCUT_INFO}}
    StrCpy $R1 "$R1$R0"

    SendMessage $eit.mui.InstallInfoPage.EditText ${WM_SETTEXT} 0 "STR:$R1"

;    StrCpy $0 "1234"
;    SendMessage $eit.mui.InstallInfoPage.EditText ${WM_SETTEXT} 0 "STR:${EIT_MUI_MSG_INFO_PROGRAM_FOLDER}"

    nsDialogs::Show

  FunctionEnd ; PRE


  ; ---------------------------------------------------------------------------
  Function "${LEAVE}"

    !insertmacro MUI_PAGE_FUNCTION_CUSTOM LEAVE

  FunctionEnd ; LEAVE

!macroend ; EIT_MUI_FUNCTION_INSTALLINFOPAGE
