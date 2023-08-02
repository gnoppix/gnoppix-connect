/**
 * SPDX-FileCopyrightText: 2015 Albert Vaca <albertvaka@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#ifndef KDECONNECTPLUGINKCM_H
#define KDECONNECTPLUGINKCM_H

#include <KCModule>
#include <KPluginMetaData> // Not in KCModule header of older KF5 versions
#include <kconfigwidgets_version.h>

#include "core/kdeconnectpluginconfig.h"
#include "kdeconnectpluginkcm_export.h"

struct KdeConnectPluginKcmPrivate;

/**
 * Inheriting your plugin's KCM from this class gets you a easy way to share
 * configuration values between the KCM and the plugin.
 */
class KDECONNECTPLUGINKCM_EXPORT KdeConnectPluginKcm : public KCModule
{
    Q_OBJECT

public:
    KdeConnectPluginKcm(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    ~KdeConnectPluginKcm() override;

    /**
     * The device this kcm is instantiated for
     */
    QString deviceId() const;

    /**
     * The object where to save the config, so the plugin can access it
     */
    KdeConnectPluginConfig *config() const;

#if KCONFIGWIDGETS_VERSION < QT_VERSION_CHECK(5, 105, 0)
    QWidget *widget()
    {
        return this;
    }
#endif

private:
    QScopedPointer<KdeConnectPluginKcmPrivate> d;
};

#endif
