cmake_minimum_required(VERSION 3.16)

# KDE Release Service Version, managed by release script
set (RELEASE_SERVICE_VERSION_MAJOR "23")
set (RELEASE_SERVICE_VERSION_MINOR "11")
set (RELEASE_SERVICE_VERSION_MICRO "70")
set (RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")

project(kdeconnect VERSION ${RELEASE_SERVICE_VERSION})

set(KF_MIN_VERSION "5.101.0")
set(QT_MIN_VERSION "5.15.2")

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)

include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMAddTests)
include(ECMSetupVersion)
include(ECMInstallIcons)
include(ECMQtDeclareLoggingCategory)
include(FeatureSummary)
include(GenerateExportHeader)
include(ECMGenerateQmlTypes)
include(KDEClangFormat)
include(KDEGitCommitHooks)
include(ECMFindQmlModule)
include(ECMQmlModule)
include(ECMDeprecationSettings)

include(KDEConnectMacros.cmake)

ecm_setup_version(${RELEASE_SERVICE_VERSION}
    VARIABLE_PREFIX KDECONNECT
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/kdeconnect-version.h
)

if(QT_MAJOR_VERSION STREQUAL "6")
    set(KIRIGAMI_ICON "icon.name")
    set(KIRIGAMI_PAGE_ACTIONS "actions")
    set(QTQUICK_FILEDIALOG_FOLDER "currentFolder")
else()
    set(QTQUICK_DIALOGS_IMPORT_VERSION 1.0)
    set(KIRIGAMI_ICON "icon")
    set(KIRIGAMI_PAGE_ACTIONS "contextualActions")
    set(QTQUICK_FILEDIALOG_FOLDER "folder")
endif()

ecm_set_disabled_deprecation_versions(
    QT ${QT_MIN_VERSION}
    KF ${KF_MIN_VERSION}
)

# Make the version header available by linking against kdeconnectversion
add_library(kdeconnectversion INTERFACE)
target_include_directories(kdeconnectversion INTERFACE ${CMAKE_CURRENT_BINARY_DIR})

set(KF5_REQUIRED_COMPONENTS I18n ConfigWidgets DBusAddons IconThemes Notifications KIO KCMUtils Service Solid Kirigami2 People WindowSystem GuiAddons DocTools)

set_package_properties(KF${QT_MAJOR_VERSION}Kirigami2 PROPERTIES
    DESCRIPTION "QtQuick plugins to build user interfaces based on KDE UX guidelines"
    PURPOSE "Required for KDE Connect's QML-based GUI applications"
    URL "https://www.kde.org/products/kirigami/"
    TYPE RUNTIME
)

if(UNIX AND NOT APPLE)
    option(WITH_X11 "Build with X11 support" ON)
    option(WITH_PULSEAUDIO "Build with Pulseaudio support" ON)
else()
    set(WITH_X11 OFF)
    set(WITH_PULSEAUDIO OFF)
endif()

if(UNIX AND NOT APPLE)
    find_package(KF${QT_MAJOR_VERSION}Package REQUIRED)
    if (WITH_PULSEAUDIO)
        find_package(KF${QT_MAJOR_VERSION}PulseAudioQt REQUIRED)
    endif()
    find_package(QtWaylandScanner REQUIRED)
    find_package(Wayland 1.9 REQUIRED Client)
    find_package(Qt${QT_MAJOR_VERSION} REQUIRED COMPONENTS WaylandClient)
    find_package(WaylandProtocols REQUIRED)
    pkg_check_modules(XkbCommon IMPORTED_TARGET xkbcommon)
    pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)
endif()

find_package(KF5PeopleVCard)
set_package_properties(KF5PeopleVCard PROPERTIES
    PURPOSE "Read vcards from the file system"
    URL "https://invent.kde.org/pim/kpeoplevcard"
    TYPE RUNTIME
)

#ecm_find_qmlmodule(org.kde.people 1.0) FIXME This results in KPeople code being called which triggers DBus calls which breaks the Windows CI
ecm_find_qmlmodule(QtQuick.Particles 2.0)

add_definitions(-DQT_NO_URL_CAST_FROM_STRING -DQT_NO_KEYWORDS -DQT_NO_CAST_FROM_ASCII)

find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} REQUIRED COMPONENTS DBus Quick QuickControls2 Network Multimedia)
if (UNIX AND NOT APPLE AND QT_MAJOR_VERSION EQUAL "5")
    find_package(Qt5 ${QT_MIN_VERSION} REQUIRED COMPONENTS X11Extras)
endif()
find_package(KF${QT_MAJOR_VERSION} ${KF_MIN_VERSION} REQUIRED COMPONENTS ${KF5_REQUIRED_COMPONENTS})

if (WIN32)
    get_filename_component(WINDOWS_KITS_DIR
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot10]" ABSOLUTE)
    file(READ "${WINDOWS_KITS_DIR}/SDKManifest.xml" SDK_MANIFEST)
    string(REGEX MATCH "PlatformIdentity[^\n]*" PLATFORM_IDENTITY "${SDK_MANIFEST}" )
    string(REGEX MATCH "[0-9][0-9][0-9][0-9][0-9]" WIN_SDK_VERSION "${PLATFORM_IDENTITY}" )
    add_compile_definitions(WIN_SDK_VERSION=${WIN_SDK_VERSION})
endif()

add_subdirectory(core)
add_subdirectory(plugins)
add_subdirectory(interfaces)

find_package(KF${QT_MAJOR_VERSION}QQC2DesktopStyle ${KF_MIN_VERSION} REQUIRED)
set_package_properties(KF${QT_MAJOR_VERSION}QQC2DesktopStyle PROPERTIES TYPE RUNTIME)

add_subdirectory(icons)
add_subdirectory(data)
add_subdirectory(cli)
add_subdirectory(declarativeplugin)

add_subdirectory(kcm)
add_subdirectory(kcmplugin)
add_subdirectory(daemon)
add_subdirectory(app)
add_subdirectory(indicator)
add_subdirectory(urlhandler)
add_subdirectory(nautilus-extension)
add_subdirectory(fileitemactionplugin)
add_subdirectory(smsapp)
add_subdirectory(settings)

if(NOT WIN32 AND NOT APPLE)
    add_subdirectory(kio)
    add_subdirectory(plasmoid)
endif()

add_subdirectory(doc)
kdoctools_install(po)

ki18n_install(po)

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

ecm_qt_install_logging_categories(EXPORT kdeconnect-kde FILE kdeconnect-kde.categories SORT DESTINATION "${KDE_INSTALL_LOGGINGCATEGORIESDIR}")

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
