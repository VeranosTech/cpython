:mod:`logging.handlers` --- 로그 핸들러
=============================================================

.. module:: logging.handlers
   :synopsis: Handlers for the logging module.

.. moduleauthor:: Vinay Sajip <vinay_sajip@red-dove.com>
.. sectionauthor:: Vinay Sajip <vinay_sajip@red-dove.com>

**Source code:** :source:`Lib/logging/handlers.py`

.. sidebar:: Important

   이 페이지는 API 참조 정보만 포함한다.
   튜토리얼 정보와 더 고급 주제는 다음을 참조한다.

   * :ref:`기초 튜토리얼 <logging-basic-tutorial>`
   * :ref:`고급 튜토리얼 <logging-advanced-tutorial>`
   * :ref:`로그 쿡북 <logging-cookbook>`

--------------

.. currentmodule:: logging

이 패키지는 앞으로 소개할 유용한 핸들러들을 제공한다. 핸들러 중 세개 (:class:`StreamHandler`,
:class:`FileHandler` 그리고 :class:`NullHandler`)는 사실 :mod:`logging` 모듈 자체에
정의되어있지만, 다른 핸들러들과 함께 여기에 같이 문서화되어 있다.

.. _stream-handler:

StreamHandler
^^^^^^^^^^^^^

패키지의 코어에 위치해있는 :class:`StreamHandler` 클래스는 로깅 아웃풋을 *sys.stdout*, *sys.stderr*
혹은 모든 파일 형태의 오브젝트 (혹은 더 정확하게는 :meth:`write`와 :meth:`flush` 메쏘드를 지원하는
모든 오브젝트)에 출력한다.


.. class:: StreamHandler(stream=None)

   :class:`StreamHandler` 클래스의 새로운 인스턴스를 반환한다. 만약 *stream*이 지정되어있다면,
   인스턴스는 로깅 출력에 그것을 사용할 것이다; 지정되어있지 않다면 *sys.stderr*이 사용될 것이다.


   .. method:: emit(record)

      포매터가 지정되어있다면, 레코드를 포맷하는데 쓰인다. 그리고 레코드가 터미네이터와 함께 스트림에 쓰여진다.
      예외 정보가 있다면, 그것은 :func:`traceback.print_exception`를 이용해 포맷되어진 후
      스트림에 덧붙여진다.


   .. method:: flush()

      :meth:`flush` 메쏘드를 호출함으로서 스트림을 플러쉬한다. :meth:`close` 메쏘드가
      :class:`~logging.Handler` 클래스로부터 상속되었기 때문에 아웃풋을 출력하지 않고, 그렇기 때문에
      별도의 :meth:`flush`가 때때로 호출되어져야 한다는 것을 알아두자.

   .. method:: setStream(stream)

      명시된 값이 기존의 스트림과 다른 경우, 인스턴스의 스트림을 명시된 값으로 지정한다. 새로운 스트림이
      세팅되기 전에 기존의 스트림은 플러쉬된다.

      :param stream: 핸들러가 사용하는 스트림

      :return: 스트림이 변경되었을 경우, 기존의 스트림을 반환하고, 그렇지 않은 경우 *None*

   .. versionadded:: 3.7


.. versionchanged:: 3.2
   ``StreamHandler`` 클래스는 이제 디폴트 값으로 ``'\n'``를 가지는 ``terminator`` 속성을 가지며,
   이것은 스트림에 형식화된 레코드를 쓸 때 종결자로 활용된다. 만약 이렇게 새로운 줄을 시작하는 종결자를 원하지
   않는다면, 핸들러 인스턴스의 ``terminator`` 속성을 빈 문자열로 지정해주면 된다. 이전 버전에서는, 종결자는
   ``'\n'`` 로 고정되어 있었다.


.. _file-handler:

FileHandler
^^^^^^^^^^^

`logging` 패키지의 코어에 위치한 :class:`FileHandler` 클래스는, 로깅 아웃풋을 디스크 파일에 보낸다.
이 클래스는 아웃풋 기능을 :class:`StreamHandler` 로부터 상속받는다.


.. class:: FileHandler(filename, mode='a', encoding=None, delay=False)

   :class:`FileHandler` 클래스의 새 인스턴스를 반환한다. 지정된 파일이 열리고 로깅을 위한 스트림으로
   활용된다. *mode* 가 지정되지 않았다면, :const:`'a'` 가 사용된다. *encoding* 이 ``None`` 이
   아니라면, 이것이 파일을 열기위한 인코딩 형식으로서 활용된다. *delay* 가 true 라면, :meth:`emit`
   가 처음 호출될때까지 파일이 열리는 것이 연기된다. 디폴트로, 파일은 무한히 커진다.

   .. versionchanged:: 3.6
      문자열 값처럼, :class:`~pathlib.Path` 객체들 또한 *filename* 에 대한 인수로 지정할 수 있다.

   .. method:: close()

      파일을 닫는다.


   .. method:: emit(record)

      파일에 대한 레코드를 출력한다.


.. _null-handler:

NullHandler
^^^^^^^^^^^

.. versionadded:: 3.1

:mod:`logging` 패키지의 로커에 위치한 :class:`NullHandler` 클래스는 어떠한 형식화나 출력도 하지
않는다. 이것은 근본적으로 'no-op' 핸들러로서, 라이브러리 개발자들이 사용하기 위함이다.

.. class:: NullHandler()

   :class:`NullHandler` 클래스의 새 인스턴스를 반환한다.


   .. method:: emit(record)

      이 메쏘드는 아무것도 하지 않는다.

   .. method:: handle(record)

      이 메쏘드는 아무것도 하지 않는다.

   .. method:: createLock()

      접근이 시리얼화된 곳에 대한 기저에 깔린 I/O가 없기 때문에, 이 메쏘드는 잠금에 대해 ``None`` 을
      반환한다.


:class:`NullHandler` 의 사용법에 대한 더 많은 정보는 :ref:`library-config` 를 참고해라.

.. _watched-file-handler:

WatchedFileHandler
^^^^^^^^^^^^^^^^^^

.. currentmodule:: logging.handlers

:mod:`logging.handlers` 모듈에 위치한 :class:`WatchedFileHandler` 클래스는 자신이 로깅하는
파일을 감시하는 :class:`FileHandler` 이다. 만약 파일이 변한다면, 그것은 닫힌 다음 파일 이름으로
다시 열린다.

