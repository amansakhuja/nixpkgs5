import os
import random
import shutil
import subprocess
import sys
from abc import ABC, abstractmethod

from remote_pdb import RemotePdb  # type:ignore

from test_driver.logger import AbstractLogger


class DebugAbstract(ABC):
    @abstractmethod
    def enable_failure_hook(self) -> None:
        pass

    @abstractmethod
    def break_on_failure(self) -> None:
        pass

    @abstractmethod
    def breakpoint(self, host: str = "127.0.0.1", port: int = 4444) -> None:
        pass


class DebugNop(DebugAbstract):
    def __init__(self) -> None:
        pass

    def enable_failure_hook(self) -> None:
        pass

    def break_on_failure(self) -> None:
        pass

    def breakpoint(self, host: str = "127.0.0.1", port: int = 4444) -> None:
        pass


class Debug(DebugAbstract):
    def __init__(self, logger: AbstractLogger) -> None:
        self.breakpoint_on_failure = False
        self.logger = logger

    def enable_failure_hook(self) -> None:
        """
        TODO: Docstring
        """
        self.breakpoint_on_failure = True

    def break_on_failure(self) -> None:
        """
        TODO: Docstring
        """
        if self.breakpoint_on_failure:
            self.breakpoint()

    def breakpoint(self, host: str = "127.0.0.1", port: int = 4444) -> None:
        """
        TODO: Docstring
        """
        pattern = str(random.randrange(999999, 9999999))
        self.logger.log_test_error(
            f"Breakpoint reached, run 'sudo @attach@ {pattern}'"
        )
        os.environ["bashInteractive"] = shutil.which("bash")  # type:ignore
        if os.fork() == 0:
            subprocess.run(["sleep", pattern])
        else:
            RemotePdb(host=host, port=port).set_trace(sys._getframe().f_back)
