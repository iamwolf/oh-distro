#include <qapplication.h>
#include "mainwindow.h"
#include "lcmthread.h"

int main(int argc, char **argv)
{
  QApplication app(argc, argv);

  MainWindow window;
  window.resize(800,400);
  window.show();

  return app.exec();
}