

/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import KRecorder 1.0
import "commonsize.js" as CSJ
import org.kde.kirigami 2.15

Item {
    id: visualization

    property int maxBarHeight
    property int animationIndex
    // which index rectangle is being expanded
    property var volumes: []
    property bool showLine
    property bool showHorizontalLine
    property bool isListMove: false
    property var audiouiColor: "#FFFFFF"
    property var centerLienColor: "#E95B4E"
    property var currentFliickableX
    property bool isPlayPage: true
    property bool isRecordPlay: false
    property bool isStartPlayRecord: false
    property bool playPageIsVisible: true
    property int duration: isPlayPage ? AudioPlayer.duration : 60 * 1000
    property int position: isPlayPage ? AudioPlayer.position : AudioRecorder.duration
    property int vzMovePosition
    property bool isVzMove
    property alias currentRecordTime: newtimeLine.lastPosition
    property alias slideValue: sliderView.value

    signal playRecordingData

    Component.onCompleted: {
        AudioRecorder.prober.maxVolumes = width / 4
        AudioPlayer.prober.maxVolumes = width / 4
    }

    onWidthChanged: {
        AudioRecorder.prober.maxVolumes = width / 4
        AudioPlayer.prober.maxVolumes = width / 4
    }

    function setSliderValue(num) {
        sliderView.value = num
    }

    Rectangle {
        id: allRect

        width: parent.width
        height: parent.height
        color: "#00000000"

        Rectangle {
            id: emitRect

            property bool lastWasPulse: false
            property bool isRecordPlay: AudioRecorder.state == AudioRecorder.RecordingState

            anchors {
                top: parent.top
                topMargin: parent.height / 10
            }
            width: parent.width
            height: parent.height * 2 / 3
            color: "#00000000"

            Timer {
                id: emitTimer

                interval: 1000
                repeat: true
                onTriggered: {

                }
            }

            PlayAnimation {
                id: animaLine

                anchors {
                    centerIn: pRImage
                }
                width: height
                height: 255 * lastAppScaleSize
                rAnimationRunning: isPlayPage
                                   || isRecordPlay ? AudioPlayer.state == AudioPlayer.PlayingState : emitRect.isRecordPlay
                wave_color: isPlayPage || isRecordPlay ? "white" : "#E95B4E"
                isAnimationPlayer: isPlayPage || isRecordPlay
            }

            Image {
                id: pRImage

                anchors.centerIn: parent
                visible: isPlayPage || isRecordPlay
                width: 37 * lastAppScaleSize
                height: width
                sourceSize: Qt.size(110, 110)
                source: AudioPlayer.state === AudioPlayer.PlayingState ? "qrc:/assets/pause.png" : "qrc:/assets/play.png"

                JMouseSolid {
                    onClicked: {
                        if (AudioPlayer.state == AudioPlayer.PlayingState) {
                            AudioPlayer.pause()
                            if (isPlayPage && playPageIsVisible
                                    && playTimer.running) {
                                playTimer.stop()
                            }
                        } else {
                            AudioPlayer.play()
                            if (isPlayPage && playPageIsVisible
                                    && !playTimer.running) {
                                playTimer.start()
                            }
                            if (!isPlayPage && isVzMove) {
                                AudioPlayer.setPosition(vzMovePosition)
                                isVzMove = false
                            }
                            isStartPlayRecord = true
                        }
                    }
                }
            }
        }

        TimeLineView {
            id: newtimeLine

            anchors {
                bottom: allRect.bottom
            }
            width: parent.width
            height: 40
            visible: !isPlayPage
            lineFixed: visualization.width
            color: "#00000000"
            models: 5 * 60 * 60 * 1000

            onLineMoved: {
                vzMovePosition = movePt
                isVzMove = true
            }
        }
        Rectangle {
            id: newcentralLine

            anchors {
                top: newtimeLine.bottom
                topMargin: 5
            }
            width: parent.width
            height: 1
            visible: !isPlayPage
            color: "#993C3F48"
        }

        Rectangle {
            id: newhorizontalCenterLine

            anchors.centerIn: newcentralLine
            width: CSJ.PlayPageView.playage_middle_middel_line_width
            height: CSJ.PlayPageView.playage_middle_middle_line_height
            color: "#E95B4E"
            radius: height / 2
            visible: !isPlayPage
        }

        Slider {
            id: sliderView

            property int playPosition
            property bool isPlayingPress

            anchors {
                bottom: allRect.bottom
            }
            width: parent.width
            height: CSJ.PlayPageView.playage_middle_middle_line_height
            visible: isPlayPage
            from: 0
            to: AudioPlayer.duration

            onPressedChanged: {
                if(pressed){
                    isPlayingPress = AudioPlayer.state == AudioPlayer.PlayingState
                    if (isPlayingPress) {
                        AudioPlayer.pause()
                        if (isPlayPage && playPageIsVisible
                                && playTimer.running) {
                            playTimer.stop()
                        }
                    }
                } else {
                    if(isPlayingPress){
                        AudioPlayer.play()
                        if (isPlayPage && playPageIsVisible
                                && !playTimer.running) {
                            playTimer.start()
                        }
                    }
                }
            }

            background: Rectangle {
                width: sliderView.availableWidth
                height: implicitHeight
                x: sliderView.leftPadding
                y: sliderView.topPadding + sliderView.availableHeight / 2 - height / 2
                implicitWidth: parent.width
                implicitHeight: 2
                radius: 2
                //black ECE8E8
                color: "#993C3F48"

                Rectangle {
                    width: sliderView.visualPosition * parent.width
                    height: parent.height
                    color: "#E95B4E"
                    radius: 2
                }
            }

            handle: Rectangle {
                x: sliderView.leftPadding + sliderView.visualPosition
                   * (sliderView.availableWidth - width)
                y: sliderView.topPadding + sliderView.availableHeight / 2 - height / 2
                color: "#E95B4E"
                border.width: 0
                implicitWidth: CSJ.PlayPageView.playage_middle_middel_line_width
                implicitHeight: CSJ.PlayPageView.playage_middle_middle_line_height
                radius: 4 * lastAppScaleSize
            }

    Timer {
        id: playTimer
        interval: 15
        repeat: true
        onTriggered: {
            sliderView.value = AudioPlayer.position
            if (AudioPlayer.state === AudioPlayer.StoppedState) {
                playTimer.stop()
            }
        }
    }
    onMoved: {
        if (AudioPlayer.duration === value) {
            AudioPlayer.stop()
        } else {
            AudioPlayer.setPosition(value)
        }
    }
}
}
}
