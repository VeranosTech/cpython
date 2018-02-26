.. _logging-cookbook:

================================
로깅 쿡북(Cookbook)
================================

:Author: Vinay Sajip <vinay_sajip at red-dove dot com>

이 페이지는 유용한 로깅(logging) 관련 래피시를 포함한다.

.. currentmodule:: logging

다수의 모듈에서 로깅 사용
---------------------------------

``logging.getLogger('someLogger')``\ 로 여러개의 호출이 보내지면 동일한 로거(logger) 객체로의 참조를 반환한다.
이는 같은 모듈뿐 아니라 같은 파이썬 인터프리터를 사용하는 다른 모듈에서 호출했을 때도 마찬가지이다.
같은 객체로의 참조에서도 동일하다.
또 어플리케이션 코드가 하나의 모듈에서 부모 로거를 정의하고 설정한 다음
다른 모듈에서 자식 로거를 생성하는 것도 가능하다.
자식 로거 호출은 모두 부모 로거로 전달된다.
다음은 메인 모듈의 예시다. ::

    import logging
    import auxiliary_module

    # 'spam_application' 로거 생성
    logger = logging.getLogger('spam_application')
    logger.setLevel(logging.DEBUG)
    # 디버그 메세지를 포함하는 파일 핸들러 생성
    fh = logging.FileHandler('spam.log')
    fh.setLevel(logging.DEBUG)
    # 더 상위의 콘솔 핸들러 생성
    ch = logging.StreamHandler()
    ch.setLevel(logging.ERROR)
    # 핸들러에 포맷을 추가
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    fh.setFormatter(formatter)
    ch.setFormatter(formatter)
    # 핸들러를 로거에 추가
    logger.addHandler(fh)
    logger.addHandler(ch)

    logger.info('creating an instance of auxiliary_module.Auxiliary')
    a = auxiliary_module.Auxiliary()
    logger.info('created an instance of auxiliary_module.Auxiliary')
    logger.info('calling auxiliary_module.Auxiliary.do_something')
    a.do_something()
    logger.info('finished auxiliary_module.Auxiliary.do_something')
    logger.info('calling auxiliary_module.some_function()')
    auxiliary_module.some_function()
    logger.info('done with auxiliary_module.some_function()')

다음은 보조 모듈이다. ::

    import logging

    # 로거 생성
    module_logger = logging.getLogger('spam_application.auxiliary')

    class Auxiliary:
        def __init__(self):
            self.logger = logging.getLogger('spam_application.auxiliary.Auxiliary')
            self.logger.info('creating an instance of Auxiliary')

        def do_something(self):
            self.logger.info('doing something')
            a = 1 + 1
            self.logger.info('done doing something')

    def some_function():
        module_logger.info('received a call to "some_function"')

다음과 같은 출력이 나타난다.::

    2005-03-23 23:47:11,663 - spam_application - INFO -
       creating an instance of auxiliary_module.Auxiliary
    2005-03-23 23:47:11,665 - spam_application.auxiliary.Auxiliary - INFO -
       creating an instance of Auxiliary
    2005-03-23 23:47:11,665 - spam_application - INFO -
       created an instance of auxiliary_module.Auxiliary
    2005-03-23 23:47:11,668 - spam_application - INFO -
       calling auxiliary_module.Auxiliary.do_something
    2005-03-23 23:47:11,668 - spam_application.auxiliary.Auxiliary - INFO -
       doing something
    2005-03-23 23:47:11,669 - spam_application.auxiliary.Auxiliary - INFO -
       done doing something
    2005-03-23 23:47:11,670 - spam_application - INFO -
       finished auxiliary_module.Auxiliary.do_something
    2005-03-23 23:47:11,671 - spam_application - INFO -
       calling auxiliary_module.some_function()
    2005-03-23 23:47:11,672 - spam_application.auxiliary - INFO -
       received a call to 'some_function'
    2005-03-23 23:47:11,673 - spam_application - INFO -
       done with auxiliary_module.some_function()

멀티스레드 로깅
-----------------------------

멀티스레드에서 로깅할 때도 특별한 노력이 필요치 않다.
다음은 메인(최초) 스레드와 다른 스레드로부터의 로깅 예시다. ::

    import logging
    import threading
    import time

    def worker(arg):
        while not arg['stop']:
            logging.debug('Hi from myfunc')
            time.sleep(0.5)

    def main():
        logging.basicConfig(level=logging.DEBUG, format='%(relativeCreated)6d %(threadName)s %(message)s')
        info = {'stop': False}
        thread = threading.Thread(target=worker, args=(info,))
        thread.start()
        while True:
            try:
                logging.debug('Hello from main')
                time.sleep(0.75)
            except KeyboardInterrupt:
                info['stop'] = True
                break
        thread.join()

    if __name__ == '__main__':
        main()

실행되었을 때 스크립트는 다음과 같은 내용을 출력해야 한다. ::

     0 Thread-1 Hi from myfunc
     3 MainThread Hello from main
   505 Thread-1 Hi from myfunc
   755 MainThread Hello from main
  1007 Thread-1 Hi from myfunc
  1507 MainThread Hello from main
  1508 Thread-1 Hi from myfunc
  2010 Thread-1 Hi from myfunc
  2258 MainThread Hello from main
  2512 Thread-1 Hi from myfunc
  3009 MainThread Hello from main
  3013 Thread-1 Hi from myfunc
  3515 Thread-1 Hi from myfunc
  3761 MainThread Hello from main
  4017 Thread-1 Hi from myfunc
  4513 MainThread Hello from main
  4518 Thread-1 Hi from myfunc

예상한대로 로그 출력이 나타난다. 이 방법은 더 많은 스레드에도 잘작동한다.

다수의 핸들러와 포매터
--------------------------------

로거는 순수 파이썬 객체다. :meth:`~Logger.addHandler` 메서드는 추가할 수 있는 핸들러 갯수의 한계가 없다.
모든 중요도의 모든 메세지를 텍스트 파일로 로그하면서 동시에 에러를 로그하거나 콘솔로 로그을 보내는 것이 어플리케이션에는 좋을 것이다.
이러한 설정을 하기 위해 간단하게 적절한 핸들러를 설정하면 된다. 어플리케이션 코드 내부의 로깅 호출은 수정되지 않은 채로 남는다.
다음 코드는 이전에 사용한 간단한 모듈 베이스 설정 예시를 조금 수정한 것이다. ::

    import logging

    logger = logging.getLogger('simple_example')
    logger.setLevel(logging.DEBUG)
    # create file handler which logs even debug messages
    fh = logging.FileHandler('spam.log')
    fh.setLevel(logging.DEBUG)
    # create console handler with a higher log level
    ch = logging.StreamHandler()
    ch.setLevel(logging.ERROR)
    # create formatter and add it to the handlers
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    ch.setFormatter(formatter)
    fh.setFormatter(formatter)
    # add the handlers to logger
    logger.addHandler(ch)
    logger.addHandler(fh)

    # 'application' code
    logger.debug('debug message')
    logger.info('info message')
    logger.warn('warn message')
    logger.error('error message')
    logger.critical('critical message')

