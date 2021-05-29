

/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import "commonsize.js" as CSJ
import KRecorder 1.0
import QtMultimedia 5.12

Rectangle {
    id: lineRect

    property int models
    property int lineFixed
    property int audioUiX
    signal lineMoved(var lineX, var isLeft, var movePt)
    property int itemWidth: 6
    property int itemMinHeight: 3
    property int itemMaxHeight: 7
    property int secondLines: 6
    property double currentLineX
    property var movePosition
    property int recordDuration: AudioRecorder.duration
    property int duration: isStartPlayRecord ? AudioPlayer.duration : 60 * 60 * 1000
    property int position: isStartPlayRecord ? AudioPlayer.position : AudioRecorder.duration
    property var mediaSource
    property int mediaPosition
    property var mediaContentx
    property var currentPosition
    property var lastPosition
    property var tPosition

    color: CSJ.backgroundColor

    ListModel {
        id: recordModel
    }

    function setListCount(setRecorderCount) {
        var nextCount = Math.round(setRecorderCount / 1000 * 7)
        var setCount = (nextCount + dateList.startRecordIndex) - dateList.count
        if (setCount > 0) {
            for (var i = 0; i < setCount; i++) {
                dateList.add()
            }
        }
    }

    ListView {
        id: dateList

        property int isVisibleIndex
        property int startRecordIndex: Math.floor(lineFixed / itemWidth / 2)
        property int currentMaxContentX

        anchors.fill: parent
        orientation: ListView.Horizontal
        interactive: AudioRecorder.state !== AudioRecorder.RecordingState
        model: startRecordIndex + models

        Timer {
            id: timeLineTimer

            interval: 20
            running: (isStartPlayRecord) ? AudioPlayer.state
                                           == AudioPlayer.PlayingState : emitRect.isRecordPlay
            repeat: true
            onRunningChanged: {
                if (!running && !isStartPlayRecord) {
                    dateList.isVisibleIndex = dateList.contentX / itemWidth
                    dateList.currentMaxContentX = dateList.contentX
                }
            }
            onTriggered: {
                if (isStartPlayRecord) {
                    tPosition = AudioPlayer.position
                } else {
                    tPosition = AudioRecorder.duration
                }
                if (lastPosition === tPosition) {
                    currentPosition += 20
                } else {
                    currentPosition = tPosition
                }
                dateList.contentX = dateList.getContentX(currentPosition)
                lastPosition = tPosition
            }
        }

        function getContentX(tPosition) {
            currentLineX = Math.round(
                        tPosition / 1000 * (itemWidth * secondLines) * 100) / 100
            return currentLineX
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                if (itemTimer.running) {
                    itemTimer.stop()
                }
                if (AudioPlayer.state === AudioPlayer.PlayingState) {
                    AudioPlayer.pause()
                }
            }
        }

        onMovementEnded: {
            if(dateList.contentX > currentMaxContentX){
                dateList.contentX = currentMaxContentX
            } else {
                movePosition = Math.round(
                            contentX / (lineRect.itemWidth * lineRect.secondLines) * 100000) / 100
                lineMoved(currentLineX, true, movePosition)
            }
        }
        Timer {
            id: itemTimer

            interval: 3 * 1000
            onTriggered: {
                if (AudioPlayer.state === AudioPlayer.PlayingState) {
                    AudioPlayer.pause()
                }
            }
        }
        delegate: Item {
            id: timeLine

            property int startIndex: Math.floor(lineFixed / itemWidth / 2)

            width: itemWidth
            height: dateList.height
            visible: timeLineIsVisible()

            function timeLineIsVisible() {
                if(!timeLineTimer.running){
                    return (model.index - startIndex < dateList.isVisibleIndex)
                            || (model.index - startIndex < dateList.contentX / itemWidth)
                            && (dateList.contentX < dateList.currentMaxContentX)
                }
                return (model.index - startIndex < dateList.isVisibleIndex)
                        || (model.index - startIndex < dateList.contentX / itemWidth)
            }

            Rectangle {
                id: dateLines

                anchors {
                    horizontalCenter: timeLine.horizontalCenter
                    bottom: timeLine.bottom
                }
                width: 1
                height: getHeight(index)
                //black #FFFFFF
                color: "#3C3F48"
                function getHeight(index) {
                    var h = timeLine.startIndex > index ? 0 : ((index - timeLine.startIndex)
                                                               % secondLines === 0 ? itemMaxHeight : itemMinHeight)
                    return h
                }
            }

            Text {
                id: dateFlag

                property int textStartIndex: index - timeLine.startIndex
                property int seconds: Math.floor(
                                          textStartIndex % 360 / secondLines)
                property int minutes: Math.floor(
                                          textStartIndex / 60 / secondLines)

                anchors {
                    bottom: dateLines.top
                    bottomMargin: 4 * lastAppScaleSize
                    horizontalCenter: timeLine.horizontalCenter
                }
                font.pixelSize: defaultFontSize - 5
                opacity: 0.6
                visible: (index - timeLine.startIndex) % secondLines == 0
                         && textStartIndex >= 0 && seconds % 2 == 0
                //black #FFFFFF
                color: "#3C3F48"
                text: (minutes >= 10 ? minutes : ("0" + minutes)) + ":"
                      + (seconds >= 10 ? seconds : ("0" + seconds))
            }
        }
    }
}
