import uuid

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_create_user():
    unique_email = f"testuser_{uuid.uuid4()}@test.com"
    response = client.post("/users/", json={"name": "Test User", "email": unique_email})
    assert response.status_code == 200
    assert response.json()["email"] == unique_email


def test_get_users():
    unique_email = f"testuser_{uuid.uuid4()}@test.com"
    client.post("/users/", json={"name": "Get Users Test User", "email": unique_email})

    response = client.get("/users/")
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    assert len(users) > 0
    assert any(u["email"] == unique_email for u in users)


def test_create_user_rejects_duplicate_email():
    unique_email = f"duplicate_{uuid.uuid4()}@test.com"
    user = {"name": "Duplicate User", "email": unique_email}

    first_response = client.post("/users/", json=user)
    duplicate_response = client.post("/users/", json=user)

    assert first_response.status_code == 200
    assert duplicate_response.status_code == 409
    assert duplicate_response.json() == {
        "detail": "A user with this email already exists."
    }

    users_response = client.get("/users/")
    assert users_response.status_code == 200
    assert sum(user["email"] == unique_email for user in users_response.json()) == 1
