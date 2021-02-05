/*
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef AUDIOPLAYER_H
#define AUDIOPLAYER_H

#include <QMediaPlayer>
#include <QAudioProbe>
#include <QQmlEngine>
#include <QUrl>
#include <QCoreApplication>
#include <audioprober.h>

class AudioPlayer;
static AudioPlayer *s_audioPlayer = nullptr;

class AudioPlayer : public QMediaPlayer
{
    Q_OBJECT
    Q_PROPERTY(AudioProber *prober READ prober CONSTANT)
    Q_PROPERTY(int playPosition READ getPosition NOTIFY propertyChanged)

public:
    static AudioPlayer *instance()
    {
        if (!s_audioPlayer) {
            s_audioPlayer = new AudioPlayer(qApp);
        }
        return s_audioPlayer;
    }

    void handleStateChange(QMediaPlayer::State state);
    void positionChange(qint64 position);

    Q_INVOKABLE int getPosition()
    {
        return currentPosition;
    }

    AudioProber *prober()
    {
        return m_audioProbe;
    }

    Q_INVOKABLE void clearVolumnList()
    {
        m_audioProbe->clearVolumesList();
    }

    Q_INVOKABLE void setMediaPath(QString path)
    {
        setMedia(QUrl::fromLocalFile(path));
    }

signals:
    void propertyChanged();

private:
    explicit AudioPlayer(QObject *parent = nullptr);

    AudioProber *m_audioProbe;
    int screent_width;
    int currentPosition;
    bool wasStopped = false;
};

#endif