위 예시의 `application' 코드는 여러 핸들러에 관여하지 않는다.
*fh*라는 이름의 새 핸들러를 추가하고 설정하기만 했다.

중요도 순위가 높거나 낮은 새 핸들러를 만들면 어플리케이션을 테스트하는데 유용하다.
디버깅을 위해 ``print`` 선언을 작성하는 대신 ``logger.debug``\ 를 사용할 수 있다.
이후에 삭제하거나 주석 처리해야 하는 ``print`` 선언과 달리 ``loger.debug``\ 선언은 소스 코드에 그대로 남아
다시 필요해질 때까지 비활성화되어 있을 수 있다.
``loger.debug``\ 가 다시 필요해지면 디버그할 로거나 핸들러의 중요도 레벨을 변경하면 된다.

.. _multiple-destinations:

다수의 목적지로의 로깅
--------------------------------

콘솔과 파일에 각각 다른 상황에서 다른 메세지 포맷을 로그를 하길 원할 수 있다.
DEBUG와 보다 높은 레벨의 메세지는 파일에, INFO와 보다 높은 레벨의 메세지는 콘솔에 로그하고 싶다고 하자.
파일은 타임스탬프를 포함해야 하고 콘솔은 포함해선 안되는 상황이다.
다음은 이러한 상황에 사용할 수 있는 예시다. ::

   import logging

   # set up logging to file - see previous section for more details
   logging.basicConfig(level=logging.DEBUG,
                       format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                       datefmt='%m-%d %H:%M',
                       filename='/temp/myapp.log',
                       filemode='w')
   # define a Handler which writes INFO messages or higher to the sys.stderr
   console = logging.StreamHandler()
   console.setLevel(logging.INFO)
   # set a format which is simpler for console use
   formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
   # tell the handler to use this format
   console.setFormatter(formatter)
   # add the handler to the root logger
   logging.getLogger('').addHandler(console)

   # Now, we can log to the root logger, or any other logger. First the root...
   logging.info('Jackdaws love my big sphinx of quartz.')

   # Now, define a couple of other loggers which might represent areas in your
   # application:

   logger1 = logging.getLogger('myapp.area1')
   logger2 = logging.getLogger('myapp.area2')

   logger1.debug('Quick zephyrs blow, vexing daft Jim.')
   logger1.info('How quickly daft jumping zebras vex.')
   logger2.warning('Jail zesty vixen who grabbed pay from quack.')
   logger2.error('The five boxing wizards jump quickly.')

위 코드를 실행하면 콘솔에 다음과 같이 나타난다. ::

   root        : INFO     Jackdaws love my big sphinx of quartz.
   myapp.area1 : INFO     How quickly daft jumping zebras vex.
   myapp.area2 : WARNING  Jail zesty vixen who grabbed pay from quack.
   myapp.area2 : ERROR    The five boxing wizards jump quickly.

파일에는 다음과 같이 나타난다. ::

   10-22 22:19 root         INFO     Jackdaws love my big sphinx of quartz.
   10-22 22:19 myapp.area1  DEBUG    Quick zephyrs blow, vexing daft Jim.
   10-22 22:19 myapp.area1  INFO     How quickly daft jumping zebras vex.
   10-22 22:19 myapp.area2  WARNING  Jail zesty vixen who grabbed pay from quack.
   10-22 22:19 myapp.area2  ERROR    The five boxing wizards jump quickly.

예시에서 볼 수 있듯이 DEBUG 메세지는 파일에만 나타난다. 다른 메세지는 파일과 콘솔에 모두 나타난다.

이 예시는 콘솔과 파일 핸들러를 사용하지만 다른 핸들러 조합을 사용할 수도 있다.


서버 설정의 예
----------------------------

다음 예시는 로깅 설정 서버 모듈의 예다. ::

    import logging
    import logging.config
    import time
    import os

    # read initial config file
    logging.config.fileConfig('logging.conf')

    # create and start listener on port 9999
    t = logging.config.listen(9999)
    t.start()

    logger = logging.getLogger('simpleExample')

    try:
        # loop through logging calls to see the difference
        # new configurations make, until Ctrl+C is pressed
        while True:
            logger.debug('debug message')
            logger.info('info message')
            logger.warn('warn message')
            logger.error('error message')
            logger.critical('critical message')
            time.sleep(5)
    except KeyboardInterrupt:
        # cleanup
        logging.config.stopListening()
        t.join()

다음 스크립트는 파일명을 받아서 해당 파일을 서버로 보낸다.
바이너리 인코딩된 파일 길이를 먼저 보내면 로그 설정을 새로 할 수 있다.::

    #!/usr/bin/env python
    import socket, sys, struct

    with open(sys.argv[1], 'rb') as f:
        data_to_send = f.read()

    HOST = 'localhost'
    PORT = 9999
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print('connecting...')
    s.connect((HOST, PORT))
    print('sending config...')
    s.send(struct.pack('>L', len(data_to_send)))
    s.send(data_to_send)
    s.close()
    print('complete')


블럭하는 핸들러 해결하기
--------------------------------

.. currentmodule:: logging.handlers

사용자가 로깅하는 스레드를 블럭하지 않고 로깅 핸들러가 작업을 수행하게 해야하는 경우가 있다.
웹 어플리케이션에서는 자주 있는 일이지만 다른 시나리오에서도 발생할 수 있다.

속도가 저하되는 주범은 대체로 :class:`SMTPHandler`: 때문이다.
이메일을 보내는데 시간이 오래 걸리기 때문인데
이는 개발자가 제어할 수 없는 원인들로 인한 것이다.
하지만 이 외에도 대부분의 네트워크 기반 핸들러에서 블럭이 발생한다.
:class:`SocketHandler` 작업도 밑단에서 DNS 쿼리를 할 수 있는데 이 때는 속도가 매우 느려진다.
(이 쿼리는 파이썬 레이어 아래의 소켓 라이브러리 코드 깊은 곳에 있을 수 있고 제어할 수 없다.)

이 문제의 해결책은 두 부분으로 나누어 접근한다.
우선, 성능이 중요한 스레드가 접근하는 로거는 :class:`QueueHandler` 만을 사용한다.
이 로거는 큐에 로그를 쌓게 되는데 큐의 크기는 상한선이 없거나 충분히 큰 용량이어야 한다.
큐에 쓰는 속도는 충분히 빠르다. 다만 혹시 발생할 수도 있는 :exc:`queue.Full` 예외를 잡아내야 한다.
라이브러리 개발자이고 성능이 중요한 스레드가 있다면 코드를 사용하는 다른 개발자를 위해 이와 관련된 사항을 반드시 문서화한다.
(로거에 ``QueueHandlers`` 만을 두라는 제안과 함께)

해결책의 두번째 부분은 :class:`QueueHandler`\ 에 대응하여 고안된 :class:`QueueListener`\ 다.
:class:`QueueListener`\ 는 매우 간단하다. 큐와 핸들러를 받아서 이 큐에 저장할
``QueueHandlers``\ 나 다른 ``LogRecords`` 소스로부터 보내진 LogRecords를 받는 내부 스레드를 작동시킨다.
저장된 ``LogRecords``\ 는 추후 큐에서 삭제되고 처리를 위해 핸들러로 보내진다.

별개의 :class:`QueueListener` 클래스를 만들 때의 장점은
같은 인스턴스로 다수의 ``QueueHandlers``\ 를 서비스할 수 있다는 것이다.
기존의 핸들러 클래스를 스레드로 만들면 된 핸들러당 스레드 하나를 잡아 먹기 때문에
:class:`QueueListener`\ 를 쓰는 것이 리소스 친화적이다.

다음은 위 해결책의 예시다.(import 생략) ::

    que = queue.Queue(-1)  # no limit on size
    queue_handler = QueueHandler(que)
    handler = logging.StreamHandler()
    listener = QueueListener(que, handler)
    root = logging.getLogger()
    root.addHandler(queue_handler)
    formatter = logging.Formatter('%(threadName)s: %(message)s')
    handler.setFormatter(formatter)
    listener.start()
    # The log output will display the thread which generated
    # the event (the main thread) rather than the internal
    # thread which monitors the internal queue. This is what
    # you want to happen.
    root.warning('Look out!')
    listener.stop()

실행하면 다음이 나타난다.

.. code-block:: none

    MainThread: Look out!

.. versionchanged:: 3.5
   파이썬 3.5 이전의 :class:`QueueListener`\ 는 함께 초기화된 모든 핸들러로의 큐로부터 받은 메세지를 항상 보냈다.
   (이는 큐가 채워진 곳에서 레벨 필터링이 모두 끝났다고 가정하기 때문이다.)
   파이썬 3.5부터는 키워드 인수 ``respect_handler_level=True``\ 를 모든 리스너 구조로 보내는 것으로 변경됐다.
   키워드 인수가 보내지면 리스너는 각 메세지의 레벨과 핸들러 레벨을 비교하고 적합한 경우에만 핸들러로 메세지를 보낸다.

.. _network-logging:

네트워크를 통해 로깅 이벤트 보내기/받기
-----------------------------------------------------

네트워크를 통해 로깅 이벤트를 보내고 수신단에서 메세지를 처리하고자 한다면
송신단의 루트 로거에 :class:`SocketHandler` 인스턴스를 두면 된다. ::

   import logging, logging.handlers

   rootLogger = logging.getLogger('')
   rootLogger.setLevel(logging.DEBUG)
   socketHandler = logging.handlers.SocketHandler('localhost',
                       logging.handlers.DEFAULT_TCP_LOGGING_PORT)
   # don't bother with a formatter, since a socket handler sends the event as
   # an unformatted pickle
   rootLogger.addHandler(socketHandler)

   # Now, we can log to the root logger, or any other logger. First the root...
   logging.info('Jackdaws love my big sphinx of quartz.')

   # Now, define a couple of other loggers which might represent areas in your
   # application:

   logger1 = logging.getLogger('myapp.area1')
   logger2 = logging.getLogger('myapp.area2')

   logger1.debug('Quick zephyrs blow, vexing daft Jim.')
   logger1.info('How quickly daft jumping zebras vex.')
   logger2.warning('Jail zesty vixen who grabbed pay from quack.')
   logger2.error('The five boxing wizards jump quickly.')

수신단에서는 :mod:`socketserver` 모듈로 리시버를 설정할 수 있다. 다음은 기본적인 작동 예시다. ::

   import pickle
   import logging
   import logging.handlers
   import socketserver
   import struct


   class LogRecordStreamHandler(socketserver.StreamRequestHandler):
       """Handler for a streaming logging request.

       This basically logs the record using whatever logging policy is
       configured locally.
       """

       def handle(self):
           """
           Handle multiple requests - each expected to be a 4-byte length,
           followed by the LogRecord in pickle format. Logs the record
           according to whatever policy is configured locally.
           """
           while True:
               chunk = self.connection.recv(4)
               if len(chunk) < 4:
                   break
               slen = struct.unpack('>L', chunk)[0]
               chunk = self.connection.recv(slen)
               while len(chunk) < slen:
                   chunk = chunk + self.connection.recv(slen - len(chunk))
               obj = self.unPickle(chunk)
               record = logging.makeLogRecord(obj)
               self.handleLogRecord(record)

       def unPickle(self, data):
           return pickle.loads(data)

       def handleLogRecord(self, record):
           # if a name is specified, we use the named logger rather than the one
           # implied by the record.
           if self.server.logname is not None:
               name = self.server.logname
           else:
               name = record.name
           logger = logging.getLogger(name)
           # N.B. EVERY record gets logged. This is because Logger.handle
           # is normally called AFTER logger-level filtering. If you want
           # to do filtering, do it at the client end to save wasting
           # cycles and network bandwidth!
           logger.handle(record)

   class LogRecordSocketReceiver(socketserver.ThreadingTCPServer):
       """
       Simple TCP socket-based logging receiver suitable for testing.
       """

       allow_reuse_address = True

       def __init__(self, host='localhost',
                    port=logging.handlers.DEFAULT_TCP_LOGGING_PORT,
                    handler=LogRecordStreamHandler):
           socketserver.ThreadingTCPServer.__init__(self, (host, port), handler)
           self.abort = 0
           self.timeout = 1
           self.logname = None

       def serve_until_stopped(self):
           import select
           abort = 0
           while not abort:
               rd, wr, ex = select.select([self.socket.fileno()],
                                          [], [],
                                          self.timeout)
               if rd:
                   self.handle_request()
               abort = self.abort

   def main():
       logging.basicConfig(
           format='%(relativeCreated)5d %(name)-15s %(levelname)-8s %(message)s')
       tcpserver = LogRecordSocketReceiver()
       print('About to start TCP server...')
       tcpserver.serve_until_stopped()

   if __name__ == '__main__':
       main()

먼저 서버를 실행하고 그 다음에 클라이언트를 실행한다. 클라이언트에서 콘솔에는 아무것도 나타나지 않는다.
반대로 서버에서는 다음과 같이 나타날 것이다. ::

   About to start TCP server...
      59 root            INFO     Jackdaws love my big sphinx of quartz.
      59 myapp.area1     DEBUG    Quick zephyrs blow, vexing daft Jim.
      69 myapp.area1     INFO     How quickly daft jumping zebras vex.
      69 myapp.area2     WARNING  Jail zesty vixen who grabbed pay from quack.
      69 myapp.area2     ERROR    The five boxing wizards jump quickly.

가끔 피클(pickle)과 관련된 보안 문제가 발생할 수 있다..
보안이 문제가 되면 :meth:`~handlers.SocketHandler.makePickle` 메서드를 덮어쓰고
그 곳에 대안을 구현해 직렬화 스키마를 대체하는 자체적인 직렬화 스키마를 사용하면 된다.
추가로 위의 스크립트를 대체 직렬화에 적용할 수 있다.


.. _context-info:

로그 출력에 맥락 정보 추가하기
----------------------------------------------------

로깅 출력이 로킹 호출에 보내진 매개 변수 혹은 맥락 정보를 포함하길 원할 수 있다.
예를 들어, 네트워크화된 어플리케이션에서 리모트 클라이언트의 사용자명이나 IP 주소 같은
클라이언트 특정 정보를 로그에 포함하는 것이 좋을 수 있다.
*extra* 매개 변수로 이를 구현할 수도 있지만 이 방법이 항상 편리한 것은 아니다.
연결마다 :class:`Logger` 인스턴스를 생성하는 것도
생성된 인스턴스가 가비지 수집이 되지 않기 때문에 좋은 방법은 아니다.
이것은 실제로 문제가 되지 않는다. 하지만 :class:`Logger` 인스턴스의 갯수가
어플리케이션을 로깅하는데 사용되는 세분화 정도에 의존하면
:class:`Logger` 인스턴스의 갯수가 실질적으로 무제한이 되어 관리하기 어려워질 수 있다.


LoggerAdapters를 사용해서 맥락 정보 보내기
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

출력에 로깅 이벤트 정보뿐 아니라 맥락 정보를 포함하는 쉬운 방법은
:class:`LoggerAdapter` 클래스를 사용하는 것이다.
이 클래스는 :class:`Logger`\ 처럼 고안되었기 때문에
:meth:`debug`, :meth:`info`, :meth:`warning`,
:meth:`error`, :meth:`exception`, :meth:`critical`, :meth:`log`\ 를 호출할 수 있다.
이 메서드들은 :class:`Logger`\ 의 같은 메서드와 동일한 함수 호출형식을 가진다.
따라서 두가지 인스턴스는 교체 가능하다.

:class:`LoggerAdapter` 인스턴스를 생성할 때 :class:`Logger` 인스턴스와
맥락 정보를 포함한 딕셔너리형 객체를 보낸다.
:class:`LoggerAdapter` 인스턴스의 로깅 메서드를 호출하면
생성자로 보내질 밑단의 :class:`Logger` 인스턴스로의 호출을 위임하고
위임된 호출에 있는 맥락 정보를 보내기 위해 정리한다.
다음은 :class:`LoggerAdapter`\ 의 코드다. ::

    def debug(self, msg, *args, **kwargs):
        """
        Delegate a debug call to the underlying logger, after adding
        contextual information from this adapter instance.
        """
        msg, kwargs = self.process(msg, kwargs)
        self.logger.debug(msg, *args, **kwargs)

:class:`LoggerAdapter`\ 의 :meth:`~LoggerAdapter.process` 메서드에서 맥락 정보를 로깅 출력에 추가한다.
로깅 호출의 메세지와 키워드 인수를 받고
밑단의 로거 호출에서 사용되도록 수정된 메세지와 키워드 인수를 돌려 보낸다.
이 메서드의 기본 구현은 메세지만으로 구성되지만
생성자로 보내질 딕셔너리형 객체를 값으로 갖는 'extra' 키를 인수로 넣을 수 있다.
당연히 'extra' 키워드 인수를 어댑터로의 호출에 보냈다면 자동으로 덮어써진다.

'extra' 키워드를 사용하는 장점은
딕셔너리형 객체의 값이 :class:`LogRecord` 인스턴스의 __dict__에 합쳐진다는 것이다.
이를 통해 딕셔너리형 객체의 키 값을 알고 있는 :class:`Formatter` 인스턴스와
사용자 지정된 문자열을 사용할 수 있다.
메세지 문자열에 맥락 정보를 붙여야 하는 경우와 같이 다른 메서드가 필요할 때는
:class:`LoggerAdapter`\ 를 서브클래싱하여
:meth:`~LoggerAdapter.process`\ 를 원하는 기능을 하도록 오버라이딩하면 된다.
다음은 이와 관련된 간단한 예시다. ::

    class CustomAdapter(logging.LoggerAdapter):
        """
        This example adapter expects the passed in dict-like object to have a
        'connid' key, whose value in brackets is prepended to the log message.
        """
        def process(self, msg, kwargs):
            return '[%s] %s' % (self.extra['connid'], msg), kwargs

위 어댑터는 다음과 같이 사용할 수 있다. ::

    logger = logging.getLogger(__name__)
    adapter = CustomAdapter(logger, {'connid': some_conn_id})

이제 어댑터로 로그하는 모든 이벤트는 로그 메세지에 붙여질 ``some_conn_id`` 값을 갖는다.

딕셔너리형이 아닌 객체로 맥락 정보 보내기
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

실제 딕셔너리를 :class:`LoggerAdapter`\ 에 보낼 필요는 없다.
``__getitem__``\ 과 ``__iter__``\ 를 구현해
로깅에는 딕셔너리와 같이 보이는 클래스의 인스턴스를 보낼 수 있다.
값이 고정된 딕셔너리와 달리 유동적인 값을 만들고자 하는 경우에 유용하다.


.. _filters-contextual:

필터를 사용해 맥락 정보 보내기
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

사용자 정의된 :class:`Filter`\ 를 보내 맥락 정보를 로그 출력에 추가할 수 있다.
``Filter`` 인스턴스는 필터로 보내질 ``LogRecords``\ 를 수정할 수 있다.
수정을 통해 적절한 포맷 문자열을 사용하는 출력이 될 수 있는 추가 인수나
필요한 경우에 커스텀 :class:`Formatter`\ 를 추가할 수 있다.

웹 어플리케이션과 같은 예시에서는
처리중인 리퀘스트나 리퀘스트 중 관심 있는 부분을 스레드 로컬(:class:`threading.local`) 변수에 저장하고
``Filter``\ 가 접근해 리퀘스트로부터의 정보를 ``LogRecord``\ 에 추가할 수 있다.
예를 들어, 위의 ``LoggerAdapter`` 예시처럼 원격 IP 주소와 사용자명을 각각 속성명 'ip'와 'user'를 사용해 보낸다.
동일한 포맷 문자열을 사용해 위 예시와 유사한 출력을 얻을 수 있다. 다음은 예시 스크립트다. ::

    import logging
    from random import choice

    class ContextFilter(logging.Filter):
        """
        This is a filter which injects contextual information into the log.

        Rather than use actual contextual information, we just use random
        data in this demo.
        """

        USERS = ['jim', 'fred', 'sheila']
        IPS = ['123.231.231.123', '127.0.0.1', '192.168.0.1']

        def filter(self, record):

            record.ip = choice(ContextFilter.IPS)
            record.user = choice(ContextFilter.USERS)
            return True

    if __name__ == '__main__':
        levels = (logging.DEBUG, logging.INFO, logging.WARNING, logging.ERROR, logging.CRITICAL)
        logging.basicConfig(level=logging.DEBUG,
                            format='%(asctime)-15s %(name)-5s %(levelname)-8s IP: %(ip)-15s User: %(user)-8s %(message)s')
        a1 = logging.getLogger('a.b.c')
        a2 = logging.getLogger('d.e.f')

        f = ContextFilter()
        a1.addFilter(f)
        a2.addFilter(f)
        a1.debug('A debug message')
        a1.info('An info message with %s', 'some parameters')
        for x in range(10):
            lvl = choice(levels)
            lvlname = logging.getLevelName(lvl)
            a2.log(lvl, 'A message at %s level with %d %s', lvlname, 2, 'parameters')

위 스크립트를 실행하면 다음과 같은 결과가 나타난다. ::

    2010-09-06 22:38:15,292 a.b.c DEBUG    IP: 123.231.231.123 User: fred     A debug message
    2010-09-06 22:38:15,300 a.b.c INFO     IP: 192.168.0.1     User: sheila   An info message with some parameters
    2010-09-06 22:38:15,300 d.e.f CRITICAL IP: 127.0.0.1       User: sheila   A message at CRITICAL level with 2 parameters
    2010-09-06 22:38:15,300 d.e.f ERROR    IP: 127.0.0.1       User: jim      A message at ERROR level with 2 parameters
    2010-09-06 22:38:15,300 d.e.f DEBUG    IP: 127.0.0.1       User: sheila   A message at DEBUG level with 2 parameters
    2010-09-06 22:38:15,300 d.e.f ERROR    IP: 123.231.231.123 User: fred     A message at ERROR level with 2 parameters
    2010-09-06 22:38:15,300 d.e.f CRITICAL IP: 192.168.0.1     User: jim      A message at CRITICAL level with 2 parameters
    2010-09-06 22:38:15,300 d.e.f CRITICAL IP: 127.0.0.1       User: sheila   A message at CRITICAL level with 2 parameters
    2010-09-06 22:38:15,300 d.e.f DEBUG    IP: 192.168.0.1     User: jim      A message at DEBUG level with 2 parameters
    2010-09-06 22:38:15,301 d.e.f ERROR    IP: 127.0.0.1       User: sheila   A message at ERROR level with 2 parameters
    2010-09-06 22:38:15,301 d.e.f DEBUG    IP: 123.231.231.123 User: fred     A message at DEBUG level with 2 parameters
    2010-09-06 22:38:15,301 d.e.f INFO     IP: 123.231.231.123 User: fred     A message at INFO level with 2 parameters


.. _multiple-processes:

다수의 프로세스에서 하나의 파일로 로깅
------------------------------------------------

로깅은 스레드-안정성을 가지고 단일 프로세스상의 멀티 스레드로부터 하나의 파일로 로깅도 지원하지만
여러 프로세스에서 하나의 파일로의 로깅하는 것은 지원하지 않는다.
파이썬에서는 여러 프로세스로부터 하나의 파일로의 접근을
직렬화 하는데 기준이 되는 방법이 없기 때문이다.
한가지 방법은 모든 프로세스 로그를
:class:`~handlers.SocketHandler`\ 에 두고 별도의 프로세스로 소켓을 읽고 파일에 로그를 쓰는 소켓 서버를 구현하는 것이다.
(원한다면 하나의 스레드를 하나의 기존 프로세스에 두어 이 함수를 수행하게 할 수 있다.)
:ref:`이 섹션 <network-logging>`\ 이 관련 접근법을 자세히 다루고 있으며
어플리케이션 제작시 참조용으로 사용될 수 있는 소켓 리시버 코드도 포함한다.

:mod:`multiprocessing` 모듈을 포함하는 최신 파이썬을 사용하고 있다면 이 모듈로부터
:class:`~multiprocessing.Lock`\ 를 사용해
프로세스로부터 파일로의 접근을 직렬화하는 핸들러를 직접 만들 수 있다.
기존 :class:`FileHandler`\ 와 하위 클래스는 현재 :mod:`multiprocessing`\ 을 사용하지 않지만
이후에는 지원할 수도 있다.
현재 :mod:`multiprocessing` 모듈은 모든 플랫폼에서 잠금 기능을 제공하지 않는다는 것을 알아두자.
(https://bugs.python.org/issue3770 참고).

.. currentmodule:: logging.handlers

대안으로 ``Queue``\ 와 :class:`QueueHandler`\ 를 사용해 멀티 프로세스 어플리케이션의
프로세스 중 한 곳으로 모든 로깅 이벤트를 보낼 수 있다. 다음은 이를 구현하기 위한 예시 스크립트다.
예로 든 개별 리스너 프로세스는 다른 프로세스가 보낸 이벤트를 듣고
리스너 프로세스의 로깅 설정에 따라 로그를 기록한다.
예시에서는 한가지 방법만을 설명하지만
리스너 프로세스와 다른 어플리케이션의 프로세스를 위한 완전히 다른 리스너 로깅 설정도 가능하다.
(예를 들어, 개별 리스너 프로세스 대신 리스너 스레드를 사용하길 원할 수 있다. 구현 방법은 비슷하다.)
예시 스크립트는 사용자의 특정 요구 사항을 만족하는 코드를 위한 기초 코드로 사용될 수 있다. ::

    # You'll need these imports in your own code
    import logging
    import logging.handlers
    import multiprocessing

    # Next two import lines for this demo only
    from random import choice, random
    import time

    #
    # Because you'll want to define the logging configurations for listener and workers, the
    # listener and worker process functions take a configurer parameter which is a callable
    # for configuring logging for that process. These functions are also passed the queue,
    # which they use for communication.
    #
    # In practice, you can configure the listener however you want, but note that in this
    # simple example, the listener does not apply level or filter logic to received records.
    # In practice, you would probably want to do this logic in the worker processes, to avoid
    # sending events which would be filtered out between processes.
    #
    # The size of the rotated files is made small so you can see the results easily.
    def listener_configurer():
        root = logging.getLogger()
        h = logging.handlers.RotatingFileHandler('mptest.log', 'a', 300, 10)
        f = logging.Formatter('%(asctime)s %(processName)-10s %(name)s %(levelname)-8s %(message)s')
        h.setFormatter(f)
        root.addHandler(h)

    # This is the listener process top-level loop: wait for logging events
    # (LogRecords)on the queue and handle them, quit when you get a None for a
    # LogRecord.
    def listener_process(queue, configurer):
        configurer()
        while True:
            try:
                record = queue.get()
                if record is None:  # We send this as a sentinel to tell the listener to quit.
                    break
                logger = logging.getLogger(record.name)
                logger.handle(record)  # No level or filter logic applied - just do it!
            except Exception:
                import sys, traceback
                print('Whoops! Problem:', file=sys.stderr)
                traceback.print_exc(file=sys.stderr)

    # Arrays used for random selections in this demo

    LEVELS = [logging.DEBUG, logging.INFO, logging.WARNING,
              logging.ERROR, logging.CRITICAL]

    LOGGERS = ['a.b.c', 'd.e.f']

    MESSAGES = [
        'Random message #1',
        'Random message #2',
        'Random message #3',
    ]

    # The worker configuration is done at the start of the worker process run.
    # Note that on Windows you can't rely on fork semantics, so each process
    # will run the logging configuration code when it starts.
    def worker_configurer(queue):
        h = logging.handlers.QueueHandler(queue)  # Just the one handler needed
        root = logging.getLogger()
        root.addHandler(h)
        # send all messages, for demo; no other level or filter logic applied.
        root.setLevel(logging.DEBUG)

    # This is the worker process top-level loop, which just logs ten events with
    # random intervening delays before terminating.
    # The print messages are just so you know it's doing something!
    def worker_process(queue, configurer):
        configurer(queue)
        name = multiprocessing.current_process().name
        print('Worker started: %s' % name)
        for i in range(10):
            time.sleep(random())
            logger = logging.getLogger(choice(LOGGERS))
            level = choice(LEVELS)
            message = choice(MESSAGES)
            logger.log(level, message)
        print('Worker finished: %s' % name)

    # Here's where the demo gets orchestrated. Create the queue, create and start
    # the listener, create ten workers and start them, wait for them to finish,
    # then send a None to the queue to tell the listener to finish.
    def main():
        queue = multiprocessing.Queue(-1)
        listener = multiprocessing.Process(target=listener_process,
                                           args=(queue, listener_configurer))
        listener.start()
        workers = []
        for i in range(10):
            worker = multiprocessing.Process(target=worker_process,
                                             args=(queue, worker_configurer))
            workers.append(worker)
            worker.start()
        for w in workers:
            w.join()
        queue.put_nowait(None)
        listener.join()

    if __name__ == '__main__':
        main()

다음 코드에서는 위 스크립트를 변형하여 메인 프로세스의 로깅을 별도의 스레드에 보관한다. ::

    import logging
    import logging.config
    import logging.handlers
    from multiprocessing import Process, Queue
    import random
    import threading
    import time

    def logger_thread(q):
        while True:
            record = q.get()
            if record is None:
                break
            logger = logging.getLogger(record.name)
            logger.handle(record)


    def worker_process(q):
        qh = logging.handlers.QueueHandler(q)
        root = logging.getLogger()
        root.setLevel(logging.DEBUG)
        root.addHandler(qh)
        levels = [logging.DEBUG, logging.INFO, logging.WARNING, logging.ERROR,
                  logging.CRITICAL]
        loggers = ['foo', 'foo.bar', 'foo.bar.baz',
                   'spam', 'spam.ham', 'spam.ham.eggs']
        for i in range(100):
            lvl = random.choice(levels)
            logger = logging.getLogger(random.choice(loggers))
            logger.log(lvl, 'Message no. %d', i)

    if __name__ == '__main__':
        q = Queue()
        d = {
            'version': 1,
            'formatters': {
                'detailed': {
                    'class': 'logging.Formatter',
                    'format': '%(asctime)s %(name)-15s %(levelname)-8s %(processName)-10s %(message)s'
                }
            },
            'handlers': {
                'console': {
                    'class': 'logging.StreamHandler',
                    'level': 'INFO',
                },
                'file': {
                    'class': 'logging.FileHandler',
                    'filename': 'mplog.log',
                    'mode': 'w',
                    'formatter': 'detailed',
                },
                'foofile': {
                    'class': 'logging.FileHandler',
                    'filename': 'mplog-foo.log',
                    'mode': 'w',
                    'formatter': 'detailed',
                },
                'errors': {
                    'class': 'logging.FileHandler',
                    'filename': 'mplog-errors.log',
                    'mode': 'w',
                    'level': 'ERROR',
                    'formatter': 'detailed',
                },
            },
            'loggers': {
                'foo': {
                    'handlers': ['foofile']
                }
            },
            'root': {
                'level': 'DEBUG',
                'handlers': ['console', 'file', 'errors']
            },
        }
        workers = []
        for i in range(5):
            wp = Process(target=worker_process, name='worker %d' % (i + 1), args=(q,))
            workers.append(wp)
            wp.start()
        logging.config.dictConfig(d)
        lp = threading.Thread(target=logger_thread, args=(q,))
        lp.start()
        # At this point, the main process could do some useful work of its own
        # Once it's done that, it can wait for the workers to terminate...
        for wp in workers:
            wp.join()
        # And now tell the logging thread to finish up, too
        q.put(None)
        lp.join()

변형된 스크립트에서 특정 로거에 설정을 적용하는 방법을 볼 수 있다.
예를 들어 ``foo`` 로거는 ``foo`` 하위 시스템의 모든 이벤트를
``mplog-foo.log`` 파일에 저장하는 특별한 핸들러를 가지고 있다.
이는 메인 프로세스의 장치 로깅에 사용되며
로깅 이벤트가 작업 프로세스에 의해 생성되었더라도 적절한 목적지에 메세지를 보낸다.

파일 로테이션 사용
-------------------

.. sectionauthor:: Doug Hellmann, Vinay Sajip (changes)
.. (see <https://pymotw.com/3/logging/>)

로그 파일이 특정 크기가 되면 새 파일을 열어 그 곳에 로그를 저장해야 할 수 있다.
로그 파일이 계속 생성되어 특정 갯수가 되면
파일을 순환해 로그 파일의 수와 크기에 제한을 두길 원할 수도 있다.
이런 사용 방식을 위해 로깅 패키지는 :class:`~handlers.RotatingFileHandler`\ 를 제공한다. ::

   import glob
   import logging
   import logging.handlers

   LOG_FILENAME = 'logging_rotatingfile_example.out'

   # Set up a specific logger with our desired output level
   my_logger = logging.getLogger('MyLogger')
   my_logger.setLevel(logging.DEBUG)

   # Add the log message handler to the logger
   handler = logging.handlers.RotatingFileHandler(
                 LOG_FILENAME, maxBytes=20, backupCount=5)

   my_logger.addHandler(handler)

   # Log some messages
   for i in range(20):
       my_logger.debug('i = %d' % i)

   # See what files are created
   logfiles = glob.glob('%s*' % LOG_FILENAME)

   for filename in logfiles:
       print(filename)

결과는 다음과 같이 어플리케이션의 로그 기록이 담긴 여섯개의 개별 파일이 되어야 한다. ::

   logging_rotatingfile_example.out
   logging_rotatingfile_example.out.1
   logging_rotatingfile_example.out.2
   logging_rotatingfile_example.out.3
   logging_rotatingfile_example.out.4
   logging_rotatingfile_example.out.5

가장 최신 기록이 담긴 파일은 :file:`logging_rotatingfile_example.out`\ 이 되고
파일이 크기 제한에 도달하면 파일명 끝에 ``.1``\ 이 붙는다. ``.1``\ 이 다음에는 ``.2``\ 이 되는 것과 같이
기존 백업 파일은 끝의 숫자가 커지는 방식으로 이름이 바뀌고 ``.6`` 이후 파일은 삭제된다.

이 예시의 로그 길이 제한은 매우 짧다. *maxBytes*로 적절한 값을 설정할 수 있다.

.. _format-styles:

대체 포맷 스타일 사용
------------------------------------

로깅 기능이 최초로 파이썬 표준 라이브러리에 추가되었을 때는 변수 내용과 함께 메세지를 포매팅하려면
%-포매팅 메서드를 사용해야 했다.
이후로 파이썬에 포매팅을 위한 두가지 방법이 추가되었는데
:class:`string.Template` (파이썬 2.4)와 :meth:`str.format` (파이썬 2.6)이다.

파이썬 3.2 이후로 로깅은 두가지 추가 포매팅 스타일의 지원을 강화했다.
:class:`Formatter` 클래스는 ``style``\ 이라는 추가, 선택 키워드 매개변수를 받도록 개선됐다.
기본은 ``'%'``\ 지만 다른 두가지 포매팅 스타일에 대응되는 ``'{'``\ 와 ``'$'`` 값도 가능하다.
기본으로 하위 호환이 지원되지만 명시적으로 스타일 매개 변수를 지정해 :meth:`str.format`\ 나
:class:`string.Template`\ 를 위한 포맷 문자열을 지정할 수 있다.
다음은 가능한 여러 예시를 보여주는 콘솔 세션이다.

.. code-block:: pycon

    >>> import logging
    >>> root = logging.getLogger()
    >>> root.setLevel(logging.DEBUG)
    >>> handler = logging.StreamHandler()
    >>> bf = logging.Formatter('{asctime} {name} {levelname:8s} {message}',
    ...                        style='{')
    >>> handler.setFormatter(bf)
    >>> root.addHandler(handler)
    >>> logger = logging.getLogger('foo.bar')
    >>> logger.debug('This is a DEBUG message')
    2010-10-28 15:11:55,341 foo.bar DEBUG    This is a DEBUG message
    >>> logger.critical('This is a CRITICAL message')
    2010-10-28 15:12:11,526 foo.bar CRITICAL This is a CRITICAL message
    >>> df = logging.Formatter('$asctime $name ${levelname} $message',
    ...                        style='$')
    >>> handler.setFormatter(df)
    >>> logger.debug('This is a DEBUG message')
    2010-10-28 15:13:06,924 foo.bar DEBUG This is a DEBUG message
    >>> logger.critical('This is a CRITICAL message')
    2010-10-28 15:13:11,494 foo.bar CRITICAL This is a CRITICAL message
    >>>

최종 출력용 로깅 메세지의 포매팅은 개별적인 로깅 메세지가 구성되는 방식과는 완전히 독립적이다.
다음처럼 개별 로깅 메세지는 %-포매팅을 사용할 수 있다. ::

    >>> logger.error('This is an%s %s %s', 'other,', 'ERROR,', 'message')
    2010-10-28 15:19:29,833 foo.bar ERROR This is another, ERROR, message
    >>>

``logger.debug()``, ``logger.info()`` 등의 로깅 호출은
실제 로깅 메세지 자체를 위한 위치 매개 변수만을 받는다.
키워드 매개 변수는 실제 로깅 호출을 처리하는 방법을 위한 옵션을 결정할 때만 사용된다.
(예시: 역추적 정보가 로그되어야 함을 나타내는 키워드 매개 변수 ``exc_info``\ 와
추가 컨텍스트 정보가 로그의 추가됨을 나타내는 ``extra`` 키워드 매개 변수)
:meth:`str.format` \ 이나 :class:`string.Template` 문법을 사용해 로깅 호출을 바로 만들 수는 없다.
내부적으로 로깅 패키지는 %-포매팅을 사용해 포맷 문자열과 변수 인수를 합치기 때문이다.
기존 코드에 있는 모든 로깅 호출이 %-포맷 문자열을 사용하기 때문에
하위 호환성 유지를 위해 이를 바꾸지 않을 것이다.

그러나 {}- 포매팅과 $- 포매팅을 사용해 개별 로그 메세지를 구성할 수 있다.
메세지에 임의의 객체를 메세지 포맷 문자열로 사용할 수 있고
로깅 패키지는 그 객체에서 ``str()``\ 을 호출해
실제 포맷 문자열을 얻는다는 것을 기억한다.
다음 두 클래스를 생각해보자. ::

    class BraceMessage:
        def __init__(self, fmt, *args, **kwargs):
            self.fmt = fmt
            self.args = args
            self.kwargs = kwargs

        def __str__(self):
            return self.fmt.format(*self.args, **self.kwargs)

    class DollarMessage:
        def __init__(self, fmt, **kwargs):
            self.fmt = fmt
            self.kwargs = kwargs

        def __str__(self):
            from string import Template
            return Template(self.fmt).substitute(**self.kwargs)

두 클래스를 포맷 문자열 자리에 사용해 {}-포매팅 또는 $-포매팅을 허용하면
"%(메세지)", "{메세지}", "$메세지" 자리에 포맷화된 로그 출력으로 나타날 실제 "메세지"를 생성할 수 있다.
무언가 로그할 때마다 클래스 네임을 사용하는 것은 번거롭지만
더블 언더스코어(__)와 같은 별칭을 사용하면 더 간단하게 할 수 있다.
더블 언더스코어(__)는 :func:`gettext.gettext`\ 의 별칭으로 사용되는 언더스코어(_)와
혼동되지 않기 위해 사용한다.

위의 클래스들은 파이썬에 포함되어 있지 않지만 코드에 복사해 가져오기 쉽다.
다음과 같이 사용될 수 있다.(``wherever`` 모듈 안에 호출된다고 가정한다.

.. code-block:: pycon

    >>> from wherever import BraceMessage as __
    >>> print(__('Message with {0} {name}', 2, name='placeholders'))
    Message with 2 placeholders
    >>> class Point: pass
    ...
    >>> p = Point()
    >>> p.x = 0.5
    >>> p.y = 0.5
    >>> print(__('Message with coordinates: ({point.x:.2f}, {point.y:.2f})',
    ...       point=p))
    Message with coordinates: (0.50, 0.50)
    >>> from wherever import DollarMessage as __
    >>> print(__('Message with $num $what', num=2, what='placeholders'))
    Message with 2 placeholders
    >>>

위의 예시는 포매팅 작동 방식을 보여주기 위해 ``print()``\ 를 사용하지만
``logger.debug()``\ 나 유사한 것을 사용해 실제로 로그를 할 수 있다.

이 예시에서 알아야 할 것은 이러한 접근법으로 인한 심각한 성능 저하가 없다는 것이다.
실제 포매팅은 로깅 호출을 생성할 때가 아니라 로그된 메세지가 핸들러로 출력되려할 때 이루어진다.
실수를 할 수 있는 특이한 부분은 포맷 문자열이 아니라 포맷 문자열과 인수를 둘러싸는 괄호다.
더블 언더스코어(__) 표기법은 XXXMessage 클래스 중 하나로의 생성자 호출을 위한 문법 첨가물일 뿐이기 때문이다.

원한다면 :class:`LoggerAdapter`\ 를 사용해 위 예시와 같은 효과를 볼 수 있다. 다음 예시를 참고한다. ::

    import logging

    class Message(object):
        def __init__(self, fmt, args):
            self.fmt = fmt
            self.args = args

        def __str__(self):
            return self.fmt.format(*self.args)

    class StyleAdapter(logging.LoggerAdapter):
        def __init__(self, logger, extra=None):
            super(StyleAdapter, self).__init__(logger, extra or {})

        def log(self, level, msg, *args, **kwargs):
            if self.isEnabledFor(level):
                msg, kwargs = self.process(msg, kwargs)
                self.logger._log(level, Message(msg, args), (), **kwargs)

    logger = StyleAdapter(logging.getLogger(__name__))

    def main():
        logger.debug('Hello, {}', 'world!')

    if __name__ == '__main__':
        logging.basicConfig(level=logging.DEBUG)
        main()

파이썬 3.2 이후 버전에서 위의 스크립트는 ``Hello, world!`` 메세지를 출력해야 한다.


.. currentmodule:: logging

.. _custom-logrecord:

``LogRecord`` 커스터마이징
---------------------------------------

모든 로그 이벤트는 :class:`LogRecord` 인스턴스로 나타난다.
이벤트가 로그되고 로거의 레벨에 의해 필터링되지 않았다면
:class:`LogRecord`\ 가 생성되고
이벤트에 대한 정보가 채워진 후
그 로거(그리고 전파 비활성화된 로거를 만날 때까지 그 조상 로거) 핸들러로 보내진다.
파이썬 3.2 이전에는 :class:`LogRecord` 생성이 두 곳에서 일어났다.

* :meth:`Logger.makeRecord` 메서드는 이벤트를 로깅하는 일반 프로세스에서 호출된다.
  인스턴스 생성을 위해 :class:`LogRecord`\ 를 직접 호출한다.
* :func:`makeLogRecord`\ 는 LogRecord에 추가될 속성을 담고 있는 딕셔너리와 함께 호출된다.
  이 메서드는 보통 적절한 딕셔너리가 네트워크를 통해 수신됐을 때 호출된다.
  (:class:`~handlers.SocketHandler`\ 를 통한 피클 형태 또는
  :class:`~handlers.HTTPHandler`\ 를 통한 JSON 형태)

이는 :class:`LogRecord`\ 로 특별한 일을 해야할 때는 다음 중 하나를 해야한다는 의미다.

* :meth:`Logger.makeRecord`\ 를 오버라이딩하는 사용자만의 :class:`Logger` 서브 클래스를 만든다.
  관련된 로거가 인스턴스되기 전에 :func:`~logging.setLoggerClass`\ 를 사용해 서브 클래스를 설정한다.
* 로거나 핸들러에 :class:`Filter`\ 를 추가한다.
  추가된 필터는 필터의 :meth:`~Filter.filter` 메서드가 호출되었을 때 사용자가 원하는 특정 변환을 한다.

첫번째 접근법은 여러개의 라이브러리가 다른 일을 하길 원하는 시나리오에서 번거로울 수 있다.
각 라이브러리가 자신의 :class:`Logger` 서브 클래스를 설정하려 하고 가장 마지막에 설정한 것으로 된다.

두번째 접근법은 많은 경우에 잘 작동하지만 특별히 설정된 :class:`LogRecord` 서브 클래스를 사용할 수 없다.
라이브러리 개발자는 적절한 필터를 로거에 넣을 수 있지만 새 로거를 소개할 때마다 이 작업을 하도록 기억해야 한다.
다음과 같이 모듈 레벨에서 새 패키지나 모듈을 추가한다.::

   logger = logging.getLogger(__name__)

이 방법은 고려할 사항이 너무 많다.
개발자는 최상위 로거의 추가된 :class:`~logging.NullHandler`\ 에
필터를 추가할 수 있지만
어플리케이션 개발자가 더 낮은 레벨의 라이브러리 로거에 핸들러를 추가하면 호출되지 않을 수 있다.
따라서 그 핸들러로부터의 출력은 라이브러리 개발자의 의도를 반영하지 않을 수 있다.

파이썬 3.2 이후에서 :class:`~logging.LogRecord`\ 는 사용자가 지정할 수 있는 팩토리를 통해 생성된다.
팩토리는 :func:`~logging.setLogRecordFactory`\ 로 설정할 수 있으며 호출가능하고 :func:`~logging.getLogRecordFactory`\ 로
팩토리 정보를 얻을 수 있다. 팩토리는 :class:`LogRecord`\ 가 기본 설정이라는 점에서
:class:`~logging.LogRecord` 생성자와 같이 호출된다.

이 방식은 사용자 지정 팩토리로 LogRecord 생성의 모든 요소를 제어할 수 있게 한다.
예를 들어, 다음과 같은 패턴으로 서브 클래스를 반환하거나 생성된 레코드에 추가 인수를 추가할 수 있다. ::

    old_factory = logging.getLogRecordFactory()

    def record_factory(*args, **kwargs):
        record = old_factory(*args, **kwargs)
        record.custom_attribute = 0xdecafbad
        return record

    logging.setLogRecordFactory(record_factory)

이 패턴으로 여러 라이브러리가 팩토리로 함께 묶일 수 있다.
이를 통해 다른 라이브러리의 인수나 표준으로 부여된 인수를 덮어쓰지 않게 된다.
그러나 함께 묶여있는 각 링크로 인해 모든 로깅 과정에 실행 시간 추가 비용이 발생하고
이 기술은 :class:`Filter`\ 의 사용으로 원하는 결과를 얻을 수 없을 때만 사용되어야 함을 알고 있어야 한다.


.. _zeromq-handlers:

QueueHandler 서브클래싱 - ZeroMQ의 예
-------------------------------------------------------------------

:class:`QueueHandler` 서브 클래스를 사용해 다른 종류의 큐로 메세지를 보낼 수 있다.
설명에 사용되는 ZeroMQ 'publish' 소켓이다.
다응 예시에서 소켓은 개별적으로 생성되고
핸들러의 큐인 것처럼 핸들러로 보내진다. ::

    import zmq   # using pyzmq, the Python binding for ZeroMQ
    import json  # for serializing records portably

    ctx = zmq.Context()
    sock = zmq.Socket(ctx, zmq.PUB)  # or zmq.PUSH, or other suitable value
    sock.bind('tcp://*:5556')        # or wherever

    class ZeroMQSocketHandler(QueueHandler):
        def enqueue(self, record):
            self.queue.send_json(record.__dict__)


    handler = ZeroMQSocketHandler(sock)


핸들러가 필요로 하는 데이터에 보내 소켓을 생성하는 것과 같이 다른 방법도 있다. ::

    class ZeroMQSocketHandler(QueueHandler):
        def __init__(self, uri, socktype=zmq.PUB, ctx=None):
            self.ctx = ctx or zmq.Context()
            socket = zmq.Socket(self.ctx, socktype)
            socket.bind(uri)
            super().__init__(socket)

        def enqueue(self, record):
            self.queue.send_json(record.__dict__)

        def close(self):
            self.queue.close()


QueueListener 서브클래싱 - ZeroMQ의 예
--------------------------------------------

:class:`QueueListener` 서브 클래스를 사용해 다른 종류의 큐로부터 메세지를 받을 수도 있다.
다음은 ZeroMQ 'subscribe' 소켓과 관련된 예시다. ::

    class ZeroMQSocketListener(QueueListener):
        def __init__(self, uri, *handlers, **kwargs):
            self.ctx = kwargs.get('ctx') or zmq.Context()
            socket = zmq.Socket(self.ctx, zmq.SUB)
            socket.setsockopt_string(zmq.SUBSCRIBE, '')  # subscribe to everything
            socket.connect(uri)
            super().__init__(socket, *handlers, **kwargs)

        def dequeue(self):
            msg = self.queue.recv_json()
            return logging.makeLogRecord(msg)


.. seealso::

   모듈 :mod:`logging`
      로깅 모델을 위한 API 참조.

   모듈 :mod:`logging.config`
      로깅 모듈을 위한 설정 API.

   모듈 :mod:`logging.handlers`
      로깅 모듈에 포함된 유용한 핸들러.

   :ref:`로깅 튜토리얼 <logging-basic-tutorial>`

   :ref:`고급 로깅 튜토리 <logging-advanced-tutorial>`


딕셔너리 기반 설정 예시
-----------------------------------------

다음은 `장고(Django) 프로젝트 문서 <https://docs.djangoproject.com/en/1.9/topics/logging/#configuring-logging>`_\
에서 가져온 로깅 설정 딕셔너리 예시다. 이 딕셔너리는 :func:`~config.dictConfig`\ 로 보내지고 설정이 적용된다. ::

    LOGGING = {
        'version': 1,
        'disable_existing_loggers': True,
        'formatters': {
            'verbose': {
                'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
            },
            'simple': {
                'format': '%(levelname)s %(message)s'
            },
        },
        'filters': {
            'special': {
                '()': 'project.logging.SpecialFilter',
                'foo': 'bar',
            }
        },
        'handlers': {
            'null': {
                'level':'DEBUG',
                'class':'django.utils.log.NullHandler',
            },
            'console':{
                'level':'DEBUG',
                'class':'logging.StreamHandler',
                'formatter': 'simple'
            },
            'mail_admins': {
                'level': 'ERROR',
                'class': 'django.utils.log.AdminEmailHandler',
                'filters': ['special']
            }
        },
        'loggers': {
            'django': {
                'handlers':['null'],
                'propagate': True,
                'level':'INFO',
            },
            'django.request': {
                'handlers': ['mail_admins'],
                'level': 'ERROR',
                'propagate': False,
            },
            'myproject.custom': {
                'handlers': ['console', 'mail_admins'],
                'level': 'INFO',
                'filters': ['special']
            }
        }
    }

