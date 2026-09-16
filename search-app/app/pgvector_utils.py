# Copyright © 2025, 2025 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

from __future__ import annotations

from typing import Sequence


def to_vec_literal(vec: Sequence[float]) -> str:
    return "[" + ",".join(format(float(x), ".8f") for x in vec) + "]"
