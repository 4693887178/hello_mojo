"""
RQAlpha Mojo - Bundle Data Management
Ported from rqalpha/data/bundle.py
"""

from std.collections import Dict, List
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils.datetime_func import convert_date_to_int, convert_int_to_datetime


comptime START_DATE = 20050104
comptime END_DATE = 29991231


def _get_current_time() -> DateTime:
    try:
        return DateTime.now()
    except:
        return DateTime(2024, 1, 1, 0, 0, 0, 0)


@fieldwise_init
struct BundleVersion(Writable, Copyable, Movable, ImplicitlyCopyable, Equatable):
    var major: Int
    var minor: Int
    var patch: Int

    def write_to(self, mut writer: Some[Writer]):
        writer.write(String(self.major), ".", String(self.minor), ".", String(self.patch))

    @staticmethod
    def default() -> BundleVersion:
        return BundleVersion(major=1, minor=0, patch=0)


@fieldwise_init
struct BundleMetadata(Writable, Movable):
    var version: BundleVersion
    var created_at: DateTime
    var market: String
    var data_types: List[String]

    def write_to(self, mut writer: Some[Writer]):
        writer.write("BundleMetadata(version=")
        self.version.write_to(writer)
        writer.write(", market=", self.market, ")")


@fieldwise_init
struct Bundle(Writable, Movable):
    var _path: String
    var _version: BundleVersion
    var _metadata: BundleMetadata
    var _instruments_path: String
    var _trading_dates_path: String
    var _stocks_path: String
    var _indexes_path: String
    var _futures_path: String
    var _funds_path: String
    var _dividends_path: String
    var _splits_path: String
    var _ex_cum_factor_path: String
    var _initialized: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Bundle(path=", self._path, ")")

    def __init__(out self, path: String):
        self._path = path
        self._version = BundleVersion.default()
        self._metadata = BundleMetadata(
            version=BundleVersion.default(),
            created_at=_get_current_time(),
            market="cn",
            data_types=List[String]()
        )
        self._instruments_path = path + "/instruments.pk"
        self._trading_dates_path = path + "/trading_dates.npy"
        self._stocks_path = path + "/stocks.h5"
        self._indexes_path = path + "/indexes.h5"
        self._futures_path = path + "/futures.h5"
        self._funds_path = path + "/funds.h5"
        self._dividends_path = path + "/dividends.h5"
        self._splits_path = path + "/split_factor.h5"
        self._ex_cum_factor_path = path + "/ex_cum_factor.h5"
        self._initialized = False

    def update(mut self) -> Bool:
        print("Updating bundle at: " + self._path)
        self._initialized = True
        return True

    def load(mut self) -> Bool:
        print("Loading bundle from: " + self._path)
        self._initialized = True
        return True

    def get_stocks_path(self) -> String:
        return self._stocks_path

    def get_indexes_path(self) -> String:
        return self._indexes_path

    def get_futures_path(self) -> String:
        return self._futures_path

    def get_funds_path(self) -> String:
        return self._funds_path

    def get_dividends_path(self) -> String:
        return self._dividends_path

    def get_splits_path(self) -> String:
        return self._splits_path

    def get_ex_cum_factor_path(self) -> String:
        return self._ex_cum_factor_path

    def get_trading_dates_path(self) -> String:
        return self._trading_dates_path

    def get_instruments_path(self) -> String:
        return self._instruments_path

    def is_initialized(self) -> Bool:
        return self._initialized

    def get_version(self) -> BundleVersion:
        return self._version

    def get_market(self) -> String:
        return self._metadata.market

    def get_path(self) -> String:
        return self._path


def create_bundle(path: String) -> Bundle:
    return Bundle(
        _path=path,
        _version=BundleVersion.default(),
        _metadata=BundleMetadata(
            version=BundleVersion.default(),
            created_at=_get_current_time(),
            market="cn",
            data_types=List[String]()
        ),
        _instruments_path=path + "/instruments.pk",
        _trading_dates_path=path + "/trading_dates.npy",
        _stocks_path=path + "/stocks.h5",
        _indexes_path=path + "/indexes.h5",
        _futures_path=path + "/futures.h5",
        _funds_path=path + "/funds.h5",
        _dividends_path=path + "/dividends.h5",
        _splits_path=path + "/split_factor.h5",
        _ex_cum_factor_path=path + "/ex_cum_factor.h5",
        _initialized=False
    )


@fieldwise_init
struct AutomaticUpdateBundle(Writable, Movable):
    var _bundle: Bundle
    var _filename: String
    var _fields: List[String]
    var _start_date: Int
    var _updated: List[String]

    def write_to(self, mut writer: Some[Writer]):
        writer.write("AutomaticUpdateBundle(", self._filename, ")")

    def __init__(out self, var bundle: Bundle, filename: String, var fields: List[String], start_date: Int = START_DATE):
        self._bundle = bundle^
        self._filename = filename
        self._fields = fields^
        self._start_date = start_date
        self._updated = List[String]()

    def get_data(mut self, order_book_id: String, dt: DateTime) -> Optional[Dict[String, Float64]]:
        var found = False
        for item in self._updated:
            if item == order_book_id:
                found = True
                break
        if not found:
            self._auto_update_task(order_book_id)
            self._updated.append(order_book_id)
        return Optional[Dict[String, Float64]](Dict[String, Float64]())

    def _auto_update_task(mut self, order_book_id: String) -> None:
        print("Auto updating data for: " + order_book_id)

    def is_updated(self, order_book_id: String) -> Bool:
        for item in self._updated:
            if item == order_book_id:
                return True
        return False
