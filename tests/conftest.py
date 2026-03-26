"""Shared test fixtures for the project."""

import pytest


@pytest.fixture
def anyio_backend():
    """Use asyncio as the async backend for tests."""
    return "asyncio"
