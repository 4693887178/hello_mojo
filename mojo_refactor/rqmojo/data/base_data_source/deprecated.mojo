"""
RQAlpha Mojo - Deprecated Functions
Ported from rqalpha/data/base_data_source/deprecated.py
"""

from collections import Dict, List, Set
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument


fn deprecated_get_price(order_book_id: String, dt: String) -> Float64:
    return 0.0


fn deprecated_get_volume(order_book_id: String, dt: String) -> Int:
    return 0


@fieldwise_init
struct DeprecatedWarning(Movable):
    var function_name: String
    var message: String
    var since_version: String
    var removed_in_version: String


fn warn_deprecated(warning: DeprecatedWarning) -> None:
    print("DeprecationWarning: " + warning.function_name + " is deprecated since version " + warning.since_version + ". " + warning.message)


trait AbstractInstrumentStore:
    def get_instruments(self, id_or_syms: Optional[List[String]]) -> List[Instrument]


@fieldwise_init
struct InstrumentStore(Movable):
    var _instrument_type: INSTRUMENT_TYPE
    var _instruments: Dict[String, Instrument]
    var _sym_id_map: Dict[String, String]

    def __init__(inout self, instruments: List[Instrument], instrument_type: INSTRUMENT_TYPE):
        self._instrument_type = instrument_type
        self._instruments = Dict[String, Instrument]()
        self._sym_id_map = Dict[String, String]()
        
        for i in range(len(instruments)):
            var ins = instruments[i]
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

    def get_instruments(self, id_or_syms: Optional[List[String]]) -> List[Instrument]:
        if id_or_syms.is_none():
            var result = List[Instrument]()
            for value in self._instruments.values():
                result.append(value)
            return result^
        
        var ids = id_or_syms.value()
        var order_book_ids = Set[String]()
        
        for i in range(len(ids)):
            var id_or_sym = ids[i]
            if self._instruments.contains(id_or_sym):
                order_book_ids.add(id_or_sym)
            elif self._sym_id_map.contains(id_or_sym):
                order_book_ids.add(self._sym_id_map[id_or_sym])
        
        var result = List[Instrument]()
        for obid in order_book_ids:
            result.append(self._instruments[obid])
        return result^


fn create_instrument_store(instruments: List[Instrument], instrument_type: INSTRUMENT_TYPE) -> InstrumentStore:
    return InstrumentStore(instruments=instruments, instrument_type=instrument_type)
