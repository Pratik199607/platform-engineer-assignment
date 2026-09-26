"""
Tests for health endpoints.
"""

from unittest.mock import patch


def test_liveness(client):
    """
    Liveness endpoint should return HTTP 200.
    """

    response = client.get(
        "/api/health/live"
    )

    assert response.status_code == 200

    data = response.json()

    assert data["status"] == "ok"
    assert data["service"] == "platform-api"


def test_readiness_without_database(client):
    """
    Readiness should return HTTP 503
    when database is not configured.
    """

    with patch(
        "app.api.health.engine",
        None,
    ):

        response = client.get(
            "/api/health/ready"
        )

    assert response.status_code == 503

    data = response.json()

    assert data["status"] == "unhealthy"
    assert data["database"] == "not_configured"


def test_root_endpoint(client):
    """
    Root endpoint should return application information.
    """

    response = client.get("/")

    assert response.status_code == 200

    data = response.json()

    assert data["application"] == "Internal Platform API"
    assert data["status"] == "running"