"""
RQAlpha Mojo - Deprecated Functions
Ported from rqalpha/data/base_data_source/deprecated.py
"""

from std.collections import Dict, List, Set
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument


trait AbstractInstrumentStore:
    def get_instruments(self, id_or_syms: Optional[List[String]]) raises -> List[Instrument]


@fieldwise_init
struct InstrumentStore(Movable):
    var _instrument_type: INSTRUMENT_TYPE
    var _instruments: Dict[String, Instrument]
    var _sym_id_map: Dict[String, String]

    def __init__(out self, instruments: List[Instrument], instrument_type: INSTRUMENT_TYPE):
        self._instrument_type = instrument_type
        self._instruments = Dict[String, Instrument]()
        self._sym_id_map = Dict[String, String]()
        
        for ins in instruments:
            if ins.type() != instrument_type:
                continue
            self._instruments[ins.order_book_id()] = ins
            self._sym_id_map[ins.symbol()] = ins.order_book_id()

    def instrument_type(self) -> INSTRUMENT_TYPE:
        return self._instrument_type

    def all_id_and_syms(self) -> List[String]:
        var result = List[String]()
        for key in self._instruments.keys():
            result.append(key)
        for key in self._sym_id_map.keys():
            result.append(key)
        return result^

    def get_instruments(self, id_or_syms: Optional[List[String]]) raises -> List[Instrument]:
        if id_or_syms == None:
            var result = List[Instrument]()
            for value in self._instruments.values():
                result.append(value)
            return result^

        var ids = id_or_syms.value().copy()
        var order_book_ids = Set[String]()

        for id_or_sym in ids:
            if id_or_sym in self._instruments:
                order_book_ids.add(id_or_sym)
            elif id_or_sym in self._sym_id_map:
                order_book_ids.add(self._sym_id_map[id_or_sym])

        var result = List[Instrument]()
        for obid in order_book_ids:
            result.append(self._instruments[obid])
        return result^


def create_instrument_store(instruments: List[Instrument], instrument_type: INSTRUMENT_TYPE) -> InstrumentStore:
    return InstrumentStore(instruments=instruments, instrument_type=instrument_type)
