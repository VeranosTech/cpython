==========================
로깅 하우투(HOWTO)
==========================

:Author: Vinay Sajip <vinay_sajip at red-dove dot com>

.. _logging-basic-tutorial:

.. currentmodule:: logging

기초 로깅 튜토리얼
----------------------

로깅은 어떤 소프트웨어가 실행될 때 발생하는 이벤트를 추적하는 수단이다.
소프트웨어 개발자들은 로깅 호출을 그들의 코드에 추가해서 특정한 이벤트가 발생했다는 것을 표시한다.
이벤트는 서술적인 메세지로 변수 데이터를 포함할 수도 있다. (데이터는 각각의 이벤트마다
다를 수 있다.) 개발자는 각각의 이벤트에 대해 중요성을 지정할 수 있다.
이를 *레벨(level)*\ 또는 *중요도(severity)*\ 라고 한다.

로깅을 사용해야 할 때
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

logging은 간단한 로깅 사용을 위한 편리한 함수들을 제공한다.
이 함수들은 :func:`debug`, :func:`info`, :func:`warning`, :func:`error`,
:func:`critical` 총 다섯 가지다. 로깅을 사용할 때를 결정하려면 아래의 테이블을 확인하라.
이 테이블은 일반적인 작업에 때 사용할 수 있는 가장 적합한 도구들을 설명하고 있다.

+-------------------------------------+--------------------------------------+
| 수행하고 싶은 작업                  | 작업을 위해 가장 적합한 도구         |
+=====================================+======================================+
| 평범한 커맨드라인 스크립트나        | :func:`print`                        |
| 프로그램 사용 시의 출력을 표시      |                                      |
|                                     |                                      |
+-------------------------------------+--------------------------------------+
| 프로그램의 일반적인 연산 중에       | :func:`logging.info` (또는           |
| 발생하는 이벤트 기록                | 진단 목적을 위해 매우 상세한 출력을  |
| (예. 상태 모니터링 또는 결함 조사)  | 원하는 경우 :func:`logging.debug`)   |
|                                     |                                      |
+-------------------------------------+--------------------------------------+
| 특정한 런타임 이벤트에 관한 경고    | 피해야 하는 이슈이고 클라이언트      |
| 발생                                | 어플리케이션이 반드시 경고를         |
|                                     | 제거하도록 수정되어야 한다면         |
|                                     | 라이브러리 코드에 있는               |
|                                     | :func:`warnings.warn`                |
|                                     |                                      |
|                                     | 클라이언트 어플리케이션이 상황에     |
|                                     | 대해서 할 수 있는 건 없으나          |
|                                     | 이벤트는 계속해서 알려져야 한다면    |
|                                     | :func:`logging.warning`              |
+-------------------------------------+--------------------------------------+
| 특정한 런타임 이벤트와 관련한       | 예외 발생                            |
| 에러를 보고                         |                                      |
+-------------------------------------+--------------------------------------+
| 예외를 발생시키지 않으면서 에러     | :func:`logging.error`,               |
| 방지를 보고 (예, 장시간 실행중인    | :func:`logging.exception` 또는       |
| 서버 프로세스 내의 에러 핸들러)     | 특정 에러와 어플리케이션 도메인에    |
|                                     | 적합한 :func:`logging.critical`      |
|                                     |                                      |
+-------------------------------------+--------------------------------------+

로깅 함수는 함수가 추적하는 이벤트의 레벨이나 중요도에 따라 이름이 지어졌다.
표준 레벨과 언제 사용하애 하는지는 (가장 중요하지 않은것부터) 아래에 설명되어 있다:

.. tabularcolumns:: |l|L|

+--------------+---------------------------------------------+
| 레벨         | 사용 되는 때                                |
+==============+=============================================+
| ``DEBUG``    | 상세한 정보, 단순히 진단을 하는 것에만      |
|              | 관심이 있을 때.                             |
+--------------+---------------------------------------------+
| ``INFO``     | 작업이 예상한대로 흘러가는지 확인 할 때.    |
+--------------+---------------------------------------------+
| ``WARNING``  | 예상하지 못한 일이 발생한 것을 나타낼 때,   |
|              | 또는 근시일에 어떤 문제가 발생할 것을       |
|              | 나타낼 때. (예. '디스크 공간이 적음')       |
|              | 소프트웨어는 계속 예상한대로 작동중이다.    |
+--------------+---------------------------------------------+
| ``ERROR``    | 더 심각한 문제 때문에, 소프트웨어가 특정한  |
|              | 기능을 더 이상 수행할 수 없을 때.           |
+--------------+---------------------------------------------+
| ``CRITICAL`` | 심각한 에러, 프로그램이 작동을 더이상       |
|              | 할 수 없음을 나타낼 때                      |
+--------------+---------------------------------------------+

디폴트 레벨은 ``WARNING``\ 이며, 로깅 패키지가 따로 설정되지 않으면 이 레벨 이상의 이벤트만이
추적된다는 것의 의미한다.

추적되는 이벤트는 여러 방식으로 처리될 수 있다. 가장 간단한 방식은 콘솔에 출력하는 것이다.
다른 방식은 디스크 파일에 쓰는 것이다.


.. _howto-minimal-example:

간단한 예시
^^^^^^^^^^^^^^^^

가장 간단한 예시는 다음과 같다::

   import logging
   logging.warning('Watch out!')  # 콘솔에 메세지를 출력한다
   logging.info('I told you so')  # 아무것도 출력하지 않는다

이 코드를 스크립트에 쓰고 실행시키면 아래와 같은 결과를 보게 된다:

.. code-block:: none

   WARNING:root:Watch out!

``INFO``\ 는 나타나지 않는다. 왜냐하면 디폴트 레벨이 ``WARNING``\ 이기 때문이다.
출력된 메세지는 레벨과 로깅 호출에서 제공된 이벤트에 대한 설명('Watch out!')을 포함하고 있다.
'root'에 대해서는 아직 신경쓰지 않아도 된다: 추후에 설명할 것이다.
실제 출력은 필요에 따라 꽤 융통성있게 포매팅될 수 있다;
포매팅 옵션도 추후에 설명할 것이다.


파일에 로깅하기
^^^^^^^^^^^^^^^^^^^^^^^^^

가장 일반적인 상황은 로깅 이벤트를 파일에 기록하는 것이다.
아래는 위에 설명됐던 세션에서 계속 하지 말고 새로 시작한 파이썬 인터프리터에서 시도하라::

   import logging
   logging.basicConfig(filename='example.log',level=logging.DEBUG)
   logging.debug('This message should go to the log file')
   logging.info('So should this')
   logging.warning('And this, too')

지금 파일을 열고 결과를 보면 로그 메세지를 보게 될 것이다::

   DEBUG:root:This message should go to the log file
   INFO:root:So should this
   WARNING:root:And this, too

이 예제는 추적의 임계치로 작동하는 로깅레벨을 설정하는 방법을 보여준다.
이 경우 임계치를 ``DEBUG```\ 로 설정했기 때문에 모든 메세지가 출력된다.

아래처럼 커맨드라인 옵션으로 로깅레벨을 설정하고 싶고::

   --log=INFO

변수 *loglevel*\ 에 있는 ``--log``\ 에 전달된 파라미터의 값이 있으면 아래 코드를 사용해::

   getattr(logging, loglevel.upper())

*level* 인수를 통해서 :func:``basicConfig``\ 에 전달할 값을 얻을 수 있다.
아래 예제처럼 모든 사용자 입력값에 대해 에러 확인을 하고 싶을 수도 있다::

   # loglevel이 커맨드 라인 인수에서 얻어진 문자열 값에 묶였다고 가정하자.
   # 사용자가 --log=DEBUG 또는 --log=debug 로 사용할 수 있도록
   # 대문자로 변경하자.
   numeric_level = getattr(logging, loglevel.upper(), None)
   if not isinstance(numeric_level, int):
       raise ValueError('Invalid log level: %s' % loglevel)
   logging.basicConfig(level=numeric_level, ...)

:func:`basicConfig` 호출은 반드시 :func:`debug`, :func:`info` *전에* 이루어져야 한다.
일회성(one-off) 단순 설정 기능으로 의도했기 때문에, 첫 번재 호출이 모든 것을 결정한다. 후속 호출은 실질적으로
작동하지 않는다.

위의 스크립트를 여러번 실행하면, 연속적인 실행 메세지는 *example.log*\ 에 추가될 것이다.
매 실행을 새롭게 시작하고 이전 실행의 메세지를 기억하고 싶지 않으면, 위 예제의 호출을 아래처럼 변경함으로써
*filemode* 인수를 지정하면 된다::

   logging.basicConfig(filename='example.log', filemode='w', level=logging.DEBUG)

출력은 이전과 같지만 로그 파일은 더이상 추가되지 않고 이전의 실행 메세지는 사라진다.


다중 모듈로부터의 로깅
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

프로그램이 여러 모듈로 구성되어 있으면 프로그램 내의 로깅을 조직하는 방법의 예는 다음과 같다::

   # myapp.py
   import logging
   import mylib

   def main():
       logging.basicConfig(filename='myapp.log', level=logging.INFO)
       logging.info('Started')
       mylib.do_something()
       logging.info('Finished')

   if __name__ == '__main__':
       main()

::

   # mylib.py
   import logging

   def do_something():
       logging.info('Doing something')

*myapp.py*\ 를 실행하면, *myapp.log*\ 에서 아래 메세지를 보게 될 것이다::

   INFO:root:Started
   INFO:root:Doing something
   INFO:root:Finished

위 메세지는 예상했던 것이다. *mylib.py*\ 에 있는 패턴을 사용해서 여러 모듈에 일반화할 수 있다.
이 간단한 사용 패턴의 경우 로그 파일만 보고서는 이벤트 설명을 제외하면 어플리케이션의 *어디에서* 메시지가
왔는지는 알 수가 없다. 메세지의 위치를 추적하고 싶으면
튜토리얼 레벨 다음에 있는 도큐먼트를 참고하라 -- :ref:`logging-advanced-tutorial`.


변수 데이터 로깅
^^^^^^^^^^^^^^^^^^^^^^^^^^

변수 데이터를 로깅하기 위해서는 이벤트 설명 메세지에 포맷 문자열을 사용하고
변수 데이터를 인수로 추가하라::

   import logging
   logging.warning('%s before you %s', 'Look', 'leap!')

위 코드는 아래처럼 출력된다:

.. code-block:: none

   WARNING:root:Look before you leap!

보다시피, 변수 데이터를 이벤트 설명 메세지와 병합할 때는 오래된 %-스타일 문자열 포맷팅을 사용한다.
이는 하위 호환성을 위한 것이다: 로깅 패키는 :meth:`str.format`\ 과 :class:`string.Template`
같은 새로운 포매팅 옵션보다 먼저 만들어졌다. 이런 새로운 포매팅 옵션은 지원되지만, 그것들에 대해서 살펴보는
것은 이 튜토리얼의 범위에서 벗어난다: 더 자세한 정보는 :ref:`formatting-styles`\ 를 참고하라.


표시되는 메세지의 형식 변경
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

메세지 표시에 사용되는 형식을 변경하기 위해서는 사용하려는 포맷을 지정해야한다::

   import logging
   logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)
   logging.debug('This message should appear on the console')
   logging.info('So should this')
   logging.warning('And this, too')

위의 코드는 아래와 같이 표시된다::

   DEBUG:This message should appear on the console
   INFO:So should this
   WARNING:And this, too

이전의 예제에서 나타났던 'root'가 사라진 것을 볼 수 있다.
포맷 문자열에서 나타날 수 있는 것들의 전체 목록은 :ref:`logrecord-attributes`\ 에 있다.
하지만 간단한 사용의 경우 *levelname* (중요도), *message* (변수 데이터를 포함하는 이벤트 설명),
이벤트가 발생했을 때를 표시하는 것만 알면 된다. 이것은 다음 섹션에 설명되어 있다.


메세지에 날짜/시간 표시
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

이벤트의 시간과 날짜를 표시하려면 포맷 문자열에 '%(asctime)s'을 써야 한다::

   import logging
   logging.basicConfig(format='%(asctime)s %(message)s')
   logging.warning('is when this event was logged.')

위 코드는 아래처럼 출력된다::

   2010-12-12 11:41:42,612 is when this event was logged.

위쪽에 보이는 날짜/시간 표시의 기본 포맷은 ISO8601이다. 날짜/시간의 포매팅을 더 수정하고 싶으면
``basicConfig``\ 에 *datefmt* 인수를 전달하라::

   import logging
   logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')
   logging.warning('is when this event was logged.')

위 코드는 아래와 같이 출력된다::

   12/12/2010 11:46:36 AM is when this event was logged.

*datefmt* 인수의 형식은 :func:`time.strftime`\ 에서 지원되는 형식과 같다.


다음 단계
^^^^^^^^^^^^^^^^

기초 튜토리얼은 여기서 끝이다. 이 정도면 로깅을 사용하기에는 충분하다. 그러나 로깅패키지는 더 많은 것들을 제공하며
그중 가장 좋은 것을 얻으려면 다음 섹션을 읽기 위해서 시간을 더 투자해야 한다. 준비가 되었다면 가장 좋아하는
음료를 마시면서 계속 진행해보자.

간단한 로깅만 필요하다면, 위의 예제들을 사용해서 스크립트에 로깅을 포함시키고 문제가 생기거나 이해를 못하는
부분이 있으면 comp.lang.python Usenet group(https://groups.google.com/forum/#!forum/comp.lang.python)에
질문을 작성하라. 오래 지나지 않아 답변을 받을 수 있을 것이다.

이제 더 깊이있는 고급 튜토리얼을 제공하는 다음 섹션으로 넘어가자. 그 다음에는 :ref:`logging-cookbook`\ 를
읽어보라.

.. _logging-advanced-tutorial:


고급 로깅 튜토리얼
-------------------------

로깅 라이브러리는 모듈형 접근방식을 취하며 여러 카테고리의 구성요소를 제공한다:
logger, handler, filter, formatter.

* Logger는 어플리케이션 코드가 직접 사용하는 인터페이스를 나타낸다.
* Handler는 로그 (logger가 생성한) 기록을 적절한 목적지로 보낸다.
* Filter는 어떤 로그 기록을 출력할 건지 결정하기 위한 좋은 기능을 제공한다.
* Formatter는 최종 출력될 때 로그 기록의 레이아웃을 지정한다.

로그 이벤트 정보는 :class:`LogRecord` 인스턴스에 있는 logger, handler, filter, formatter
사이에서 전달된다.

로깅은 :class:`Logger` 클래스의 인스턴스에 있는 메서드를 호출함으로써 수행된다.
(이후로는 :dfn:`loggers`\ 라고 한다.) 각 인스턴스는 이름이 있고, 구분자로 구두점을 사용하는
네임스페이스 계층에 개념적으로 배치되어 있다. 예를 들어, 이름이 'scan'인 로거는 'scan.text',
'scan.html', 'scan.pdf' 로거의 부모가 된다. 로거 이름은 아무렇게나 될 수 있으며,
로그 메세지가 발생한 어플리케이션 위치를 나타낸다.

로거를 네이밍할 때 사용하는 좋은 컨벤션은 모듈 레벨 로거를 사용하는 것이며,
로깅을 사용하는 각 모듈은 아래와 같이 이름 짓는다::

   logger = logging.getLogger(__name__)

이는 로거 이름이 패키지/모듈 계층을 추적한다는 뜻이며, 로거 이름으로부터 직관적으로
이벤트가 어디에서 로그되는지를 알 수 있다.

로거 계층의 루트는 root 로거라고 한다. 이것은 :func:`debug`, :func:`info`, :func:`warning`,
:func:`error`, :func:`critical` 함수가 사용하는 로거이며, 같은 이름의 root 로거 메서드를 호출한다.
함수와 메서드는 같은 시그너쳐를 가지고 있다. root 로거의 이름은 로그된 출력에서 'root'로 출력된다.

물론 다른 곳에 메세지를 로그할 수도 있다. 패키지에서는 파일, HTTP GET/POST 위치, SMTP를 통한 이메일, 일반 소켓,
큐 또는 syslog나 Windows NT 이벤트 로그 같은 OS별 로깅 메커니즘에 로그 메세지를 쓰는 기능을 지원한다.
지원된다. 목적지는 :dfn:`handler` 클래스에 의해서 제공된다. 요구사항을 만족하는 빌트인 handler 클래스가
없을 경우에 자신만 로그 목적지 클래스를 만들 수 있다.

기본적으로, 로깅 메세지에 대해서 목적지는 설정되어 있지 않다. 목적지는 튜토리얼 예제처럼
:func:`basicConfig`\ 를 사용해서 콘솔이나 파일로 지정할 수 있다. :func:`debug`, :func:`info`,
:func:`warning`, :func:`error`, :func:`critical`\ 를 호출하면, 이 함수들은
목적지가 설정되어있지 않은지를 확인한다; 그리고 지정되어있지 않으면 콘솔을 목적지(``sys.stderr``)와
root 로거가 실제 메세지를 출력하도록 위임하기 전에 표시되는 메세지의 기본 포맷을 설정한다.

:func:`basicConfig`\ 에 의해 설정되는 기본 포맷은 아래와 같다::

   severity:logger name:message

포맷 문자열을 *format* 키워드 인수로 :func:`basicConfig`\ 에 전달해서 포맷을 바꿀 수 있다.
포맷 문자열을 구성하는 방법에 관한 전체 옵션은 :ref:`formatter-objects`\ 에서 볼 수 있다.

로깅 플로우
^^^^^^^^^^^^^^^^

로거에 있는 로그 이벤트 정보의 플로우는 아래 다이어그램에 나타나있다.

.. image:: logging_flow.png

로거(Loggers)
^^^^^^^^^^^^^^^^^

:class:`Logger` 객체는 3중 작업을 한다. 첫 번째, 어플리케이션이 실행 중에 메세지를
로그할 수 있도록 어플리케이션 코드에 몇가지 메서드를 노출한다. 두 번째, 로거 객체는
중요도 또는 필터 객체에 기반해 어떤 메세지를 활용할지 결정한다. 세 번째, 로거 객체는
관련있는 로그 메세지를 모든 관련 있는 로그 핸들러에 넘긴다.

로거 객체에서 가장 많이 활용되는 메서드는 두 카테고리로 나뉜다: 설정과 메세지 전송.

아래는 가장 일반적인 설정 메서드다:

* :meth:`Logger.setLevel`\ 은 로거가 처리하게 될 가장 낮은 중요도의 로그 메세지를 지정하며,
  빌트인 중요도 레벨에서 debug가 가장 낮고 critical이 가장 높다. 예를 들어,
  중요도 레벨이 INFO면 로거는 INFO, WARNING, ERROR, CRITICAL 메세지만 처리하고
  DEBUG 메세지는 무시한다.

* :meth:`Logger.addHandler`\ 와 :meth:`Logger.removeHandler`\ 는 로거 객체에
  핸들러 객체를 추가하고 제거한다. 핸들러는 :ref:`handler-basic`\ 에서 더 자세하게 다룬다.

* :meth:`Logger.addFilter`\ 와 :meth:`Logger.removeFilter`\ 는 로거 객체에
  필터 객체를 추가하고 제거한다. 필터는 :ref:`filter`\ 에서 더 자세하게 다룬다.

생성하는 모든 로거에서 이 메서드들을 항상 호출할 필요는 없다.
이 섹션의 마지막 두 문단을 확인하라.

로거 객체가 설정된 상태에서, 아래의 메서드가 로그 메세지를 생성한다:

* :meth:`Logger.debug`, :meth:`Logger.info`, :meth:`Logger.warning`,
  :meth:`Logger.error`, :meth:`Logger.critical` 모두 메세지와 각각의 메서드 이름에
  상응하는 레벨의 로그 기록을 생성한다. 메세지는 실제로 포맷 문자열이며, 표준 문자열 대체 신택스
  ``%s``, ``%d``, ``%f`` 등을 포함하고 있다. 인수의 나머지는 메세지의 대체 필드에 대응하는 객체의 리스트다.
  ``**kwagrs``\ 관해서 로깅 메소드는 ``exc_info``\ 키워드만 신경쓰며 예외 정보를 로깅할지를 결정한다.

* :meth:`Logger.exception`\ 는 :meth:`Logger.error`\ 와 유사한 로그 메세지를
  출력한다. 차이점은 :meth:`Logger.exception`\ 는 추적하는 스택 추적을 덤프한다.
  예외 핸들러에서만 이 메서드를 호출하라.

* :meth:`Logger.log`\ 는 명시적인 인수로 로그 레벨을 취한다. 이 메서드는 위에 있는
  로그 레벨 편의 메서드를 사용하는 것 보다 조금 더 자세한 로그를 생성하지만 이는 커스텀 로그 레벨에서
  로깅을 하는 방식이다.

:func:`getLogger`\ 는 이름이 제공되었으면 이름을, 제공되지 않았으면 ``root``\ 인 로거
인스턴스에 대한 레퍼런스를 반환한다. 이름은 구두점으로 구분된 계층적인 구조로 이루어져있다. 같은 이름을 가진
:func:`getLogger`\ 에 대한 다중 호출은 같은 로거 객체에 대한 레퍼런스를 반환한다.
계층 리스트에서 더 아래에 있는 로거는 리스트의 위에 있는 로거의 자식이 된다.
예를 들어 ``foo``\ 라는 이름의 로거가 있으면 ``foo.bar``, ``foo.bar.baz``, ``foo.bam``\ 는
``foo``\ 의 자손이 된다.

로거에는 *effective level*\ 이라는 개념이 있다. 명시적으로 레벨이 로거에 설정되어있지 않으면
유효 레벨로서 부모의 것이 대신 사용된다. 만약 부모가 명시적인 레벨이
설정되어있지 않으면 그 부모를 조사한다 -- 명시적인 레벨을 찾기 전까지 모든 조상이 검색된다.
루트 로거는 항상 기본적으로 명시적인 ``WARNING`` 레벨을 갖는다. 이벤트 처리 시에,
로거의 유효 레벨은 이벤트가 로거의 핸들러에 전달될지를 결정하기 위해 사용된다.

자식 로거는 조상 로거와 연결된 핸들러에게까지 메세지를 전파한다. 이것 때문에 어플리케이션에서 사용하는
모든 로거에 대해 핸들러를 정의하고 설정할 필요가 없다. 최상위 레벨 로거에 대한 핸들러를 설정하고, 필요한대로
자식로거를 생성하는 것으로 충분하다. (그러나, 로거의 *propagate* 속성을 ``False``\ 로 설정해서,
전파를 꺼버릴 수 있다.)


.. _handler-basic:

핸들러(Handlers)
^^^^^^^^^^^^^^^^^^^^^^

:class:`~logging.Handler`\ 는 (로그 메세지의 중요도에 따라) 적절한 로그 메세지를 핸들러의 특정한
목적지에 전달하는 책임을 맡고 있는 객체다. :class:`Logger` 객체는 자신에게 0개 이상의 핸들러 객체를
:meth:`~Logger.addHandler` 메서드로 추가할 수 있다. 예제 시나리오로,
한 어플리케이션이 모든 로그 메세지를 한 로그 파일에, 모든 에러 이상의 로그 메세지를
표준 출력에, 모든 크리티컬 메세지를 이메일 주소에 보내고 싶다고 하자. 이 시나리오는 세 개의 개별적인
핸들러가 필요하며 각 핸들러는 특정한 중요도의 메시지를 특정한 위치에 보내야 한다.

표준 라이브러리는 몇 가지 핸들러 타입을 포함하고 있다. (:ref:`useful-handlers` 참고);
튜토리얼은 주로 :class:`StreamHandler`\ 와 :class:`FileHandler`\ 를 사용한다.

핸들러에는 어플리케이션 개발자들이 고려할만한 매우 적은 수의 메서드가 있다.
빌트인 핸들러 객체를 사용하는 어플리케이션 개발자와 관련이 있는 것처럼 보이는 유일한 핸들러 메서드는
아래의 설정 메서드들이다:

* :meth:`~Handler.setLevel` 메서드, 로거 객체에 있으며, 적절한 목적지에 전달될 가장 낮은 중요도
  를 지정한다. 왜 두 :func:`setLevel` 메서드가 있을까? 로거에서 설정된 레벨은 어떤 중요도의 메세지가
  핸들러로 전달될지를 결정한다. 각각의 핸들러에서 설정된 레벨은 핸들러가 어떤 메세지를 보낼지 결정한다.

* :meth:`~Handler.setFormatter`\ 는 이 핸들러가 사용할 포매터 객체를 선택한다.

* :meth:`~Handler.addFilter`, :meth:`~Handler.removeFilter`\ 는 각각
  핸들러에 대한 필터 객체를 설정하거나 설정해제한다.

어플리케이션 코드는 직접 :class:`Handler`\ 를 인스턴스화 해서 인스턴스를 사용하면 안 된다.
대신에 :class:`Handler`\ 는 베이스 클래스로서 모든 핸들러가 가져야 하는 인터페이스를 정의하고
자식 클래스가 사용할 수 있는 (또는 오버라이드하는) 기본적인 동작을 구성한다.


포매터(Formatters)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

포매터 객체는 로그 메세지의 마지막 순서, 구조, 내용을 구성한다. 베이스 :class:`logging.Handler`
클래스와 다르게, 어플리케이션이 특별한 동작이 필요하면 쉽게 포매터를 상속할 수 있지만,
어플리케이션 코드에서 포매터 클래스를 인스턴스화 할 수도 있다.
컨스트럭터는 세 가지의 선택적인 인수를 받는다 -- 메세지 포맷 문자열, 날짜 포맷 문자열, 스타일 지시자.

.. method:: logging.Formatter.__init__(fmt=None, datefmt=None, style='%')

매세지 포맷 문자열이 없으면 로우 메세지를 기본으로 사용한다.
날짜 포맷 문자열이 없으면 아래와 같은 기본 날짜 포맷이 사용된다::

    %Y-%m-%d %H:%M:%S

끝에 밀리 세컨드까지 붙는다. ``style``\ 은 '%', '{', '$' 중에 하나다.
이 셋 중 하나가 지정되지 않으면, '%'가 사용된다.

``style``\ 이 '%'면, 메세지 포맷 문자열은 ``%(<dictionary key>)s`` 문자열 대체 스타일을
사용한다; 사용 가능한 키는 :ref:`logrecord-attributes`\ 에 있다. 스타일이 '{'면, 메세지
포맷 문자열은 (키워드 인수를 사용하는) :meth:`str.format`\ 와 호환된다고 가정한다,
반면 스타일이 '$'면 메세지 포맷 문자열은 :meth:`string.Template.substitute`\ 에 의해 예상되는
것을 따라야 한다.

.. versionchanged:: 3.2
   ``style`` 파라미터가 추가되었다.

아래의 메세지 포맷 문자열은 사람이 읽을 수 있는 형식의 시간과, 메세지 중요도, 메세지 내용 순으로
로깅한다::

    '%(asctime)s - %(levelname)s - %(message)s'

포매터는 레코드의 시간 생성을 튜플로 변환하기 위해 사용자가 설정할 수 있는 함수를 사용한다.
기본적으로 :func:`time.localtime`\ 이 사용된다; 특정한 포매터 인스턴스에 대해서 이것을 바꾸려면
인스턴스의 ``converter`` 속성을 :func:`time.localtime`, :func:`time.gmtime` 같은
동일한 시그너쳐를 가진 함수로 설정해야 한다. 모든 포매터에 대해서 바꾸기 위해서는, 예를 들어
모든 로깅 시간이 GMT로 보여지길 원하면, 포매터 클래스에 있는 ``converter`` 속성을 ``time.gmtime`` 로
변경해야 한다.


로깅 설정하기
^^^^^^^^^^^^^^^^^^^^^^^

.. currentmodule:: logging.config

프로그래머는 로깅을 세 가지 방법으로 설정할 수 있다:

1. 위에 있는 설정 메서드를 호출하는 파이썬 코드를 사용해서 로거, 핸들러, 포매터를 명시적으로 생성한다.
2. 로깅 설정 파일을 생성하고 :func:`fileConfig` 함수를 사용해서 파일을 읽는다.
3. 설정 정보에 대한 딕셔너리를 생성하고 :func:`dictConfig` 함수에 전달한다.

뒤의 두 옵션에 대한 참조 문헌은 :ref:`logging-config-api`\ 를 참고하라.
아래의 예제는 매우 간단한 로거, 콘솔 핸들러, 파이썬 코드를 사용하는 간단한 포매터를 구성한다::

    import logging

    # create logger
    logger = logging.getLogger('simple_example')
    logger.setLevel(logging.DEBUG)

    # create console handler and set level to debug
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)

    # create formatter
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    # add formatter to ch
    ch.setFormatter(formatter)

    # add ch to logger
    logger.addHandler(ch)

    # 'application' code
    logger.debug('debug message')
    logger.info('info message')
    logger.warn('warn message')
    logger.error('error message')
    logger.critical('critical message')

이 모듈을 커맨드라인에서 실행하면 아래의 출력을 생성한다:

.. code-block:: shell-session

    $ python simple_logging_module.py
    2005-03-19 15:10:26,618 - simple_example - DEBUG - debug message
    2005-03-19 15:10:26,620 - simple_example - INFO - info message
    2005-03-19 15:10:26,695 - simple_example - WARNING - warn message
    2005-03-19 15:10:26,697 - simple_example - ERROR - error message
    2005-03-19 15:10:26,773 - simple_example - CRITICAL - critical message

아래의 파이썬 모듈은 위에 있는 것들과 거의 동일한 로거, 핸들러, 포매터를 생성하는데 유일한 차이점은
객체의 이름이다::

    import logging
    import logging.config

    logging.config.fileConfig('logging.conf')

    # create logger
    logger = logging.getLogger('simpleExample')

    # 'application' code
    logger.debug('debug message')
    logger.info('info message')
    logger.warn('warn message')
    logger.error('error message')
    logger.critical('critical message')

아래는 logging.conf 파일이다::

    [loggers]
    keys=root,simpleExample

    [handlers]
    keys=consoleHandler

    [formatters]
    keys=simpleFormatter

    [logger_root]
    level=DEBUG
    handlers=consoleHandler

    [logger_simpleExample]
    level=DEBUG
    handlers=consoleHandler
    qualname=simpleExample
    propagate=0

    [handler_consoleHandler]
    class=StreamHandler
    level=DEBUG
    formatter=simpleFormatter
    args=(sys.stdout,)

    [formatter_simpleFormatter]
    format=%(asctime)s - %(name)s - %(levelname)s - %(message)s
    datefmt=

출력은 설정 파일 베이스가 아닌 예제의 출력과 거의 동일하다:

.. code-block:: shell-session

    $ python simple_logging_config.py
    2005-03-19 15:38:55,977 - simpleExample - DEBUG - debug message
    2005-03-19 15:38:55,979 - simpleExample - INFO - info message
    2005-03-19 15:38:56,054 - simpleExample - WARNING - warn message
    2005-03-19 15:38:56,055 - simpleExample - ERROR - error message
    2005-03-19 15:38:56,130 - simpleExample - CRITICAL - critical message

설정 파일 접근법은 설정과 코드를 분리하고 프로그래머가 아닌 사람이 쉽게 로깅 특성을
변경할 수 있다는 점에서 코드 접근법에 비해 몇 가지 이점이 있다.

.. warning:: :func:`fileConfig` 함수는 기본 파라미터,
   ``disable_existing_loggers``\ 를 받는데, 하위 호환성의 이유로 ``True``\ 로
   설정되어 있다. 이는 당신이 원하는 것일 수도 아닐 수도 있다. 왜냐하면 :func:`fileConfig` 호출 전에
   존재하는 로거가 설정에서 이름이 명시적으로 있지 않을 경우 비활성화 되기 때문이다.
   더 자세한 정보는 레퍼런스 도큐먼트를를 참고하고 원한다면 이 파라미터를 ``False``\ 로
   지정해라.

   :func:`dictConfig`\ 로 전달된 딕셔너리는 ``disable_existing_loggers`` 키의 값을
   불리언 값으로 지정할 수 있고, 딕셔너리에서 명시적으로 지정되어있지 않으면 ``True`\ 로 해석된다.
   이럴 경우 위에서 설명한 (당신이 원하지 않는) 로거 비활성화 작동을 하게 되므로 명시적으로 ``False``
   값을 가진 키를 명시적으로 제공해주어야 한다.


.. currentmodule:: logging

설정 파일에서 참조되는 클래스 이름은 로깅 모듈에 대해 상대적이거나 일반 임포트 매커니즘을 사용해 해석할 수 있는
절대 경로 값이어야 할 필요가 있다. 따라서 :class:`~logging.handlers.WatchedFileHandler`
(로깅 모듈에 대해 상대적) 또는 ``mypackage.mymodule.MyHandler`` (``mypackage`` 패키지와
``mymodule`` 모듈에서 정의됐으면서 파이썬 임포트 경로로 ``mypackage``\ 가 이용할 수 있는 경우)
를 모두 쓸 수 있다.

파이썬 3.2에서, 딕셔너리를 사용해 설정 정보를 담고 있는 새로운 로깅 설정 방법이 도입되었다.
위에서 서술된 설정 파일 기반 접근법 기능의 상위 집합을 제공하며, 새로운 어플리케이션이나 배포에
이 설정 방법을 사용하는 것을 추천한다. 왜냐하면 파이썬 딕셔너리는 설정 정보를 유지하기 위해서
사용되기 때문에 다른 수단을 사용해 딕셔너리에 추가를 할수 있으므로 설정에 관한 더 많은 구성 옵션을 가질
수 있다. 예를 들어, JSON 포맷으로 설정파일을 사용할 수 있고 또는 YAML 프로세싱 기능에 접근할 수 있으면
설정 딕셔너리에 YAML 포맷의 파일을 사용해 추가할 수도 있다. 또는, 파이썬 코드로 사전을 구성하거나,
소켓을 거쳐서 피클된 형식을 받을 수도 있는 등 어플리케이션에서 사용할 수 있는 어떤 방식을 사용해도 상관이 없다.

아래 예제는 새로운 딕셔너리 기반 방식을 위해 YAML 포맷으로 만들어진 위와 같은 설정 파일이다::

    version: 1
    formatters:
      simple:
        format: '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    handlers:
      console:
        class: logging.StreamHandler
        level: DEBUG
        formatter: simple
        stream: ext://sys.stdout
    loggers:
      simpleExample:
        level: DEBUG
        handlers: [console]
        propagate: no
    root:
      level: DEBUG
      handlers: [console]

딕셔너리를 사용한 로깅에 대해서는 :ref:`logging-config-api`\ 를 참고하라.

설정이 제공되지 않으면 어떤 일이 일어나는가
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

로깅 설정이 제공되지 않으면, 로깅 이벤트가 출력될 필요가 있지만 이벤트 출력을 위한 핸들러가 없는 상황이
발생할 수 있다. 이 상황에서의 로깅 패키지의 동작은 파이썬 버전에 따라 다르다.

3.2 이전 버전의 파이썬에서는 아래의 동작이 이루어진다:

* *logging.raiseExceptions* \ 이 ``False``\ 면 (프로덕션 모드), 이벤트는 조용히
  드랍된다.

* *logging.raiseExceptions*\ 이 ``True``\ 면 (개발 모드),
  'No handlers could be found for logger X.Y.Z' 메세지가 한 번 출력된다.

파이썬 3.2 이후 버전에의 동작은 다음과 같다:

* ``logging.lastResort``\ 에 저장된 '최후의 핸들러'를 사용해 이벤트가 출력된다.
  이 내부 핸들러는 다른 로거와 연결되어있지 않고 현재 ``sys.stderr``\ 의 값에 이벤트 메세지를
  작성하는 :class:`~logging.StreamHandler`\ 와 유사하게 작동한다. (그러므로 적용중인
  리다이렉션을 준수한다.) 메세지에 포매팅은 적용되지 않는다. - 가장 기본적인 설명 메세지만 출력된다.
  핸들러의 레벨이 ``WARNING``\ 으로 설정되어 있으면 이 중요도 이상의 모든 이벤트가 출력될 것이다.

3.2 버전 이전의 동작을 원하면 ``logging.lastResort``\ 을 ``None``\ 으로 설정하면 된다.

.. _library-config:

라이브러리를 위한 로깅 설정하기
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

로깅을 사용하는 라이브러리를 개발할 때, 라이브러리가 로깅을 사용하는 방법을 문서화 해야 한다.
-- 예, 사용된 로거의 이름. 로깅 설정에도 주의를 기울여야 할 필요가 있다.
사용하는 어플리케이션이 로깅을 사용하지 않으면 라이브러리 코드는 로깅을 호출하고 (이전 섹션에서 설명한대로)
``WARNING`` 이상의 중요도를 가진 이벤트가 ``sys.stderr``\ 로 출력될 것이다. 이것은
최고의 디폴트 동작으로 간주된다.

로깅 설정 없이 이러한 메세지가 출력되지 않기를 원한다면, 아무것도 하지 않는 핸들러를 라이브러리의 최상위
레벨 로거에 추가하면 된다. 그러면 핸들러가 라이브러리의 이벤트가 발생할 때 항상 찾아지기 때문에
메세지가 출력되는 것을 막을 수 있다: 단순히 출력을 만들지 않는 것이다. 어플리케이션 사용을 위해
라이브러리 사용자가 로깅을 설정한다면, 어떤 핸들러에 설정이 추가됐고, 레벨이 적절하게 설정됐다면
라이브러리에서 발생된 로깅 호출은 평소와 같이 핸들러에 출력을 보낼 것이다.

아무것도 하지 않는 핸들러는 로깅 패키지에 포함되어 있다.
:class:`~logging.NullHandler` (파이썬 3.1 이후). 이 핸들러의 인스턴스는 라이브러리에서
사용되는 로깅 네임스페이스의 최상위 로거에 추가될 수 있다. (*만약* 로깅 설정 없이 라이브러리의 로그된 이벤트가
``sys.stderr``\ 로 출력되는 것을 막고자 한다면). 라이브러리 *foo*\ 의 모든 로깅이 'foo.x', 'foo.x.y'
등의 이름과 일치하는 로거를 사용해서 이루어지면::

    import logging
    logging.getLogger('foo').addHandler(logging.NullHandler())

위 코드로 원하는 결과를 얻을 수 있을 것이다. 한 조직에서 여러 라이브러리를 제작한다면, 로거 이름은
'foo'라고 하는 것보다 'orgname.foo'라고 하는 것이 낫다.

.. note:: :class:`~logging.NullHandler` \ 를 제외하고는 어떠한 핸들러도 라이브러리의 로거에
   추가하지 않기를 권장한다. 핸들러의 설정은 라이브러리를 사용하는 어플리케이션 개발자의 특권이기 때문이다.
   어플리케이션 개발자들은 자신들의 타겟을 알고 있으며 그들의 어플리케이션에 가장 적절한 핸들러가 무엇인지
   알고 있다: 핸들러를 밑단에 추가해버리면, 개발자들의 요구사항에 맞는 로그의 전달과 단위테스트를 수행하는
   것을 방해하게 될 것이다.


로깅 레벨
--------------

로깅 레벨의 숫자 값은 아래 테이블에 나타나있다. 이것들은 사전에 정의된 레벨에 상대적으로 특정한 값을
갖도록 하면서 자신만의 레벨을 정의할 때 중요하다. 같은 숫자 값으로 레벨을 정의하면, 사전에 정의된
값을 덮어쓰게 된다; 사전에 정의된 이름은 사라진다.

+--------------+---------------+
| 레벨          | 숫자 값      |
+==============+===============+
| ``CRITICAL`` | 50            |
+--------------+---------------+
| ``ERROR``    | 40            |
+--------------+---------------+
| ``WARNING``  | 30            |
+--------------+---------------+
| ``INFO``     | 20            |
+--------------+---------------+
| ``DEBUG``    | 10            |
+--------------+---------------+
| ``NOTSET``   | 0             |
+--------------+---------------+

레벨은 로거와 연관이 있으며, 개발자에 의해서나 저장된 로깅 설정을 로드해서 설정할 수 있다.
로깅 메서드가 로거에서 호출될 때, 로거는 자신의 레벨과 메서드 호출과 관련된 레벨을 비교한다. 로거의
레벨이 메서드 호출의 레벨보다 높으면 로깅 메세지는 실제로 발생되지 않는다. 이 기본 매커니즘이
로깅 출력의 복잡함을 제어하는 방식이다.

로깅 메세지는 :class:`~logging.LogRecord` 클래스의 인스턴스로 인코딩 된다.
로거가 실제로 이벤트를 로그하도록 결정했을 때, :class:`~logging.LogRecord` 인스턴스가
로깅 메세지로부터 생성된다.

로깅 메세지는 :class:`Handler` 클래스의 상속클래스 인스턴스인 :dfn:`handlers`\ 를 사용해
전송 매커니즘을 받는다. 핸들러는 로그된 메세지(:class:`LogRecord` 형태)를 메세지의 타겟
사용자들(엔드 유저, 지원 데스크 스태프, 시스템 관리자, 개발자)에게 유용한 특정한 위치(또는 위치 집합)에
확실이 도달하게 하는 책임을 지고 있다. 핸들러는 특정한 목적지로 향하는 :class:`LogRecord` 인스턴스를
전달 받는다. 각 로거는 (:class:`Logger` 메서드의 :meth:`~Logger.addHandler`\ 를 통해서)
0 개 이상의 연관된 핸들러를 가진다. 로거와 직접적으로 연관된 핸들러 외에 로거의 모든 조상과 연관된 핸들러도
메세지를 전송하기 위해 호출된다. (로거의 *propagate* 플래그가 false 값으로 설정되어 있으면
조상핸들러로 전달되는 것이 멈춘다.)

로거와 마찬가지로, 핸들러는 연관된 레벨이 있다. 핸들러의 레벨은 필터로서 로거의 레벨이 하는 것과 같은 방식으로
동작한다. 핸들러가 이벤트를 실제로 전달하기로 결정했다면, :meth:`~Handler.emit` 메서드가
목적지로 메세지를 보내기 위해 사용된다. 대부분의 사용자 정의 :class:`Handler` 상속 클래스는
:meth:`~Handler.emit`\ 을 오버라이드할 필요가 있다.

.. _custom-levels:

커스텀 레벨
^^^^^^^^^^^^^^^^^^^^^^

자신만의 레벨을 정의하는 것은 가능하지만 현재 레벨이 실제적인 경험을 기반으로 선택된 것이기 때문에
반드시 필요한 것은 아니다. 그러나 커스텀 레벨이 필요하다는 확신이 있으면 실행을 할 때 굉장히 주의를
기울여야 하며 *라이브러리를 개발하는 중이라면* 이는 굉장히 나쁜 아이디어라고 할 수 있다.
여러 라이브러리 제작자들이 각자 커스텀레벨을 정의하면 함께 사용되는 여러 라이브러리의 로깅 출력을
사용하는 개발자들이 통제하고 또는 해석하는 데 어려워질 수 있다. 왜냐하면 주어진 숫자 값이 다른
라이브러리에서 다른 의미를 가질 수 있기 때문이다.

.. _useful-handlers:

유용한 핸들러
--------------------

베이스 :class:`Handler` 클래스 외에, 많은 유용한 하위클래스들이 제공된다:

#. :class:`StreamHandler` 인스턴스는 스트림(파일 유형의 객체)에 메세지를 전송한다.

#. :class:`FileHandler` 인스턴스는 메세지를 디스크 파일에 전송한다.

#. :class:`~handlers.BaseRotatingHandler` 특정한 시점에서 로그파일을 회전시키는
   핸들러를 위한 베이스 클래스다. 직접 인스턴스화되지 않는다. 대신,
   :class:`~handlers.RotatingFileHandler` 또는
   :class:`~handlers.TimedRotatingFileHandler`\ 를 사용한다.

#. :class:`~handlers.RotatingFileHandler` 인스턴스는 최대 파일 사이즈 및
   로그 파일 회전에 대한 지원을 제공하면서 디스크 파일에 메세지를 전송한다.

#. :class:`~handlers.TimedRotatingFileHandler` 인스턴스는 특정 시간에
   로그 파일을 회전시키면서 디스크 파일에 메세지를 전송한다.

#. :class:`~handlers.SocketHandler` 인스턴스는 TCI/IP 소켓에 메세지를
   전송한다. 3.4 이후로 Unix 도메인 소켓도 지원된다.

#. :class:`~handlers.DatagramHandler` 인스턴스는 UDP 소켓에 메세지를 전송한다.
   3.4 이후로 Unix 도메인 소켓도 지원된다.

#. :class:`~handlers.SMTPHandler` 인스턴스는 지정된 이메일 주소로 메세지를 전송한다.

#. :class:`~handlers.SysLogHandler` 인스턴스는 원격 머신에 있을 수도 있는
   Unix syslog 데몬에 메제지를 전송한다.

#. :class:`~handlers.NTEventLogHandler` 인스턴스는 Windows NT/2000/XP 이벤트
   로그에 메세지를 전송한다.

#. :class:`~handlers.MemoryHandler` 인스턴스는 특정한 조건이 충족될 때마다
   플러시 되는 메모리에 있는 버퍼에 메세지를 전달한다.

#. :class:`~handlers.HTTPHandler` 인스턴스는 ``GET`` 또는 ``POST`` 시멘틱을 사용해서
   HTTP 서버에 메세지를 전송한다.

#. :class:`~handlers.WatchedFileHandler` 인스턴스는 로깅하는 파일을 관찰한다.
   파일이 변경되면 파일명을 이용해서 닫힌 다음 다시 열린다. 이 핸들러는 Unix 형 시스템에서만 유용하다;
   윈도우는 필요한 하부 메커니즘을 지원하지 않는다.

#. :class:`~handlers.QueueHandler` 인스턴스는 :mod:`queue` 또는 :mod:`multiprocessing` 같은
   모듈로 구현된 큐에 메세지를 전송한다.

#. :class:`NullHandler` 인스턴스는 에러 메세지에 대해서 아무것도 하지 않는다. 로깅은 원하지만 라이브러리
   사용자가 로깅을 구성하지 않을 때 표시되는 'No handlers could be found for logger XXX' 메세지를
   원하지 않는 라이브러리 개발자가 사용한다. 자세한 내용은 :ref:`library-config`\ 를 확인하라

.. versionadded:: 3.1
   :class:`NullHandler` 클래스

.. versionadded:: 3.2
   :class:`~handlers.QueueHandler` 클래스

:class:`NullHandler`, :class:`StreamHandler`, :class:`FileHandler`
클래스는 코어 로깅 패키지에서 정의된다. 다른 핸들러는 하위 모듈, :mod:`logging.handlers`\
에 정의되어 있다. (설정 기능을 위한 다른 하위 모듈, :mod:`logging.config`\ 도 있다.)

로그된 메세지는 :class:`Formatter` 클래스의 인스턴스를 통해 포매팅 된다.
인스턴스는 % 연산자와 딕셔너리 사용에 적합한 포맷 문자열로 초기화된다.

배치(batch)에서 여러 메세지를 포매팅하는 경우, :class:`~handlers.BufferingFormatter`
인스턴스가 사용될 수 있다. 포맷 문자열 (배치에서 각 메세지에 적용된다) 외에, 헤더와 트레일러 포맷 문자열에
관한 규정도 있다.

로거 레벨이나 헨들러 레벨에 기반한 필터링으로 충분하지 않을 떄,
:class:`Filter` 인스턴스를 :class:`Logger`\ 와 :class:`Handler` 인스턴스에
(:meth:`~Handler.addFilter` 메서드를 통해서) 추가할 수 있다.
추가적인 메세지 처리를 결정하기 전에 로거와 핸들러는 허가와 관련해 자신들의 모든 필터에
검사를 받는다. 만약 어떤 필터가 false 값을 반환하면 메세지는 더 처리되지 않는다.

기본 :class:`Filter` 기능은 특정한 로거 이름으로 필터링하는 것을 허용한다.
이 기능이 사용되면 메세지는 이름이 있는 로거에 전송되고 그 자식들은 필터에서 허용되고
나머지는 다 걸러진다.


.. _logging-exceptions:

로깅 중에 발생한 예외
--------------------------------

로깅 패키지는 로그 생산 중에 발생하는 예외는 삼켜버리게 디자인되어 있다.
로깅 이벤트를 다루는 중에 발생하는 에러는 - 로깅 설정 에러, 네트워크 또는 다른 유사한 에러 -
로깅을 사용하는 어플리케이션을 실행 중에 종료시키지 않는다.

:class:`SystemExit`\ 과 :class:`KeyboardInterrupt` 예외는 절대 삼켜지지 않는다.
:class:`Handler` 하위 클래스의 :meth:`~Handler.emit` 메서드 동작 중에 발생하는 다른 예외는
자신의 :meth:`~Handler.handleError` 메서드에 전달된다.

:class:`Handler`\ 의 :meth:`~Handler.handleError`\ 는 모듈 레벨 변수,
:data:`raiseExceptions`\ 가 설정되었는지를 확인하도록 구현되어 있다.
설정되어 있으면 역추적(traceback)이 :data:`sys.stderr`\ 에 출력된다.
설정되어 있지 않으면 예외는 삼켜진다.

.. note:: :data:`raiseExceptions`\ 의 디폴트 값은 ``True``\ 다.
   이는 개발 중에 일반적으로 예외가 발생하는 것을 알기 원하기 때문이다. 프로덕션 사용의 경우
   :data:`raiseExceptions`\ 을 ``False``\ 로 사용하는것을 권장한다.

.. currentmodule:: logging

.. _arbitrary-object-messages:

메세지로 임의(arbitrary) 객체 사용하기
------------------------------------------------------

앞선 섹션과 예제에서 로깅 이벤트가 문자열일 때 메세지가 전달된다고 가정했다.
그러나, 그런 가능성만 있는 것은 아니다. 임의 객체를 메세지로 전달하고, 로깅 시스템이 문자열 표현으로
변경할 필요가 있을 때 :meth:`~object.__str__` 메서드가 호출되게 할 수 있다.
사실, 원한다면 문자열 표현 연산을 완전히 하지 않을 수 있다. - 예를 들어
:class:`~handlers.SocketHandler`\ 은 메세지를 피클화 하고 전선을 통해 전송하는 방식으로
이벤트를 내보낸다.


최적화
------------

메세지 인수의 포매팅은 피할 수 없을 때까지 연기된다.
그러나 로깅 메서드에 전달된 인수를 연산하는 것은 마찬가지로 비용이 많이 들고, 로거가 단순히
이벤트를 버릴 거라면 이런 동작을 피하고 싶을 것이다. 무엇을 연산할지 결정하도록 레벨 인수를 받고
해당 레벨의 호출에 대한 로거에 의해 이벤트가 생성되었으면 true를 반환하는
:meth:`~Logger.isEnabledFor` 메서드를 호출할 수 있다. 아래처럼 코드를
작성하면 된다::

    if logger.isEnabledFor(logging.DEBUG):
        logger.debug('Message with %s, %s', expensive_func1(),
                                            expensive_func2())

로거의 상한선이 ``DEBUG`` 위로 설정되면, :func:`expensive_func1`\ 와
:func:`expensive_func2`\ 에 대한 호출은 이루어지지 않는다.

.. note:: 어떤 경우에는 원하는 것보다 :meth:`~Logger.isEnabledFor`\ 이 자신을 더 비용이 높게
   만들어 버릴 수 있다. (예, 명시적 레벨이 로거 계층에서 높게 설정된 깊게 중첩된 로거).
   이러한 경우 (또는 타이트한 루프에서 메서드 호출을 피하고 싶은 경우)
   로컬이나 인스턴스 변수에서 :meth:`~Logger.isEnabledFor`\ 에 대한 호출의 결과를 캐슁하고,
   매번마다 메서드를 호출하는 대신 사용하게 할 수 있다. 캐슁된 값은 어플리케이션이 실행 중인 동안
   동적으로 로깅 설정이 변경됐을 때만 (일반적이지는 않다) 재연산된다.

어떤 로깅 정보가 수집되어야 하는지에 대해 더 정밀한 제어가 필요한 특정 어플리케이션에서 쓸 수 있는
다른 최적화도 있다. 아래는 필요 없는 로깅 중의 처리를 피할 수 있는 몇 가지 방법에 대한 리스트다:

+-----------------------------------------------+----------------------------------------+
| 수집하고 싶지 않은 것                         | 수집을 피하는 방법                     |
+===============================================+========================================+
| 호출이 이루어진 곳에 대한 정보.               | ``logging._srcfile``\ 을 ``None``\ 으로|
|                                               | 설정.                                  |
|                                               | PyPy가 파이썬 3.x를 지원하면           |
|                                               | :func:`sys._getframe` 호출을 피해서    |
|                                               | PyPy 같은 (:func:`sys._getframe`\ 를   |
|                                               | 사용하는 코드의 속도를 높일 수 없는)   |
|                                               | 환경에서 코드의 속도를 높여준다.       |
+-----------------------------------------------+----------------------------------------+
| 쓰레딩 정보.                                  | ``logging.logThreads``\ 를 ``0``\ 으로 |
|                                               | 설정.                                  |
+-----------------------------------------------+----------------------------------------+
| 프로세스 정보.                                | ``logging.logProcesses``\ 를           |
|                                               | ``0``\ 으로 설정.                      |
+-----------------------------------------------+----------------------------------------+

또한 코어 로깅 모듈은 기본 핸들러만 포함하고 있다는 점을 명심하라.
:mod:`logging.handlers`\ 과 :mod:`logging.config`\ 를 호출하지 않으면, 이들은
메모리를 차지하지 않을 것이다.

.. seealso::

   모듈 :mod:`logging`
      로깅 모듈에 대한 API 레퍼런스.

   모듈 :mod:`logging.config`
      로깅 모듈에 대한 설정 API.

   모듈 :mod:`logging.handlers`
      로깅 모듈에 포함된 유용한 핸들러.

   :ref:`A logging cookbook <logging-cookbook>`
