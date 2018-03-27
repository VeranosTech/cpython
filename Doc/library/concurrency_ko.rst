.. _concurrency:

********************
동시 실행
********************

이 장에서 설명하는 모듈은 코드의 동시 실행을 지원하지 위한 것이다.
실행할 작업이 CPU를 소모하는 작업(CPU bound)인지 IO를 소모하는지(IO bound)에,
그리고 선호하는 개발 스타일이 이벤트 드리븐 멀티태스킹 방식(event driven cooperative multitasking)인지
아니면 선점형 멀티태스킹 방식(preemptive multitasking)인지에 따라 적절한 도구를 골라야 한다.


.. toctree::

   threading_ko.rst
   multiprocessing.rst
   concurrent.rst
   concurrent.futures.rst
   subprocess.rst
   sched.rst
   queue.rst


다음 모듈은 위의 서비스의 일부를 지원하는 모듈들이다.:

.. toctree::

   _thread.rst
   _dummy_thread.rst
   dummy_threading.rst
