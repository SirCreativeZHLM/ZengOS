#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

// Bridge between the QML installer UI and the install backend.
// On Linux it runs lib/zengos/zeng-install-backend and reads one JSON object
// per line from its stdout. In demo mode (any other OS, or --demo) it plays a
// scripted run so the UI can be developed and screenshotted without a disk.
class Backend : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool demo READ demo CONSTANT)
    Q_PROPERTY(QVariantList disks READ disks NOTIFY disksChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(bool finished READ finished NOTIFY finishedChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString message READ message NOTIFY progressChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)

public:
    explicit Backend(QObject *parent = nullptr);

    bool demo() const { return m_demo; }
    QVariantList disks() const { return m_disks; }
    bool running() const { return m_running; }
    bool finished() const { return m_finished; }
    double progress() const { return m_progress; }
    QString message() const { return m_message; }
    QString error() const { return m_error; }

    void setDemo(bool demo) { m_demo = demo; }

    Q_INVOKABLE void refreshDisks();
    Q_INVOKABLE void install(const QVariantMap &config);
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void quit();

signals:
    void disksChanged();
    void runningChanged();
    void finishedChanged();
    void progressChanged();
    void errorChanged();

private:
    void handleLine(const QByteArray &line);
    void demoTick();
    void fail(const QString &text);

    bool m_demo = false;
    bool m_running = false;
    bool m_finished = false;
    double m_progress = 0;
    QString m_message;
    QString m_error;
    QVariantList m_disks;
    QProcess *m_process = nullptr;
    QTimer m_demoTimer;
    int m_demoStep = 0;
    QByteArray m_buffer;
};
