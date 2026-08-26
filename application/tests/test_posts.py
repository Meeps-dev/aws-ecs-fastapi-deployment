import uuid

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_create_post_for_existing_user():
    # First create a user with unique email
    unique_email = f"user_{uuid.uuid4()}@test.com"
    user_response = client.post(
        "/users/", json={"name": "Post Author", "email": unique_email}
    )
    assert user_response.status_code == 200

    user_id = user_response.json()["id"]

    # Now create a post for that user
    post_response = client.post(
        f"/posts/users/{user_id}",
        json={"title": "Test Post", "content": "This post was created by pytest"},
    )

    assert post_response.status_code == 200
    assert post_response.json()["title"] == "Test Post"
    assert post_response.json()["user_id"] == user_id


def test_create_post_for_nonexistent_user():
    response = client.post(
        "/posts/users/99999",
        json={"title": "Ghost Post", "content": "This should not exist"},
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"


def test_get_posts_for_user():
    unique_email = f"user_{uuid.uuid4()}@test.com"
    user_response = client.post(
        "/users/", json={"name": "Post Author", "email": unique_email}
    )
    assert user_response.status_code == 200
    user_id = user_response.json()["id"]

    # Create two posts for this user
    client.post(
        f"/posts/users/{user_id}",
        json={"title": "First Post", "content": "First post content"},
    )
    client.post(
        f"/posts/users/{user_id}",
        json={"title": "Second Post", "content": "Second post content"},
    )

    # Get posts for the user
    response = client.get(f"/posts/users/{user_id}")
    assert response.status_code == 200
    posts = response.json()
    assert isinstance(posts, list)
    assert len(posts) >= 2
    titles = [p["title"] for p in posts]
    assert "First Post" in titles
    assert "Second Post" in titles


def test_get_posts_for_nonexistent_user():
    response = client.get("/posts/users/99999")
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"