파일의 변화는 *newsyslog* 나 *logrotate* 같은 로그 파일 로테이션을 수행하는 프로그램들에 의해서
일어날 수 있다. 유닉스/리눅스 기반에서 사용하기 위한 이 핸들러는 파일이 마지막 emit 이후에 변했는지를
관찰한다. (파일의 디바이스나 inode 가 변했다면 파일이 변한것으로 여겨진다.) 만약 파일이 변했다면,
기존의 파일 스트림은 종료되고, 새로운 스트림을 위한 파일이 열린다.

이 핸들러는 윈도우에서 쓰기에 적합하지 않다. 윈도우에서는 열려있는 로그 파일이 이동되거나 이름이 바뀔 수 없기
때문에 - 로깅이 전용 잠금을 이용해 파일을 연다 - 이러한 핸들러는 필요하지 않다. 더 나아가, *ST_INO* 은
윈도우에서 지원되지 않는다; :func:`~os.stat` 는 이 값에 항상 0을 반환한다.


.. class:: WatchedFileHandler(filename, mode='a', encoding=None, delay=False)

   :class:`WatchedFileHandler` 클래스의 새로운 인스턴스를 반환한다. 명시된 파일이 열리고 로깅을
   위한 스트림으로서 쓰여진다. *mode* 가 지정되지 않았다면, :const:`'a'` 가 사용된다. *encoding*
   이 ``None`` 이 아니라면, 이것이 파일을 열기위한 인코딩 형식으로서 활용된다. *delay* 가 true 라면,
   :meth:`emit` 가 처음 호출될때까지 파일이 열리는 것이 연기된다. 디폴트로, 파일은 무한히 커진다.

   .. versionchanged:: 3.6
      문자열 값처럼, :class:`~pathlib.Path` 객체들 또한 *filename* 에 대한 인수로 지정할 수 있다.

   .. method:: reopenIfNeeded()

      파일이 변했는지 확인한다. 만약 변했다면, 기존의 스트림은 플러쉬되고, 닫히고, 파일이 다시 열린다.
      파일은 일반적으로 레코드를 파일에 출력하는 것에 대한 프리커서로서 열리게 된다.

      .. versionadded:: 3.6


   .. method:: emit(record)

      레코드를 파일에 출력하는데, 그 전에 만약 파일이 변했다면 다시 열기 위해 :meth:`reopenIfNeeded`
      를 호출한다.

.. _base-rotating-handler:

BaseRotatingHandler
^^^^^^^^^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`BaseRotatingHandler` 는 :class:`RotatingFileHandler`
와 :class:`TimedRotatingFileHandler` 와 같은 선회하는 파일 핸들러에 대한 베이스 클래스이다. 이
클래스를 바로 인스턴스로 만들 수는 없지만, 오버라이드할 수 있는 속성과 메쏘드를 가지고 있다.

.. class:: BaseRotatingHandler(filename, mode, encoding=None, delay=False)

   매개변수는 :class:`FileHandler` 의 그것과 같다. 속성은 다음과 같다:

   .. attribute:: namer

      만약 이 속성이 호출가능한 타입으로 설정됬다면, :meth:`rotation_filename` 메쏘드는 이
      호출가능한 타입에 위임한다. 호출가능한 타입에 넘겨진 매개변수들은 :meth:`rotation_filename`
      메쏘드에 넘겨진 그것들이다.

      .. note:: 롤오버과정에서 명명자 함수가 꽤 많이 호출되기 때문에, 명명자 함수는 가능한 단순하고 빨라야 한다.
         또한 이것은 매번 주어진 입력값에 대해 항상 같은 결과를 반환해야 하며, 그렇지 않으면 롤오버 행동
         양식이 기대와 다르게 동작할 수 있다.

      .. versionadded:: 3.3


   .. attribute:: BaseRotatingHandler.rotator

      이 속성이 호출가능한 타입으로 설정된다면, :meth:`rotate` 메쏘드는 이 호출가능한 타입에 위임한다.
      이 호출가능한 타입에 넘겨진 매개변수들이 :meth:`rotate` 메쏘드에 넘겨진 그것들이다.

      .. versionadded:: 3.3

   .. method:: BaseRotatingHandler.rotation_filename(default_name)

      순환할 때 로그 파일의 파일이름을 수정한다.

      커스텀 파일 이름이 제공될 수 있도록 이 메쏘드가 제공된다.

      디폴트로 구현된 것은, 이 메쏘드가 핸들러의 'namer' 속성을 호출하고 (호출가능하다면), 디폴트 이름을
      그것에 넘겨준다. 만약 이 속성이 호출가능하지 않다면 (디폴트는 ``None``이다), 이름은 변경되지
      않은 채 반환된다.

      :param default_name: The default name for the log file. 로그 파일의 디폴트 이름

      .. versionadded:: 3.3


   .. method:: BaseRotatingHandler.rotate(source, dest)

      순환할 때, 현재 로그를 순환해라.

      디폴트로 구현된 것은, 이 메쏘드가 핸들러의 'rotator' 속성을 호출하고 (호출가능하다면), 소스와
      dest 인수를 그것에 넘겨준다. 만약 이 속성이 호출가능하지 않다면 (디폴트는 ``None``이다),
      소스는 단순히 도착지로 이름이 변경된다.

      :param source: 소스의 파일 이름. 이것은 일반적으로 'test.log'와 같은 기본 파일이름이다.
      :param dest:   도착지의 파일이름. 이것은 일반적으로 'test.log.1'과 같이 소스가 순환한 도착지이다.

      .. versionadded:: 3.3

속성들이 존재하는 이유은 서브클래스를 가지지 않아도 되도록 하기 위함이다 - :class:`RotatingFileHandler`와
:class:`TimedRotatingFileHandler` 의 인스턴스들에서 같은 호출가능 타입을 사용할 수 있다.
만약 namer 이나 rotator 호출가능 타입이 예외를 제기한다면, 이것은 :meth:`emit` 호출과정에서의
모든 예외와 같은 방식으로 핸들링될 것이다. 즉, 핸들러의 :meth:`handleError` 메쏘드를 통해서 핸들링된다.

만약 순환 과정에 더 중요한 변화를 줘야할 경우에는, 메쏘드를 오버라이드함으로서 가능하다.

예시로, :ref:`cookbook-rotator-namer` 참고.


.. _rotating-file-handler:

RotatingFileHandler
^^^^^^^^^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`RotatingFileHandler` 클래스는 디스크 로그
파일의 순환을 지원한다.


