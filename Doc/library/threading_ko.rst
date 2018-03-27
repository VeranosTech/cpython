:mod:`threading` --- 스레드 기반 병렬 처리
=============================================

.. module:: threading
   :synopsis: Thread-based parallelism.

**소스 코드:** :source:`Lib/threading.py`

--------------

이 모듈은 하위 레벨 :mod:`_thread` 모듈의 상단에서 상위 레벨 스레딩 인터페이스를 구현한다.
:mod:`queue` 모듈을 참고한다.

.. versionchanged:: 3.7
   이 모듈은 선택적으로 사용되었지만 이제 항상 사용가능하다.

.. note::

   아래 목록에는 없지만 파이썬2 시리즈에서 이 모듈의 몇몇 함수와 메서드에 사용되던 ``카멜 표기법은`` 지금도 지원된다.


이 모듈은 다음 함수를 정의한다.


.. function:: active_count()

   현재 활성화된 :class:`Thread` 객체수를 반환한다.
   반환값은 :func:`.enumerate` 함수로 반환되는 리스트의 길이와 동일하다.


.. function:: current_thread()

   호출기의 제어 스레드에 대응하는 현재 :class:`Thread` 객체를 반환한다.
   호출기의 제어 스레드가 :mod:`threading` 모듈을 통해 생성되지 않았다면 제한된 기능을 갖는 더미 스레드 객체를 반환한다.


.. function:: get_ident()

   현재 스레드의 스레드 식별자를 반환한다. 반환값은 0이 아닌 정수다.
   값 자체로 갖는 의미는 없지만 스레드 특정 데이터 딕셔너리의 인덱스와 같이 매직 쿠키로 사용하기 위해 고안되었다.
   스레드 식별자는 스레드를 종료하고 다른 스레드가 생성될 때 재사용될 수 있다.

   .. versionadded:: 3.3


.. function:: enumerate()

   현재 활성화된 모든 :class:`Thread` 객체 리스트를 반환한다.
   리스트는 :func:`current_thread` 함수로 생성된 데몬 스레드, 더미 스레드 객체와 메인 스레드를 포함한다.
   종료된 스레드와 아직 시작되지 않은 스레드는 제외한다.


.. function:: main_thread()

   메인 :class:`Thread` 객체를 반환한다.
   일반적인 상황에서 파이썬 인터프리터가 시작되는 스레드가 메인 스레드가 된다.

   .. versionadded:: 3.4


.. function:: settrace(func)

   .. index:: single: trace function

   :mod:`threading` 모듈로부터 시작된 모든 스레드를 위한 트레이스 함수를 설정한다.
   각 스레드의 :meth:`~Thread.run` 메서드가 호출되기 전에 settrace 함수가 :func:`sys.setprofile`\ 로 보내진다.


.. function:: setprofile(func)

   .. index:: single: profile function

   :mod:`threading` 모듈에서 시작되는 모든 스레드의 프로파일 함수를 설정한다.
   각 스레드의 :meth:`~Thread.run` 메서드가 호출되기 전에 setprofile 함수가 :func:`sys.setprofile`\ 로 보내진다.


.. function:: stack_size([size])

   새로운 스레드를 생성할 때 사용되는 스레드 스택 사이즈를 반환한다.
   선택 인수 *size*는 이후에 생성될 스레드를 위해 사용될 스택 사이즈를 지정한다.
   이 인수는 반드시 0이나 32,768(32KiB) 이상의 양의 정수가 되어야 한다.
   값을 지정하지 않거나 0으로 지정하면 플랫폼 기본값 또는 설정된 기본값을 사용한다.
   스레드 스택 사이즈 변경을 지원하지 않는 경우 :exc:`RuntimeError`\ 가 발생한다.
   유효하지 않은 스택 사이즈를 지정하면 :exc:`ValueError`\ 가 발생하고 스택 사이즈를 수정하지 않는다.
   지원하는 가장 작은 스택 사이즈가 32KiB인 이유는 인터프리터 자체의 스택 공간을 충분히 확보하기 위함이다.
   몇몇 플랫폼에서는 최소 스택 사이즈가 32KiB를 넘어야 하거나 시스템 메모리 페이지 사이즈의 배수를 할당해야 하는 등
   스택 사이즈 값에 특정한 제한이 있을 수 있다. 관련 사항은 플랫폼 문서를 참고한다.
   (일반적인 페이지 사이즈는 4 KiB다. 자세한 정보가 없을 때는 4096의 배수를 스택 사이즈로 사용하는 것을 제안한다.)
   가용성: 윈도우, POSIX 스레드를 사용하는 시스템.


이 모듈은 다음 상수를 정의한다.

.. data:: TIMEOUT_MAX

   함수를 블럭하는 *timeout* 매개 변수에 허용되는 최대값.
   (:meth:`Lock.acquire`, :meth:`RLock.acquire`, :meth:`Condition.wait`, etc.).
   이 값보다 큰 *timeout*을 사용하면 :exc:`OverflowError`\ 가 발생한다.

   .. versionadded:: 3.2


이 모듈은 다수의 클래스를 정의한다. 아래 섹션에서 이 클래스들을 설명한다.

이 모듈의 디자인은 자바의 스레딩 모델을 기반으로 한다.
그러나 자바는 모든 객체의 락과 컨디션 변수 기본 동작을 한 곳에서 수행하지만 파이썬은 개별 객체에서 수행한다.
파이썬의 :class:`Thread` 클래스는 자바의 Thread 클래스 동작 중 일부를 지원한다.
현재는 우선 순위, 스레드 그룹을 사용할 수 없고 스레드를 파괴, 정지, 연기, 재개, 중단할 수 없다.
자바 Thread 클래스의 정적 메서드는 파이썬의 모듈 레벨 함수로 매핑해 구현한다.

아래에서 다루는 모든 메서드는 개별적으로 실행된다.


스레드 로컬 데이터
-----------------

