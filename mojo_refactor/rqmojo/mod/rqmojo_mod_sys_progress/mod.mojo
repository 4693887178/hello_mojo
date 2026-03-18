"""
RQAlpha Mojo - Progress Mod
Ported from rqalpha/mod/rqalpha_mod_sys_progress/mod.py
"""

from rqmojo.interface import Mod
from rqmojo.const import EXIT_CODE
from rqmojo.core.events import EVENT


@fieldwise_init
struct ProgressBar:
    var _length: Int
    var _current: Int
    var _show_eta: Bool

    fn __init__(inout self, length: Int, show_eta: Bool = False) -> Self:
        return Self(_length=length, _current=0, _show_eta=show_eta)

    fn update(mut self, steps: Int = 1) -> None:
        self._current += steps
        self._render()

    fn _render(self) -> None:
        var percent = self._current * 100 // self._length
        var filled = self._current * 40 // self._length
        var empty = 40 - filled
        print("[", end="")
        for _ in range(filled):
            print("=", end="")
        for _ in range(empty):
            print(" ", end="")
        print("] ", percent, "%", sep="")

    fn render_finish(self) -> None:
        print()


@fieldwise_init
struct ProgressMod(Mod, Stringable, Movable):
    var name: String
    var _show: Bool
    var _progress_bar: Optional[ProgressBar]
    var _trading_length: Int

    fn __str__(self) -> String:
        return "ProgressMod(" + self.name + ")"

    fn __init__(ref self) -> Self:
        return Self(
            name="progress",
            _show=False,
            _progress_bar=Optional[ProgressBar](None),
            _trading_length=0
        )

    fn start_up(mut self, env: object, mod_config: object) -> None:
        self._show = True
        if self._show:
            pass

    fn _init(mut self, trading_length: Int) -> None:
        self._trading_length = trading_length
        self._progress_bar = Optional[ProgressBar](ProgressBar(length=trading_length, show_eta=False))

    fn _tick(mut self) -> None:
        if var bar = self._progress_bar.value():
            bar.update(1)

    fn tear_down(self, code: EXIT_CODE, exception: Optional[object]) -> None:
        if self._show:
            if var bar = self._progress_bar.value():
                bar.render_finish()


fn create_progress_mod() -> ProgressMod:
    return ProgressMod(
        name="progress",
        _show=False,
        _progress_bar=Optional[ProgressBar](None),
        _trading_length=0
    )