.. class:: RotatingFileHandler(filename, mode='a', maxBytes=0, backupCount=0, encoding=None, delay=False)

   :class:`RotatingFileHandler` 클래스의 새로운 인스턴스를 반환한다. 명시된 파일이 열리고 로깅을
   위한 스트림으로서 사용된다. *mode* 가 명시되지 않았으면, ``'a'`` 가 사용된다. *encoding*
   이 ``None`` 이 아니라면, 이것이 파일을 열기위한 인코딩 형식으로서 활용된다. *delay* 가 true 라면,
   :meth:`emit` 가 처음 호출될때까지 파일이 열리는 것이 연기된다. 디폴트로, 파일은 무한히 커진다.

   파일을 미리 지정된 크기로 :dfn:`rollover` 하기 위해 *maxBytes* 와 *backupCount* 값을
   사용할 수 있다. 크기가 초과할때쯤이면, 파일이 닫히고 새로운 파일이 아웃풋을 위해 조용히 열린다. 현재
   로그 파일의 길이가 거의 *maxBytes* 에 이르렀을때마다 롤오버가 일어난다; 하지만 만약 *maxBytes* 와
   *backupCount* 중 어느 하나라도 0인 값이 있으면, 롤오버는 절대 일어나지 않기 때문에, *backupCount*
   를 최소한 1로 설정해두고, *maxBytes* 를 0이 아닌 값으로 설정해두는 것이 일반적으로 좋다. *backupCount*
   가 0이 아니라면, 시스템은 기존의 로그 파일들을 '.1', '.2' etc., 와 같은 확장자를 파일 이름에
   덧붙이면서 저장한다. 예를 들어, *backupCount* 가 5이고 기본 파일 이름이 :file:`app.log` 일 때,
   :file:`app.log`, :file:`app.log.1`, :file:`app.log.2`, 에서 :file:`app.log.5` 까지
   저장된다. 쓰여지는 파일은 항상 :file:`app.log` 이다. 이 파일은 다 채워지면, 이것은 닫히고
   :file:`app.log.1` 로 재명명되며, 만약 :file:`app.log.1`, :file:`app.log.2`, etc. 가
   존재한다면, 그것들은 각각 :file:`app.log.2`, :file:`app.log.3` etc 로 재명명된다.

   .. versionchanged:: 3.6
      문자열 값처럼, :class:`~pathlib.Path` 객체들 또한 *filename* 에 대한 인수로 지정할 수 있다.

   .. method:: doRollover()

      위에 묘사된 것과 같이 롤오버를 수행한다.


   .. method:: emit(record)

      위에 묘사된 것과 같은 롤오버에 맞추면서 파일에 레코드를 출력한다.

.. _timed-rotating-file-handler:

TimedRotatingFileHandler
^^^^^^^^^^^^^^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`TimedRotatingFileHandler` 클래스는 디스크
로그 파일을 특정 시간 간격을 가지고 순환하는 것을 지원한다.

.. class:: TimedRotatingFileHandler(filename, when='h', interval=1, backupCount=0, encoding=None, delay=False, utc=False, atTime=None)

   :class:`TimedRotatingFileHandler` 의 새로운 인스턴스를 반환한다. 명시된 파일은 열리고 로깅을
   위한 스트림으로서 사용된다. 또한 순한화면서 파일이름의 접미사를 지정한다. 순환은 *when* 와 *interval*
   을 곱한 값에 기초하여 일어난다.

   *interval* 의 타입을 지정하기 위해 *when* 을 사용할 수 있다. 가능한 값의 리스트는 아래와 같다.
   이들이 대소문자를 구분하지 않는다는 것에 유의하라.

   +----------------+----------------------------+-------------------------+
   | Value          | Type of interval           | If/how *atTime* is used |
   +================+============================+=========================+
   | ``'S'``        | Seconds                    | Ignored                 |
   +----------------+----------------------------+-------------------------+
   | ``'M'``        | Minutes                    | Ignored                 |
   +----------------+----------------------------+-------------------------+
   | ``'H'``        | Hours                      | Ignored                 |
   +----------------+----------------------------+-------------------------+
   | ``'D'``        | Days                       | Ignored                 |
   +----------------+----------------------------+-------------------------+
   | ``'W0'-'W6'``  | Weekday (0=Monday)         | Used to compute initial |
   |                |                            | rollover time           |
   +----------------+----------------------------+-------------------------+
   | ``'midnight'`` | Roll over at midnight, if  | Used to compute initial |
   |                | *atTime* not specified,    | rollover time           |
   |                | else at time *atTime*      |                         |
   +----------------+----------------------------+-------------------------+

   주간 순환을 사용할 때, 월요일은 'W0', 화요일은 'W1' 과 같은 방식으로 일요일은 'W6' 과 같이 지정하라.
   이와 같은 경우, *interval* 에 넘겨진 값은 사용되지 않는다.

   시스템은 파일이름에 확장자를 덧붙이면서 기존의 로그 파일들을 저장할 것이다. 확장자는 날짜-시간에 기반할 것이며,
   ``%Y-%m-%d_%H-%M-%S`` 와 같은 strftime 형식을 사용하거나 롤오버 간격에 따라 그것의 선두 부분
   을 사용할 것이다.

   다음 롤오버 시간을 처음으로 계산할 때 (핸들러가 생성됬을때), 현재 존재하는 로그 파일의 마지막 수정 시간,
   혹은 현재 시간, 이 다음 순환이 언제 일어날 것인지를 계산하기 위해 사용된다.

   만약 *utc* 인수가 참이라면, UTC 기준 시간이 사용된다; 그렇지 않으면 현지 시각이 사용된다.

   만약 *backupCount* 이 0이 아닌 값이라면, 최대 *backupCount* 개수만큼의 파일이 유지될 것이며,
   만약 롤오버가 일어날 때 더 많은 파일이 생겨나게 되면, 가장 오래된 것이 삭제된다. 삭제하는 로직은 간격을
   사용해 어느 파일을 삭제할 것인지 정하기 때문에, 간격을 바꾸는 것은 오래된 파일을 여기저기 방치시킬 수 있다.

   *delay* 가 참이라면, :meth:`emit` 가 처음 호출될 때 까지 파일이 열리는 것이 연장된다.

   만약 *atTime* 이 ``None``이 아니라면, 그것은 롤오버가 일어나는 시간을 지정하는 ``datetime.time``
   인스턴스여야하며, 롤오버가 "자정"에, 혹은 "특정 주일"에 일어나게 지정하는 것이 가능하다. 이러한 경우,
   *atTime* 값은 *initial* 롤오버를 계산하는데 효과적으로 사용되며, 이따르는 롤오버들은 일반적인
   간격 계산 방식에 의해 계산된다는 점에 유의하라.

   .. note:: 초기의 롤오버 시간에 대한 계산은 핸들러가 초기화되었을 때 수행된다. 이따르는 롤오버 타임에 대한 계산은
      롤오버가 일어날 때에만 계산되며, 롤오버는 아웃풋을 방출할때만 일어난다. 이것을 유념하지 않으면, 조금의
      혼동이 야기될 수 있다. 예를 들어, "매 분"이라는 시간 가격이 지정되었다면, 이것은 매 분마다의 시간을
      파일 이름으로 가지는 로그 파일이 생성된다는 뜻이 아니다; 만약 어플리케이션의 실행중에 로깅의 출력이
      매 분보다 더 자주 생성된다면, *그렇다면* 매 분마다의 시간으로 나뉜 로그 파일을 볼 수 있을 것이다.
      만약, 다른 한편으로, 로깅 메세지가 매 5분마다 출력된다면 (예를 들어), 출력이 생기지 않은 (즉 롤오버가
      일어나지 않은) 시간만큼 파일 시간에 공백이 생길 것이다.

   .. versionchanged:: 3.4
      *atTime* 매개변수가 추가됨.

   .. versionchanged:: 3.6
      문자열 값처럼, :class:`~pathlib.Path` 객체들 또한 *filename* 에 대한 인수로 지정할 수 있다.

   .. method:: doRollover()

      위에 묘사된 것처럼, 롤오버를 수행한다.

   .. method:: emit(record)

      위에 묘사된 것과 같은 롤오버에 맞추면서 파일에 레코드를 출력한다.


