################################
# Sokol
################################

if(BUILD_SOKOL)

    if(APPLE)
        set(SOKOL_LIB_SRC ${CMAKE_SOURCE_DIR}/src/system/sokol/sokol.m)
    else()
        set(SOKOL_LIB_SRC ${CMAKE_SOURCE_DIR}/src/system/sokol/sokol.c)
    endif()

    add_library(sokol STATIC ${SOKOL_LIB_SRC})

    if(APPLE)
        target_compile_definitions(sokol PRIVATE SOKOL_METAL)
        target_link_libraries(sokol
            "-framework Cocoa"
            "-framework QuartzCore"
            "-framework Metal"
            "-framework MetalKit"
            "-framework AudioToolbox"
        )
    elseif(WIN32)
        target_compile_definitions(sokol PRIVATE SOKOL_D3D11)
        target_link_libraries(sokol PRIVATE D3D11)
    elseif(LINUX)
        target_compile_definitions(sokol PRIVATE SOKOL_GLCORE)
        target_link_libraries(sokol PRIVATE X11 Xcursor Xi GL m dl asound)
    elseif(ANDROID)
        target_compile_definitions(sokol PRIVATE SOKOL_GLES3)
        target_link_libraries(sokol PRIVATE android log aaudio EGL GLESv2 GLESv3)
    elseif(EMSCRIPTEN)
        target_compile_definitions(sokol PRIVATE SOKOL_WGPU)
    endif()

    target_include_directories(sokol PRIVATE ${THIRDPARTY_DIR}/sokol)

    if(BUILD_PLAYER)

        add_executable(player WIN32 ${CMAKE_SOURCE_DIR}/src/system/sokol/player.c)

        if(MINGW)
            target_link_libraries(player mingw32)
            target_link_options(player PRIVATE -static)
        endif()

        target_include_directories(player PRIVATE
            ${CMAKE_SOURCE_DIR}/include
            ${THIRDPARTY_DIR}/sokol
            ${CMAKE_SOURCE_DIR}/src)

        target_link_libraries(player tic80core sokol)
    endif()

    set(TIC80_SRC ${CMAKE_SOURCE_DIR}/src/system/sokol/main.c)

    if(WIN32)

        configure_file("${PROJECT_SOURCE_DIR}/build/windows/tic80.rc.in" "${PROJECT_SOURCE_DIR}/build/windows/tic80.rc")
        set(TIC80_SRC ${TIC80_SRC} "${PROJECT_SOURCE_DIR}/build/windows/tic80.rc")

        add_executable(${TIC80_TARGET} WIN32 ${TIC80_SRC})
    elseif(ANDROID)
        add_library(${TIC80_TARGET} SHARED ${TIC80_SRC})
        set_target_properties(${TIC80_TARGET} PROPERTIES PREFIX "")
    else()
        add_executable(${TIC80_TARGET} ${TIC80_SRC})

        if(EMSCRIPTEN)
            set_target_properties(${TIC80_TARGET} PROPERTIES LINK_FLAGS "-s USE_WEBGPU=1 -s ALLOW_MEMORY_GROWTH=1 -s FETCH=1 --pre-js ${CMAKE_SOURCE_DIR}/build/html/prejs.js -lidbfs.js")
        endif()
    endif()

    target_include_directories(${TIC80_TARGET} PRIVATE
        ${CMAKE_SOURCE_DIR}/include
        ${CMAKE_SOURCE_DIR}/src
        ${THIRDPARTY_DIR}/sokol)

    if(MINGW)
        target_link_libraries(${TIC80_TARGET} mingw32)
        target_link_options(${TIC80_TARGET} PRIVATE -static -mconsole)
    endif()

    target_link_libraries(${TIC80_TARGET} tic80studio sokol)

endif()