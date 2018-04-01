# cmake/modules/DownloadCodes.cmake

FUNCTION (LEIOT_GIT_CLONE dirname tag url dstdir)
    IF (EXISTS "${dstdir}/${dirname}")
        RETURN ()
    ENDIF ()
    MESSAGE (STATUS "Download ${dirname} with tag ${tag}, Please wait!")
    EXECUTE_PROCESS (
        COMMAND git clone -b ${tag} ${url}
        WORKING_DIRECTORY ${dstdir}
        TIMEOUT 900
        RESULT_VARIABLE result
        )
    IF (NOT ${result} EQUAL 0)
        MESSAGE (STATUS "Download ${dirname} with tag ${tag} fail!")
        IF (EXISTS "${dstdir}/${dirname}")
            EXECUTE_PROCESS (
                COMMAND rm -rf ${dstdir}/${dirname}
                WORKING_DIRECTORY ${dstdir}
                )
        ENDIF ()
        MESSAGE (FATAL_ERROR "Download manually in ${dstdir}: \n\tgit clone -b ${tag} ${url}\n")
    ENDIF (NOT ${result} EQUAL 0)
ENDFUNCTION ()

FUNCTION (LEIOT_SVN_CHECKOUT dirname tag url dstdir)
    MESSAGE (WARNING "Not impl")
    RETURN ()
ENDFUNCTION ()

FUNCTION (LEIOT_WGET_ARCHIVE dirname tag url dstdir)
    IF (EXISTS "${dstdir}/${dirname}")
        RETURN ()
    ENDIF ()
    MESSAGE (STATUS "Download ${dirname} with tag ${tag}, Please wait!")
    EXECUTE_PROCESS (
        COMMAND wget ${url}/archive/${tag}.zip
        TIMEOUT 900
        RESULT_VARIABLE result
        )
    IF (NOT ${result} EQUAL 0)
        MESSAGE (FATAL_ERROR "Download ${dirname} with tag ${tag} fail!")
    ELSE ()
        EXECUTE_PROCESS (
            COMMAND unzip ${tag}.zip -d tmpdir
            RESULT_VARIABLE result
            )
    ENDIF (NOT ${result} EQUAL 0)
    IF (NOT ${result} EQUAL 0)
        IF (EXISTS "${dstdir}/${dirname}")
            EXECUTE_PROCESS (
                COMMAND rm -rf ${dstdir}/${dirname}
                COMMAND rm -f ${tag}.zip
                )
        ENDIF ()
        MESSAGE (FATAL_ERROR "unzip ${tag}.zip error.\n")
    ELSE ()
        EXECUTE_PROCESS (
            COMMAND rm -f ${tag}.zip
            COMMAND ls tmpdir
            OUTPUT_VARIABLE srcdir
            )
        STRING(FIND ${srcdir} "\n" len)
        IF (${len} GREATER 1)
            STRING(SUBSTRING ${srcdir} 0 ${len} srcdir)
            EXECUTE_PROCESS (
                COMMAND mv tmpdir/${srcdir} ${dstdir}/${dirname}
                COMMAND rm -rf tmpdir
                )
        ENDIF ()
    ENDIF (NOT ${result} EQUAL 0)
ENDFUNCTION ()