위 설정과 관련된 자세한 정보는 장고 문서의
`관련 섹션 <https://docs.djangoproject.com/en/1.9/topics/logging/#configuring-logging>`_\ 에서
볼 수 있다.

.. _cookbook-rotator-namer:

로그 ratator와 namer를 사용한 로그 순환 프로세싱 커스터마이징
------------------------------------------------------------------------------------------------

다음 코드는 namer와 rotator 설정 예시다. 로그 파일의 zlip 기반 압축을 보여준다. ::

    def namer(name):
        return name + ".gz"

    def rotator(source, dest):
        with open(source, "rb") as sf:
            data = sf.read()
            compressed = zlib.compress(data, 9)
            with open(dest, "wb") as df:
                df.write(compressed)
        os.remove(source)

    rh = logging.handlers.RotatingFileHandler(...)
    rh.rotator = rotator
    rh.namer = namer

이 파일들은 텅빈 압축 데이터로 실제 gzip 파일에서 볼 수 있는 컨테이너가 없기 때문에 진짜 .gz 파일이 아니다.
위 코드는 설명을 위한 예시일 뿐이다.

더 정교한 멀티 프로세싱 예시
----------------------------------------

다음 예시는 설정 파일을 사용하는 멀티 프로세싱에 로깅이 어떻게 사용될 수 있는지 보여준다.
간단한 설정이지만 실제 멀티프로세싱 시나리오에서 더 복잡한 설정이 어떻게 구현될 수 있는지 설명한다.

