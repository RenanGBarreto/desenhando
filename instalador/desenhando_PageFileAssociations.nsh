; -----------------------------------------------------------------------------
; Page File Extension Associations
;
; Export:
;   Macro EIT_MUI_PAGE_FILEASSOCIATIONS is used to set the Page.
;
;   Macro EIT_MUI_PAGE_FILEASSOCIATIONS_ADD_EXTENSION is used to add 
;   file association on the Page.
;
;   Macro EIT_MUI_PAGE_FILEASSOCIATIONS_CREATE is used to create 
;   selected file association.
; -----------------------------------------------------------------------------

!include MUI2.nsh
!include LogicLib.nsh
!include WinMessages.nsh
!include FileFunc.nsh
!include nsDialogs.nsh

; -----------------------------------------------------------------------------
; The default state of the checkbox that enables installing the association.

!define EIT_MUI_FILE_ASSOCIATION_STATE_ENABLE   ${BST_CHECKED}
!define EIT_MUI_FILE_ASSOCIATION_STATE_DISABLE  ${BST_UNCHECKED}


; -----------------------------------------------------------------------------
; Aply the givemn action to all possible file association entries
!macro EIT_MUI_FILE_ASSOCIATION_ITERATE_ENTRIES  ACTION  ARGUMENTS

  ${${ACTION}} 1 ${ARGUMENTS} 
  ${${ACTION}} 2 ${ARGUMENTS} 
  ${${ACTION}} 3 ${ARGUMENTS} 
  ${${ACTION}} 4 ${ARGUMENTS} 
  ${${ACTION}} 5 ${ARGUMENTS} 
  ${${ACTION}} 6 ${ARGUMENTS} 

!macroend
!define EIT_MUI_FILE_ASSOCIATION_IterateEntries '!insertmacro EIT_MUI_FILE_ASSOCIATION_ITERATE_ENTRIES'


; -----------------------------------------------------------------------------
; Define variables and mocros for the given file association entry
!macro EIT_MUI_FILE_ASSOCIATION_DEFINE_ENTRY  ENTRY_INDEX  \
                                              FILE_EXT APPLICATION_NAME DEFAULT_STATE \
                                              DESCRIPTION COMMAND ARGUMENTS

  !ifndef EIT_MUI_FILE_ASSOCIATION_ENTRY_DEFINED
    !ifndef EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}
      !define EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}

      Var eit.mui.FileAssociationPage.Entry${ENTRY_INDEX}        
      Var eit.mui.FileAssociationPage.Entry${ENTRY_INDEX}.State        

      !define EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_FILE_EXT         "${FILE_EXT}"
      !define EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_APPLICATION_NAME "${APPLICATION_NAME}"
      !define EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_DEFAULT_STATE    "${DEFAULT_STATE}"
      !define EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_DESCRIPTION      "${DESCRIPTION}"
      !define EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_COMMAND          "${COMMAND}"
      !define EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_ARGUMENTS        "${ARGUMENTS}"

      !define EIT_MUI_FILE_ASSOCIATION_ENTRY_DEFINED

      !ifndef EIT_MUI_FILE_ASSOCIATION_ENABLED 
        !define EIT_MUI_FILE_ASSOCIATION_ENABLED
      !endif

    !endif
  !endif

!macroend ; EIT_MUI_FILE_ASSOCIATION_DEFINE_ENTRY
!define EIT_MUI_FILE_ASSOCIATION_DefineEntry '!insertmacro EIT_MUI_FILE_ASSOCIATION_DEFINE_ENTRY'


