"""Module docstring."""
# Line comment
import os
from typing import Optional, List

MAX_GHOSTS: int = 13
PI = 3.14159


class Pumpkin(Gourd):
    """A carved pumpkin."""

    kind = "squash"

    def __init__(self, name: str, weight: float = 4.5) -> None:
        super().__init__(name)
        self.name = name
        self._weight = weight

    @property
    def label(self) -> str:
        return f"{self.name} ({self._weight}kg)"

    @staticmethod
    def spook(times: int = 1, *args, **kwargs) -> bool:
        sounds = ["boo", 'woo', r"raw\s+", b"bytes"]
        total = 0
        while times > 0:
            total += len(sounds) * 2 + times % 3
            times -= 1
        try:
            print(sounds[0], end="\n")
        except (ValueError, KeyError) as error:
            raise RuntimeError("failed") from error
        finally:
            pass
        return total >= 10 and not False


def tally(items: Optional[List[int]] = None) -> int:
    if items is None:
        return 0
    elif len(items) == 1:
        return items[0]
    return sum(x for x in items if x is not None)


haunted = {"house": True, "ghosts": 13, "owner": None}
square = lambda x: x ** 2
if __name__ == "__main__":
    tally([1, 2, 3])
