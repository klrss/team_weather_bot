from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

load_dotenv()

Base = declarative_base()
engine = create_engine(os.getenv('APP_DATABASE_URL'))


class UserCoord(Base):
    __tablename__ = 'usercoord'
    id = Column(Integer, primary_key=True)
    u_id = Column(Integer(), index=True)
    name = Column(String(60))
    lat = Column(String(16))
    lon = Column(String(16))
    city = Column(String(64))
    country = Column(String(16))
    pop = Column(Integer)

    def __repr__(self):
        return "<Coordinates(name='{}', lat='{}', lon='{}', u_id='{}', city='{}')>".format(self.name,
                                                                                           self.lat, self.lon,
                                                                                           self.u_id, self.city)


Base.metadata.create_all(engine)
