"""
RQAlpha Mojo - Position Queue
Ported from rqalpha/portfolio/position.py
Position queue for tracking opening positions with dates (FIFO)
"""

from std.collections import List
from rqmojo.utils.typing import DateTime, DateTimeDate


struct PositionQueueItem(Copyable, Movable, ImplicitlyCopyable, Writable):
    """A single item in the position queue representing one opening trade"""
    var date: DateTimeDate
    var quantity: Int

    def __init__(out self, date: DateTimeDate, quantity: Int):
        self.date = date
        self.quantity = quantity

    def __init__(out self, *, copy: Self):
        self.date = copy.date
        self.quantity = copy.quantity

    def __init__(out self, *, deinit take: Self):
        self.date = take.date
        self.quantity = take.quantity

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PositionQueueItem(date=, qty=", String(self.quantity), ")")


struct PositionQueue(Movable):
    """FIFO queue for tracking position openings"""
    var _items: List[PositionQueueItem]

    def __init__(out self):
        self._items = List[PositionQueueItem]()

    def __init__(out self, *, deinit take: Self):
        self._items = take._items^

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PositionQueue(items=", String(len(self._items)), ")")

    def len(self) -> Int:
        return len(self._items)

    def is_empty(self) -> Bool:
        return len(self._items) == 0

    def push(mut self, date: DateTimeDate, quantity: Int) -> None:
        """Add a new position opening to the queue"""
        if quantity == 0:
            return
        self._items.append(PositionQueueItem(date=date, quantity=quantity))

    def pop(mut self, quantity: Int) -> None:
        """Remove quantity from the queue (FIFO)"""
        if quantity <= 0 or len(self._items) == 0:
            return
        
        var remaining = quantity
        var new_items = List[PositionQueueItem]()
        
        for item in self._items:
            if remaining <= 0:
                new_items.append(item)
            elif item.quantity <= remaining:
                remaining -= item.quantity
            else:
                var new_qty = item.quantity - remaining
                remaining = 0
                if new_qty != 0:
                    new_items.append(PositionQueueItem(date=item.date, quantity=new_qty))
        
        self._items = new_items^

    def handle_trade_init(mut self, quantity: Int) -> None:
        """Initialize queue with initial quantity (used in create_position)"""
        if quantity == 0:
            return
        var d = DateTimeDate(1970, 1, 1)
        self._items.append(PositionQueueItem(date=d, quantity=quantity))

    def handle_trade_open(mut self, quantity: Int) -> None:
        """Handle an OPEN trade - append to queue (merge same-day if possible)"""
        if quantity == 0:
            return
        if len(self._items) > 0:
            var last_idx = len(self._items) - 1
            self._items[last_idx].quantity += quantity
        else:
            var d = DateTimeDate(1970, 1, 1)
            self._items.append(PositionQueueItem(date=d, quantity=quantity))

    def handle_trade_close(mut self, quantity: Int) -> None:
        """Handle a CLOSE trade - remove from queue FIFO (close old first, then today)"""
        if quantity <= 0 or len(self._items) == 0:
            return
        var remaining = quantity
        var new_items = List[PositionQueueItem]()
        for item in self._items:
            if remaining <= 0:
                new_items.append(item)
            elif abs(item.quantity) <= abs(remaining):
                remaining += item.quantity
            else:
                self._items[0] = PositionQueueItem(date=item.date, quantity=item.quantity + remaining)
                remaining = 0
        self._items = new_items^
        if remaining != 0 and remaining != quantity:
            var d = DateTimeDate(1970, 1, 1)
            self._items.append(PositionQueueItem(date=d, quantity=remaining))

    def get_items(self) -> List[PositionQueueItem]:
        """Get all items in the queue"""
        var result = List[PositionQueueItem]()
        for item in self._items:
            result.append(item)
        return result^

    def total_quantity(self) -> Int:
        """Get total quantity in the queue"""
        var total = 0
        for item in self._items:
            total += item.quantity
        return total

    def get_item(self, index: Int) -> PositionQueueItem:
        """Get item at index"""
        return self._items[index]

    def clear(mut self) -> None:
        """Clear all items"""
        self._items = List[PositionQueueItem]()

    def copy(self) -> PositionQueue:
        """Return a copy of the queue"""
        var q = PositionQueue()
        for item in self._items:
            q._items.append(item)
        return q


def create_position_queue() -> PositionQueue:
    return PositionQueue()
