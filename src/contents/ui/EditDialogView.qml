/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import "commonsize.js" as CSJ
import KRecorder 1.0
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.15 as Kirigami

Kirigami.JPopupMenu{
    id: menu

    property int mwidth: 200 * lastAppScaleSize
    property int m_menItemHeight: 180 * lastAppScaleSize / 4
    property int mheight: m_menItemHeight * menuItemCount
    property var separatorColor: "#1A000000"
    property int separatorWidth: mwidth * 8 / 10
    property int mouseX
    property int mouseY
    property int menuItemCount: menu.count
    property int backRadius: 12 * lastAppScaleSize

    signal bulkClicked
    signal deleteClicked
    signal renameClicked
    signal saveClicked

    padding: 0
    margins: 0

    function rmBulkAction() {
    }
    function addBulkAction() {
    }

    Action { 
        text: i18n(CSJ.Left_View_Edit_Menu_Bulk)
        icon.source: "qrc:/assets/edit_bulk.png"
        onTriggered:
        {
            bulkClicked()
            close()
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: i18n(CSJ.Left_View_Edit_Menu_Delete)
        icon.source: "qrc:/assets/edit_delete.png"
        onTriggered:
        {
            deleteClicked()
            close()
        }
    }

    Kirigami.JMenuSeparator { }

    Action { 
        text: i18n(CSJ.Left_View_Edit_Menu_Rename)
        icon.source: "qrc:/assets/edit_rename.png"
        onTriggered:
        {
            renameClicked()
            close()
        }
    }
}
