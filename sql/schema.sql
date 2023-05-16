
CREATE TABLE IF NOT EXISTS PLATFORM_USER (
    ID SERIAL PRIMARY KEY,
    NAME VARCHAR(50) NOT NULL,
    PASSWORD VARCHAR(50) NOT NULL
);
CREATE TABLE IF NOT EXISTS CHAT(
    ID SERIAL PRIMARY KEY,
    PLATFORM_USER1_ID INTEGER NOT NULL,
    PLATFORM_USER2_ID INTEGER NOT NULL,
    FOREIGN KEY (PLATFORM_USER1_ID) REFERENCES PLATFORM_USER(ID),
    FOREIGN KEY (PLATFORM_USER2_ID) REFERENCES PLATFORM_USER(ID)
);
CREATE TABLE IF NOT EXISTS MESSAGE(
    ID SERIAL PRIMARY KEY,
    MESSAGE VARCHAR(255) NOT NULL,
    CHAT_ID INTEGER NOT NULL,
    SENDER INTEGER NOT NULL,
    FOREIGN KEY (CHAT_ID) REFERENCES CHAT(ID),
    FOREIGN KEY (SENDER) REFERENCES PLATFORM_USER(ID)
);