스레드 로컬 데이터는 그 값이 스레드 특정인 데이터를 말한다.
스레드 로컬 데이터를 관리하려면 :class:`local`(또는 서브클래스)의 인스턴스를 생성하고
이 곳에 인수를 저장한다. ::

  mydata = threading.local()
  mydata.x = 1

인스턴스의 값은 스레드마다 다르다.


.. class:: local()

   스레드 로컬 데이터를 나타내는 클래스.

   자세한 정보와 확장된 예시는 :mod:`_threading_local` 모듈 문서를 본다.


.. _thread-objects:

스레드 객체
--------------

:class:`Thread` 클래스는 개별적인 제어 스레드에서 실행되는 활동을 나타낸다.
활동을 지정하는 방법에는 두가지가 있다. 호출 가능 객체를 생성자에 보내거나
서브클래스에서 :meth:`~Thread.run`\ 을 덮어쓴다.
생성자를 제외한 다른 메서드는 서브클래스에 덮어 쓰여야 한다.
다시 말해 이 클래스의 :meth:`~Thread.__init__`\ 과 :meth:`~Thread.run` 메서드만을 덮어쓴다.

스레드 객체가 생성되면 객체의 활동은 반드시 스레드의 :meth:`~Thread.start` 메서드를 호출함으로써 시작되어야 한다.
이를 통해 별개의 제어 스레드의 :meth:`~Thread.run` 메서드를 불러온다.

스레드의 활동이 시작되면 스레드는 활성화된 것으로 취급되고 :meth:`~Thread.run` 메서드가 종료될 때 비활성화된다.
:meth:`~Thread.run` 메서드의 종료란 일반적인 종료 또는 처리할 수 없는 예외가 발생했을 때를 말한다.
:meth:`~Thread.is_alive` 메서드로 스레드가 활성화되어 있는지 테스트한다.

다른 스레드가 어떤 스레드의 :meth:`~Thread.join` 메서드를 호출할 수 있다.
이 메서드를 호출한 스레드는 메서드가 호출된 스레드가 종료될 때까지 블럭된다.

스레드는 이름을 갖는다. 이 이름은 생성자로 보내지고 :attr:`~Thread.name` 인수를 통해 읽혀지거나 변경될 수 있다.

스레드는 데몬 스레드로 표시될 수 있다. 데몬 스레드만 남았을 때 전체 파이썬 프로그램이 종료된다.
초기값은 생성 스레드로부터 상속된다. :attr:`~Thread.daemon` 속성 또는 *daemon* 생성자 인수를 통해 설정할 수 있다.

.. note::
   데몬 스레드는 프로그램 종료시에 바로 중지된다. 열린 파일, 데이터베이스 트랜잭션 등 데몬 스레드의 리소스가
   제대로 릴리즈되지 않을 수 있다. 스레드가 문제없이 종료되길 원한다면 데몬 스레드로 만들지 않고
   :class:`Event`\ 와 같은 적절한 시그널 방법을 사용한다.

메인 스레드 객체란 파이썬 프로그램의 초기 제어 스레드로 생각할 수 있다. 이 스레드는 데몬 스레드가 아니다.

더미 스레드 객체가 생성될 수 있다. 이 스레드 객체는 외부 스레드로 생각할 수 있다.
외부 스레드란 C 코드와 같이 스레딩 모듈 바깥에서 시작된 제어 스레드를 말한다.
더미 스레드 객체는 제한된 기능을 갖는다. 이 객체는 항상 활성화되어 있거나 데몬 스레드인 것처럼 취급된다.
:meth:`~Thread.join` 메서드도 사용할 수 없다. 외부 스레드의 종료를 감지할 수 없기 때문에 삭제할 수도 없다.


