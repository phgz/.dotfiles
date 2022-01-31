import json
import os
import re

import numpy as np


class People(object):
    """
    People class.
    """

    ret_ages = {"Half": 60, "AlmostFull": 65, "Full": 71}  # years

    def __init__(self, name, age, ret_mode):
        super(People, self).__init__()

        if ret_mode not in self.ret_ages.keys():
            raise KeyError(ret_mode + " not in " + str(self.ret_ages.keys()))
            breakpoint()
        self.name = name
        self.age = age
        self.ret_mode = ret_mode

    def get_remaining_years(self):
        """
        Return how many years People have still to work before earning.

        <rate> retirement. <rate> could be "Half", "Middle" or "Full".
        """
        try:
            return self.ret_ages[self.ret_mode] - self.age
        except KeyError:
            raise KeyError("rate has to be in " + str(self.ret_ages.keys()))


def main():
    """Main function."""
    people_list = [
        People("Juliette", 35, "Full"),
        People("Coralie", 26, "Half"),
        People("Laura", 27, "AlmostFull"),
    ]
    people_closer_to_ret = min(
        people_list, key=lambda people: people.get_remaining_years()
    )

    print(people_closer_to_ret.name, "will be retired soon !")


if __name__ == "__main__":
    main()
