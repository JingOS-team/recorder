
/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.0
import "commonsize.js" as CSJ
import KRecorder 1.0
import org.kde.kirigami 2.15 as Kirigami

Rectangle {
    id:playpagebottom

    property var defaultSource
    property var playSource : "qrc:/assets/mic_pic.png"
    property var pauseSource : "qrc:/assets/pause.png"
    property var whitePauseSource : "qrc:/assets/pause_white.png"
    property bool isPlayPage
    property bool isAnimImage

    signal playClicked
    signal pauseClicked
    signal continueClicked
    signal doneClicked

    width: parent.width
    height: parent.height * (CSJ.PlayPageView.playpage_bottom_height/CSJ.ScreenCurrentHeight)
    color: "transparent"



    Item{
        width:  parent.height * (CSJ.playPage_Bottom_middle_Image_height/ CSJ.PlayPageView.playpage_bottom_height) + 8 * lastAppScaleSize
        height: width
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Rectangle{
            color: "#E95B4E"
            anchors.fill: parent
            anchors.margins: 8 * lastAppScaleSize
            radius: height/2
            Image {
                id: playPauseBase

                width: parent.height
                height: width
                anchors.centerIn: parent
                visible: !isPlayPage
                source: "qrc:/assets/record_base.png"

                NumberAnimation {
                    running:isAnimImage
                    loops: Animation.Infinite
                    target: playPauseBase
                    from: 0
                    to: 360
                    property: "rotation"
                    duration: 1000
                }
            }

            Image {
                id: playPauseImage

                width: playpagebottom.height * (CSJ.PlayPageView.playpage_bottom_play_pause_width/ CSJ.PlayPageView.playpage_bottom_height)
                height: width
                anchors.centerIn: parent
                source: defaultSource
            }

            MouseArea{
                id:playMouse
                hoverEnabled: true
                anchors.fill: parent
                onClicked:{
                    if(playPauseImage.source == playSource){
                        playClicked()
                    }else{
                        pauseClicked()
                    }
                }
            }
        }

        Rectangle{
            anchors.fill: parent
            radius: height/2
            color: playMouse.containsMouse ? (playMouse.pressed ? Kirigami.JTheme.pressBackground : Kirigami.JTheme.hoverBackground ) : "transparent"
        }
    }

    Rectangle{
        id:doneRect

        width: playpagebottom.height * (CSJ.playPage_Bottom_right_Image_height/ CSJ.PlayPageView.playpage_bottom_height)
        height: width
        anchors{
            bottom: parent.bottom
            right: parent.right
            rightMargin: root.width * (CSJ.playPage_Bottom_Left_right_margin/CSJ.ScreenCurrentWidth)
        }
        color: "#00000000"
        visible: !isPlayPage

        Kirigami.JIconButton {
            id: saveImage

            width: playpagebottom.height * (CSJ.playPage_Bottom_right_Image_height/ CSJ.PlayPageView.playpage_bottom_height) + 5 * lastAppScaleSize
            height: width
            anchors.centerIn: parent
            source: "qrc:/assets/save.png"
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    doneClicked()
                }
            }
        }

    }
}