.. class:: Thread(group=None, target=None, name=None, args=(), kwargs={}, *, \
                  daemon=None)

   이 생성자는 항상 키워드 인수와 함께 호출되어야 한다. 인수는 다음과 같다.

   *group*: ``None`` 값이 되어야 한다. :class:`ThreadGroup` 클래스가 실행될 때 확장을 위해 예약되어 있다.

   *target*: :meth:`run` 메서드로 불러지는 호출가능 객체다. 기본은 ``None``\ 으로 아무것도 호출되지 않는다.

   *name*: 스레드 이름이다. 기본으로 "Thread-*N*" 형태의 고유한 이름이 사용된다. *N*은 작은 십진법 수다.

   *args*: 대상 호출을 위한 인수 튜플이다. 기본은 ``()``\ 다.

   *kwargs*: 대상 호출을 위한 키워드 인수 딕셔너리다. 기본은 ``{}``\ 다.

   *daemon*: ``None``\ 이 아니면 이 인수는 스레드가 데몬인지를 명시적으로 설정한다. 기본값 ``None``\ 이면 현재 스레드로부터 데몬 속성을 상속받는다.

   서브 클래스가 생성자를 덮어쓰면 스레드에 무언가 작업하기 전에 반드시 기본 클래스 생성자를 ``Thread.__init__()``\ 를 불러와야 한다.

   .. versionchanged:: 3.3
      *daemon* 인수 추가.

   .. method:: start()

      스레드의 활동을 시작한다.

      반드시 스레드 객체마다 한번씩 호출되어야 한다. 개별 제어 스레드에서 불러질 객체의 :meth:`~Thread.run` 메서드를 배열한다.

      동일한 스레드 객체에서 이 메서드가 두번 이상 불러지면 :exc:`RuntimeError`\ 가 발생한다.

   .. method:: run()

      스레드의 활동을 나타내는 메서드.

      하위 클래스에서 이 메서드를 덮어쓸 수 있다. 표준이 되는 :meth:`run` 메서드는 타겟 인수로
      객체의 생성자로 보내진 호출 가능 객체를 부른다.
      *args*, *kwargs* 인수로부터 추가 인수와 키워드 인수가 존재하면 함께 호출한다.

   .. method:: join(timeout=None)

      스레드가 종료될 때까지 기다린다. 이 메서드는 :meth:`~Thread.join`\ 가 호출된 스레드가 종료되거나
      선택으로 사용된 제한 시간을 초과할 때까지 다른 호출 스레드를 블럭한다. 처리할 수 없는 예외의 발생도 스레드 종료에 해댕한다.

      *timeout* 인수가 존재하고 ``None``\ 이 아니면 그 값은 초단위로 연산의 제한 시간을 지정하는 부동 소수점이 되어야 한다.
      :meth:`~Thread.join` 메서드는 항상 ``None``\ 을 반환하기 때문에 제한 시간이 적용되었는지 확인하려면
      :meth:`~Thread.join` 이후에 :meth:`~Thread.is_alive`\ 를 호출해야 한다.
      스레드가 아직 살아있으면 :meth:`~Thread.join` 호출 시간이 초과된 것이다.

      *timeout* 인수가 존재하지 않거나 그 값이 ``None``\ 이면 연산은 스레드가 종료될 때까지 블럭한다.

      스레드는 :meth:`~Thread.join`\ 을 여러번 사용할 수 있다.

      현재 스레드에 연결하려는 시도가 데드락을 발생시킬 수 있으면
      :meth:`~Thread.join`\ 은 :exc:`RuntimeError`\ 를 발생시킨다.
      스레드가 시작되기 전에 연결하려는 시도 또한 에러에 해당하며 같은 예외가 발생한다.

   .. attribute:: name

      스레드 식별 목적으로만 사용되는 문자열로 의미는 없다. 다수의 스레드가 같은 이름을 가질 수 있다. 초기값은 생성자의 의해 설정된다.

   .. method:: getName()
               setName()

      :attr:`~Thread.name`\ 의 이전 API. 속성으로 바로 사용한다.

   .. attribute:: ident

      스레드의 스레드 식별자다. 스레드가 시작되지 않았으면 ``None`` 값이 된다.
      0이 정수값을 갖는다. :func:`get_ident` 함수를 본다.
      스레드 식별자는 스레드가 종료되거나 다른 스레드가 생성되었을 때 재사용될 수 있다.
      식별자는 스레드가 종료된 후에도 유효하다.

   .. method:: is_alive()

      스레드가 활성화되어 있는지를 알려준다.

      :meth:`~Thread.run` 메서드가 시작되기 직전부터 종료된 직후까지 이 메서드는 ``True``\ 를 반환한다.
      모듈 함수 :func:`.enumerate`\ 는 활성화된 모든 스레드의 리스트를 반환한다.

   .. attribute:: daemon

      부올리언값을 반환해 스레드가 데몬 스레드인지 알려준다. 데몬 스레드면 ``True``\ 를 반환한다.
      반드시 :meth:`~Thread.start`\ 가 호출되기 전에 설정되어야 하고 아니면 :exc:`RuntimeError`\ 가 발생한다.
      초기값은 생성 스레드로부터 상속 받는다. 메인 스레드는 데몬 스레드가 아니기 때문에 메인 스레드에서 생성된 스레드는 기본으로
      :attr:`~Thread.daemon` = ``False``\ 가 된다.

      활성화된 스레드에 데몬 스레드만 남게 되면 전체 파이썬 프로그램이 종료된다.

   .. method:: isDaemon()
               setDaemon()

      :attr:`~Thread.daemon`\ 의 이전 API. 속성으로 바로 사용한다.


.. impl-detail::

   CPython에서 :term:`Global Interpreter Lock`\ 으로 인해 한번에 하나의 스레드만 파이썬 코드를 실행할 수 있다.
   (몇몇 성능 지향 라이브러리는 해당되지 않는다.)
   멀티 코어 머신에서 컴퓨터 자원을 더 효율적으로 사용하고 싶다면 :mod:`multiprocessing`\ 이나
   :class:`concurrent.futures.ProcessPoolExecutor`\ 를 사용한다.
   그러나 다수의 IO 바운드 작업을 동시에 해야 한다면 스레딩이 적절한 모델이다.


.. _lock-objects:

락 객체
------------

기본 락(lock)은 동기화의 기본 요소로 락되었을 때 특정 스레드에 의해 소유되지 않는다.
파이썬에서 사용 가능한 가장 낮은 레벨의 동기화 기본 요소로 :mod:`_thread` 확장 모듈에 의해 직접 구현된다.

기본 락은 "locked", "unlocked" 두가지 상태 중 하나가 된다.
잠금 해제 상태에서 생성되고 두개의 기본 메서드 :meth:`~Lock.acquire`, :meth:`~Lock.release`\ 를 갖는다.
잠금 해제 상태면 :meth:`~Lock.acquire` 메서드가 상태를 잠금으로 바꾸고 바로 반환한다.
잠금 상태에서 :meth:`~Lock.acquire` 메서드는 다른 스레드가 :meth:`~Lock.release`\ 를 호출해
잠금 해제될 때까지 블럭된다. 잠금 해제되면 :meth:`~Lock.acquire` 호출로 상태는 다시 잠금이 되고 바로 반환된다.
:meth:`~Lock.release` 메서드는 잠금 상태에서만 호출되어야 한다. 이 메서드는 상태를 잠금 해제로 바꾸고 바로 반환한다.
잠금 해제 상태를 해제하려고 하면 :exc:`RuntimeError`\ 가 발생한다.

락은 :ref:`context management protocol <with-locks>`\ 를 지원한다.

여러 스레드가 :meth:`~Lock.acquire`\ 에 블럭되어 잠금 해제를 기다릴 때 잠금이 해제되면 하나의 스레드만이 진행된다.
이 때 진행되는 스레드는 정의되어 있지 않으며 구현에 따라 다르게 나타난다.

모든 메서드는 자동으로 실행된다.

