include(ECMPoQmTools)

# Determine if a .po file must be compiled into a .mo or a .qm file
file(GLOB po_files *.po)
set(mo_po_files)
set(qm_po_files)
foreach(po_file ${po_files})
    string(REGEX MATCH "_qt\\.po$" match "${po_file}")
    if(match)
        set(qm_po_files ${qm_po_files} ${po_file})
    else()
        set(mo_po_files ${mo_po_files} ${po_file})
    endif()
endforeach()

if(qm_po_files)
    ecm_process_po_files_as_qm(${CURRENT_LANG} ALL
        INSTALL_DESTINATION ${LOCALE_INSTALL_DIR}
        PO_FILES ${qm_po_files}
    )
endif()

if (mo_po_files)
    gettext_process_po_files(${CURRENT_LANG} ALL
        INSTALL_DESTINATION ${LOCALE_INSTALL_DIR}
        PO_FILES ${mo_po_files}
    )
endif()