예시에서 메인 프로세스는 리스너 프로세스와 몇몇 작업 프로세스를 생성한다.
각 메인 프로세스, 리스너 프로세스, 작업 프로세스는 구별되는 세개의 설정을 갖는다.
(작업 프로세스는 모두 같은 설정을 공유한다.)
우리는 메인 프로세스의 로깅에서 작업 프로세스가 어떻게 QueueHandler로 로그하는지와
리스너 프로세스가 어떻게 QueueListener와 더 복잡한 로깅 설정을 구현하고
큐를 통해 받은 이벤트를 설정에 지정된 핸들러로 보내기 위해 정렬하는지 볼 수 있다.
이 설정들은 설명만을 위한 것이지만 이 예시를 사용자의 시나리오에 적용할 수 있어야 한다.

다음은 예시 스크립트다. 독스트링과 코멘트가 작동 방식을 설명한다. ::

    import logging
    import logging.config
    import logging.handlers
    from multiprocessing import Process, Queue, Event, current_process
    import os
    import random
    import time

    class MyHandler:
        """
        A simple handler for logging events. It runs in the listener process and
        dispatches events to loggers based on the name in the received record,
        which then get dispatched, by the logging system, to the handlers
        configured for those loggers.
        """
        def handle(self, record):
            logger = logging.getLogger(record.name)
            # The process name is transformed just to show that it's the listener
            # doing the logging to files and console
            record.processName = '%s (for %s)' % (current_process().name, record.processName)
            logger.handle(record)

    def listener_process(q, stop_event, config):
        """
        This could be done in the main process, but is just done in a separate
        process for illustrative purposes.

        This initialises logging according to the specified configuration,
        starts the listener and waits for the main process to signal completion
        via the event. The listener is then stopped, and the process exits.
        """
        logging.config.dictConfig(config)
        listener = logging.handlers.QueueListener(q, MyHandler())
        listener.start()
        if os.name == 'posix':
            # On POSIX, the setup logger will have been configured in the
            # parent process, but should have been disabled following the
            # dictConfig call.
            # On Windows, since fork isn't used, the setup logger won't
            # exist in the child, so it would be created and the message
            # would appear - hence the "if posix" clause.
            logger = logging.getLogger('setup')
            logger.critical('Should not appear, because of disabled logger ...')
        stop_event.wait()
        listener.stop()

    def worker_process(config):
        """
        A number of these are spawned for the purpose of illustration. In
        practice, they could be a heterogeneous bunch of processes rather than
        ones which are identical to each other.

        This initialises logging according to the specified configuration,
        and logs a hundred messages with random levels to randomly selected
        loggers.

        A small sleep is added to allow other processes a chance to run. This
        is not strictly needed, but it mixes the output from the different
        processes a bit more than if it's left out.
        """
        logging.config.dictConfig(config)
        levels = [logging.DEBUG, logging.INFO, logging.WARNING, logging.ERROR,
                  logging.CRITICAL]
        loggers = ['foo', 'foo.bar', 'foo.bar.baz',
                   'spam', 'spam.ham', 'spam.ham.eggs']
        if os.name == 'posix':
            # On POSIX, the setup logger will have been configured in the
            # parent process, but should have been disabled following the
            # dictConfig call.
            # On Windows, since fork isn't used, the setup logger won't
            # exist in the child, so it would be created and the message
            # would appear - hence the "if posix" clause.
            logger = logging.getLogger('setup')
            logger.critical('Should not appear, because of disabled logger ...')
        for i in range(100):
            lvl = random.choice(levels)
            logger = logging.getLogger(random.choice(loggers))
            logger.log(lvl, 'Message no. %d', i)
            time.sleep(0.01)

    def main():
        q = Queue()
        # The main process gets a simple configuration which prints to the console.
        config_initial = {
            'version': 1,
            'formatters': {
                'detailed': {
                    'class': 'logging.Formatter',
                    'format': '%(asctime)s %(name)-15s %(levelname)-8s %(processName)-10s %(message)s'
                }
            },
            'handlers': {
                'console': {
                    'class': 'logging.StreamHandler',
                    'level': 'INFO',
                },
            },
            'root': {
                'level': 'DEBUG',
                'handlers': ['console']
            },
        }
        # The worker process configuration is just a QueueHandler attached to the
        # root logger, which allows all messages to be sent to the queue.
        # We disable existing loggers to disable the "setup" logger used in the
        # parent process. This is needed on POSIX because the logger will
        # be there in the child following a fork().
        config_worker = {
            'version': 1,
            'disable_existing_loggers': True,
            'handlers': {
                'queue': {
                    'class': 'logging.handlers.QueueHandler',
                    'queue': q,
                },
            },
            'root': {
                'level': 'DEBUG',
                'handlers': ['queue']
            },
        }
        # The listener process configuration shows that the full flexibility of
        # logging configuration is available to dispatch events to handlers however
        # you want.
        # We disable existing loggers to disable the "setup" logger used in the
        # parent process. This is needed on POSIX because the logger will
        # be there in the child following a fork().
        config_listener = {
            'version': 1,
            'disable_existing_loggers': True,
            'formatters': {
                'detailed': {
                    'class': 'logging.Formatter',
                    'format': '%(asctime)s %(name)-15s %(levelname)-8s %(processName)-10s %(message)s'
                },
                'simple': {
                    'class': 'logging.Formatter',
                    'format': '%(name)-15s %(levelname)-8s %(processName)-10s %(message)s'
                }
            },
            'handlers': {
                'console': {
                    'class': 'logging.StreamHandler',
                    'level': 'INFO',
                    'formatter': 'simple',
                },
                'file': {
                    'class': 'logging.FileHandler',
                    'filename': 'mplog.log',
                    'mode': 'w',
                    'formatter': 'detailed',
                },
                'foofile': {
                    'class': 'logging.FileHandler',
                    'filename': 'mplog-foo.log',
                    'mode': 'w',
                    'formatter': 'detailed',
                },
                'errors': {
                    'class': 'logging.FileHandler',
                    'filename': 'mplog-errors.log',
                    'mode': 'w',
                    'level': 'ERROR',
                    'formatter': 'detailed',
                },
            },
            'loggers': {
                'foo': {
                    'handlers': ['foofile']
                }
            },
            'root': {
                'level': 'DEBUG',
                'handlers': ['console', 'file', 'errors']
            },
        }
        # Log some initial events, just to show that logging in the parent works
        # normally.
        logging.config.dictConfig(config_initial)
        logger = logging.getLogger('setup')
        logger.info('About to create workers ...')
        workers = []
        for i in range(5):
            wp = Process(target=worker_process, name='worker %d' % (i + 1),
                         args=(config_worker,))
            workers.append(wp)
            wp.start()
            logger.info('Started worker: %s', wp.name)
        logger.info('About to create listener ...')
        stop_event = Event()
        lp = Process(target=listener_process, name='listener',
                     args=(q, stop_event, config_listener))
        lp.start()
        logger.info('Started listener')
        # We now hang around for the workers to finish their work.
        for wp in workers:
            wp.join()
        # Workers all done, listening can now stop.
        # Logging in the parent still works normally.
        logger.info('Telling listener to stop ...')
        stop_event.set()
        lp.join()
        logger.info('All done.')

    if __name__ == '__main__':
        main()


