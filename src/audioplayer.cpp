/*
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audioplayer.h"
#include "recordingmodel.h"
#include <QScreen>
#include <QGuiApplication>


AudioPlayer::AudioPlayer(QObject *parent) : QMediaPlayer(parent)
{

    m_audioProbe = new AudioProber(parent);
    m_audioProbe->setSource(this);

    RecordingModel *rm =  RecordingModel::instance();
    Recording *rd = rm->firstRecording();
    if (rd) {
        this->setMediaPath(rd->filePath());
    }
    QQmlEngine::setObjectOwnership(m_audioProbe, QQmlEngine::CppOwnership);

    connect(this, &AudioPlayer::stateChanged, this, &AudioPlayer::handleStateChange);
    connect(this,&AudioPlayer::positionChanged,this,&AudioPlayer::positionChange);
}

void AudioPlayer::positionChange(qint64 position) {
    currentPosition = position;
    emit propertyChanged();
}

void AudioPlayer::handleStateChange(QMediaPlayer::State state)
{
    if (state == QMediaPlayer::StoppedState) {
        wasStopped = true;
    } else if (state == QMediaPlayer::PlayingState && wasStopped) {
        wasStopped = false;
    }
}


