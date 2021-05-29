/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audiorecorder.h"
#include <QScreen>
#include <QGuiApplication>
#include <QProcess>
#include <QDateTime>
#include "waveutil.h"

AudioRecorder::AudioRecorder(QObject *parent) : QAudioRecorder(parent)
{
    QScreen *screen=QGuiApplication::primaryScreen ();
    QRect mm=screen->availableGeometry() ;
    int screen_width = mm.width();

    m_audioProbe = new AudioProber(parent);
    m_audioProbe->setSource(this);
    m_audioProbe->setNullDataSize(screen_width*240/1920);
    m_encoderSettings.setChannelCount(2);
    m_encoderSettings.setQuality(QMultimedia::VeryHighQuality);

    setContainerFormat("audio/x-wav");
    setAudioSettings(m_encoderSettings);
    emit audioCodecChanged();

    QQmlEngine::setObjectOwnership(m_audioProbe, QQmlEngine::CppOwnership);
//    QString defaultName =  QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + "/" + getRecordingName("test");
//    setOutputLocation(defaultName);

    // once the file is done writing, save recording to model
    connect(this, &QAudioRecorder::stateChanged, this, &AudioRecorder::handleStateChange);
}

void AudioRecorder::setAudioCodec(const QString &codec)
{
    m_encoderSettings.setCodec(codec);
    setAudioSettings(m_encoderSettings);
    emit audioCodecChanged();
}

void AudioRecorder::setAudioQuality(int quality)
{
    m_encoderSettings.setQuality(QMultimedia::EncodingQuality(quality));
    setAudioSettings(m_encoderSettings);
    emit audioQualityChanged();
}

void AudioRecorder::handleStateChange(QAudioRecorder::State state)
{
    if (state == QAudioRecorder::StoppedState) {
        m_currentTime = "";
        if (resetRequest) {
            // reset
            resetRequest = false;
            QFile(outputLocationPath().toString()).remove();
            recordingName = "";
        } else {
            // rename file to desired file name
            renameCurrentRecording();
            // create recording
            saveRecording();
        }

        // clear volumes list
        m_audioProbe->clearVolumesList();

    } else if (state == QAudioRecorder::PausedState) {
        cachedDuration = duration();
    } else if ( state == QAudioRecorder::RecordingState) {
        bool getLocalTimeIs24 = RecordingModel::instance()->is24HourFormat();
        QString currentDayString = getLocalTimeIs24 ? "hh:mm" : (QLatin1String("hh:mm") + " AP");

        m_currentTime = QDateTime::currentDateTime().toString(currentDayString);
        emit currentDateChanged();
    }
}

bool AudioRecorder::setRecordingName(const QString &rName)
{
    QStringList spl =outputLocation().fileName().split(".");
    QString suffix = spl.size() > 0 ? "." + spl[spl.size()-1] : "";
    QString path = QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + "/" + rName;
    QString updatedPath = path + suffix;

    // ignore if the file destination is the same as the one currently being written to
    QFileInfo check(updatedPath);
    if (check.exists()) {
        return true;
    } else {
        recordingName = rName;
        return false;
    }
}

QString AudioRecorder::getRecordingName(QString dName)
{
    QString suffix = ".wav";
    QString path = QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + "/" + dName;
    QString updatedPath = path + suffix;
    QString newFileName;

    int cur = 1;
    QFileInfo check(updatedPath);
    if (check.exists()) {
        while (check.exists()) {
            updatedPath = QString("%1_%2%3").arg(path, QString::number(cur), suffix);
            check = QFileInfo(updatedPath);
            cur++;
        }
        newFileName = QString("%1_%2").arg(dName, QString::number((cur != 1 ? (cur-1) : 1)));
    } else {
        newFileName = dName;
    }
    return newFileName;
}

void AudioRecorder::renameCurrentRecording()
{
    if (!recordingName.isEmpty()) {

        // determine new file name
        QStringList spl =outputLocation().fileName().split(".");
        QString suffix = spl.size() > 0 ? "." + spl[spl.size()-1] : "";
        QString path = QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + "/" + recordingName;
        QString updatedPath = path + suffix;

        // ignore if the file destination is the same as the one currently being written to
        if (outputLocation().path() != (path+suffix)) {
            // if the file already exists, add a number to the end
            int cur = 1;
            QFileInfo check(path + suffix);
            while (check.exists()) {
                updatedPath = QString("%1_%2%3").arg(path, QString::number(cur), suffix);
                check = QFileInfo(updatedPath);
                cur++;
            }

            QFile(outputLocation().path()).rename(updatedPath);
        }

        savedPath = updatedPath;
        recordingName = "";
    } else {
        savedPath = outputLocation().path();
    }
}

QString AudioRecorder::getFilePath()
{
    QString filePath = outputLocationPath().toString();
    bool isExists = QFile::exists(filePath);
    if (isExists) {
        QStringList spl = outputLocationPath().fileName().split(".");
        QString suffix = spl.size() > 0 ? "." + spl[spl.size()-1] : "";
        if (outputLocationPath().toString() != "") {
            setOutputLocation(outputLocationPath());
        }
        recordPlayPath = QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + "/.recordPlay"+ suffix;
//        QString   cFilePath = QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + "/copyPlay"+ suffix;

        if ( QFile::exists(recordPlayPath)) {
            QFile::remove(recordPlayPath);
//            QFile::remove(cFilePath);
        }
        QFile newFile(recordPlayPath);
        if (newFile.open(QIODevice::ReadWrite)) {
            QProcess *p2 = new QProcess();
            int result = p2->execute("cp "+ filePath + " " + recordPlayPath);
            if (result == 0) {
                int size = newFile.size();
                int NUMBER_OF_SAMPLES = (size-44)/2;
                FILE * file;
                file = fopen(recordPlayPath.toUtf8(), "r+");
                waveFormatHeader_t * wh = stereo16bit44khzWaveHeaderForLength(NUMBER_OF_SAMPLES);
                int seekResult =  fseek(file,0,SEEK_SET);
                writeWaveHeaderToFile(wh, file);
                free(wh);
                fclose(file);

            }
            return recordPlayPath;
        }
    }
    return "";
}

bool AudioRecorder::deleteFilePath() {
    if (!recordPlayPath.isEmpty() &&  QFile::exists(recordPlayPath)) {
        QFile newFile(recordPlayPath);
        if (newFile.open(QIODevice::ReadWrite)) {
            bool isDeleteOk = QFile::remove(recordPlayPath);
        }
    }
    return false;
}

void AudioRecorder::saveRecording()
{
    // get file name from path
    QStringList spl = savedPath.split("/");
    QString fileName = spl.at(spl.size()-1).split(".")[0];

    RecordingModel::instance()->insertRecording(savedPath, fileName, QDateTime::currentDateTime(), (cachedDuration + 500) / 1000);
}