SysLogHandler에 보내지는 메세지에 BOM 삽입하기
-----------------------------------------------------

`RFC 5424 <https://tools.ietf.org/html/rfc5424>`_\ 는 syslog 데몬으로 보내지는
유니코드 메세지는 다음 구조를 갖는 바이트 모음으로 보내지길 요구한다.
선택적인 순수 ASCII 컴포넌트, UTF-8 BOM(바이트 순서 표식), UTF-8로 인코딩된 유니코드.
(`관련 섹션 <https://tools.ietf.org/html/rfc5424#section-6>`_\ 을 참고한다.)

파이썬 3.1에서 메세지에 BOM을 삽입하는 코드가 :class:`~logging.handlers.SysLogHandler`\ 에 추가되었다.
하지만 잘못 구현되어 BOM이 메세지 시작 부분에 나타나고 앞에 순수 ASCII 컴포넌트가 올 수 있다.

파이썬 3.2.4 이후 버전에서는 잘못된 BOM 삽입 코드가 삭제되었지만 다른 코드로 대체되지 않았다.
따라서 BOM 앞뒤로 각각 선택적 순수 ASCII 시퀀스와 임의의 UTF-8 인코딩 유니코드가 오는

#. 다음과 같은 포맷 문자열로 :class:`~logging.Formatter` 인스턴스를
   사용자의 :class:`~logging.handlers.SysLogHandler` 인스턴스에 추가한다. ::

      'ASCII section\ufeffUnicode section'

   유니코드 포인트 U+FEFF는 UTF-8로 인코딩할 때 UTF-8 BOM로 인코딩 되고 ``b'\xef\xbb\xbf'``\ 가 된다.