; -----------------------------------------------------------------------------
; Add on the Page a file associarion entry for the given file extension 
!macro EIT_MUI_PAGE_FILEASSOCIATIONS_ADD_EXTENSION  FILE_EXT APPLICATION_NAME DEFAULT_STATE \
                                                    DESCRIPTION COMMAND ARGUMENTS

  !ifdef EIT_MUI_FILE_ASSOCIATION_ENTRY_DEFINED
    !undef EIT_MUI_FILE_ASSOCIATION_ENTRY_DEFINED
  !endif

  ${EIT_MUI_FILE_ASSOCIATION_IterateEntries} EIT_MUI_FILE_ASSOCIATION_DefineEntry \
                                             '"${FILE_EXT}" "${APPLICATION_NAME}" "${DEFAULT_STATE}" \
                                             "${DESCRIPTION}" "${COMMAND}" "${ARGUMENTS}"'

  !ifndef EIT_MUI_FILE_ASSOCIATION_ENTRY_DEFINED
    !error "The limit of file associations are exceeded"
  !else
    !undef EIT_MUI_FILE_ASSOCIATION_ENTRY_DEFINED
  !endif

!macroend ; EIT_MUI_PAGE_FILEASSOCIATIONS_ADD_EXTENSION
!define EIT_MUI_PAGE_FILEASSOCIATIONS_AddExtensions '!insertmacro EIT_MUI_PAGE_FILEASSOCIATIONS_ADD_EXTENSION'


; -----------------------------------------------------------------------------
; Page interface settings and variables
!macro EIT_MUI_FILEASSOCIATIONPAGE_INTERFACE

  !ifndef EIT_MUI_FILEASSOCIATIONPAGE_INTERFACE
    !define EIT_MUI_FILEASSOCIATIONPAGE_INTERFACE

    Var eit.mui.FileAssociationPage
    Var eit.mui.FileAssociationPage.Description    
    Var eit.mui.FileAssociationPage.y    

  !endif
  
  !ifndef MUI_${MUI_PAGE_UNINSTALLER_PREFIX}WELCOMEFINISHPAGE_BITMAPS
    !insertmacro MUI_DEFAULT MUI_${MUI_PAGE_UNINSTALLER_PREFIX}WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\win.bmp"  
  !endif

!macroend ; EIT_MUI_FILEASSOCIATIONPAGE_INTERFACE


; -----------------------------------------------------------------------------
; Set initial state for the given file association entry
!macro EIT_MUI_FILE_ASSOCIATION_INIT_ENTRY  ENTRY_INDEX 

  !ifdef EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}

    StrCpy $eit.mui.FileAssociationPage.Entry${ENTRY_INDEX}.State \
           "${${EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_DEFAULT_STATE}}"

  !endif

!macroend 
!define EIT_MUI_FILE_ASSOCIATION_InitEntry '!insertmacro EIT_MUI_FILE_ASSOCIATION_INIT_ENTRY'


; -----------------------------------------------------------------------------
; Interface initialization
!macro EIT_MUI_FILEASSOCIATIONPAGE_GUIINIT

  !ifndef EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}FILEASSOCIATIONPAGE_GUINIT
    !define EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}FILEASSOCIATIONPAGE_GUINIT

    Function ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}eit.mui.FileAssociationPage.GUIInit
      
      ${EIT_MUI_FILE_ASSOCIATION_IterateEntries} EIT_MUI_FILE_ASSOCIATION_InitEntry ""

      !ifdef MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT
        Call "${MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT}"
      !endif   

    FunctionEnd ; eit.mui.FileAssociationPage.GUIInit

    !insertmacro MUI_SET MUI_${MUI_PAGE_UNINSTALLER_PREFIX}PAGE_FUNCTION_GUIINIT \
                         ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}eit.mui.FileAssociationPage.GUIInit

  !endif    

!macroend ; EIT_MUI_FILEASSOCIATIONPAGE_GUIINIT


