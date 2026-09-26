"""
Tests for users endpoint.
"""

from unittest.mock import patch


def test_users_without_database(client):
    """
    Users endpoint should return HTTP 503
    when database is not configured.
    """

    with patch(
        "app.api.users.SessionLocal",
        None,
    ):

        response = client.get(
            "/api/users"
        )

    assert response.status_code == 503

    data = response.json()

    assert data["status"] == "unavailable"

    assert (
        data["message"]
        == "Database is not configured"
    )