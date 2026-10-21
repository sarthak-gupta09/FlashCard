import datetime
from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base


class ReviewHistory(Base):
    __tablename__ = "review_history"

    id = Column(String, primary_key=True, index=True)
    card_id = Column(String, ForeignKey("cards.id"), index=True, nullable=False)
    user_id = Column(String, ForeignKey("users.id"), index=True, nullable=False)
    
    # Rating: "AGAIN", "HARD", "GOOD", "EASY" (or "KNOW", "NEEDS_REVISION")
    rating = Column(String, nullable=False)
    was_correct = Column(Boolean, nullable=False)
    selected_option = Column(String, nullable=True)     # "A", "B", "C", "D"
    response_time_ms = Column(Integer, nullable=True)   # Speed of recall
    reviewed_at = Column(DateTime, default=datetime.datetime.utcnow, index=True)

    # Relationships
    card = relationship("Card", back_populates="reviews")
