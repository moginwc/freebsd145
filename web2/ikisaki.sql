CREATE TABLE IF NOT EXISTS ikisaki (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            lat  TEXT NOT NULL,
            lon  TEXT NOT NULL,
            stat TEXT NOT NULL
        );


INSERT INTO ikisaki (name, lat, lon, stat) VALUES ('A点', '35.6650016', '139.6963361', '訪問済み');
