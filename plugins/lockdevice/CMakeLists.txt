if (WIN32)
    list(APPEND lockdevice_SRCS lockdeviceplugin-win.cpp)
else ()
    list(APPEND lockdevice_SRCS lockdeviceplugin.cpp)
endif()

kdeconnect_add_plugin(kdeconnect_lockdevice SOURCES ${lockdevice_SRCS})

ecm_qt_declare_logging_category(kdeconnect_lockdevice
    HEADER plugin_lock_debug.h
    IDENTIFIER KDECONNECT_PLUGIN_LOCKREMOTE CATEGORY_NAME kdeconnect.plugin.lock
    DEFAULT_SEVERITY Warning
    EXPORT kdeconnect-kde DESCRIPTION "kdeconnect (plugin lockremote)")

target_link_libraries(kdeconnect_lockdevice
    kdeconnectcore
    kdeconnectinterfaces
    Qt::DBus
    KF${QT_MAJOR_VERSION}::I18n
)