; -----------------------------------------------------------------------------
; Page declaration
!macro EIT_MUI_PAGEDECLARATION_FILEASSOCIATION  CREATE_FILE_ASSOCIATION

  !insertmacro MUI_SET EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}FILEASSOCIATIONPAGE ""
  !insertmacro EIT_MUI_FILEASSOCIATIONPAGE_INTERFACE

  !insertmacro EIT_MUI_FILEASSOCIATIONPAGE_GUIINIT
  !define EIT_MUI_FILEASSOCIATION_CREATE_FILE_ASSOCIATION ${CREATE_FILE_ASSOCIATION}

  !insertmacro MUI_DEFAULT EIT_MUI_FILEASSOCIATIONPAGE_HEADER      "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_FILEASSOCIATION_HEADER)"
  !insertmacro MUI_DEFAULT EIT_MUI_FILEASSOCIATIONPAGE_SUBHEADER   "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_FILEASSOCIATION_SUBHEADER)"
  !insertmacro MUI_DEFAULT EIT_MUI_FILEASSOCIATIONPAGE_DESCRIPTION "$(EIT_MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_FILEASSOCIATION_DESCRIPTION)"

  !insertmacro MUI_PAGE_FUNCTION_FULLWINDOW

  PageEx ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}custom

  PageCallbacks ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_FileAssociationPage.Pre_${MUI_UNIQUEID}  \
                ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_FileAssociationPage.Leave_${MUI_UNIQUEID}
  
  PageExEnd

  !insertmacro EIT_MUI_FUNCTION_FILEASSOCIATIONPAGE ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_FileAssociationPage.Pre_${MUI_UNIQUEID}  \
                                                    ${MUI_PAGE_UNINSTALLER_FUNCPREFIX}EIT_MUI_FileAssociationPage.Leave_${MUI_UNIQUEID}
        
  !insertmacro MUI_UNSET EIT_MUI_FILEASSOCIATIONPAGE_HEADER
  !insertmacro MUI_UNSET EIT_MUI_FILEASSOCIATIONPAGE_SUBHEADER
  !insertmacro MUI_UNSET EIT_MUI_FILEASSOCIATIONPAGE_DESCRIPTION

!macroend ; EIT_MUI_PAGEDECLARATION_FILEASSOCIATION


; -----------------------------------------------------------------------------
; CREATE_FILE_ASSOCIATION is a macro to be used to create file extension  
; associations whitch are selected by the user.
!macro EIT_MUI_PAGE_FILEASSOCIATIONS  CREATE_FILE_ASSOCIATION

  !ifdef EIT_MUI_FILE_ASSOCIATION_ENABLED 
    !verbose push
    !verbose ${MUI_VERBOSE}

    !insertmacro MUI_PAGE_INIT
    !insertmacro EIT_MUI_PAGEDECLARATION_FILEASSOCIATION ${CREATE_FILE_ASSOCIATION}

    !verbose pop
  !endif

!macroend ; EIT_MUI_PAGE_FILEASSOCIATIONS



; -----------------------------------------------------------------------------
!macro EIT_MUI_FILEASSOCIATION_CREATE_CHECKBOX  ENTRY_INDEX  YPOS

  !ifdef EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}

    StrCpy $0 "${EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_FILE_EXT}"
    StrCpy $1 "${EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_APPLICATION_NAME}"

    ${NSD_CreateCheckBox} 16u ${YPOS}u 284u 8u "$(MSG_FILEEXTS_TEMPLATE)"
    Pop $eit.mui.FileAssociationPage.Entry${ENTRY_INDEX}

    ${NSD_SetState} $eit.mui.FileAssociationPage.Entry${ENTRY_INDEX} \
                    $eit.mui.FileAssociationPage.Entry${ENTRY_INDEX}.State

    IntOp  ${YPOS} ${YPOS} + 16

  !endif

!macroend
!define EIT_MUI_FILE_ASSOCIATION_CreateCheckbox '!insertmacro EIT_MUI_FILEASSOCIATION_CREATE_CHECKBOX'


; -----------------------------------------------------------------------------
!macro EIT_MUI_FILEASSOCIATION_SAVE_CHECKBOX_STATE  ENTRY_INDEX

  !ifdef EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}

    ${NSD_GetState} $eit.mui.FileAssociationPage.Entry${ENTRY_INDEX} \
                    $eit.mui.FileAssociationPage.Entry${ENTRY_INDEX}.State

  !endif

