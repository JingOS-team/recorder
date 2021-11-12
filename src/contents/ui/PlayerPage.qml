

/*
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Zhang He Gang <zhanghegang@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0
import "commonsize.js" as CSJ

Rectangle {
    id: playPageRect

    property Recording recording: RecordingModel.firstRecording()
    property PlayPageTitle ppTitle: playerPageTitle

    onRecordingChanged: {
        playVisualization.setSliderValue(0)
    }

    onVisibleChanged: {
        playVisualization.playPageIsVisible = visible
    }

    Connections {
        target: RecordingModel

        onInsertNewRecordFile: {
            playPageRect.recording = RecordingModel.firstRecording()
        }
        function onError(error) {
            console.warn("Error on the recorder", error)
        }
    }

    function setFileName() {
        if (recording) {
            if (recording.fileName !== playerPageTitle.textChangeContent) {
                recording.fileName = playerPageTitle.textChangeContent
            }
        }
    }

    Rectangle {
        id: playPageTop
        width: parent.width
        height: playerPageTitle.height + playVisualization.height
        color: "transparent"
        visible: !nullLoader.active

        PlayPageTitle {
            id: playerPageTitle

            anchors {
                top: parent.top
            }
            titleContent: recording.fileName
            dateContent: recording.recordDate
            lengthContent: recording.recordingLength
            currentDateContent: Utils.formatTime(
                                    Math.floor(playVisualization.slideValue))
            onRenameClicked: {
                if (isFileNameEdit) {
                    recording.fileName = newFileName
                }
            }
        }

        Visualization {
            id: playVisualization

            anchors {
                left: palypageBottom.left
                right: palypageBottom.right
                top: playerPageTitle.bottom
            }
            width: parent.width
            height: playPageRect.height - playerPageTitle.height
                    - palypageBottom.height - 19 * lastAppScaleSize
            Layout.fillWidth: false
            isListMove: true
            audiouiColor: "#FFAF0A"
            centerLienColor: "#FF9500"
            showLine: false
            showHorizontalLine: true
            currentFliickableX: recording.recordingLength
            maxBarHeight: height / 2
            animationIndex: AudioPlayer.prober.animationInde
            volumes: AudioPlayer.prober.volumesList
            isPlayPage: true
        }
    }

    Component {
        id: nullComponent
        Rectangle {
            id: nullPageView
            width: playPageTop.width
            height: playPageTop.height
            color: "transparent"

            Text {
                id: nullPlayTip
                anchors.centerIn: parent
                text: i18n("Tap the record button to start recording")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: defaultFontSize
                color: Kirigami.JTheme.disableForeground
            }
            Rectangle {
                id: nullLine
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Kirigami.JTheme.disableForeground
            }
        }
    }

    Loader {
        id: nullLoader
        sourceComponent: nullComponent
        active: mainLeftView.leftItemCount <= 0
    }
    PlayPageBottom {
        id: palypageBottom
        isPlayPage: true
        color: "#00000000"
        defaultSource: playSource
        anchors.bottom: parent.bottom
        onPlayClicked: {
            AudioPlayer.stop()
            AudioRecorder.mkdirPath()
            root.pushRecordView(playPageTop.width)
            ppTitle.renamePlayPageTitle(false)
            setFileName()
        }
    }
}
