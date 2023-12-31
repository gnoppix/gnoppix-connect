kdeconnect_add_plugin(kdeconnect_pausemusic)

if(WIN32)
    target_sources(kdeconnect_pausemusic PRIVATE pausemusicplugin-win.cpp)
else()
    target_sources(kdeconnect_pausemusic PRIVATE pausemusicplugin.cpp)
endif()

ecm_qt_declare_logging_category(kdeconnect_pausemusic
    HEADER plugin_pausemusic_debug.h
    IDENTIFIER KDECONNECT_PLUGIN_PAUSEMUSIC CATEGORY_NAME kdeconnect.plugin.pausemusic
    DEFAULT_SEVERITY Warning
    EXPORT kdeconnect-kde DESCRIPTION "kdeconnect (plugin pausemusic)")

target_link_libraries(kdeconnect_pausemusic
    kdeconnectcore
    kdeconnectinterfaces
    Qt::Core
    Qt::DBus
)
if (WIN32)
    target_link_libraries(kdeconnect_pausemusic windowsapp)
    target_compile_features(kdeconnect_pausemusic PUBLIC cxx_std_17)
else()
    target_link_libraries(kdeconnect_pausemusic KF${QT_MAJOR_VERSION}::PulseAudioQt)
endif()

#######################################
# Config

kcoreaddons_add_plugin(kdeconnect_pausemusic_config SOURCES pausemusic_config.cpp INSTALL_NAMESPACE "kdeconnect/kcms")

ki18n_wrap_ui(kdeconnect_pausemusic_config pausemusic_config.ui)
target_link_libraries(kdeconnect_pausemusic_config
    kdeconnectcore
    kdeconnectpluginkcm
    KF${QT_MAJOR_VERSION}::I18n
    KF${QT_MAJOR_VERSION}::KCMUtils
)