!macroend ; EIT_MUI_FILEASSOCIATION_SAVE_CHECKBOX_STATE
!define EIT_MUI_FILE_ASSOCIATION_SaveCheckboxState '!insertmacro EIT_MUI_FILEASSOCIATION_SAVE_CHECKBOX_STATE'


; -----------------------------------------------------------------------------
; Page functions
!macro EIT_MUI_FUNCTION_FILEASSOCIATIONPAGE  PRE  LEAVE

  ; ---------------------------------------------------------------------------
  Function "${PRE}"

    !ifndef EIT_MUI_FILE_ASSOCIATION_ENABLED 
      Abort
    !endif

    !insertmacro MUI_PAGE_FUNCTION_CUSTOM PRE
    !insertmacro MUI_HEADER_TEXT_PAGE ${EIT_MUI_FILEASSOCIATIONPAGE_HEADER} \
                                      ${EIT_MUI_FILEASSOCIATIONPAGE_SUBHEADER}

    nsDialogs::Create /NOUNLOAD 1018
    Pop $eit.mui.FileAssociationPage

    ${if} $eit.mui.FileAssociationPage == error
      Abort
    ${endif}

    ; Description text
    ${NSD_CreateLabel} 0u 0u 300u 8u "${EIT_MUI_FILEASSOCIATIONPAGE_DESCRIPTION}"
    Pop $eit.mui.FileAssociationPage.Description

    ; CheckBoxes
    StrCpy $eit.mui.FileAssociationPage.y  20
    ${EIT_MUI_FILE_ASSOCIATION_IterateEntries} EIT_MUI_FILE_ASSOCIATION_CreateCheckbox \
                                               $eit.mui.FileAssociationPage.y

    nsDialogs::Show

  FunctionEnd ; PRE


  ; ---------------------------------------------------------------------------
  Function "${LEAVE}"

    ${EIT_MUI_FILE_ASSOCIATION_IterateEntries} EIT_MUI_FILE_ASSOCIATION_SaveCheckboxState ""

    !insertmacro MUI_PAGE_FUNCTION_CUSTOM LEAVE

  FunctionEnd ; LEAVE

!macroend ; EIT_MUI_FUNCTION_FILEASSOCIATIONPAGE



; -----------------------------------------------------------------------------
!macro EIT_MUI_FILE_ASSOCIATION_PROCESS_ENTRY  ENTRY_INDEX

  !ifdef EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}

    ${if} "$eit.mui.FileAssociationPage.Entry${ENTRY_INDEX}.State" == "${EIT_MUI_FILE_ASSOCIATION_STATE_ENABLE}"
      ${${EIT_MUI_FILEASSOCIATION_CREATE_FILE_ASSOCIATION}}             \
          "${EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_FILE_EXT}"    \
          "${EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_DESCRIPTION}" \
          "${EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_COMMAND}"     \
          "${EIT_MUI_FILEASSOCIATION_ENTRY_${ENTRY_INDEX}_ARGUMENTS}"
    ${endif}

  !endif

!macroend
!define EIT_MUI_FILE_ASSOCIATION_ProcessEntry '!insertmacro EIT_MUI_FILE_ASSOCIATION_PROCESS_ENTRY'


; -----------------------------------------------------------------------------
; Create selected file association.
!macro EIT_MUI_PAGE_FILEASSOCIATIONS_CREATE_FILE_ASSOCIATIONS

  !ifdef EIT_MUI_FILE_ASSOCIATION_ENABLED 
    ${EIT_MUI_FILE_ASSOCIATION_IterateEntries} EIT_MUI_FILE_ASSOCIATION_ProcessEntry ""
  !endif

!macroend ; EIT_MUI_PAGE_FILEASSOCIATIONS_CREATE_FILE_ASSOCIATIONS
!define EIT_MUI_PAGE_FILEASSOCIATIONS_CreateFileAssociation '!insertmacro EIT_MUI_PAGE_FILEASSOCIATIONS_CREATE_FILE_ASSOCIATIONS'
