"""
RQAlpha Mojo - Progress Mod
Ported from rqalpha/mod/rqalpha_mod_sys_progress/mod.py
"""

from rqmojo.interface import ModInterface
from rqmojo.const import EXIT_CODE
from rqmojo.core.events import EVENT
from rqmojo.utils.i18n import gettext
from std.collections import List
from std.python import PythonObject


comptime __all__: List[String] = [
    "ProgressBar",
    "ProgressMod",
    "create_progress_mod",
]


@fieldwise_init
struct ProgressBar(Writable, Movable, ImplicitlyCopyable):
    var _length: Int
    var _current: Int
    var _show_eta: Bool

    def __init__(length: Int, show_eta: Bool = False) -> Self:
        return Self(_length=length, _current=0, _show_eta=show_eta)

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ProgressBar(length=", String(self._length), ")")

    def update(mut self, steps: Int = 1) -> None:
        self._current += steps
        if self._current > self._length:
            self._current = self._length
        self._render()

    def _render(self) -> None:
        var percent = self._current * 100 // self._length
        var filled = self._current * 40 // self._length
        var empty = 40 - filled
        var bar = "["
        for _ in range(filled):
            bar = bar + "="
        for _ in range(empty):
            bar = bar + " "
        bar = bar + "] " + String(percent) + "%"
        print("\r", bar, sep="", end="")

    def render_finish(self) -> None:
        print()

    def reset(mut self) -> None:
        self._current = 0


@fieldwise_init
struct ProgressMod(ModInterface, Writable, Movable):
    var name: String
    var _show: Bool
    var _progress_bar: Optional[ProgressBar]
    var _trading_length: Int
    var _initialized: Bool

    def __str__(self) -> String:
        return "ProgressMod(" + self.name + ")"

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ProgressMod(", self.name, ")")

    def __init__() -> Self:
        return Self(
            name="progress",
            _show=False,
            _progress_bar=Optional[ProgressBar](None),
            _trading_length=0,
            _initialized=False
        )

    def start_up(mut self, env_name: String, mod_config_name: String) -> None:
        self._show = True
        self._initialized = True

    def _init(mut self, trading_length: Int) -> None:
        self._trading_length = trading_length
        self._progress_bar = Optional[ProgressBar](ProgressBar(length=trading_length, show_eta=False))

    def _tick(mut self) -> None:
        if self._progress_bar:
            var bar = self._progress_bar.value()
            bar.update(1)

    def tear_down(self, code: EXIT_CODE, exception: Optional[String]) -> None:
        if self._show:
            if self._progress_bar:
                var bar = self._progress_bar.value()
                bar.render_finish()


def create_progress_mod() -> ProgressMod:
    return ProgressMod()
