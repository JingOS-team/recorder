#
# SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

set(krecorder_SRCS
    main.cpp
    audiorecorder.cpp
    audioplayer.cpp
    recordingmodel.cpp
    audioprober.cpp
    utils.cpp
    waveutil.cpp
    settingsmodel.cpp
    resources.qrc
)

add_executable(krecorder ${krecorder_SRCS})

find_package(Taglib REQUIRED)
#externalproject_add(taglib
#     URL http://taglib.org/releases/taglib-1.11.1.tar.gz
#     CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
#     )
# set(TAGLIB_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include ${CMAKE_INSTALL_PREFIX}/include/#taglib)
 #set(TAGLIB_LIBRARIES ${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}/libtag.so)

# add_dependencies(krecorder taglib)



target_include_directories(krecorder PRIVATE ${TAGLIB_INCLUDE_DIRS})
target_link_libraries(krecorder 
    Qt5::Core 
    Qt5::Gui 
    Qt5::Qml 
    Qt5::Quick 
    Qt5::Widgets 
    Qt5::QuickControls2 
    Qt5::Multimedia 
    KF5::I18n
    KF5::ConfigGui
    KF5::CoreAddons
    Qt5::QuickControls2
    Qt5::DBus
    KF5::ConfigCore
    jappcoreqt
    mediainfo
)

install(TARGETS krecorder ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
if(CMAKE_SYSTEM_NAME STREQUAL "Android")
    kirigami_package_breeze_icons(ICONS
        media-playback-pause media-playback-start
        media-playback-stop media-record microphone
        entry-edit delete settings-configure
    )

    find_package(Qt5Svg REQUIRED)
    target_link_libraries(krecorder Qt5::Svg)
endif()
