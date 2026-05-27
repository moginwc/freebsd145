# --- ikisaki.py
from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3

app = Flask(__name__)
CORS(app)
DB = "ikisaki.db"

def db():
    return sqlite3.connect(DB)

# --- 新規作成（空レコード）
@app.route("/insert", methods=["POST"])
def insert():
    conn = db()
    cur = conn.cursor()
    cur.execute("INSERT INTO ikisaki (name, lat, lon, stat) VALUES ('', '', '', '')")
    conn.commit()
    cid = cur.lastrowid
    conn.close()
    return jsonify({"id": cid})

# --- 更新
@app.route("/update", methods=["POST"])
def update():
    data = request.json
    conn = db()
    cur = conn.cursor()
    cur.execute(
        "UPDATE ikisaki SET name=?, lat=?, lon=?, stat=? WHERE id=?",
        (data["name"], data["lat"], data["lon"], data["stat"], data["id"])
    )
    conn.commit()
    conn.close()
    return jsonify({"status": "ok"})

# --- 削除
@app.route("/del", methods=["POST"])
def delele():
    data = request.json
    conn = db()
    cur = conn.cursor()
    cur.execute("DELETE FROM ikisaki WHERE id=?", (data["id"],))
    conn.commit()
    conn.close()
    return jsonify({"status": "ok"})

# --- コピー
@app.route("/copy/<int:id>", methods=["POST"])
def copy(id):
    conn = db()
    cur = conn.cursor()
    cur.execute("SELECT name, lat, lon, stat FROM ikisaki WHERE id=?", (id,))
    row = cur.fetchone()

    if not row:
        return jsonify({"error":"not found"})

    cur.execute(
        "INSERT INTO ikisaki (name, lat, lon, stat) VALUES (?, ?, ?, ?)",
        (row[0], row[1], row[2], row[3])
    )
    conn.commit()

    new_id = cur.lastrowid
    conn.close()

    return jsonify({"id": new_id})

# --- レコード取得（ID指定）
@app.route("/get/<int:id>")
def get(id):
    conn = db()
    cur = conn.cursor()
    cur.execute("SELECT id, name, lat, lon, stat FROM ikisaki WHERE id=?", (id,))
    row = cur.fetchone()
    conn.close()
    if row:
        return jsonify({"id": row[0], "name": row[1], "lat": row[2], "lon": row[3], "stat": row[4]})
    return jsonify({})

# --- 次レコード
@app.route("/next/<int:id>")
def next(id):
    conn = db()
    cur = conn.cursor()
    cur.execute("SELECT id FROM ikisaki WHERE id > ? ORDER BY id LIMIT 1", (id,))
    row = cur.fetchone()
    conn.close()
    return jsonify({"id": row[0] if row else id})

# --- 前レコード
@app.route("/prev/<int:id>")
def prev(id):
    conn = db()
    cur = conn.cursor()
    cur.execute("SELECT id FROM ikisaki WHERE id < ? ORDER BY id DESC LIMIT 1", (id,))
    row = cur.fetchone()
    conn.close()
    return jsonify({"id": row[0] if row else id})

# --- 最後のレコード
@app.route("/last")
def last():
    conn = db()
    cur = conn.cursor()
    cur.execute("SELECT id FROM ikisaki ORDER BY id DESC LIMIT 1")
    row = cur.fetchone()
    conn.close()
    return jsonify({"id": row[0] if row else None})

# --- 検索
@app.route("/search")
def search():
    key = request.args.get("key", "")

    conn = db()
    cur = conn.cursor()
    cur.execute("""
        SELECT id
        FROM ikisaki
        WHERE name LIKE ?
        ORDER BY id
        LIMIT 1
    """, (f"%{key}%",))
    row = cur.fetchone()
    conn.close()

    if not row:
        return jsonify({"id": None})
    return jsonify({"id": row[0]})

if __name__ == "__main__":
    app.run(port=5000, debug=True)