#. ASCII 섹션을 원하는 자리표시자로 대체하지만 대체 이후에 그 섹션에 나타나는 데이터는 항상 ASCII가 된다.
   (이로 인해 UTF-8 인코딩 이후에도 변경되지 않고 남는다.)

#. 유니코드 섹션을 원하는 자리표시자로 대체한다. 대체 이후에 섹션에 나타나는 데이터가 ASCII 범위 바깥의 문자를
   포함해도 UTF-8로 인코딩될 것이기 때문에 괜찮다.

포맷화된 메세지는 ``SysLogHandler``\로 인코딩되며 UTF-8을 사용한다.
위의 규칙을 지킨다면 RFC 5424를 준수하는 메세지를 생성할 수 있다.
위배된 규칙이 있으면 로깅에서는 문제가 없이 지나가지만 메세지는 RFC 5424를 준수하지 않기 때문에 syslog 데몬에서 문제가 생길 수 있다.


구조화된 로그 구현
-------------------------------

대부분의 로깅 메세지는 사람이 읽기 위한 것이고 당연히 기계가 쉽게 파싱할 수 없다.
하지만 프로그램으로 파싱할 수 있도록 구조화된 포맷의 출력 메세지가 필요한 상황이 올 수 있다.
(복잡한 정규 표현식을 사용하지 않고 로그 메세지를 파싱할 수 있는 것이 좋다.)
로깅 패키지를 사용하면 이러한 구조화 로그를 간단히 구현할 수 있다.
다양한 방법이 있지만 다음 예시는 JSON을 사용해 이벤트를 기계가 파싱할 수 있게 나열하는 간단한 방법이다. ::

    import json
    import logging

    class StructuredMessage(object):
        def __init__(self, message, **kwargs):
            self.message = message
            self.kwargs = kwargs

        def __str__(self):
            return '%s >>> %s' % (self.message, json.dumps(self.kwargs))

    _ = StructuredMessage   # optional, to improve readability

    logging.basicConfig(level=logging.INFO, format='%(message)s')
    logging.info(_('message 1', foo='bar', bar='baz', num=123, fnum=123.456))

위 스크립트가 실행되면 다음과 같은 메세지가 나타난다. ::

    message 1 >>> {"fnum": 123.456, "num": 123, "bar": "baz", "foo": "bar"}

아이템의 나열 순서는 파이썬 버전에 따라 달라질 수 있다.

보다 특화된 처리를 원한다면 다음 예시와 같이 사용자 지정 JSON 인코더를 사용할 수 있다. ::

    from __future__ import unicode_literals

    import json
    import logging

    # This next bit is to ensure the script runs unchanged on 2.x and 3.x
    try:
        unicode
    except NameError:
        unicode = str

    class Encoder(json.JSONEncoder):
        def default(self, o):
            if isinstance(o, set):
                return tuple(o)
            elif isinstance(o, unicode):
                return o.encode('unicode_escape').decode('ascii')
            return super(Encoder, self).default(o)

    class StructuredMessage(object):
        def __init__(self, message, **kwargs):
            self.message = message
            self.kwargs = kwargs

        def __str__(self):
            s = Encoder().encode(self.kwargs)
            return '%s >>> %s' % (self.message, s)

    _ = StructuredMessage   # optional, to improve readability

    def main():
        logging.basicConfig(level=logging.INFO, format='%(message)s')
        logging.info(_('message 1', set_value={1, 2, 3}, snowman='\u2603'))

    if __name__ == '__main__':
        main()

위 스크립트가 실행되면 다음과 같이 나타난다. ::

    message 1 >>> {"snowman": "\u2603", "set_value": [1, 2, 3]}

아이템의 나열 순서는 파이썬 버전에 따라 달라질 수 있다.


.. _custom-handlers:

.. currentmodule:: logging.config

:func:`dictConfig` 함수로 핸들러 커스터마이징
--------------------------------------------

특정한 방법으로 로깅 핸들러를 커스터마이징 하길 원할 때가 있다.
:func:`dictConfig`\ 를 사용하면 서브 클래스화 없이 커스터마이징 할 수 있다.
아래 예시처럼 로그 파일의 소유권을 설정하길 원하는 경우를 생각해보자.
POSIX에서 :func:`shutil.chown`\ 를 사용해 손쉽게 할 수 있지만 stdlib의 파일 핸들러는 빌트인 지원을 제공하지 않는다.
핸들러 생성을 다음과 같은 순수 함수로 커스터마이징할 수 있다. ::

    def owned_file_handler(filename, mode='a', encoding=None, owner=None):
        if owner:
            if not os.path.exists(filename):
                open(filename, 'a').close()
            shutil.chown(filename, *owner)
        return logging.FileHandler(filename, mode, encoding)

다음으로 :func:`dictConfig`\ 로 보내지는 로깅 설정에서
로깅 핸들러가 이 함수를 호출함으로써 생성된다는 것을 명시할 수 있다. ::

    LOGGING = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'default': {
                'format': '%(asctime)s %(levelname)s %(name)s %(message)s'
            },
        },
        'handlers': {
            'file':{
                # The values below are popped from this dictionary and
                # used to create the handler, set the handler's level and
                # its formatter.
                '()': owned_file_handler,
                'level':'DEBUG',
                'formatter': 'default',
                # The values below are passed to the handler creator callable
                # as keyword arguments.
                'owner': ['pulse', 'pulse'],
                'filename': 'chowntest.log',
                'mode': 'w',
                'encoding': 'utf-8',
            },
        },
        'root': {
            'handlers': ['file'],
            'level': 'DEBUG',
        },
    }

이 예시는 단순히 설명 목적으로 ``pulse`` 사용자와 그룹을 사용한 소유권을 설정한다.
위 함수와 설정을 작업 스크립트 ``chowntest.py``\ 에 합친다. ::

    import logging, logging.config, os, shutil

    def owned_file_handler(filename, mode='a', encoding=None, owner=None):
        if owner:
            if not os.path.exists(filename):
                open(filename, 'a').close()
            shutil.chown(filename, *owner)
        return logging.FileHandler(filename, mode, encoding)

    LOGGING = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'default': {
                'format': '%(asctime)s %(levelname)s %(name)s %(message)s'
            },
        },
        'handlers': {
            'file':{
                # The values below are popped from this dictionary and
                # used to create the handler, set the handler's level and
                # its formatter.
                '()': owned_file_handler,
                'level':'DEBUG',
                'formatter': 'default',
                # The values below are passed to the handler creator callable
                # as keyword arguments.
                'owner': ['pulse', 'pulse'],
                'filename': 'chowntest.log',
                'mode': 'w',
                'encoding': 'utf-8',
            },
        },
        'root': {
            'handlers': ['file'],
            'level': 'DEBUG',
        },
    }

    logging.config.dictConfig(LOGGING)
    logger = logging.getLogger('mylogger')
    logger.debug('A debug message')

위 스크립트는 ``root`` 권한으로 실행해야 한다.

.. code-block:: shell-session

    $ sudo python3.3 chowntest.py
    $ cat chowntest.log
    2013-11-05 09:34:51,128 DEBUG mylogger A debug message
    $ ls -l chowntest.log
    -rw-r--r-- 1 pulse pulse 55 2013-11-05 09:34 chowntest.log

이 예시는 :func:`shutil.chown`\ 가 있는 파이썬 3.3을 사용함을 알아두자.
따라서 :func:`dictConfig`\ 를 지원하는 파이썬 2.7, 파이썬 3.2 또는 이후 버전에서 사용해야 한다.
파이썬 3.3 이전 버전에서는 소유권을 :func:`os.chown` 함수로 변경해야 한다.

실제로 핸들러 생성 함수는 프로젝트 어딘가의 유틸리티 모듈에 있을 수 있다.
다음 과 같은 설정 행 대신 ::

    '()': owned_file_handler,

다음 예시와 같이 핸들러 생성 함수를 명시할 수 있다. ::

    '()': 'ext://project.util.owned_file_handler',

``project.util``\ 은 함수가 위치한 패키지 이름으로 대체할 수 있다.
위의 작업 스크립트에서 ``'ext://__main__.owned_file_handler'``\ 로 명시해도 작동해야 한다.
실제 호출가능 여부는 ``ext://`` 지정으로부터의 :func:`dictConfig` 함수로 해결되었다.

이 예시는 다른 유형의 파일 수정을 구현하는 방법도 알려줄 수 있다.
예를 들어, 특정 POSIX 권한 비트를 설정할 수 있다. 같은 방법에서 :func:`os.chmod` 함수를 사용한다.

