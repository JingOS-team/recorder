/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef RECORDINGMODEL_H
#define RECORDINGMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSettings>
#include <QFile>
#include <QJsonObject>
#include <QDateTime>
#include <QCoreApplication>
#include <QScreen>
#include <QGuiApplication>
#include <KLocalizedString>
#include <QFileSystemWatcher>
#include <kdirwatch.h>
#include <KSharedConfig>
#include <KConfigGroup>
#include <QDBusConnection>
#include <KConfigWatcher>

class RecordingModel;
static RecordingModel *s_recordingModel = nullptr;
static QString dateFormatString = "yyyy/MM/dd hh:mm ap";
#define FORMAT24H "HH:mm:ss"
#define FORMAT12H "h:mm:ss ap"

class RecordingTag :public QObject {
    Q_OBJECT
    Q_PROPERTY(QString tagName READ tagName WRITE setTagName NOTIFY propertyChanged)
    Q_PROPERTY(QString tagDate READ tagDate WRITE setTagDate NOTIFY propertyChanged)
public:
    explicit RecordingTag(QObject *parent = nullptr,const QString &tagName = {}, const QString &tagDate = {});
    explicit RecordingTag(const QJsonObject obj);
    ~RecordingTag();
    QJsonObject toJson() const;

    QString tagName() {
        return m_tagName;
    }

    QString tagDate() {
        return m_tagDate;
    }

    void setTagName(const QString &newTagName);
    void setTagDate(const QString &date);

private:
    QString m_tagName;
    QString m_tagDate;
signals:
    void propertyChanged();
};




class Recording : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool itemChecked READ itemChecked WRITE setItemChecked NOTIFY checkedChanged)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY propertyChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY propertyChanged)
    Q_PROPERTY(QString recordDate READ recordDatePretty NOTIFY propertyChanged)
    Q_PROPERTY(QString recordingLength READ recordingLengthPretty NOTIFY propertyChanged)
    Q_PROPERTY(QList<RecordingTag*> tags READ tags WRITE setTags NOTIFY tagsChanged)

public:
    explicit Recording(QObject *parent = nullptr, const QString &filePath = {}, const QString &fileName = {}, QDateTime recordDate = QDateTime::currentDateTime(), int recordingLength = 0,QList<RecordingTag*> tagList= {});
    explicit Recording(const QJsonObject &obj);
    ~Recording();

    QJsonObject toJson() const;

    bool itemChecked() const
    {
        return m_itemChecked;
    }
    QList<RecordingTag*> tags() {
        return m_recordingTag;
    }

    QString filePath() const
    {
        return m_filePath;
    }
    QString fileName() const
    {
        return m_fileName;
    }
    QDateTime recordDate() const
    {
        return m_recordDate;
    }
    QString recordDatePretty() const;
    int recordingLength() const
    {
        return m_recordingLength;
    }
    QString recordingLengthPretty() const;

    void setItemChecked(bool checked);
    void setFilePath(const QString &filePath);
    void setFileName(const QString &fileName);

    void setRecordDate(const QDateTime &date);
    void setRecordingLength(int recordingLength);
    void setTags(QList<RecordingTag*> tags);
    Q_INVOKABLE void addTags(QString &tagName,QString &tagDate);
    Q_INVOKABLE void removeTags(int index);
    Q_INVOKABLE void getTags();
    void saveTags();



private:
    bool m_itemChecked;
    QString m_filePath, m_fileName;
    QDateTime m_recordDate;
    int m_recordingLength; // seconds
    QList<RecordingTag*> m_recordingTag;

signals:
    void propertyChanged();
    void checkedChanged();
    void tagsChanged();

};


class RecordingModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QList<RecordingTag*> tags READ tags NOTIFY tagsChanged)
    Q_PROPERTY(bool isForeground READ isForeground WRITE setForeground NOTIFY foregroundChanged)

private:
    QString m_searchContent;
public:
    QList<RecordingTag*> tags() {
        return m_recordingTag;
    }

    bool isForeground() {
        return m_isForeground;
    }

    void setForeground(bool isForeG) {
        m_isForeground = isForeG;
        emit foregroundChanged();
    }

    enum Roles {
        RecordingRole = Qt::UserRole
    };

    static RecordingModel* instance()
    {
        if (!s_recordingModel) {
            s_recordingModel = new RecordingModel(qApp);
        }
        return s_recordingModel;
    }

    void load();
    void save();
    Q_INVOKABLE void loadByContent(const QString &content);
    Q_INVOKABLE void setAllItemCheck(bool state);
    Q_INVOKABLE bool deleteAllCheck();
    Q_INVOKABLE Recording* firstRecording();
    Q_INVOKABLE int getScreenWidth();
    Q_INVOKABLE int getScreenHeight();
    QJsonArray loadFromFiles();
    qint64 getAudioTime(const QString &path);
    int getPcmDB( char *pcmdata, int size);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Q_INVOKABLE QString nextDefaultRecordingName();

    Q_INVOKABLE void insertRecording(QString filePath, QString fileName, QDateTime recordDate, int recordingLength);
    Q_INVOKABLE void deleteRecording(const int index);
    Q_INVOKABLE void deleteRecordingByItem(Recording* item);
    Q_INVOKABLE void addTags(QString tagName,QString tagDate);
    Q_INVOKABLE void removeTags(int index);
    Q_INVOKABLE bool is24HourFormat();
    QString getCurrentFormat();
public slots:
    void kcmClockUpdated();
public:
    QSettings* m_settings;

private:
    explicit RecordingModel(QObject *parent = nullptr);
    ~RecordingModel();

    QList<Recording*> m_recordings;
    QList<RecordingTag*> m_recordingTag;
    int m_screenWidth;
    int m_screenHeight;
    int m_itemSelectCount;
    bool m_isForeground = true;
    QString m_currentLocalTime;

signals:
    void tagsChanged();
    void insertNewRecordFile();
    void recorderCheckedChange(bool checked);
    void showTipText(QString tipText);
    void foregroundChanged();
public slots:
    void recordDirChanged(const QString &path);

};

#endif // RECORDINGMODEL_H
