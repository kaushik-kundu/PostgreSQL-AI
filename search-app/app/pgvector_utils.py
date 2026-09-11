# # Copyright © 2025, 2026 Oracle and/or its affiliates.
# #
# # This software is under the Apache License 2.0
# # (LICENSE-APACHE or http://www.apache.org/licenses/LICENSE-2.0) or Universal Permissive License
# # (UPL) 1.0 (LICENSE-UPL or https://oss.oracle.com/licenses/upl), at your option.

from __future__ import annotations

from typing import Sequence


def to_vec_literal(vec: Sequence[float]) -> str:
    return "[" + ",".join(format(float(x), ".8f") for x in vec) + "]"