.. class:: Lock()

   이 클래스는 기본 락 객체를 구현한다. 스레드가 락을 얻으면 이후의 락을 얻으려는 시도는 락이 해제될 때까지 블럭된다.
   어떤 스레드도 락을 해제할 수 있다.

   실제로 ``Lock``\ 은 플랫폼이 지원하는 가장 효율적인 형태의 콘크리트 락 인스턴스를 반환하는 팩토리 함수임을 알아두자.


   .. method:: acquire(blocking=True, timeout=-1)

      락을 얻고 블럭하거나 하지 않는다.

      *blocking* 인수가 기본값인 ``True``\ 로 설정된 채로 불러지면
      락이 해제될 때까지 블럭한다. 그리고 락을 한 후에 ``True``\ 를 반환한다.

      *blocking* 인수가 ``False``\ 로 설정된 채로 호출되면 블럭하지 않는다.
      *blocking*이 ``True``\ 로 설정된 호출은 블럭하고 바로 ``False``\ 를 반환한다.
      그렇지 않으면 락을 잠그고 ``True``\ 를 반환한다.

      부동 소수점 *timeout* 인수가 양의 값으로 설정된 채로 호출되면 *timeout*에 명시된
      초단위 시간 동안 블럭하고 락을 얻을 수 없다. *timeout*이 ``-1``\ 로 설정되면
      시간 제한없이 기다린다. *blocking*이 ``False``\ 면 *timeout*을 사용할 수 없다.

      락을 성공적으로 획득하면 ``True``\ 를 반환한다. *timeout*을 초과한 경우와 같이 락을 얻을 수 없으면 ``False``\ 를 반환한다.

      .. versionchanged:: 3.2
         *timeout* 매개 변수 추가.

      .. versionchanged:: 3.2
         POSIX 시그널로 락 획득이 중단될 수 있다..


   .. method:: release()

      락을 해제한다. 락을 획득한 스레드 뿐 아니라 스레드도 호출할 수 있다.

      락이 잠금되어 있으면 이를 해제하고 반환한다. 락의 해제를 기다리는 스레드들이 있다면 이 중 하나만 진행을 허용한다.

      잠금 해제된 락에 대해 호출되면 :exc:`RuntimeError`\ 가 발생한다.

      반환값은 없다.


.. _rlock-objects:

재진입 락 객체
-------------

재진입 락(RLock)은 동기화 기본 요소로 같은 스레드에 의해 여러번 획득될 수 있다.
내부적으로 재진입 락은 기본 락이 사용하는 잠금, 해제 상태에 더해 "소유 스레드"와 "반복 레벨" 개념을 사용한다.
잠금된 상태에서 어떤 스레드가 락을 소유한다. 해제된 상태면 어떤 스레드도 잠금을 소유하지 않는다.

락을 잠그기 위해 스레드는 자신의 :meth:`~RLock.acquire` 메서드를 호출한다.
이 메서드는 스레드가 잠금을 소유할 때 반환한다. 잠금을 해제하려면 스레드는 자신의 :meth:`~Lock.release` 메서드를 호출한다.
:meth:`~Lock.acquire`/:meth:`~Lock.release` 호출 쌍은 중첩될 수 있고 마지막(가장 바깥의 호출 쌍)
:meth:`~Lock.release` 메서드만이 락을 해제하고 :meth:`~Lock.acquire`\ 에 블럭된 다른 스레드가 진행하도록 허용한다.

재진입 락은 :ref:`context management protocol <with-locks>`\ 을 지원한다.


.. class:: RLock()

   이 클래스는 재진입 락 객체를 구현한다. 재진입 락은 반드시 이 락을 획득한 스레드에 의해 해제되어야 한다.
   스레드가 재진입 락을 획득하면 이 스레드는 블럭되지 않고 락을 다시 획득할 수 있다.
   스레드는 락을 얻을 때마다 락을 해제해야 한다.

   실제로 ``RLock``\ 은 플랫폼이 지원하는 가장 효율적인 형태의 콘크리트 재진입 락 인스턴스를 반환하는 팩토리 함수임을 알아두자.


   .. method:: acquire(blocking=True, timeout=-1)

      락을 얻고 블럭하거나 블럭하지 않는다.

      인수 없이 호출되었을 때 이 스레드가 이미 락을 소유하고 있다면 반복 레벨을 하나 올리고 바로 반환한다.
      만약 다른 스레드가 락을 소유하고 있으면 락이 해제될 때까지 블럭된다.
      락이 해제되고 다른 스레드가 소유하지 않으면 소유권을 갖고 반복 레벨을 하나 올린 후 반환한다.
      락이 해제되길 기다리는 스레드가 여러개일 때는 하나의 스레드만이 락의 소유권을 가질 수 있다.
      이 경우에 반환값은 없다.

      *blocking* 인수가 ``True``\ 로 설정된 채로 호출되면 *blocking* 인수가 없을 때와
      같은 일을 하고 ``True``\ 를 반환한다.

      *blocking* 인수가 ``False``\ 면 블럭하지 않는다.
      *blocking* 인수가 없는 호출이 블럭되면 바로 ``False``\ 를 반환한다.
      그렇지 않으면 이 인수가 없이 호출했을 때와 같은 일을 하고 ``True``\ 를 반환한다.

      부동 소수점 *timeout* 인수가 양의 값으로 설정된 채로 호출되면 *timeout*에 명시된 초단위 시간 동안 블럭하고 락을 얻을 수 없다.
      락을 얻으면 ``True``\ 를 반환하고 제한 시간이 지나면 ``False``\ 를 반환한다.

      .. versionchanged:: 3.2
         *timeout* 매개 변수 추가.


   .. method:: release()

      락을 해제하고 반복 레벨을 낮춘다. 레벨을 낮춘 후 그 값이 0이면 락의 상태를 해제로 재설정한다.
      (다른 스레드에 소유되지 않는다.) 락이 해제될 때까지 기다리는 스레드가 있으면 이 중 하나의 진행을 허용한다.
      레벨을 낮춘 후에 그 값이 0이 아니면 락은 남아있고 이를 호출한 스레드가 여전히 락을 소유한다.

      이 메서드를 호출하는 스레드는 락을 소유하고 있어야 한다.
      락이 잠겨있지 않은 경우에 이 메서드를 호출하면 :exc:`RuntimeError`\ 가 발생한다.

      이 메서드의 반환값은 없다.