.. _socket-handler:

SocketHandler
^^^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`SocketHandler` 클래스는 로깅 출력을 네트워크
소켓에 보낸다. 베이스 클래스는 TCP 소켓을 사용한다.

.. class:: SocketHandler(host, port)

   *host*와 *port*에 의해 정해지는 주소를 가지는 원격 머신과 통신하기 위한 :class:`SocketHandler`의
   새로운 인스턴스를 반환한다.

   .. versionchanged:: 3.4
      만약, ``port`` 가 ``None`` 으로 명시되어 있다면, ``host`` 내부의 값을 이용하여 유닉스
      도메인 소켓이 생성된다 - 그렇지 않으면, TCP 소켓이 생성된다.

   .. method:: close()

      소켓을 닫는다.


   .. method:: emit()

      레코드의 속성 딕셔너리를 pickle 하고 바이너리 형태로 소켓에 쓴다. 만약 소켓에 에러가 있다면, 조용히
      패킷을 드랍한다. 만약 이전에 연결이 종료됬었다면, 연결을 다시 활성화한다. 수신 측의 레코드를
      :class:`~logging.LogRecord` 에 unpickle 하려면, :func:`~logging.makeLogRecord`
      함수를 사용해라.


   .. method:: handleError()

      :meth:`emit` 도중에 발생하는 에러를 핸들링한다. 가장 가능성이 높은 원인은 연결이 끊어진 것이다.
      다음 이벤트때 다시 시도할 수 있도록 소켓을 닫아라.


   .. method:: makeSocket()

      이것은 서브 클래스가 원하는 소켓의 정확한 유형을 정의할 수 있게 하는 팩토리 메쏘드이다. 기본 구현은
      TCP 소켓(:const:`socket.SOCK_STREAM`)을 만든다.


   .. method:: makePickle(record)

      길이를 접두사로 가지는 이진 형식으로 레코드의 속성 딕셔너리를 pickle 하고, 소켓을 통해 전송할 준비가
      된 상태로 반환한다.

      피클은 완전히 안전하지 않다는 점에 유의하라. 만약 보안이 염려된다면, 이 메쏘드를 재정의하여 보다
      안전한 메커니즘을 구현할 수 있다. 예를 들어, HMAC을 사용하여 피클에 서명한 다음 수신 측에서 피클을
      확인하거나, 수신 측에서 전역 개체의 unpickling 을 비활성화할 수 있다.


   .. method:: send(packet)

      피클링된 문자열 *packet* 을 소켓에 보낸다. 이 기능은 네트워크가 사용중 일 때 발생할 수 있는
      부분 전송을 허용한다.



   .. method:: createSocket()

      소켓을 만들고자 시도한다; 실패시, exponential back-off 알고리즘을 사용한다. 초기 실패시,
      핸들러는 보내려던 메시지를 삭제한다. 후속 메시지가 같은 인스턴스에 의해 핸들링된다면, 조금 시간이
      지날때까지 연결을 시도하지 않는다. 기본 매개변수는 초기 지연이 1초가 되도록 하고, 만약 그 지연 후에도
      연결이 되지 않는다면, 핸들러는 최대 30초까지 매번 지연 시간을 두배로 늘린다.

      이 행동은 다음의 핸들러 속성에 의해 제어된다:

      * ``retryStart`` (초기 지연, 1.0초로 기본값 설정).
      * ``retryFactor`` (배수, 2로 기본값 설정).
      * ``retryMax`` (최대 지연, 30.0초로 기본값 설정).

      즉 원격 수신기가 핸들러가 사용된 *후에* 시작된다면, 메시지를 잃을 수 있다 (지연 시간이 경과할 때까지
      처리기가 연결을 시도하지 않고, 지연 시간 동안의 메시지를 자동으로 삭제하기 때문에).


.. _datagram-handler:

DatagramHandler
^^^^^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`DatagramHandler` 클래스는 :class:`SocketHandler`
로부터 상속받아 UDP 소켓을 통해 로깅 메시지를 보내는 것을 지원한다.


.. class:: DatagramHandler(host, port)

   *host*와 *port*에 의해 정해지는 주소를 가지는 원격 머신과 통신하기 위한 :class:`DatagramHandler`의
   새로운 인스턴스를 반환한다.

   .. versionchanged:: 3.4
      만약, ``port`` 가 ``None`` 으로 명시되어 있다면, ``host`` 내부의 값을 이용하여 유닉스
      도메인 소켓이 생성된다 - 그렇지 않으면, TCP 소켓이 생성된다.

   .. method:: emit()

      레코드의 속성 딕셔너리를 pickle 하고 바이너리 형태로 소켓에 쓴다. 만약 소켓에 에러가 있다면, 조용히
      패킷을 드랍한다. 만약 이전에 연결이 종료됬었다면, 연결을 다시 활성화한다. 수신 측의 레코드를
      :class:`~logging.LogRecord` 에 unpickle 하려면, :func:`~logging.makeLogRecord`
      함수를 사용해라.


   .. method:: makeSocket()

      :class:`SocketHandler` 의 팩토리 메쏘드는 UDP 소켓(:const:`socket.SOCK_DGRAM`)을
      말들기 위해 여기서 재정의된다.

   .. method:: send(s)

      피클링된 문자열을 소켓에 보낸다.