물론 이 접근법은 :class:`~logging.FileHandler`\ 가 아닌 다른 타입의 핸들러로 확장할 수 있다.
예를 들어, 순환 파일 핸들러 중 하나나 다른 타입의 핸들러에 함게 사용할 때도 확장할 수 있다.


.. currentmodule:: logging

.. _formatting-styles:

어플리케이션에서 특정 포매팅 스타일 사용하기
--------------------------------------------------------------

파이썬 3,2에서 :class:`~logging.Formatter`\ 에 추가된 ``style`` 키워드 매개 변수로 하위 호환을 위한
``%``를 기본으로 하면서 ``{``\ 나 ``$`` 설정을 허용해 :meth:`str.format`\ 와 :class:`string.Template`\ 이
지원하는 포매팅 방식을 지원할 수 있다. 이 기능은 로그로의 최종 출력을 위한 로깅 메세지의 포매팅 만을 관리하고
개별 로깅 메세지를 생성하는 방식과는 완전히 별개임을 알아두자.

``logger.debug()``, ``logger.info()`` 등의 로깅 호출은 실제 로깅 메세지 자체를 위한 위치 매개 변수만을 받는다.
키워드 매개 변수는 실제 로깅 호출을 처리하는 방법을 위한 옵션을 결정할 때만 사용된다.
(예시: 역추적 정보가 로그되어야 함을 나타내는 키워드 매개 변수 ``exc_info``\ 와
추가 컨텍스트 정보가 로그의 추가됨을 나타내는 ``extra`` 키워드 매개 변수)
:meth:`str.format` \ 이나 :class:`string.Template` 문법을 사용해 로깅 호출을 바로 만들 수는 없다.
내부적으로 로깅 패키지는 %-포매팅을 사용해 포맷 문자열과 변수 인수를 합치기 때문이다.
기존 코드에 있는 모든 로깅 호출이 %-포맷 문자열을 사용하기 때문에 하위 호환성을 유지하면서 변화가 생기진 않을 것이다.

포맷 스타일을 특정 로거에 연결하기 위한 제안들은 있어왔지만 이러한 방법들은 하위 호환성 문제와 결부된다.
기존 코드가 주어진 로거 이름과 %-포매팅을 사용하고 있을 수 있기 때문이다.

서드 파티 라이브러리와 사용자의 코드를 상호 운용적으로 사용하도록 로깅하려면
포매팅과 관련된 결정은 개별 로깅 호출의 레벨에서 정해져야 한다.
이를 통해 대체 포매팅 스타일이 수용되는 방식에 대한 여러 방법들이 생긴다.


LogRecord 팩토리 사용하기
^^^^^^^^^^^^^^^^^^^^^^^^^

앞서 다룬 :class:`~logging.Formatter` 변경과 함께 파이썬 3.2에서 로깅 패키지는 사용자가
:func:`setLogRecordFactory`\ 함수를 사용해 자신의 :class:`LogRecord` 서브 클래스를 설정하는 것을 허용한다.
이 함수를 사용해 사용자만의 :class:`LogRecord` 서브 클래스를 설정할 수 있다.
이는 :meth:`~LogRecord.getMessage` 메서드를 덮어쓰는 것과 같은 일이다.
이 메서드의 기본 클래스 구현은 ``msg % args`` 포매팅이 일어나는 곳과 대체 포매팅을 삽입할 수 있는 곳이다.
그러나 모든 포매팅 스타일을 지원하고 %-포매팅을 기본으로 허용해 다른 코드와의 상호운용성을 보장하도록 주의한다.
기본 구현과 마찬가지로 ``str(self.msg)`` 호출도 주의해야 한다.

더 많은 정보는 :func:`setLogRecordFactory`\ 와 :class:`LogRecord`\ 를 참고한다.


사용자 커스터마이징 메세지 객체 사용하기
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{}-포매팅과 $-포매팅을 사용해 개별 로그 메세지를 구성하는 더 간단한 방법이 있다.
:ref:`arbitrary-object-messages`\ 에서 로깅할 때 임의의 객체를 메세지 포맷 문자열로 사용할 수 있다는 것과
로깅 패키지가 그 객체에 :func:`str`\ 을 호출해 실제 포맷 문자열을 가져온다는 것을 다룬 적이 있다.
다음 두 클래스를 생각해보자. ::

    class BraceMessage(object):
        def __init__(self, fmt, *args, **kwargs):
            self.fmt = fmt
            self.args = args
            self.kwargs = kwargs

        def __str__(self):
            return self.fmt.format(*self.args, **self.kwargs)

    class DollarMessage(object):
        def __init__(self, fmt, **kwargs):
            self.fmt = fmt
            self.kwargs = kwargs

        def __str__(self):
            from string import Template
            return Template(self.fmt).substitute(**self.kwargs)

두 클래스를 포맷 문자열 자리에 사용해 {}-포매팅 또는 $-포매팅을 허용하면
"%(메세지)", "{메세지}", "$메세지" 자리에 포맷화된 로그 출력으로 나타날 실제 "메세지"를 생성할 수 있다.
무언가 로그할 때마다 클래스 네임을 사용하는 것은 번거롭지만 메세지에 ``M`` 이나 ``_`` 와 같은 별칭을 사용하면 더 간단하게 할 수 있다.
(지역화를 위해 ``_`` 를 사용하고 있다면 ``__``)

다음은 이 방법과 관련된 예시다. 먼저 :meth:`str.format`\ 로 포매팅하다. ::

    >>> __ = BraceMessage
    >>> print(__('Message with {0} {1}', 2, 'placeholders'))
    Message with 2 placeholders
    >>> class Point: pass
    ...
    >>> p = Point()
    >>> p.x = 0.5
    >>> p.y = 0.5
    >>> print(__('Message with coordinates: ({point.x:.2f}, {point.y:.2f})', point=p))
    Message with coordinates: (0.50, 0.50)

다음으로 :class:`string.Template`\ 으로 포매팅한다. ::

    >>> __ = DollarMessage
    >>> print(__('Message with $num $what', num=2, what='placeholders'))
    Message with 2 placeholders
    >>>

이 예시에서 알아야 할 것은 예시의 접근법으로 인한 심각한 성능 패널티가 없다는 것이다.
실제 포매팅은 로깅 호출을 생성할 때가 아니라 로그된 메세지가 핸들러로 로그로의 출력이 되려할 때 이루어진다.
실수를 할 수 있는 특이한 부분은 포맷 문자열이 아니라 포맷 문자열과 인수를 둘러싸는 괄호다.
더블 언더스코어(__) 표기법은 위 예시처럼 ``XXXMessage`` 클래스 중 하나로의 생성자 호출을 위한 문법 첨가물일 뿐이기 때문이다.


.. _filters-dictconfig:

.. currentmodule:: logging.config

:func:`dictConfig` 함수로 필터 설정
-------------------------------------------

처음에는 조금 난해한 방법으로 느껴질 수 있지만 :func:`~logging.config.dictConfig`\ 를 사용해 필터를 설정할 수 있다.
, though it
might not be obvious at first glance how to do it (hence this recipe). Since
표준 라이브러리에 포함된 필터 클래스는 :class:`~logging.Filter`\ 뿐이고 많은 요구사항을 만족하기 어렵기 때문에
보통은 사용자만의 :class:`~logging.Filter` 하위 클래스를 정의해 :meth:`~logging.Filter.filter` 메서드를 덮어써야 한다.
이를 위해 필터 설정 딕셔너리에 ``()`` 키를 지정해 필터를 생성하는데 사용될 호출 가능 객체를 지정해야 한다.
(클래스가 가장 알기 쉽지만 :class:`~logging.Filter` 인스턴스를 반환하는 어떤 호출 가능 객체도 가능하다.)
다음은 완성된 예시다. ::

    import logging
    import logging.config
    import sys

    class MyFilter(logging.Filter):
        def __init__(self, param=None):
            self.param = param

        def filter(self, record):
            if self.param is None:
                allow = True
            else:
                allow = self.param not in record.msg
            if allow:
                record.msg = 'changed: ' + record.msg
            return allow

    LOGGING = {
        'version': 1,
        'filters': {
            'myfilter': {
                '()': MyFilter,
                'param': 'noshow',
            }
        },
        'handlers': {
            'console': {
                'class': 'logging.StreamHandler',
                'filters': ['myfilter']
            }
        },
        'root': {
            'level': 'DEBUG',
            'handlers': ['console']
        },
    }

    if __name__ == '__main__':
        logging.config.dictConfig(LOGGING)
        logging.debug('hello')
        logging.debug('hello - noshow')

이 예시에서 인스턴스를 생성하는 호출 가능 객체로 키워드 매개 변수 형태의 설정 데이터를 보내는 방법을 볼 수 있다.
실행도면 다음과 같이 나타난다. ::

    changed: hello

필터가 설정대로 작동하는 것을 볼 수 있다.

다음은 알아야 할 추가 사항이다.

* 객체가 다른 모듈에 있어 설정 딕셔너리가 있는 곳에 바로 가져올 수 없을 때와 같이
  설정에서 호출 가능 객체를 바로 참조할 수 없는 경우가 있다. 이 때는 :ref:`logging-config-dict-externalobj`\ 에서
  설명하는대로 ``ext://...`` 형식을 사용할 수 있다. 예를 들어, 위 예시에서 ``MyFilter`` 대신
  ``'ext://__main__.MyFilter'``\ 를 사용할 수 있다.

* 핸들러와 포매터에서도 위 방법을 사용해 사용자 지정 핸들러와 포매터도 설정할 수 있다.
  :ref:`logging-config-dict-userdef`\ 를 보면 로깅이 설정에서 사용자 지정 객체를 지원하는 방법을 볼 수 있다.
  :ref:`custom-handlers` \ 도 참고한다.


.. _custom-format-exception:

예외 포매팅 커스터마이징
-------------------------------

예외 포매팅을 커스터마이징하길 원할 때가 있다. 인수를 위해 예외 정보가 있을 때도 로그 이벤트당 하나의 행을 원한다고 가정하자.
다음 예시와 같이 사용자 지정 포매터 클래스로 할 수 있다. ::

    import logging

    class OneLineExceptionFormatter(logging.Formatter):
        def formatException(self, exc_info):
            """
            Format an exception so that it prints on a single line.
            """
            result = super(OneLineExceptionFormatter, self).formatException(exc_info)
            return repr(result)  # or format into one line however you want to

        def format(self, record):
            s = super(OneLineExceptionFormatter, self).format(record)
            if record.exc_text:
                s = s.replace('\n', '') + '|'
            return s

    def configure_logging():
        fh = logging.FileHandler('output.txt', 'w')
        f = OneLineExceptionFormatter('%(asctime)s|%(levelname)s|%(message)s|',
                                      '%d/%m/%Y %H:%M:%S')
        fh.setFormatter(f)
        root = logging.getLogger()
        root.setLevel(logging.DEBUG)
        root.addHandler(fh)

    def main():
        configure_logging()
        logging.info('Sample message')
        try:
            x = 1 / 0
        except ZeroDivisionError as e:
            logging.exception('ZeroDivisionError: %s', e)

    if __name__ == '__main__':
        main()

위 스크립트를 실행하면 딱 두 행을 갖는 파일이 생성된다. ::

    28/01/2015 07:21:23|INFO|Sample message|
    28/01/2015 07:21:23|ERROR|ZeroDivisionError: integer division or modulo by zero|'Traceback (most recent call last):\n  File "logtest7.py", line 30, in main\n    x = 1 / 0\nZeroDivisionError: integer division or modulo by zero'|

위 방법은 간단하지만 사용자가 원하는 대로 예외 정보 포맷을 정하는 방법을 알려준다.
더 특화된 목적에는 :mod:`traceback` 모듈이 도움이 될 것이다.

.. _spoken-messages:

로깅 메세지 말하기
-------------------------

로깅 메세지를 시각화보다 음성화하는 것이 더 좋은 상황이 있다.
파이썬 바인딩이 아니더라도 시스템에서 텍스트 음성 변환 기능을 사용할 수 있다면 쉽게 할 수 있다.
대부분의 텍스트 음성 변환 시스템은 명령줄 프로그램을 실행할 수 있고 이를 :mod:`subprocess` 핸들러로 호출할 수 있다.
이 예시는 다음과 같은 가정을 한다. TTS의 명령줄 프로그램은 사용자와 상호 작용하거나 작업을 마치는데 오랜 시간이 걸리지 않는다.
로그된 메세지의 빈도가 사용자가 메세지에 빠질 만큼 높지 않다. 메세지를 동시에 말하지 않고 하나씩 말해도 된다.
아래 예시의 구현은 메세지가 말해지길 기다렸다가 다음 메세지를 처리한다. 이로 인해 다른 핸들러는 대기해야 할 수 있다.
다음 짧은 예시는 ``espeak`` 텍스트 음성화 패키지를 사용 가능하다고 가정한 예시다. ::

    import logging
    import subprocess
    import sys

    class TTSHandler(logging.Handler):
        def emit(self, record):
            msg = self.format(record)
            # Speak slowly in a female English voice
            cmd = ['espeak', '-s150', '-ven+f3', msg]
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT)
            # wait for the program to finish
            p.communicate()

    def configure_logging():
        h = TTSHandler()
        root = logging.getLogger()
        root.addHandler(h)
        # the default formatter just returns the message
        root.setLevel(logging.DEBUG)

    def main():
        logging.info('Hello')
        logging.debug('Goodbye')

    if __name__ == '__main__':
        configure_logging()
        sys.exit(main())