.. _condition-objects:

컨디션 객체
-----------------

컨디션 변수는 항상 어떤 종류의 락과 관련된다. 이 변수는 전달받거나 기본으로 생성될 수 있다.
여러 컨디션 변수가 같은 락을 공유해야 할 때는 변수를 보내는 것이 좋다.
락은 컨디션 객체의 일부이므로 따로 추적하지 않아도 된다.

컨디션 변수는 :ref:`context management protocol <with-locks>`\ 을 따른다.
``with`` 선언을 사용해 닫힌 블럭이 지속되는 동안 관련된 락을 얻는다.
:meth:`~Condition.acquire`, :meth:`~Condition.release` 메서드는 관련된 락에 맞는 메서드를 가져온다.

다른 메서드는 연관된 락을 가지고 호출되어야 한다. :meth:`~Condition.wait` 메서드는 락을 해제하고
다른 스레드가 :meth:`~Condition.notify`\ 나 :meth:`~Condition.notify_all`\ 를 호출해 이를 깨울 때까지 블럭한다.
깨어나면 :meth:`~Condition.wait` 메서드는 락을 다시 획득하고 반환한다. 제한 시간을 지정할 수 있다.

:meth:`~Condition.notify` 메서드는 컨디션 변수를 기다리고 있는 스레드가 있으면 그 중 하나를 깨운다.
:meth:`~Condition.notify_all` 메서드는 컨디션 변수를 기다리는 모든 스레드를 깨운다.

주의: :meth:`~Condition.notify`\ 와 :meth:`~Condition.notify_all` 메서드는
락을 해제하지 않는다. 이는 스레드나 깨워진 스레드가 :meth:`~Condition.wait`\ 로부터 바로 반환하지 않고
:meth:`~Condition.notify`\ 나 :meth:`~Condition.notify_all`\ 를 호출한 스레드가
락의 소유권을 넘겼을 때 반환한다는 의미다.

컨디션 변수를 사용하는 일반적인 프로그래밍 방법은 락을 어떤 공유 상태로의 접근을 동기화 하기 위해 사용한다.
특정 상태 변화에 관심을 두는 스레드는 원하는 상태가 될 때까지 :meth:`~Condition.wait` 메서드를 반복적으로 호출한다.
이 때 상태를 변경하는 스레드는 다른 대기 스레드가 원할 만한 상태로 상태를 변화시켰을 때
:meth:`~Condition.notify`\ 나 :meth:`~Condition.notify_all`\ 를 호출한다.
예를 들어, 다음 코드는 버퍼 용량에 제한이 없는 일반적인 생산자-소비자 환경이다. ::

   # Consume one item
   with cv:
       while not an_item_is_available():
           cv.wait()
       get_an_available_item()

   # Produce one item
   with cv:
       make_an_item_available()
       cv.notify()

:meth:`~Condition.wait`\ 가 임의의 긴 시간이 지난후에 반환을 할 수 있고
이 때 :meth:`~Condition.notify` 호출을 요청한 컨디션이 더 이상 ``True``\ 가 아닐 수 있다.
따라서 어플리케이션의 컨디션을 확인하는 ``while`` 반복은 중요하다.
이는 멀티 스레드 프로그래밍에서 필수적이다. :meth:`~Condition.wait_for` 메서드를 사용해
컨디션 확인을 자동화하고 제한 시간 계산을 간편하게 할 수 있다. ::

   # Consume an item
   with cv:
       cv.wait_for(an_item_is_available)
       get_an_available_item()

하나의 상태 변화가 하나의 대기 스레드와 관련이 있는지 아니면 다수의 대기 스레드와 관련이 있는지에 따라
:meth:`~Condition.notify`\ 와 :meth:`~Condition.notify_all` 메서드를 선택한다.
예를 들어, 일반적인 생산자-소비자 환경에서 하나의 아이템을 버퍼에 추가하면 하나의 소비자 스레드만 깨우면 된다.


