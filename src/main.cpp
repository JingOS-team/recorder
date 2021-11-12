/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Zhang He Gang <zhanghegang@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedString>
#include <KLocalizedContext>
#include <QAudioRecorder>
#include "recordingmodel.h"
#include "utils.h"
#include "audioplayer.h"
#include "audiorecorder.h"
#include "audioprober.h"
#include "settingsmodel.h"
#include <QDateTime>
#include <QQmlDebuggingEnabler>
#include<japplicationqt.h>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QString appVersion = "1.0-dev";
    qint64 startTime = QDateTime::currentMSecsSinceEpoch();
    qDebug()<<Q_FUNC_INFO << " loadtime:: main start time:" << startTime;
    KLocalizedString::setApplicationDomain("jing_record");
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    JApplicationQt japp;
    japp.enableBackgroud(true);
    QObject::connect(qApp, &QCoreApplication::aboutToQuit, [](){
        qDebug() << "aboutToQuit";
        AudioRecorder::instance()->stopRecording();
        emit RecordingModel::instance()->quitApp();
    });
    app.setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    app.setApplicationVersion(appVersion);
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("kde.org");
    QCoreApplication::setApplicationName("Voice Memos");
    qmlRegisterType<Recording>("KRecorder", 1, 0, "Recording");
    qmlRegisterType<AudioProber>("KRecorder", 1, 0, "AudioProber");

    qDebug()<<Q_FUNC_INFO << " loadtime:: main qmlRegisterType time:" << (QDateTime::currentMSecsSinceEpoch() - startTime);
    qmlRegisterSingletonType<Utils>("KRecorder", 1, 0, "Utils", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return new Utils;
    });
    qmlRegisterSingletonType<SettingsModel>("KRecorder", 1, 0, "AudioPlayer", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return AudioPlayer::instance();
    });
    qmlRegisterSingletonType<SettingsModel>("KRecorder", 1, 0, "AudioRecorder", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return AudioRecorder::instance();
    });
    qmlRegisterSingletonType<RecordingModel>("KRecorder", 1, 0, "RecordingModel", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return RecordingModel::instance();
    });
    qmlRegisterSingletonType<SettingsModel>("KRecorder", 1, 0, "SettingsModel", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return SettingsModel::instance();
    });
    qDebug()<<Q_FUNC_INFO << " main qmlRegisterSingletonType time:" << (QDateTime::currentMSecsSinceEpoch() - startTime);


    QSettings settings;
    QString appVersionKey = "appVersion";
    QString cacheAppVersion = settings.value(appVersionKey,"").toString();
    qDebug()<<Q_FUNC_INFO << " cacheAppVersion: " << cacheAppVersion;
    if(cacheAppVersion != appVersion){
        QDir qmlCachePath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/qmlcache");

        if(qmlCachePath.exists()){
            bool isSuc = qmlCachePath.removeRecursively();
        }
    }
    settings.setValue(appVersionKey,appVersion);
    QQmlDebuggingEnabler::startTcpDebugServer(8003, QQmlDebuggingEnabler::WaitForClient);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty("MainStartTime",startTime);
    qint64 loadUrlBeforeTime = QDateTime::currentMSecsSinceEpoch();

    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
