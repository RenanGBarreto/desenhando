; -----------------------------------------------------------------------------
; Page Istallation Type
;
; Export:
;   Function EIT_CheckAdminRights. It should be executed in the LEAVE
;   function of Page Welcom. If installation type common is required and  
;   process has not administrator privileges the installation will be
;   terminated.
;   
;   Macro MUI_PAGE_INSTALLTYPE. It is used to set the page. It has one 
;   argument a boolean variable. The value '1' will be assigned to the 
;   given variable, if the common installation type should be used. 
;   Otherwise the value '0' will be assigned. 
; -----------------------------------------------------------------------------

!include MUI2.nsh
!include LogicLib.nsh
!include WinMessages.nsh
!include FileFunc.nsh
!include nsDialogs.nsh

; -----------------------------------------------------------------------------
; Declaration of variables

Var eit.HasAdminRigth


; -----------------------------------------------------------------------------
; Check that administrator privileges are granted
; Parameters: register $R1 must include disired installation type. The valid 
; values for installation type: "auto" | "askuser" | "common" | "private".
; If installation type common is required and process has not administrator
; privileges the installation will be terminated.
Function EIT_CheckAdminRights
;   $R1 <- ${DESIRED_INSTALL_TYPE}

    ; eit.HasAdminRigth := 1 only if the user has administrative rights:
    StrCpy $eit.HasAdminRigth 0
    ClearErrors
    UserInfo::GetName
    IfErrors Win9x
    Goto WinOk
    Win9x:
      StrCpy $eit.HasAdminRigth 1
    WinOk:
    Pop $0
    UserInfo::GetAccountType
    Pop $1
    ${if} $1 == "Admin"
      StrCpy $eit.HasAdminRigth 1
    ${endif}

    ; It it is not have Admin rights and Common install type is selected then HALT
    ${if} "$R1" == "common"
      ${if} $eit.HasAdminRigth != 1
        MessageBox MB_OK|MB_ICONSTOP "$(MSG_NO_RIGHTS)"
        Quit
      ${endif}
    ${endif}
FunctionEnd ; EIT_CheckAdminRights


; -----------------------------------------------------------------------------
; Page interface settings and variables
!macro EIT_MUI_INSTALLTYPEPAGE_INTERFACE

  !ifndef EIT_MUI_INSTALLTYPEPAGE_INTERFACE
    !define EIT_MUI_INSTALLTYPEPAGE_INTERFACE

    Var eit.mui.InstallTypePage
    Var eit.mui.InstallTypePage.Description    
    Var eit.mui.InstallTypePage.Common
    Var eit.mui.InstallTypePage.Personal

  !endif
  
  !ifndef MUI_${MUI_PAGE_UNINSTALLER_PREFIX}WELCOMEFINISHPAGE_BITMAPS
    !insertmacro MUI_DEFAULT MUI_${MUI_PAGE_UNINSTALLER_PREFIX}WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\win.bmp"  
  !endif

!macroend ; EIT_MUI_INSTALLTYPEPAGE_INTERFACE


; -----------------------------------------------------------------------------
; Interface initialization
!macro EIT_MUI_INSTALLTYPEPAGE_GUIINIT

  !ifndef EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}INSTALLTYPEPAGE_GUINIT
    !define EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}INSTALLTYPEPAGE_GUINIT

    Function ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}eit.mui.InstallTypePage.GUIInit
      
      !ifdef MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT
        Call "${MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT}"
      !endif   

    FunctionEnd ; eit.mui.InstallTypePage.GUIInit

    !insertmacro MUI_SET MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT \
                         ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}eit.mui.InstallTypePage.GUIInit

  !endif    

!macroend ; EIT_MUI_INSTALLTYPEPAGE_GUIINIT


; -----------------------------------------------------------------------------
; Page declaration
!macro EIT_MUI_PAGEDECLARATION_INSTALLTYPE ${COMMON_SELECTED}

  !insertmacro MUI_SET EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}INSTALLTYPEPAGE ""
  !insertmacro EIT_MUI_INSTALLTYPEPAGE_INTERFACE
  
  !insertmacro EIT_MUI_INSTALLTYPEPAGE_GUIINIT
  !define EIT_MUI_INSTALLTYPEPAGE_COMMON_SELECTED ${COMMON_SELECTED}

  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLTYPEPAGE_HEADER      "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INSTALLTYPE_HEADER)"
  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLTYPEPAGE_SUBHEADER   "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INSTALLTYPE_SUBHEADER)"
  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLTYPEPAGE_DESCRIPTION "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INSTALLTYPE_DESCRIPTION)"
  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLTYPEPAGE_COMMON      "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INSTALLTYPE_COMMON)"
  !insertmacro MUI_DEFAULT EIT_MUI_INSTALLTYPEPAGE_PERSONAL    "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_INSTALLTYPE_PERSONAL)"
  
  !insertmacro MUI_PAGE_FUNCTION_FULLWINDOW

  PageEx ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}custom

  PageCallbacks ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_InstallTypePage.Pre_${MUI_UNIQUEID}  \
                ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_InstallTypePage.Leave_${MUI_UNIQUEID}

  PageExEnd

  !insertmacro EIT_MUI_FUNCTION_INSTALLTYPEPAGE ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_InstallTypePage.Pre_${MUI_UNIQUEID}  \
                                                ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_InstallTypePage.Leave_${MUI_UNIQUEID}

  !insertmacro MUI_UNSET EIT_MUI_INSTALLTYPEPAGE_HEADER
  !insertmacro MUI_UNSET EIT_MUI_INSTALLTYPEPAGE_SUBHEADER
  !insertmacro MUI_UNSET EIT_MUI_INSTALLTYPEPAGE_DESCRIPTION
  !insertmacro MUI_UNSET EIT_MUI_INSTALLTYPEPAGE_COMMON
  !insertmacro MUI_UNSET EIT_MUI_INSTALLTYPEPAGE_PERSONAL

