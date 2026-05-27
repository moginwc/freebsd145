# Python初期設定
from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, StreamingResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import sqlite3
import csv
import io

# webアプリ初期設定
app = FastAPI()
app.mount("/static", StaticFiles(directory="."), name="static")
templates = Jinja2Templates(directory=".")

# データベース初期設定
DB_PATH = "location.db"

def init_db():
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute('''CREATE TABLE IF NOT EXISTS location (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            lat  TEXT NOT NULL,
            lon  TEXT NOT NULL,
            status TEXT NOT NULL
        )''')

# スタート
@app.on_event("startup")
def startup_event():
    init_db()

# 画面
@app.get("/", response_class=HTMLResponse)
def read_root(request: Request, keyword: str = ""):
    with sqlite3.connect(DB_PATH) as conn:
        cur = conn.cursor()
        if keyword:
            query = """
                SELECT * FROM location
                WHERE name LIKE ? OR lat LIKE ? OR lon LIKE ? OR status LIKE ?
            """
            kw = f"%{keyword}%"
            cur.execute(query, (kw, kw, kw, kw))
        else:
            cur.execute("SELECT * FROM location ORDER BY name")
        records = cur.fetchall()
    return templates.TemplateResponse("index.html", {"request": request, "records": records})

# 追加
@app.post("/add")
def add_entry(name: str = Form(...), lat: str = Form(...), lon: str = Form(...), status: str = Form(...)):
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("INSERT INTO location (name, lat, lon, status) VALUES (?, ?, ?, ?)", (name, lat, lon, status))
    return RedirectResponse("/", status_code=303)

# 削除
@app.get("/delete/{entry_id}")
def delete_entry(entry_id: int):
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("DELETE FROM location WHERE id = ?", (entry_id,))
    return RedirectResponse("/", status_code=303)

# 更新
@app.post("/edit/{entry_id}")
def edit_entry(entry_id: int, name: str = Form(...), lat: str = Form(...), lon: str = Form(...), status: str = Form(...)):
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("UPDATE location SET name = ?, lat = ?, lon = ?, status = ?  WHERE id = ?", (name, lat, lon, status, entry_id))
    return RedirectResponse("/", status_code=303)

# CSVダウンロード
@app.get("/csv")
def export_csv():
    with sqlite3.connect(DB_PATH) as conn:
        cur = conn.cursor()
        cur.execute("SELECT name,lat, lon, status FROM location")
        records = cur.fetchall()
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["場所", "緯度", "経度", "状況"])
    writer.writerows(records)
    output.seek(0)
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=location.csv"}
    )