.. class:: Condition(lock=None)

   이 클래스는 컨디션 변수 객체를 구현한다.
   컨디션 변수는 하나 이상의 스레드가 다른 스레드의 알림을 받을 때까지 대기할 수 있게 한다.

   *lock* 인수가 주어지고 ``None``\ 이 아니면 :class:`Lock` 또는 :class:`RLock` 객체가 되어야 한다.
   이 객체는 밑단의 락으로 사용된다. 아닌 경우에 새로운 :class:`RLock` 객체가 생성되고 밑단의 락으로 사용된다.

   .. versionchanged:: 3.3
      팩토리 함수에서 클래스로 변경.

   .. method:: acquire(*args)

      밑단의 락을 얻는다. 이 메서드는 밑단의 락에 맞는 메서드를 호출한다. 반환값은 호출한 메서드의 반환값이 된다.

   .. method:: release()

      밑단의 락을 해제한다. 이 메서드는 밑단의 락에 맞는 메서드를 호출한다. 반환값은 없다.

   .. method:: wait(timeout=None)

      알림을 받거나 제한시간이 초과될 때까지 대기한다. 이 메서드가 호출될 때 이를
      호출하는 객체가 락을 얻지 못하면 :exc:`RuntimeError`\ 가 발생한다.

      이 메서드는 밑단의 락을 해제하고 같은 다른 스레드에서 같은 컨디션 변수의
      :meth:`notify` 또는 :meth:`notify_all` 호출로 깨어나거나 선택 제한 시간이
      초과될 때까지 블럭한다. 깨어나거나 제한 시간이 초과되면 락을 다시 획득하고 반환한다.

      *timeout* 인수가 존재하고 그 값이 ``None``\ 이 아니면 초단위로 작업 시간을 지정하는 부동소수점 값이 되어야 한다.

      밑단의 락이 :class:`RLock`\ 이면 :meth:`release` 메서드로 해제되지 않는다.
      락이 반복적으로 여러번 획득된 경우에는 실제로 잠금이 해제되지 않기 때문이다.
      대신 여러번 잠금이 획득되었어도 잠금을 해제하는 :class:`RLock` 클래스의 내부 인터페이스가 사용된다.
      다른 내부 인터페이스가 락을 다시 획득했을 때 반복 레벨을 회복하기 위해 사용된다.

      주어진 제한 시간을 초과하지 않는 한 반환값은 ``True``\ 다. 제한 시간이 초과되면 ``False``\ 를 반환한다.

      .. versionchanged:: 3.2
         이전에는 메서드는 항상 ``None``\ 을 반환했다.

   .. method:: wait_for(predicate, timeout=None)

      컨디션이 ``True``\ 로 확인될 때까지 대기한다.
      *predicate*는 결과가 부올리언 값으로 해석되는 호출 가능 객체가 되어야 한다.
      *timeout*으로 대기 제한 시간을 줄 수 있다.

      이 유틸리티 메서드는 *predicate*가 만족되거나 제한 시간이 초과될 때까지
      :meth:`wait` 메서드를 반복적으로 호출할 수 있다.
      반환값은 *predicate*의 마지막 반환값으로 메서드가 제한 시간을 초과하면 ``False``\ 가 된다.

      제한 시간 기능을 제외하면 이 메서드를 호출하는 것은 대략 다음과 같다. ::

        while not predicate():
            cv.wait()

      따라서 :meth:`wait`\ 에서와 같은 규칙이 적용된다.
      호출했을 때 락은 반드시 잠겨있어야 하고 반환 시에 다시 획득된다.
      *predicate*는 락이 되어 있는 것으로 취급된다.

      .. versionadded:: 3.2

   .. method:: notify(n=1)

      기본으로 이 컨디션을 기다리는 스레드가 있다면 하나를 깨운다.
      이 메서드가 호출될 때 호출하는 스레드가 락을 획득하지 못하면 :exc:`RuntimeError`\ 가 발생한다.

      이 메서드는 최대 *n*개의 컨디션 변수를 기다리는 스레드를 깨운다.
      기다리는 스레드가 없다면 아무 작업을 하지 않는다.

      현재 구현된 메서드는 최소한 *n*개 이상의 스레드가 대기중일 때 정확히 *n*개의 스레드를 개운다.
      그러나 이러한 방식에 의존하는 것은 안전하지 않다.
      미래에는 최적화된 구현으로 상황에 따라 *n*개 이상의 스레드를 깨울 수도 있다.

      주의: 깨어난 스레드는 실제로는 락을 다시 획득할 때까지 :meth:`wait`\ 호출로 반환하지 않는다.
      :meth:`notify`\ 가 락을 해제하지 않기 때문에 이 메서드의 호출기가 락을 해제해야 한다.

   .. method:: notify_all()

      이 컨디션을 기다리고 있는 모든 스레드를 깨운다.
      이 메서드는 :meth:`notify`\ 처럼 같이 작동하지만 하나가 아닌 모든 스레드를 깨운다.
      메서드가 호출되었을 때 스레드 호출이 락을 얻지 못했다면 :exc:`RuntimeError`\ 가 발생한다.


.. _semaphore-objects:

세마포어 객체
-----------------