.. _syslog-handler:

SysLogHandler
^^^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`SysLogHandler` 클래스는 원격 혹은 로컬 유닉스
syslog 에 로깅 메시지를 보내는 것을 지원한다.


.. class:: SysLogHandler(address=('localhost', SYSLOG_UDP_PORT), facility=LOG_USER, socktype=socket.SOCK_DGRAM)

   ``(host, port)`` 튜플 형태로 주소가 주어진 원격 유닉스 머신과 통신하기 위한 :class:`SysLogHandler`
   클래스의 새로운 인스턴스를 반환한다. 만약 *address* 가 지정되지 않았으면, ``('localhost', 514)``
   가 사용된다. 주소는 소켓을 여는데 사용된다. ``(host, port)`` 튜플을 제공하는 것에 대한 대안은
   주소를 문자열 형태, 예를 들어 '/dev/log', 로 제공하는 것이다. 이 경우 유닉스 도메인 소켓이 syslog
   에 메시지를 보내는데 쓰인다. 만약 *facility* 가 지정되지 않았으면, :const:`LOG_USER` 가
   사용된다. 열리는 소켓의 종류는 *socktype* 인수에 의존하는데, 이것은 기본으로 :const:`socket.SOCK_DGRAM`
   으로 설정되어 있고 따라서 UDP 소켓을 연다. TCP 소켓을 열기 위해서는 (rsyslog 와 같은 더 최신의
   syslog 데몬을 사용하기 위해) :const:`socket.SOCK_STREAM` 값을 지정하면 된다.

   만약 서버가 UDP 포트 514에서 수신대기하지 않는 경우, :class:`SysLogHandler` 가 작동하지
   않는 것처럼 보일 수 있다. 이 경우 도메인 소켓으로 쓰일 주소가 어떤 것이 되어야 하는지 확인해라 - 이것은
   시스템에 따라 드랃. 예를 들어, 리눅스에서는 보통 '/dev/log' 이지만 OS/X 에서는 '/var/run/syslog'
   이다. 사용하는 플랫폼을 확인하고 그에 적합한 주소를 사용해야 한다 (응용 프로그램이 여러 플랫폼에서
   실행되어야 할 경우 런타임에서 이 검사를 수행해야할 수도 있다). 윈도우에서는 UDP 옵션을 사용해야 할
   가능성이 높다.

   .. versionchanged:: 3.2
      *socktype* 이 추가됨.


   .. method:: close()

      원격 호스트에 대한 소켓을 닫는다.


   .. method:: emit(record)

      레코드가 형식화된 다음 syslog 서버로 전송된다. 만약 예외 정보가 존재하면, 그것은 서버에 보내지지
      *않는다*.

      .. versionchanged:: 3.2.1
         (참조: :issue:`12168`) 이전 버전에서는, syslog 데몬으로 보낸 메시지는 항상 NUL 바이트로
         종료되었는데, 이 데몬의 이전 버전들에서는 NUL 종료 메시지를 필요로 했기 때문이다 - 관련 사양
         (RFC 5424) 에는 나타나지 않더라도. 더 최신 버전의 데몬은 NUL 바이트를 필요로 하지 않고
         그것이 있다면 이를 제거하고, 더더욱 최신의 데몬은 (RFC 524와 더 밀접하게 일치하는) NUL
         바이트를 메시지의 일부로서 전달한다.

         이러한 모든 다른 데몬 동작에 직면하여 syslog 메시지를 보다 쉽게 처리할 수 있도록, NUL 바이트를
         덧붙이는 것은 클래스 수준 속성인 ``append_nul`` 을 사용하여 구성 가능하게 만들어졌다.
         이 속성은 기본적으로 ``True`` (기존의 행동을 유지) 로 설정되어 있지만, ``SysLogHandler``
         인스턴스에서 ``False`` 로 설정하여 그 인스턴스가 NULL 종결자를 덧붙이지 않도록 설정할 수 있다.

      .. versionchanged:: 3.3
         (참조: :issue:`12419`.) 이전 버전에서는, "ident"나 "tag" 접두어가 메시지의 소스를
         식별할 수 있는 기능이 없었다. 이것은 이제 클래스 수준의 속성을 사용하여 지정될 수 있으며, 기존
         행동을 유지하기 위해 ``""`` 로 기본으로 설정되어 있지만 ``SysLogHandler`` 인스턴스에서
         재정의되어 이 인스턴스가 모든 메시지에 ident를 추가하도록 할 수 있다. 제공된 ident 는 바이트가
         아닌 텍스트여야 하며, 메시지 앞에 그대로 추가되어야 함에 유의하라.

   .. method:: encodePriority(facility, priority)

      facility 와 priority 를 정수로 인코딩한다. 매개변수에 문자열이나 정수를 넘겨줄 수 있다 -
      정수열이 넘겨지면, 내부 매핑 딕셔너리가 그것들을 정수로 변환하는데 사용된다.

      ``LOG_`` 기호값들이 :class:`SysLogHandler` 에서 정의되며 ``sys/syslog.h`` 헤더
      파일에서 정의된 값들을 미러링한다.

      **Priorities**

      +--------------------------+---------------+
      | Name (string)            | Symbolic value|
      +==========================+===============+
      | ``alert``                | LOG_ALERT     |
      +--------------------------+---------------+
      | ``crit`` or ``critical`` | LOG_CRIT      |
      +--------------------------+---------------+
      | ``debug``                | LOG_DEBUG     |
      +--------------------------+---------------+
      | ``emerg`` or ``panic``   | LOG_EMERG     |
      +--------------------------+---------------+
      | ``err`` or ``error``     | LOG_ERR       |
      +--------------------------+---------------+
      | ``info``                 | LOG_INFO      |
      +--------------------------+---------------+
      | ``notice``               | LOG_NOTICE    |
      +--------------------------+---------------+
      | ``warn`` or ``warning``  | LOG_WARNING   |
      +--------------------------+---------------+

      **Facilities**

      +---------------+---------------+
      | Name (string) | Symbolic value|
      +===============+===============+
      | ``auth``      | LOG_AUTH      |
      +---------------+---------------+
      | ``authpriv``  | LOG_AUTHPRIV  |
      +---------------+---------------+
      | ``cron``      | LOG_CRON      |
      +---------------+---------------+
      | ``daemon``    | LOG_DAEMON    |
      +---------------+---------------+
      | ``ftp``       | LOG_FTP       |
      +---------------+---------------+
      | ``kern``      | LOG_KERN      |
      +---------------+---------------+
      | ``lpr``       | LOG_LPR       |
      +---------------+---------------+
      | ``mail``      | LOG_MAIL      |
      +---------------+---------------+
      | ``news``      | LOG_NEWS      |
      +---------------+---------------+
      | ``syslog``    | LOG_SYSLOG    |
      +---------------+---------------+
      | ``user``      | LOG_USER      |
      +---------------+---------------+
      | ``uucp``      | LOG_UUCP      |
      +---------------+---------------+
      | ``local0``    | LOG_LOCAL0    |
      +---------------+---------------+
      | ``local1``    | LOG_LOCAL1    |
      +---------------+---------------+
      | ``local2``    | LOG_LOCAL2    |
      +---------------+---------------+
      | ``local3``    | LOG_LOCAL3    |
      +---------------+---------------+
      | ``local4``    | LOG_LOCAL4    |
      +---------------+---------------+
      | ``local5``    | LOG_LOCAL5    |
      +---------------+---------------+
      | ``local6``    | LOG_LOCAL6    |
      +---------------+---------------+
      | ``local7``    | LOG_LOCAL7    |
      +---------------+---------------+

   .. method:: mapPriority(levelname)

      로깅 수준 이름을 syslog 우선 순위 이름에 매핑한다. 사용자 지정 수준을 사용하고자 하거나, 기본
      알고리즘이 사용자 요구에 적합하지 않은 경우 이 메쏘드를 재정의하는 것이 좋을 수 있다. 기본 알고리즘은
      ``DEBUG``, ``INFO``, ``WARNING``, ``ERROR``, 그리고 ``CRITICAL`` 을 동등한 syslog
      이름에 매핑하고, 다른 모든 레벨 이름을 'waring' 으로 매핑한다.

.. _nt-eventlog-handler:

NTEventLogHandler
^^^^^^^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`NTEventLogHandler` 클래스는 로컬 Windows NT,
Windows 2000 혹은 Windows XP 이벤트 로그에 로깅 메시지 보내는 것을 지원한다. 이것을 사용하기 전에
Mark Hammond 의 Python 용 Win32 익스텐션이 설치되어 있어야 한다.


.. class:: NTEventLogHandler(appname, dllname=None, logtype='Application')

   :class:`NTEventLogHandler` 클래스의 새로운 인스턴스를 반환한다. *appname* 이벤트 로그에
   나타나는 응용 프로그램의 이름을 정의하는데 사용된다. 이 이름을 사용하여 적절한 레지스트리 항목이 작성된다.
   *dllname* 은 로그에 보관할 메시지 정의를 포함하는 .dll 또는 .exe 의 완전한 경로 이름을 제공해야 한다
   (만약 명시되지 않았다면, ``'win32service.pyd'`` 가 사용된다 - 이것은 Win32 익스텐션과 함께
   설치되고 몇 개의 기본적인 placeholder 메시지 정의를 포함한다. 이러한 placeholder 의 사용하면
   전체 메시지 소스가 로그에 보관되기 때문에 이벤트 로그가 커진다는 점을 유의하라. 더 슬림한 로그를 원한다면,
   이벤트 로그에 사용할 메시지 정의가 들어있는 .dll 또는 .exe 의 이름을 직접 만들어 전달해주어야 한다.)
   *logtype*은 ``'Application'``, ``'System'`` 또는 ``'Security'`` 중 하나이고, 기본
   설정은 ``'Application'`` 이다.


   .. method:: close()

      이 시점에서, 이벤트 로그 항목의 원본으로서 레지스트리에서 응용 프로그램의 이름을 제거할 수 있다. 그러나
      이렇게 하면 의도한 대로의 이벤트를 이벤트 로그 뷰어에서 확인할 수 없다 - .dll 이름을 알기 위해
      레지스트리에 접근할 권한이 있어야 한다. 현재 버전은 아직 이 작업을 수행하지 않는다.


   .. method:: emit(record)

      메시지 ID, 이벤트 카테고리, 이벤트 타입을 정의하고, NT 이벤트 로그에 메시지를 로깅한다.


   .. method:: getEventCategory(record)

      레코드의 이벤트 카테고리를 반환한다. 자신의 카테고리를 직접 지정하고 싶다면 이 메쏘드를 재정의하라.
      이 버전은 0을 반환한다.


   .. method:: getEventType(record)

      레코드의 이벤트 타입을 반환한다. 자신의 타입을 직접 지정하고 싶다면 이 메쏘드를 재정의하라. 이 버전은
      핸들러의 typemap 속성을 사용하여 매핑을 수행한다. 이 속성은 :const:`DEBUG`, :const:`INFO`,
      :const:`WARNING`, :const:`ERROR` 그리고 :const:`CRITICAL` 에 대한 매핑을 포함하는
      딕셔너리에 :meth:`__init__` 으로 설정된다.


   .. method:: getMessageID(record)

      레코드를 위한 메시지 ID 를 반환한다. 자신의 메시지를 사용하는 경우, 형식 문자열이 아니라 ID 인
      *msg* 를 로거에 전달함으로서 이 작업을 수행할 수 있다. 그런 다음, 딕셔너리 죄회를 사용함으로서
      메시지 ID 를 가져올 수 있다. 이 버전은 :file:`win32service.pyd` 의 기본 메시지 ID 인
      1을 반환한다.

.. _smtp-handler:

SMTPHandler
^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`SMTPHandler` 클래스는 SMTP 를 이용해 이메일
주소에 로깅 메시지를 보내는 것을 지원한다.


.. class:: SMTPHandler(mailhost, fromaddr, toaddrs, subject, credentials=None, secure=None, timeout=1.0)

   :class:`SMTPHandler` 클래스의 새로운 인스턴스를 반환한다. 인스턴스는 이메일의 시작 및 끝 주소와
   제목을 사용하여 초기화된다. *toaddrs* 는 문자열 목록이어야 한다. 비표준 SMTP 포트를 지정하려면,
   *mailhost* 인수에 (host, port) 퓨틀 형식을 사용하라. 문자열을 사용한 표준 SMTP 포트가 사용된다.
   SMTP 서버에 인증이 필요한 경우 *credentials* 인수에 대해 (username, password) 튜플을
   지정할 수 있다.

   보안 프로토콜 (TLS) 의 사용을 지정하려면, *secure* 인수에 튜플을 전달하라. 이것은 인증자격 증명이
   제공될 때만 사용된다. 튜플은 빈 튜플이거나 키파일의 이름을 가진 단일값 튜플이거나 키파일과 인증서 파일의
   이름을 가진 2개의 값을 가지는 튜플이어야 한다. (이 튜플은 :meth:`smtplib.SMTP.starttls` 메쏘드에
   전달된다.)

   *timeout* 인수를 사용하여 SMTP 서버와의 통신에서 타임아웃을 지정할 수 있다.

   .. versionadded:: 3.3
      *timeout* 인수가 추가됨.

   .. method:: emit(record)

      레코드를 형식화하고 지정된 주소들에 보낸다.


   .. method:: getSubject(record)

      레코드에 종속적인 줄을 지정하려면 이 메쏘드를 재정의하라.

.. _memory-handler:

MemoryHandler
^^^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`MemoryHandler`클래스는 메모리의 로깅 레코드를
버퍼링하고, 주기적으로 :dfn:`target` 핸들러에 플러시한다. 플러시는 버퍼가 꽉 찼거나 특정 심각도 이상의
이벤트가 발생할 때마다 일어난다.

:class:`MemoryHandler` 는 추상 클래스이자 더 보편적인 클래스인 :class:`BufferingHandler`
의 서브클래스이다. 이것은 메모리에 로깅 레코드를 버퍼링한다. 각 레코드가 버퍼에 추가될때마다, 버퍼가 플러쉬
되어야 하는지 확인하기 위해 :meth:`shouldFlush` 가 호출된다. 만약 플러쉬되어야 한다면, :meth:`flush`
가 플러쉬를 수행한다.


.. class:: BufferingHandler(capacity)

   지정된 용량의 버퍼를 가지는 핸들러를 초기화한다.


   .. method:: emit(record)

      버퍼에 레코드를 덧붙인다. 만약 :meth:`shouldFlush` 가 참을 반환한다면, :meth:`flush`
      를 호출하여 버퍼를 처리한다.


   .. method:: flush()

      이 메쏘드를 재정의하여 사용자 지정 플러쉬 행동을 시행할 수 있다. 이 버전은 단순히 버퍼를 비운다.


   .. method:: shouldFlush(record)

      버퍼가 용량이 꽉 찬 경우 참을 반환한다. 이 메쏘드를 재정의하여 사용자 지정 플러쉬 전략을 시행할 수 있다.


.. class:: MemoryHandler(capacity, flushLevel=ERROR, target=None, flushOnClose=True)

   :class:`MemoryHandler` 클래스의 새로운 인스턴스를 반환한다. 인스턴스는 *capacity* 의 사이즈를
   가지는 버퍼를 가지고 초기화된다. *flushlevel* 이 지정되지 않았으면, :const:`ERROR` 이 사용된다.
   *target* 이 지정되지 않았으면, 이 핸들러가 어떤 유용한 일을 할 수 있게 되기 전에 :meth:`setTarget`
   을 이용해 target 을 지정해야 한다. 만약 *flushOnClose* 가 ``False`` 로 지정되었다면, 핸들러가
   종료될 때 버퍼가 플러시되지 *않는다*. 만약 지정되지 않았거나 ``True`` 로 지정되지 않았으면, 핸들러가
   종료될 때 이전의 버퍼 플러시 행동방식대로 플러시가 일어날 것이다.

   .. versionchanged:: 3.6
      *flushOnClose* 매개변수가 추가됨.


   .. method:: close()

      :meth:`flush` 를 호출, target 을 ``None`` 으로 지정하고 버퍼를 없앤다.


   .. method:: flush()

      :class:`MemoryHandler` 의 경우, (존재하는 경우) 버퍼된 레코드를 target 으로 보내는 것을
      플러쉬라고 한다. 이것이 일어날 때도 버퍼가 클리어된다. 다른 행동방식을 원한다면 이 메쏘드를 재정의하라.


   .. method:: setTarget(target)

      이 핸들러의 타겟 핸들러를 지정한다.


   .. method:: shouldFlush(record)

      버퍼가 가득 찼는지 혹은 *flushLevel* 혹은 그 이상에서의 레코드를 확인한다.

.. _http-handler:

HTTPHandler
^^^^^^^^^^^

:mod:`logging.handlers` 모듈에 위치한 :class:`HTTPHandler` 클래스는 ``GET`` 이나 ``POST``
시맨틱스를 활용하여 웹 서버에 로깅 메시지를 보내는 것을 지원한다.


.. class:: HTTPHandler(host, url, method='GET', secure=False, credentials=None, context=None)

   :class:`HTTPHandler` 클래스의 새로운 인스턴스를 반환한다. 특정 포트 번호를 사용해야 할 경우 *host*
   는 ``host:port`` 의 형태가 될 수 있다. 만약 *method* 가 명시되지 않았으면, ``GET`` 이 사용된다.
   만약 *secure* 가 참이라면, HTTPS 연결이 사용된다. *context* 매개 변수는 :class:`ssl.SSLContext`
   의 인스턴스로 설정되어 HTTPS 연결에 사용되는 SSL 설정을 구성할 수 있다. 만약 *credentials* 이
   지정되었다면, userid 와 password로 이루어진 2-튜플이 되어야 하며, 이것은 기본 인증을 사용하는
   HTTP 'Authorization' 헤더에 위치할 것이다. credentials 을 지정하는 경우, userid 와 password
   가 전선을 통해 일반 텍스트로 전달되지 않도록 secure=True 로 지정해야 한다.

   .. versionchanged:: 3.5
      *context* 매개변수가 추가됨.

   .. method:: mapLogRecord(record)

      ``record`` 에 근거한 딕셔너리를 제공하며, 이것은 URL로 암호화되어 웹 서버에 보내진다. 기본 구현은
      단순히 ``record.__dict__`` 를 반환한다. :class:`~logging.LogRecord` 의 일부만
      웹서버에 보내고자 하거나, 서버에 어떤 것이 보내져야 되는지에 대한 더 구체적인 사용자 정의가 필요한 경우에
      이 메쏘드를 재정의할 수 있다.

   .. method:: emit(record)

      URL 로 암호화된 딕셔너리를 웹 서버에 보낸다. 레코드를 보내질 딕셔너리로 변환하기 위해 :meth:`mapLogRecord`
      가 사용된다.


   .. note:: 웹서버에 보내질 레코드를 준비하는 것은 일반 서식 작업과는 다르기 때문에, :class:`HTTPHandler`
      를 위한 :class:`~logging.Formatter` 를 지정하기 위해 :meth:`~logging.Handler.setFormatter`
      를 사용하는 것은 아무런 효과가 없다. :meth:`~logging.Handler.format` 를 호출하는 대신,
      이 핸들러는 :meth:`mapLogRecord` 를 호출한 후 :func:`urllib.parse.urlencode` 를
      호출하여 딕셔너리를 웹 서버에 보내기 적합한 형태로 암호화한다.


.. _queue-handler:


QueueHandler
^^^^^^^^^^^^

.. versionadded:: 3.2

:mod:`logging.handlers` 모듈에 위치한 :class:`QueueHandler` 클래스는 (:mod:`queue` 혹은
:mod:`multiprocessing` 모듈에서 구현된 것과 같은) 큐 (queue)에 로깅 메시지를 보내는 것을 지원한다.

:class:`QueueListener` 클래스와 함께, 로깅을 하는 스레드와 별개의 스레드에서 핸들러가 작업을 하는 것을
가능케 하기 위해 :class:`QueueHandler` 가 쓰일 수 있다. 이것은 웹 프로그램과, 고객을 서비스하는 쓰레드가
가능한 빨리 반응해야 하는 다른 서비스들의 경우 중요하다. 느린 작업 (예를 들어, :class:`SMTPHandler`
를 통해 이메일을 보내는 것과 같은)은 별도의 스레드에서 수행된다.

.. class:: QueueHandler(queue)

   :class:`QueueHandler` 클래스의 새로운 인스턴스를 반환한다. 인스턴스는 메시지를 받을 수 있는 큐와
   함께 초기화된다. 큐는 어떠한 큐 비슷한 객체도 가능하다; 큐는 :meth:`enqueue` 에 의해 있는 그대로
   사용되며, 이 메쏘드는 큐에 어떤 방식으로 메시지를 보내야 하는지 알아야 한다.


   .. method:: emit(record)

      LogRecord 의 준비 결과를 큐에 더한다.

   .. method:: prepare(record)

      큐잉에 대한 레코드를 준비하다. 이 메쏘드에 의해 반환되는 객체는 큐에 더해진다.

      기본 구현은 메시지와 인수를 병합하도록 레코드의 서식을 지정하고 레코드에서 unpickleable 항목을
      제거한다.

      만약 레코드를 딕셔너리나 JSON 문자열로 변환하거나, 원본은 보존한채 레코드의 수정된 복사본을 보내고
      싶을 경우 이 메쏘드를 재정의해야 할 수 있다.


   .. method:: enqueue(record)

      ``put_nowait()`` 를 사용하여 큐에 레코드를 더한다; 블로킹 동작이나 타임 아웃 또는 사용자 정의
      큐 구현을을 사용하려는 경우 이 메쏘드를 재정의할 수 있다.



.. _queue-listener:

QueueListener
^^^^^^^^^^^^^

.. versionadded:: 3.2

:mod:`logging.handlers` 모듈에 위치한 :class:`QueueListener` 클래스는, :mod:`queue`
혹은 :mod:`multiprocessing` 모듈에서 구현된 것과 같이, 큐로부터 로깅 메시지를 받는 것을 지원한다.
내부 스레드 안의 큐에서 메시지를 전달받은 후, 같은 스레드에서 하나 혹은 더 많은 핸들러에게 그것을 넘겨준다.
:class:`QueueListener` 는 그 자체로 핸들러는 아니지만, :class:`QueueHandler` 와 밀접하게
관련되어 동작하기 때문에 여기에 문서화한다.

:class:`QueueHandler` 클래스와 함께, :class:`QueueListener` 는 로깅을 하는 스레드와 별개의
스레드에서 핸들러들이 작동할 수 있도록 해준다. 이것은 웹 프로그램과, 고객을 서비스하는 쓰레드가
가능한 빨리 반응해야 하는 다른 서비스들의 경우 중요하다. 느린 작업 (예를 들어, :class:`SMTPHandler`
를 통해 이메일을 보내는 것과 같은)은 별도의 스레드에서 수행된다.

.. class:: QueueListener(queue, *handlers, respect_handler_level=False)

   :class:`QueueListener` 클래스의 새로운 인스턴스를 반환한다. 인스턴스는, 메시지를 받을 수 있는
   큐와 큐에 위치한 항목들을 처리할 핸들러 목록과 함께 초기화된다. 큐는 어떠한 큐 비슷한 객체도 가능하다;
   큐는 :meth:`enqueue` 에 의해 있는 그대로 사용되며, 이 메쏘드는 큐에 어떤 방식으로 메시지를 보내야
   하는지 알아야 한다. 만약 ``respect_handler_level`` 이 ``True`` 라면, 메시지를 핸들러에
   보낼지 말지를 결정하는데 그 핸들러의 수준 (메시지의 수준과 비교해서)이 우선 고려된다; 그 외에는,
   이전의 Python 버전의 작동 방식과 같다 - 각 메시지를 각 핸들러에 항상 보낸다.

   .. versionchanged:: 3.5
      ``respect_handler_levels`` 인수가 추가됨.

   .. method:: dequeue(block)

      큐에서 레코드를 빼와서 반환하고, 선택적으로 차단한다.

      기본 구현은 ``get()`` 을 사용한다. 타임 아웃을 사용하거나 사용자 정의 큐를 사용하고자 하는 경우
      이 메쏘드를 재정의할 수 있다.

   .. method:: prepare(record)

      핸들링을 위한 레코드를 준비한다.

      이 구현은 단순히 전달된 레코드를 반환한다. 핸들러에 넘겨주기 전에 사용자 정의 정렬이 필요하거나 레코드의
      조작이 필요한 경우, 이 메쏘드를 재정의할 수 있다.

   .. method:: handle(record)

      레코드를 핸들링한다.

      이 메쏘드는 핸들러를 순환하며 핸들링할 레코드를 제공한다. 핸들러에 실제로 전해지는 객체는
      :meth:`prepare` 로부터 반환되는 것이다.

   .. method:: start()

      리쓰너를 시작한다.

      이 메쏘드는 LogRecords 가 처리할 큐를 감시하기 위한 백그라운드 스레드를 시작한다.

   .. method:: stop()

      리쓰너를 중단한다.

      이 메쏘드는 스레드가 종료될 것을 요구하고, 종료될 때까지 기다린다. 응용 프로그램이 종료되기 전에
      이 메쏘드를 호출하지 않으면 처리되지 않을 레코드가 큐에 남아있을 수 있다는 점에 유의하라.

   .. method:: enqueue_sentinel()

      리쓰너를 종료시키기 위한 센티넬을 큐에 추가한다. 이 구현은 ``put_nowait()`` 을 사용한다.
      타임아웃을 사용하거나 사용자 정의 큐를 사용하고자 하는 경우 이 메쏘드를 재정의할 수 있다.

      .. versionadded:: 3.3


.. seealso::

   모듈 :mod:`logging`
      로깅 모듈에 대한 API 참조.

   모듈 :mod:`logging.config`
      로깅 모듈에 대한 환경 설정 API.


