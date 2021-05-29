/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
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

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qint64 startTime = QDateTime::currentMSecsSinceEpoch();
    KLocalizedString::setApplicationDomain("jing_record");
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    app.setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("kde.org");
    QCoreApplication::setApplicationName("KRecorder");

    qmlRegisterType<Recording>("KRecorder", 1, 0, "Recording");
    qmlRegisterType<AudioProber>("KRecorder", 1, 0, "AudioProber");

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


    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty("MainStartTime",startTime);
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    qint64 endTime = QDateTime::currentMSecsSinceEpoch();

    return app.exec();
}
