"""
RQAlpha Mojo - Instruments Mixin
Ported from rqalpha/data/instruments_mixin.py

Python original provides:
  - InstrumentsMixin wraps a data_source and adds time-based filtering
  - get_active_instrument: get instrument active at a specific datetime (lru_cache)
  - get_instrument_history: get instrument history sorted by listed_date (lru_cache)
  - get_active_instruments: batch get active instruments at a datetime
  - get_instruments_history: batch get instrument history
  - get_all_instruments: get all instruments by type, optionally filtered by datetime
  - assure_order_book_id: validate and return standard order_book_id (lru_cache)
  - Deprecated: all_instruments, instrument_not_none, instrument, instruments

Mojo adaptation:
  - Stores instruments internally with indexing (order_book_id, symbol, type)
  - Uses convert_dt_to_int/convert_date_to_int for DateTime comparison
  - Raises Error for InstrumentNotFound cases
  - lru_cache omitted for methods returning non-String types (TODO: add generic cache)
"""

from std.collections import Dict, List, Set
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.datetime_func import convert_date_to_int, convert_dt_to_int
from rqmojo.utils.exception import InstrumentNotFound


struct InstrumentsMixin(Movable):
    var _instruments: List[Instrument]
    var _id_instrument_map: Dict[String, Dict[Int, Instrument]]
    var _sym_instrument_map: Dict[String, Dict[Int, Instrument]]
    var _grouped_instruments: Dict[INSTRUMENT_TYPE, List[Instrument]]

    def __init__(out self):
        self._instruments = List[Instrument]()
        self._id_instrument_map = Dict[String, Dict[Int, Instrument]]()
        self._sym_instrument_map = Dict[String, Dict[Int, Instrument]]()
        self._grouped_instruments = Dict[INSTRUMENT_TYPE, List[Instrument]]()

    def __init__(out self, var instruments: List[Instrument]) raises:
        self._instruments = List[Instrument]()
        self._id_instrument_map = Dict[String, Dict[Int, Instrument]]()
        self._sym_instrument_map = Dict[String, Dict[Int, Instrument]]()
        self._grouped_instruments = Dict[INSTRUMENT_TYPE, List[Instrument]]()
        self.register_instruments(instruments)

    def register_instruments(mut self, instruments: List[Instrument]) raises:
        for ins in instruments:
            self._instruments.append(ins)
            var obid = ins.order_book_id()
            var sym = ins.symbol()
            var listed_dt = convert_date_to_int(ins.listed_date())

            if obid not in self._id_instrument_map:
                self._id_instrument_map[obid] = Dict[Int, Instrument]()
            self._id_instrument_map[obid][listed_dt] = ins

            if sym not in self._sym_instrument_map:
                self._sym_instrument_map[sym] = Dict[Int, Instrument]()
            self._sym_instrument_map[sym][listed_dt] = ins

            var ins_type = ins.type()
            if ins_type not in self._grouped_instruments:
                self._grouped_instruments[ins_type] = List[Instrument]()
            self._grouped_instruments[ins_type].append(ins)

    def _get_instruments_by_ids(self, id_or_syms: List[String]) raises -> List[Instrument]:
        var result = List[Instrument]()
        var seen: Set[String] = Set[String]()
        for i in id_or_syms:
            var v_id = self._id_instrument_map.get(i)
            var v_sym = self._sym_instrument_map.get(i)
            if v_id != None:
                for dt_val in v_id.value().values():
                    var ins = dt_val
                    var dedup_key = ins.order_book_id() + "_" + String(convert_date_to_int(ins.listed_date()))
                    if dedup_key not in seen:
                        seen.add(dedup_key)
                        result.append(ins)
            if v_sym != None:
                for dt_val in v_sym.value().values():
                    var ins = dt_val
                    var dedup_key = ins.order_book_id() + "_" + String(convert_date_to_int(ins.listed_date()))
                    if dedup_key not in seen:
                        seen.add(dedup_key)
                        result.append(ins)
        return result^

    def _get_instruments_by_types(self, types: List[INSTRUMENT_TYPE]) raises -> List[Instrument]:
        var result = List[Instrument]()
        var seen: Set[String] = Set[String]()
        for t in types:
            if t in self._grouped_instruments:
                for ins in self._grouped_instruments[t]:
                    var dedup_key = ins.order_book_id() + "_" + String(convert_date_to_int(ins.listed_date()))
                    if dedup_key not in seen:
                        seen.add(dedup_key)
                        result.append(ins)
        return result^

    def _get_all_instruments(self) raises -> List[Instrument]:
        var result = List[Instrument]()
        var seen: Set[String] = Set[String]()
        for k in self._grouped_instruments.keys():
            if k in self._grouped_instruments:
                for ins in self._grouped_instruments[k]:
                    var dedup_key = ins.order_book_id() + "_" + String(convert_date_to_int(ins.listed_date()))
                    if dedup_key not in seen:
                        seen.add(dedup_key)
                        result.append(ins)
        return result^

    def get_active_instrument(self, id_or_sym: String, dt: DateTime) raises -> Instrument:
        var candidates = List[Instrument]()
        var id_list = List[String]()
        id_list.append(id_or_sym)
        var all_ins = self._get_instruments_by_ids(id_list^)
        for instrument in all_ins:
            if instrument.active_at(dt):
                candidates.append(instrument)
        if len(candidates) == 0:
            raise Error(
                InstrumentNotFound(
                    "No instrument found at " + String(dt) + ": " + id_or_sym
                ).message
            )
        if len(candidates) > 1:
            raise Error(
                InstrumentNotFound(
                    "Multiple instruments found at " + String(dt) + ": " + id_or_sym
                ).message
            )
        return candidates[0]

    def get_instrument_history(
        self, id_or_sym: String, listed_at: Optional[DateTime] = None
    ) raises -> List[Instrument]:
        var id_list = List[String]()
        id_list.append(id_or_sym)
        var result = self._get_instruments_by_ids(id_list^)
        if listed_at != None:
            var filtered = List[Instrument]()
            var dt_val = listed_at.value()
            for ins in result:
                if ins.listed_at(dt_val):
                    filtered.append(ins)
            result = filtered^
        return self._sort_by_listed_date(result)

    def _sort_by_listed_date(self, instruments: List[Instrument]) -> List[Instrument]:
        if len(instruments) <= 1:
            return instruments.copy()
        var items = instruments.copy()
        for i in range(len(items)):
            var min_idx = i
            for j in range(i + 1, len(items)):
                if convert_date_to_int(items[j].listed_date()) < convert_date_to_int(items[min_idx].listed_date()):
                    min_idx = j
            if min_idx != i:
                var tmp = items[i]
                items[i] = items[min_idx]
                items[min_idx] = tmp
        return items^

    def get_active_instruments(
        self, id_or_syms: List[String], dt: DateTime
    ) raises -> Dict[String, Instrument]:
        var result = Dict[String, Instrument]()
        var all_ins = self._get_instruments_by_ids(id_or_syms.copy())
        for ins in all_ins:
            if ins.active_at(dt):
                result[ins.order_book_id()] = ins
        return result^

    def get_instruments_history(
        self, id_or_syms: List[String]
    ) raises -> List[Instrument]:
        return self._get_instruments_by_ids(id_or_syms.copy())

    def get_all_instruments(
        self, types: List[INSTRUMENT_TYPE], dt: Optional[DateTime] = None
    ) raises -> List[Instrument]:
        var li = List[Instrument]()
        var all_ins = self._get_instruments_by_types(types.copy())
        for i in all_ins:
            if dt == None or i.active_at(dt.value()):
                li.append(i)
        return li^

    def assure_order_book_id(
        self, order_book_id: String, expected_type: Optional[INSTRUMENT_TYPE] = None
    ) raises -> String:
        var id_list = List[String]()
        id_list.append(order_book_id)
        var all_ins = self._get_instruments_by_ids(id_list^)
        for instrument in all_ins:
            if expected_type != None and instrument.type() != expected_type.value():
                continue
            return instrument.order_book_id()
        raise Error(
            InstrumentNotFound(
                "No instrument found: " + order_book_id
            ).message
        )

    def all_instruments(
        self, types: List[INSTRUMENT_TYPE], dt: Optional[DateTime] = None
    ) raises -> List[Instrument]:
        return self.get_all_instruments(types, dt)

    def instrument_not_none(self, id_or_sym: String) raises -> Instrument:
        var ins = self.get_instrument_history(id_or_sym)
        if len(ins) == 0:
            raise Error(
                InstrumentNotFound(
                    "No instrument found: " + id_or_sym
                ).message
            )
        return ins[0]

    def instrument(self, sym_or_id: String) raises -> Optional[Instrument]:
        var ins = self.get_instrument_history(sym_or_id)
        if len(ins) == 0:
            return None
        return Optional[Instrument](ins[0])

    def instruments_by_ids(
        self, sym_or_ids: List[String]
    ) raises -> List[Instrument]:
        return self._get_instruments_by_ids(sym_or_ids.copy())