!macroend ; EIT_MUI_PAGEDECLARATION_INSTALLTYPE


; -----------------------------------------------------------------------------
; Parameter COMMON_SELECTED must be a boolean variable. The value '1' 
; will be assigned to the given variable, if the common installation type 
; should be used. Otherwise  the value '0' is assigned. 
!macro EIT_MUI_PAGE_INSTALLTYPE  COMMON_SELECTED

  !verbose push
  !verbose ${MUI_VERBOSE}

  !insertmacro MUI_PAGE_INIT
  !insertmacro EIT_MUI_PAGEDECLARATION_INSTALLTYPE ${COMMON_SELECTED}

  !verbose pop

!macroend ; EIT_MUI_PAGE_INSTALLTYPE


; -----------------------------------------------------------------------------
; Page functions
!macro EIT_MUI_FUNCTION_INSTALLTYPEPAGE PRE LEAVE

  ; ---------------------------------------------------------------------------
  Function "${PRE}"

    ${switch} ${DESIRED_INSTALL_TYPE}
        ${case} "common"
            ${if} $eit.HasAdminRigth == 1
                StrCpy ${EIT_MUI_INSTALLTYPEPAGE_COMMON_SELECTED} 1
            ${else}
                MessageBox MB_OK|MB_ICONSTOP "Internal error: Admin expected" ; was not abandoned in CheckAdmin()?
                Quit
            ${endif}
            Abort
        ${break}

        ${case} "personal"
            StrCpy ${EIT_MUI_INSTALLTYPEPAGE_COMMON_SELECTED} 0
            Abort
        ${break}

        ${case} "auto"
            ${if} $eit.HasAdminRigth == 1
                StrCpy ${EIT_MUI_INSTALLTYPEPAGE_COMMON_SELECTED} 1
            ${else}
                StrCpy ${EIT_MUI_INSTALLTYPEPAGE_COMMON_SELECTED} 0
            ${endif}
            Abort
        ${break}
    ${endswitch}

    !insertmacro MUI_PAGE_FUNCTION_CUSTOM PRE

    !insertmacro MUI_HEADER_TEXT_PAGE ${EIT_MUI_INSTALLTYPEPAGE_HEADER} \
                                      ${EIT_MUI_INSTALLTYPEPAGE_SUBHEADER}

    nsDialogs::Create /NOUNLOAD 1018
    Pop $eit.mui.InstallTypePage

    ${if} $eit.mui.InstallTypePage == error
      Abort
    ${endif}

    ; Description text
    ${NSD_CreateLabel} 0u 0u 300u 8u "${EIT_MUI_INSTALLTYPEPAGE_DESCRIPTION}"
    Pop $eit.mui.InstallTypePage.Description

    ; Radio buttons
    ${NSD_CreateRadioButton} 16u 20u 284u 8u "${EIT_MUI_INSTALLTYPEPAGE_COMMON}"
    Pop $eit.mui.InstallTypePage.Common

    ${NSD_CreateRadioButton} 16u 36u 284u 8u "${EIT_MUI_INSTALLTYPEPAGE_PERSONAL}"
    Pop $eit.mui.InstallTypePage.Personal

    ${if} ${EIT_MUI_INSTALLTYPEPAGE_COMMON_SELECTED} != 0
      ${NSD_Check} $eit.mui.InstallTypePage.Common
    ${else}
      ${NSD_Check} $eit.mui.InstallTypePage.Personal
    ${endif}

    nsDialogs::Show

  FunctionEnd ; PRE


  ; ---------------------------------------------------------------------------
  Function "${LEAVE}"

    ${NSD_GetState} $eit.mui.InstallTypePage.Common $R0

    ${if} $R0 == ${BST_CHECKED}
      StrCpy ${EIT_MUI_INSTALLTYPEPAGE_COMMON_SELECTED} 1
    ${else}
      StrCpy ${EIT_MUI_INSTALLTYPEPAGE_COMMON_SELECTED} 0
    ${endif}

    !insertmacro MUI_PAGE_FUNCTION_CUSTOM LEAVE

  FunctionEnd ; LEAVE

!macroend ; EIT_MUI_FUNCTION_INSTALLTYPEPAGE
