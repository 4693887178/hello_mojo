"""
RQAlpha Mojo - Position Queue
Ported from rqalpha/portfolio/position.py
Position queue for tracking opening positions with dates
"""

from std.collections import List
from rqmojo.utils.datetime_func import DateTime, Date


@fieldwise_init
struct PositionQueueItem(Copyable, Movable, ImplicitlyCopyable):
    """A single item in the position queue representing one opening trade"""
    var date: Date
    var quantity: Int

    fn __str__(self) -> String:
        return "PositionQueueItem(date=" + self.date.__str__() + ", qty=" + String(self.quantity) + ")"


struct PositionQueue(Copyable, Movable, ImplicitlyCopyable):
    """FIFO queue for tracking position openings"""
    var _items: List[PositionQueueItem]

    fn __init__(out self):
        self._items = List[PositionQueueItem]()

    fn __init__(out self, *, copy: Self):
        self._items = copy._items.copy()

    fn __init__(out self, *, deinit take: Self):
        self._items = take._items^

    fn __str__(self) -> String:
        return "PositionQueue(items=" + String(len(self._items)) + ")"

    fn len(self) -> Int:
        return len(self._items)

    fn is_empty(self) -> Bool:
        return len(self._items) == 0

    fn push(mut self, date: Date, quantity: Int) -> None:
        """Add a new position opening to the queue"""
        if quantity == 0:
            return
        self._items.append(PositionQueueItem(date=date, quantity=quantity))

    fn pop(mut self, quantity: Int) -> None:
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

    fn get_items(self) -> List[PositionQueueItem]:
        """Get all items in the queue"""
        var result = List[PositionQueueItem]()
        for item in self._items:
            result.append(item)
        return result^

    fn total_quantity(self) -> Int:
        """Get total quantity in the queue"""
        var total = 0
        for item in self._items:
            total += item.quantity
        return total

    fn get_item(self, index: Int) -> PositionQueueItem:
        """Get item at index"""
        return self._items[index]

    fn clear(mut self) -> None:
        """Clear all items"""
        self._items = List[PositionQueueItem]()


fn create_position_queue() -> PositionQueue:
    return PositionQueue()
