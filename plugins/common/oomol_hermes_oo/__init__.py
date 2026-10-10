"""Shared OO CLI behavior for bundled OOMOL Hermes providers."""

from .auth import OOLoginRequired, require_oo_authentication
from .identity import team_arguments

__all__ = ["OOLoginRequired", "require_oo_authentication", "team_arguments"]
