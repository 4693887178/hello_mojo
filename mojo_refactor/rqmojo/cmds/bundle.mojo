"""
RQAlpha Mojo - Bundle Command
Ported from rqalpha/cmds/bundle.py
"""

from rqmojo.utils.datetime_func import DateTime, Date


@fieldwise_init
struct BundleConfig(Movable):
    var data_path: String
    var start_date: DateTime
    var end_date: DateTime
    var include_stock: Bool
    var include_future: Bool
    var compression: Bool
    var concurrency: Int


def update_bundle(config: BundleConfig) -> Int:
    print("=== Bundle Update ===")
    print("Data Path: ", config.data_path)
    print("Start Date: ", config.start_date.__str__())
    print("End Date: ", config.end_date.__str__())
    print("Include Stock: ", config.include_stock)
    print("Include Future: ", config.include_future)
    print("Compression: ", config.compression)
    print("Concurrency: ", config.concurrency)
    print("")
    print("Note: Bundle update requires rqdatac. Please use Python version for actual bundle operations.")
    return 0


def create_bundle(data_path: String, start_date: DateTime, end_date: DateTime) -> Int:
    var config = BundleConfig(
        data_path=data_path,
        start_date=start_date,
        end_date=end_date,
        include_stock=True,
        include_future=False,
        compression=False,
        concurrency=1
    )
    
    return update_bundle(config)


def download_bundle(data_path: String = "./bundle") -> Int:
    var start_date = DateTime(2010, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    print("=== Bundle Download ===")
    print("Data Path: ", data_path)
    print("Start Date: ", start_date.__str__())
    print("End Date: ", end_date.__str__())
    print("")
    print("Note: Bundle download is not supported in Mojo. Please use Python version.")
    return 1


def check_bundle(data_path: String = "./bundle") -> Int:
    print("=== Bundle Check ===")
    print("Data Path: ", data_path)
    print("")
    print("Note: Bundle check is not fully supported in Mojo. Please use Python version for detailed check.")
    return 0
