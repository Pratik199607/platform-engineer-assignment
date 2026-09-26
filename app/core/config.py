"""
Application configuration.

Production secrets must never be stored in source code.
Configuration is loaded from environment variables.
"""

import os


class Settings:
    """
    Application settings.
    """

    APP_ENV: str = os.getenv(
        "APP_ENV",
        "development",
    )

    LOG_LEVEL: str = os.getenv(
        "LOG_LEVEL",
        "INFO",
    )

    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "",
    )


settings = Settings()