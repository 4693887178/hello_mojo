"""
RQAlpha Mojo - Bundle Data Management
Ported from rqalpha/data/bundle.py
"""

from collections import Dict, List
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.datetime_func import DateTime, Date, convert_date_to_int, convert_int_to_datetime


alias START_DATE = 20050104
alias END_DATE = 29991231


fn _get_current_time() -> DateTime:
    try:
        return DateTime.now()
    except:
        return DateTime(2024, 1, 1, 0, 0, 0, 0)


@value
struct BundleVersion(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var major: Int
    var minor: Int
    var patch: Int

    fn __str__(self) -> String:
        return String(self.major) + "." + String(self.minor) + "." + String(self.patch)

    @staticmethod
    fn default() -> BundleVersion:
        return BundleVersion(major=1, minor=0, patch=0)


@value
struct BundleMetadata(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var version: BundleVersion
    var created_at: DateTime
    var market: String
    var data_types: List[String]

    fn __str__(self) -> String:
        return "BundleMetadata(version=" + str(self.version) + ", market=" + self.market + ")"


@fieldwise_init
struct Bundle(Movable):
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

    fn __init__(inout self, path: String):
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

    fn update(mut self) -> Bool:
        print("Updating bundle at: " + self._path)
        self._initialized = True
        return True

    fn load(mut self) -> Bool:
        print("Loading bundle from: " + self._path)
        self._initialized = True
        return True

    fn get_stocks_path(self) -> String:
        return self._stocks_path

    fn get_indexes_path(self) -> String:
        return self._indexes_path

    fn get_futures_path(self) -> String:
        return self._futures_path

    fn get_funds_path(self) -> String:
        return self._funds_path

    fn get_dividends_path(self) -> String:
        return self._dividends_path

    fn get_splits_path(self) -> String:
        return self._splits_path

    fn get_ex_cum_factor_path(self) -> String:
        return self._ex_cum_factor_path

    fn get_trading_dates_path(self) -> String:
        return self._trading_dates_path

    fn get_instruments_path(self) -> String:
        return self._instruments_path

    fn is_initialized(self) -> Bool:
        return self._initialized

    fn get_version(self) -> BundleVersion:
        return self._version

    fn get_metadata(self) -> BundleMetadata:
        return self._metadata

    fn get_path(self) -> String:
        return self._path


fn create_bundle(path: String) -> Bundle:
    return Bundle(path)


@fieldwise_init
struct AutomaticUpdateBundle(Movable):
    var _bundle: Bundle
    var _filename: String
    var _fields: List[String]
    var _start_date: Int
    var _updated: List[String]

    fn __init__(inout self, bundle: Bundle, filename: String, fields: List[String], start_date: Int = START_DATE):
        self._bundle = bundle
        self._filename = filename
        self._fields = fields
        self._start_date = start_date
        self._updated = List[String]()

    fn get_data(self, order_book_id: String, dt: DateTime) -> Optional[Dict[String, Float64]]:
        if order_book_id notin self._updated:
            self._auto_update_task(order_book_id)
            self._updated.append(order_book_id)
        return Dict[String, Float64]()

    fn _auto_update_task(mut self, order_book_id: String) -> None:
        print("Auto updating data for: " + order_book_id)

    fn is_updated(self, order_book_id: String) -> Bool:
        return order_book_id in self._updated