세마포어는 컴퓨터 과학 역사의 가장 오래된 동기화 기본 요소로 네덜란드의 컴퓨터 과학자 에츠허르 데이크스트라가 고안했다.
(:meth:`~Semaphore.acquire`, :meth:`~Semaphore.release` 대신 ``P()``\ 와 ``V()``\ 를 사용한다.

세마포어는 :meth:`~Semaphore.acquire` 호출로 감소하고 :meth:`~Semaphore.release`\ 로 증가하는 내부 카운터를 관리한다.
카운터 값은 0 아래로 내려갈 수 없다. :meth:`~Semaphore.acquire`\ 가 값이 0임을 감지하면
다른 스레드가 :meth:`~Semaphore.release`\ 를 호출할 때까지 기다린다.

세마포어는 :ref:`context management protocol <with-locks>`\ 를 지원한다.


.. class:: Semaphore(value=1)

   이 클래스는 세마포어 객체를 구현한다. 세마포어는 원자성 카운터를 관리한다.
   이 카운터 값은 초기값에 :meth:`release` 호출 횟수를 더하고 :meth:`acquire` 호출 횟수를 뺀 값이 된다.
   :meth:`acquire` 메서드는 필요에 따라 음이 아닌 카운터 값을 반환할 수 있을 때까지 블럭한다.
   값이 주어지지 않으면 *value*는 기본으로 1이다.

   선택 인수는 내부 카운터의 초기값을 부여한다. 기본값은 ``1``\ 이다.
   0보다 작은 값을 주면 :exc:`ValueError`\ 가 발생한다.

   .. versionchanged:: 3.3
      팩토리 함수에서 클래스로 변경.

   .. method:: acquire(blocking=True, timeout=None)

      세마포어를 얻는다.

      인수 없이 호출되면 다음을 따른다.

      * 내부 카운터가 0보다 큰 값을 가지고 있으면 값을 1 낮추고 바로 ``True``\ 를 반환한다.
      * 내부 카운터 값이 0이면 :meth:`~Semaphore.release`\ 가 호출될 때까지 기다린다.
        :meth:`~Semaphore.release`\ 이 호출되고 카운터 값이 0보다 크면 값을 1 낮추고 ``True``\ 를 반환한다.
        :meth:`~Semaphore.release` 호출되었을 때 하나의 스레드만이 진행된다. 스레드 진행 순서는 알 수 없다.

      *blocking* 인수가 ``False``\ 일 때 호출되면 블럭하지 않는다.
      이 인수 없이 호출되어 블럭되면 바로 ``False``\ 를 반환한다.
      아닌 경우에는 인수 없이 호출되었을 때와 같은 일을 하고 ``True``\ 를 반환한다.

      *timeout* 인수가 ``None``\ 이 아닐 때 호출되면 인수에 지정된 초단위 시간 만큼 기다린다.
      제한 시간 안에 세마포어 획득을 하지 못하면 ``False``\ 를 반환한다. 아닌 경우에는 ``True``\ 를 반환한다.

      .. versionchanged:: 3.2
         *timeout* 매개 변수 추가.

   .. method:: release()

      세마포어를 해제한다. 내부 카운터 값을 1 만큼 올린다.
      메서드가 호출될 때 카운터 값이 0이고 다른 스레드가 값이 증가하길 기다리고 있으면
      그 스레드를 진행한다.


.. class:: BoundedSemaphore(value=1)

   제한 세마포어 객체를 구현하는 클래스다. 제한 세마포어는 현재값이 초기값을 넘지 않는지 확인한다.
   초기값을 넘으면 :exc:`ValueError`\ 가 발생한다. 세마포어는 주로 제한된 용량을 갖는
   리소스를 보호해야 하는 환경에서 사용된다. 세마포어가 너무 많이 해제되면 이는 버그가 있다는 신호다.
   *value*의 기본값은 1이다.

   .. versionchanged:: 3.3
      팩토리 함수에서 클래스로 변경.


.. _semaphore-examples:

:class:`Semaphore` 예시
^^^^^^^^^^^^^^^^^^^^^^^^^^

세마포어는 데이터베이스 서버와 같은 제한된 용량을 갖는 리소스를 보호해야하는 환경에서 주로 사용된다.
리소스의 크기가 고정된 상황이라면 제한 세마포어를 사용해야 한다. 작업 스레드를 생성하기 전에
메인 스레드가 세마포어를 초기화해야 한다. ::

   maxconnections = 5
   # ...
   pool_sema = BoundedSemaphore(value=maxconnections)

작업 스레드가 생성되면 서버에 연결해야 할 때 세마포어의 :meth:`~Semaphore.acquire` , :meth:`~Semaphore.release` 메서드를 호출한다. ::

   with pool_sema:
       conn = connectdb()
       try:
           # ... use connection ...
       finally:
           conn.close()

제한 세마포어를 사용하면 세마포어의 획득보다 해제가 더 많이 되는 프로그래밍 에러 감지를 용이하게 할 수 있다.


.. _event-objects:

이벤트 객체
-------------

이 객체는 스레드 간의 소통을 위한 가장 간단한 방법이다. 하나의 스레드가 이벤트를 보내고 다른 스레드는 이벤트를 기다린다.

이벤트 객체는 내부 플래그를 관리한다. 이 내부 플래그는 :meth:`~Event.set` 메서드로 True가 되고
:meth:`~Event.clear` 메서드로 False가 된다. :meth:`~Event.wait` 메서드는 플래그가 True인 동안 다른 스레드를 블럭한다.


.. class:: Event()

   이벤트 객체를 구현하는 클래스. 이벤트 객체는 플래그를 관리한다.
   이 플래그는 :meth:`~Event.set` 메서드로 True가 되고 :meth:`~Event.clear` 메서드로 ``False``\ 가 된다.
   :meth:`wait` 메서드는 플래그가 True인 동안 다른 스레드를 블럭한다. 플래그의 초기값은 ``False``\ 다.

   .. versionchanged:: 3.3
      팩토리 함수에서 플래그가 되었다.

   .. method:: is_set()

      내부 플래그가 ``True``\ 일 때만 ``True``\ 를 반환한다.

   .. method:: set()

      내부 플래그를 ``True``\ 로 설정한다. 플래그가 ``True``\ 가 되길 기다리는 모든 스레드가 깨어난다.
      플래그가 ``True``\ 가 되면 :meth:`wait`\ 을 호출하는 스레드는 아예 블럭되지 않는다.

   .. method:: clear()

      내부 플래그를 ``False``\ 로 리셋한다. 추가로 :meth:`wait`\ 을 호출하는 스레드는
      :meth:`.set`\ 이 호출되어 내부 플래그를 다시 ``True``\ 로 만들 때까지 블럭된다.

   .. method:: wait(timeout=None)

      내부 플래그가 ``True``\ 가 될 때까지 기다린다. 처음부터 내부 플래그가 ``True``\ 면
      바로 반환한다. 아닌 경우에 다른 스레드가 :meth:`.set`\ 을 호출해 플래그를 ``True``\ 로 바꾸거나
      선택으로 지정한 제한 시간이 지날 때까지 기다린다.

      timeout 인수가 ``None``\ 이 아닌 값을 가지면 그 값은 초 단위로 작업의 제한 시간을 지정하는 부동소수점이 되어야 한다.

      이 메서드는 내부 플래그가 ``True``\ 일 때만 ``True``\ 를 반환한다.
      대기 호출이나 대기가 시작된 후에도 값을 반환하므로 제한 시간이 있고 초과되었을 때를 제외하면 항상 ``True``\ 를 반환한다.

      .. versionchanged:: 3.1
         이전에는 항상 ``None``\ 을 반환했다.


.. _timer-objects:

타이머 객체
-------------

이 클래스는 특정 시간이 지난 후에만 실행되어야 하는 동작, 즉 타이머를 나타낸다.
:class:`Timer`\ 는 :class:`Thread`\ 의 서브클래스로 커스텀 스레드를 생성하는 예시가 되는 함수다.

스레드처럼 타이머는 :meth:`~Timer.start` 메서드를 호출해 시작된다.
타이머는 그 동작이 시작되기 전에 :meth:`~Timer.cancel` 메서드로 중단될 수 없다.
타이머가 동작을 실행하기 전에 기다리는 간격은 사용자가 지정한 간격과 완전히 일치하지 않을 수 있다.

예시 ::

   def hello():
       print("hello, world")

   t = Timer(30.0, hello)
   t.start()  # after 30 seconds, "hello, world" will be printed


.. class:: Timer(interval, function, args=None, kwargs=None)

   *interval* 시간이 지나고 인수 *args*와 키워드 인수 *kwargs*로 *function*을 실행할 타이머를 생성한다.
   *args*가 기본값인 ``None``\ 이면 비어진 리스트가 사용된다.
   *kwargs*가 기본값인 ``None``\ 이면 비어진 딕셔너리가 사용된다.

   .. versionchanged:: 3.3
      팩토리 함수에서 클래스로 변경.

   .. method:: cancel()

      타이머를 멈추고 타이머 동작의 실행을 취고한다. 타이머가 대기 상태일 때만 작동한다.


배리어 객체
---------------

.. versionadded:: 3.2

이 클래스는 간단한 동기화 기본 요소를 제공하며 정해진 수의 스레드가 서로를 기다려야할 때 사용된다.
각 스레드는 :meth:`~Barrier.wait` 메서드를 호출해 베리어를 통과하려 하고
모든 스레드가 :meth:`~Barrier.wait` 호출을 할 때까지 블럭된다.
모든 스레드가 :meth:`~Barrier.wait`\ 을 호출하면 스레드의 블럭이 동시에 풀린다.

베리어는 같은 수의 스레드를 위해 몇번이고 재사용될 수 있다.

다음 예시는 클라이언트와 서버 스레드를 동기화하는 간단한 방법을 보여준다. ::

   b = Barrier(2, timeout=5)

   def server():
       start_server()
       b.wait()
       while True:
           connection = accept_connection()
           process_server_connection(connection)

   def client():
       b.wait()
       while True:
           connection = make_connection()
           process_client_connection(connection)


.. class:: Barrier(parties, action=None, timeout=None)

   *parties* 수의 스레드를 위한 베리어 객체를 생성한다.
   *action*이 주어지면 스레드가 해제될 때 호출할 수 있는 호출 가능 객체가 된다.
   *timeout*은 :meth:`wait` 메서드에 ``None``\ 이 지정되었을 때 기본 제한 시간이 된다.

   .. method:: wait(timeout=None)

      베리어를 통과한다. 베리어로의 모든 스레드 파티가 이 함수를 호출하면 스레드는 동시에 베리어를 통과한다.
      *timeout*을 부여하면 클래스 생성자에 있는 제한 시간보다 우선적으로 사용된다.

      반환값은 0부터 *parties* 값 사이의 정수가 된다. 각 스레드에 대해 다른 값이 된다.
      이 메서드를 사용해 특정 관리 작업을 할 스레드를 선택할 수 있다. 예시 ::

         i = barrier.wait()
         if i == 0:
             # Only one thread needs to print this
             print("passed the barrier")

      *action*이 생성자에 주어지면 스레드 중 하나가 해제되기 전에 이를 호출한다.
      베리어가 붕괴되면 이 호출은 에러를 발생시켜야 한다.

      호출 제한 시간을 초과하면 베리어는 붕괴된다.

      스레드가 대기하는 동안에 베리어가 붕괴되거나 리셋되면 이 메서드는 :class:`BrokenBarrierError` 예외를 발생시킬 수 있다.

   .. method:: reset()

      베리어를 기본인 공백 상태로 반환한다. 베리어에서 대기중인 모든 스레드는 :class:`BrokenBarrierError` 예외를 수신한다.

      상태를 알 수 없는 다른 스레드가 있을 때 이 함수를 사용하려면 외부 동기화가 필요할 수 있다는 것을 알아두자.
      베리어가 붕괴되면 이 베리어는 그대로 두고 새 베리어를 만드는게 나을 수 있다.

   .. method:: abort()

      베리어를 붕괴 상태로 만든다. 이 메서드는 :meth:`wait`\ 로의 활성화된 호출이나
      미래의 호출이 :class:`BrokenBarrierError`\ 와 함께 실패하게 만든다.
      어플리케이션 데드락을 막거나 중단해야 할 때 사용한다.

      베리어를 생성할 때 적절한 *timeout* 값을 사용해 오류가 발생하는 스레드로부터 자동으로 보호하는 것이 나을 수 있다.

   .. attribute:: parties

      베리어를 통과하기 위해 필요한 스레드 수.

   .. attribute:: n_waiting

      현재 베리어에서 대기중인 스레드 수,

   .. attribute:: broken

      부올리언 값으로 베리어가 붕괴하면 ``True``\ 가 된다.


.. exception:: BrokenBarrierError

   이 예외는 :exc:`RuntimeError`\ 의 서브 클래스로 :class:`Barrier`\ 객체가 리셋되거나 붕괴하면 발생한다.


.. _with-locks:

:keyword:`with` 선언에서 락, 컨디션, 세마포어 사용하기
------------------------------------------------------------------------

이 모듈이 제공하는 객체 중 :meth:`acquire`, :meth:`release` 메서드를 갖는
모든 객체는 :keyword:`with` 선언의 컨텍스트 매니저로 사용될 수 있다.
블럭에 들어갈 때 :meth:`acquire` 메서드가 호출되고 블럭에서 나올 때 :meth:`release` 메서드가 호출된다.
따라서 다음 코드는 ::

   with some_lock:
       # do something...

아래 코드와 같다. ::

   some_lock.acquire()
   try:
       # do something...
   finally:
       some_lock.release()

현재 :class:`Lock`, :class:`RLock`, :class:`Condition`, :class:`Semaphore`, :class:`BoundedSemaphore`
객체가 :keyword:`with` 선언 컨텍스트 매니저로 사용될 수 있다.
