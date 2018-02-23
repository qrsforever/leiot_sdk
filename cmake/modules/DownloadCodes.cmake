# cmake/modules/DownloadCodes.cmake

FUNCTION (LEIOT_GIT_CLONE dirname tag url workdir)
    IF (EXISTS "${workdir}/${dirname}")
        RETURN ()
    ENDIF ()
    MESSAGE (STATUS "Download ${dirname} with tag ${tag}, Please wait!")
    EXECUTE_PROCESS (
        COMMAND git clone -b ${tag} ${url}
        WORKING_DIRECTORY ${workdir}
        TIMEOUT 900
        RESULT_VARIABLE result
        )
    IF (NOT ${result} EQUAL 0)
        MESSAGE (STATUS "Download ${dirname} with tag ${tag} fail!")
        IF (EXISTS "${workdir}/${dirname}")
            EXECUTE_PROCESS (
                COMMAND rm -rf ${workdir}/${dirname}
                WORKING_DIRECTORY ${workdir}
                )
        ENDIF ()
        MESSAGE (FATAL_ERROR "Download manually in ${workdir}: \n\tgit clone -b ${tag} ${url}\n")
    ENDIF (NOT ${result} EQUAL 0)
ENDFUNCTION ()

FUNCTION (LEIOT_SVN_CHECKOUT dirname tag url workdir)
    MESSAGE (WARNING "Not impl")
    RETURN ()
ENDFUNCTION ()