실행하면 위 스크립트는 여성 음성으로 "Hello"와 "Goodbye"를 순서대로 말한다.

위 방법을 다른 텍스트 음성 변환 시스템이나 아예 다른 시스템에 적용해 명령줄에서 실행되는 외부 프로그램으로 메세지를 처리할 수 있다.


.. _buffered-logging:

상황에 따른 메세지 로깅과 출력 버퍼링
------------------------------------------------------------

임시 영역에 로그 메세지를 두었다가 특정 상황에만 메세지를 출력해야 하는 경우가 있다.
예를 들어, 함수에서 디버그 이벤트 로깅을 시작한다. 함수가 에러 없이 종료되면 수집된 디버그 정보로 로그를 어지럽히지 않는다.
에러가 발생하면 모든 디버그 정보와 에러를 출력해야 한다.

다음 예시에서 함수에 데코레이터를 사용해 이와 같은 로깅을 하는 방법을 볼 수 있다.
특정 상황이 발생할 때가지 로그 이벤트를 지연하는 :class:`logging.handlers.MemoryHandler`\ 를 사용한다.
특정 상황이 발생하면 지연된 이벤트는 플러시되고 다른 핸들러(목표 핸들러)로 보내진다.
기본으로 ``MemoryHandler``\ 는 버퍼가 차거나 지정된 임계점 이상의 이벤트가 나타나면 플러시된다.
사용자 지정 플러시를 원한다면 이 방법을 사용해 더 특화된 ``MemoryHandler`` 서브 클래스를 만들 수 있다.

예시 스크립트는 간단한 함수 ``foo``\ 를 가지고 있다. 이 함수는 모든 로깅 레벨을 돌아 ``sys.stderr``\ 에
작성해 곧 로그할 레벨을 알려주고 그 레벨에 실제로 메세지를 로그한다. ``foo`` 에 매개 변수를 보낼 수 있고
참이면 ERROR와 CRITICAL 레벨에 로그하고 아니면 DEBUG, INFO, WARNING 레벨에만 로그한다.

다음 스크립트는 필요한 조건부 로깅을 수행하는 데코레이터를 ``foo``\ 에 배열한다.
데코레이터는 로거를 매개 변수처럼 받고 데코레이터를 사용한 함수로의 호출 지속 시간을 위한 메모리 핸들러를 추가한다.
데코레이터는 타켓 핸들러, 플러시되어야 하는 레벨, 버퍼를 위한 기능을 사용해 추가적으로 매개 변수화 될 수 있다.
``sys.stderr``, ``logging.ERROR``, ``100``\ 에 개별적으로 작성하는 :class:`~logging.StreamHandler`\ 가 기본 핸들러다.

다음은 스크립트다. ::

    import logging
    from logging.handlers import MemoryHandler
    import sys

    logger = logging.getLogger(__name__)
    logger.addHandler(logging.NullHandler())

    def log_if_errors(logger, target_handler=None, flush_level=None, capacity=None):
        if target_handler is None:
            target_handler = logging.StreamHandler()
        if flush_level is None:
            flush_level = logging.ERROR
        if capacity is None:
            capacity = 100
        handler = MemoryHandler(capacity, flushLevel=flush_level, target=target_handler)

        def decorator(fn):
            def wrapper(*args, **kwargs):
                logger.addHandler(handler)
                try:
                    return fn(*args, **kwargs)
                except Exception:
                    logger.exception('call failed')
                    raise
                finally:
                    super(MemoryHandler, handler).flush()
                    logger.removeHandler(handler)
            return wrapper

        return decorator

    def write_line(s):
        sys.stderr.write('%s\n' % s)

    def foo(fail=False):
        write_line('about to log at DEBUG ...')
        logger.debug('Actually logged at DEBUG')
        write_line('about to log at INFO ...')
        logger.info('Actually logged at INFO')
        write_line('about to log at WARNING ...')
        logger.warning('Actually logged at WARNING')
        if fail:
            write_line('about to log at ERROR ...')
            logger.error('Actually logged at ERROR')
            write_line('about to log at CRITICAL ...')
            logger.critical('Actually logged at CRITICAL')
        return fail

    decorated_foo = log_if_errors(logger)(foo)

    if __name__ == '__main__':
        logger.setLevel(logging.DEBUG)
        write_line('Calling undecorated foo with False')
        assert not foo(False)
        write_line('Calling undecorated foo with True')
        assert foo(True)
        write_line('Calling decorated foo with False')
        assert not decorated_foo(False)
        write_line('Calling decorated foo with True')
        assert decorated_foo(True)

위 스크립트를 실행하면 다음과 같은 출력을 볼 수 있다. ::

    Calling undecorated foo with False
    about to log at DEBUG ...
    about to log at INFO ...
    about to log at WARNING ...
    Calling undecorated foo with True
    about to log at DEBUG ...
    about to log at INFO ...
    about to log at WARNING ...
    about to log at ERROR ...
    about to log at CRITICAL ...
    Calling decorated foo with False
    about to log at DEBUG ...
    about to log at INFO ...
    about to log at WARNING ...
    Calling decorated foo with True
    about to log at DEBUG ...
    about to log at INFO ...
    about to log at WARNING ...
    about to log at ERROR ...
    Actually logged at DEBUG
    Actually logged at INFO
    Actually logged at WARNING
    Actually logged at ERROR
    about to log at CRITICAL ...
    Actually logged at CRITICAL

위 예시에서 볼 수 있듯이 실제 로깅 출력은 중요도가 ERROR 이상인 이벤트가 로그되었을 때만 나타난다.
그러나 이 경우에 더 낮은 중요도를 갖는 이전 이벤트 또한 로그된다.

데코레이터의 일반적인 기능도 사용할 수 있다. ::

    @log_if_errors(logger)
    def foo(fail=False):
        ...


.. _utc-formatting:

설정을 통해 UTC (GMT)로 시간 포매팅하기
--------------------------------------------------

시간 UTC 포맷으로 해야하는 경우가 있다. 다음과 같이 `UTCFormatter` 클래스를 사용하면 된다. ::

    import logging
    import time

    class UTCFormatter(logging.Formatter):
        converter = time.gmtime

이제 코드에 :class:`~logging.Formatter` 클래스 대신 ``UTCFormatter``\ 를 사용할 수 있다.
설정을 통해 UTC 포맷을 사용하고 싶다면 다음 예시처럼 :func:`~logging.config.dictConfig` API를 사용할 수 있다. ::

    import logging
    import logging.config
    import time

    class UTCFormatter(logging.Formatter):
        converter = time.gmtime

    LOGGING = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'utc': {
                '()': UTCFormatter,
                'format': '%(asctime)s %(message)s',
            },
            'local': {
                'format': '%(asctime)s %(message)s',
            }
        },
        'handlers': {
            'console1': {
                'class': 'logging.StreamHandler',
                'formatter': 'utc',
            },
            'console2': {
                'class': 'logging.StreamHandler',
                'formatter': 'local',
            },
        },
        'root': {
            'handlers': ['console1', 'console2'],
       }
    }

    if __name__ == '__main__':
        logging.config.dictConfig(LOGGING)
        logging.warning('The local time is %s', time.asctime())

이 스크립트를 실행하면 다음과 같은 출력이 나타난다. ::

    2015-10-17 12:53:29,501 The local time is Sat Oct 17 13:53:29 2015
    2015-10-17 13:53:29,501 The local time is Sat Oct 17 13:53:29 2015

핸들러 당 하나씩 현지 시간과 UTC 포맷 모두 나타나는 것을 볼 수 있다.


.. _context-manager:

선택적 로깅을 위해 컨텍스트 매니저 사용하기
---------------------------------------------

로깅 설정을 잠시 바꾸었다가 어떤 작업을 하고 다시 되돌려 놓는 것이 유용할 때가 있다.
이를 위해 로깅 컨텍스트를 저장해두었다가 다시 되돌리는 가장 확실한 방법은 컨텍스트 매니저다.
다음은 컨텍스트 매니저의 간단한 예시로 로깅 레벨을 선택적으로 바꾸고 순수하게 컨텍스트 매니저의 범위에서 로깅 핸들러를 추가할 수 있다. ::

    import logging
    import sys

    class LoggingContext(object):
        def __init__(self, logger, level=None, handler=None, close=True):
            self.logger = logger
            self.level = level
            self.handler = handler
            self.close = close

        def __enter__(self):
            if self.level is not None:
                self.old_level = self.logger.level
                self.logger.setLevel(self.level)
            if self.handler:
                self.logger.addHandler(self.handler)

        def __exit__(self, et, ev, tb):
            if self.level is not None:
                self.logger.setLevel(self.old_level)
            if self.handler:
                self.logger.removeHandler(self.handler)
            if self.handler and self.close:
                self.handler.close()
            # implicit return of None => don't swallow exceptions

레벨 값을 정의하면 로거의 레벨은 컨텍스트 매니저가 다루는 with 블럭의 범위 안의 값으로 설정된다.
핸들러를 지정하면 블럭으로 들어올 때 로거에 추가되고 블럭으로부터 나올 때 삭제된다.
블럭을 나올 때 핸들러를 닫도록 매니저에 요청할 수 있다. 핸들러가 더 필요하지 않다면 이렇게 해도 된다.

어떻게 작동하는지 설명하기 위해 다음 코드 블럭을 위 예시에 추가할 수 있다. ::

    if __name__ == '__main__':
        logger = logging.getLogger('foo')
        logger.addHandler(logging.StreamHandler())
        logger.setLevel(logging.INFO)
        logger.info('1. This should appear just once on stderr.')
        logger.debug('2. This should not appear.')
        with LoggingContext(logger, level=logging.DEBUG):
            logger.debug('3. This should appear once on stderr.')
        logger.debug('4. This should not appear.')
        h = logging.StreamHandler(sys.stdout)
        with LoggingContext(logger, level=logging.DEBUG, handler=h, close=True):
            logger.debug('5. This should appear twice - once on stderr and once on stdout.')
        logger.info('6. This should appear just once on stderr.')
        logger.debug('7. This should not appear.')

처음에 로거 레벨을 ``INFO``\ 로 설정했기 때문에 메세지 #1이 나타나고 메세지 #2는 나타나지 않는다.
다음으로 따라오는 ``with`` 블럭에서 잠시 레벨을 ``DEBUG``\ 로 바꿨기 때문에 메세지 #3이 나타난다.
블럭에서 나오면 로거의 레벨은 ``INFO``\ 되돌아가고 메세지 #4는 나타나지 않는다.
다음 ``with`` 블럭에서 레벨을 다시 ``DEBUG``\ 로 설정했지만 ``sys.stdout``\ 로의 핸들러 작성을 추가했다.
따라서 메세지 #5는 콘솔에 두번 나타난다.(``stderr``\ 를 통해 한번 ``stdout``\ 을 통해 한번)
``with`` 선언이 끝나면 다시 이전 상태로 돌아가 메세지 #6은 나타나지만 메세지 #7은 나타나지 않는다.

결과 스크립트를 실행하면 다음과 같이 나타난다.

.. code-block:: shell-session

    $ python logctx.py
    1. This should appear just once on stderr.
    3. This should appear once on stderr.
    5. This should appear twice - once on stderr and once on stdout.
    5. This should appear twice - once on stderr and once on stdout.
    6. This should appear just once on stderr.

``stderr``\ 를 ``/dev/null``\ 로 보내고 다시 실행하면 다음과 같이 ``stdout``\ 에 작성된 메세지만이 나타난다.

.. code-block:: shell-session

    $ python logctx.py 2>/dev/null
    5. This should appear twice - once on stderr and once on stdout.

``stdout``\ 를 ``/dev/null``\ 로 보내고 다시 실행하면 다음과 같이 나타난다.

.. code-block:: shell-session

    $ python logctx.py >/dev/null
    1. This should appear just once on stderr.
    3. This should appear once on stderr.
    5. This should appear twice - once on stderr and once on stdout.
    6. This should appear just once on stderr.

이 예시에서 예상대로 ``stdout``\ 로 출력된 메세지 #5는 나타나지 않는다.

여기서 설명하는 방법은 로깅 필터를 임시로 두기 위한 예시로서 일반화된 방법이다.
위 코드는 파이썬2 와 파이썬 3에서 모두 작동한다는 것을 알아두자.