def create_instruments_mixin_with_test_data() raises -> InstrumentsMixin:
    var instruments = List[Instrument]()

    instruments.append(create_future_instrument(
        "RB1912", "螺纹钢1912",
        DateTime(2019, 1, 1, 0, 0, 0, 0),
        DateTime(2019, 12, 15, 0, 0, 0, 0),
        DateTime(2019, 12, 15, 0, 0, 0, 0),
        10.0, EXCHANGE.SHFE, "RB"
    ))
    instruments.append(create_future_instrument(
        "AG1912", "白银1912",
        DateTime(2019, 1, 1, 0, 0, 0, 0),
        DateTime(2019, 12, 15, 0, 0, 0, 0),
        DateTime(2019, 12, 15, 0, 0, 0, 0),
        15.0, EXCHANGE.SHFE, "AG"
    ))
    instruments.append(create_future_instrument(
        "TF1912", "五年期国债1912",
        DateTime(2019, 1, 1, 0, 0, 0, 0),
        DateTime(2019, 12, 15, 0, 0, 0, 0),
        DateTime(2019, 12, 15, 0, 0, 0, 0),
        10000.0, EXCHANGE.CFFEX, "TF"
    ))
    instruments.append(create_stock_instrument(
        "000001.XSHE", "平安银行",
        DateTime(1991, 4, 3, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    instruments.append(create_stock_instrument(
        "600000.XSHG", "浦发银行",
        DateTime(1999, 11, 10, 0, 0, 0, 0),
        EXCHANGE.XSHG
    ))

    return InstrumentsMixin(instruments^)
