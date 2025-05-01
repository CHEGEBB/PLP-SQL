from fastapi import APIRouter, Depends, HTTPException, status
from mysql.connector import Error
from database import get_db
from models import User, UserCreate
import bcrypt
from typing import List

router = APIRouter()

@router.post("/", response_model=User, status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate, db=Depends(get_db)):
    connection, cursor = db
    
    # Hash the password
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    
    try:
        # Check if user already exists
        cursor.execute("SELECT * FROM users WHERE username = %s OR email = %s", 
                       (user.username, user.email))
        existing_user = cursor.fetchone()
        
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username or email already registered"
            )
        
        # Insert the new user
        cursor.execute(
            "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s)",
            (user.username, user.email, hashed_password.decode('utf-8'))
        )
        connection.commit()
        
        # Get the newly created user
        user_id = cursor.lastrowid
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        new_user = cursor.fetchone()
        
        return new_user
    except Error as e:
        connection.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.get("/", response_model=List[User])
def read_users(skip: int = 0, limit: int = 100, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        cursor.execute("SELECT * FROM users LIMIT %s OFFSET %s", (limit, skip))
        users = cursor.fetchall()
        return users
    except Error as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.get("/{user_id}", response_model=User)
def read_user(user_id: int, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        user = cursor.fetchone()
        
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        return user
    except Error as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(user_id: int, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        # Check if user exists
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        user = cursor.fetchone()
        
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Delete the user
        cursor.execute("DELETE FROM users WHERE user_id = %s", (user_id,))
        connection.commit()
        
        return None
    except Error as e:
        connection.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )