#include "backend.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QCommandLineParser>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("ZengOS Installer");

    QCommandLineParser parser;
    QCommandLineOption windowed("windowed", "Run in a window instead of full screen.");
    QCommandLineOption shot("screenshot", "Render a page to a PNG and exit (development).", "path");
    QCommandLineOption page("page", "Start on a page index (development).", "n", "0");
    QCommandLineOption light("light", "Use the light appearance.");
    parser.addOptions({windowed, shot, page, light});
    parser.process(app);


    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule("ZengInstaller", "Main");
    return app.exec();
}
